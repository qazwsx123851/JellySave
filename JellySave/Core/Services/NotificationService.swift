import Combine
import CoreData
import Foundation
import UserNotifications

protocol NotificationServiceProtocol {
    func requestPermission() -> AnyPublisher<Bool, Error>
    func fetchSettings() -> AnyPublisher<NotificationSettings, Error>
    func updateSettings(isEnabled: Bool, time: DateComponents, category: QuoteCategory) -> AnyPublisher<NotificationSettings, Error>
    func scheduleDailyNotification(time: DateComponents, category: QuoteCategory) -> AnyPublisher<Void, Error>
    func cancelAllNotifications()
    func randomQuote(for category: QuoteCategory) -> MotivationalQuote
}

final class NotificationService: NotificationServiceProtocol {
    private let center: UNUserNotificationCenter
    private let coreDataStack: CoreDataStack
    private let quoteRepository: QuoteRepository

    init(center: UNUserNotificationCenter = .current(), coreDataStack: CoreDataStack = .shared, quoteRepository: QuoteRepository = QuoteRepository()) {
        self.center = center
        self.coreDataStack = coreDataStack
        self.quoteRepository = quoteRepository
    }

    func requestPermission() -> AnyPublisher<Bool, Error> {
        Future { promise in
            self.center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error {
                    promise(.failure(error))
                } else {
                    promise(.success(granted))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func fetchSettings() -> AnyPublisher<NotificationSettings, Error> {
        perform { context in
            let request: NSFetchRequest<NotificationSettings> = NotificationSettings.fetchRequest()
            request.fetchLimit = 1
            if let settings = try context.fetch(request).first {
                return settings
            }

            let settings = NotificationSettings(context: context)
            settings.id = UUID()
            settings.isEnabled = false
            settings.notificationTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
            settings.quoteCategory = .saving
            settings.updatedAt = Date()
            try self.coreDataStack.save(context: context)
            return settings
        }
    }

    func updateSettings(isEnabled: Bool, time: DateComponents, category: QuoteCategory) -> AnyPublisher<NotificationSettings, Error> {
        perform { context in
            let settings = try self.fetchSettings(in: context)
            settings.isEnabled = isEnabled
            settings.quoteCategory = category
            settings.updateTime(time)
            try self.coreDataStack.save(context: context)
            return settings
        }
    }

    func scheduleDailyNotification(time: DateComponents, category: QuoteCategory) -> AnyPublisher<Void, Error> {
        Future { promise in
            self.center.removeAllPendingNotificationRequests()

            let quote = self.quoteRepository.randomQuote(for: category)

            var components = time
            components.calendar = Calendar.current

            let content = UNMutableNotificationContent()
            content.title = category == .saving ? "今日儲蓄激勵" : "今日投資洞察"
            content.body = quote.formatted
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: "daily-motivation", content: content, trigger: trigger)

            self.center.add(request) { error in
                if let error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }

    func randomQuote(for category: QuoteCategory) -> MotivationalQuote {
        quoteRepository.randomQuote(for: category)
    }

    // MARK: - Helpers

    private func fetchSettings(in context: NSManagedObjectContext) throws -> NotificationSettings {
        let request: NSFetchRequest<NotificationSettings> = NotificationSettings.fetchRequest()
        request.fetchLimit = 1
        if let settings = try context.fetch(request).first {
            return settings
        }
        let settings = NotificationSettings(context: context)
        settings.id = UUID()
        settings.isEnabled = false
        settings.notificationTime = Date()
        settings.quoteCategory = .saving
        settings.updatedAt = Date()
        return settings
    }

    private func perform<T>(_ work: @escaping (NSManagedObjectContext) throws -> T) -> AnyPublisher<T, Error> {
        Future { promise in
            let context = self.coreDataStack.context
            context.perform {
                do {
                    let value = try work(context)
                    promise(.success(value))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
