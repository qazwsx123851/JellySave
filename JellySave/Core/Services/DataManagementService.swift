import Combine
import CoreData
import Foundation

protocol DataManagementServiceProtocol {
    func exportData() async throws -> URL
    func importData(from url: URL) async throws
    func clearData() async throws
}

enum DataManagementError: LocalizedError {
    case invalidBackupFormat
    case emptyBackup

    var errorDescription: String? {
        switch self {
        case .invalidBackupFormat:
            return "備份檔案格式不正確，請再次確認檔案內容。"
        case .emptyBackup:
            return "備份檔案沒有任何資料。"
        }
    }
}

final class DataManagementService: DataManagementServiceProtocol {
    private let coreDataStack: CoreDataStack
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
        encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - Export

    func exportData() async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            coreDataStack.context.perform {
                do {
                    let accounts = try self.coreDataStack.context.fetch(Account.fetchRequest())
                    let goals = try self.coreDataStack.context.fetch(SavingGoal.fetchRequest())
                    let snapshots = try self.coreDataStack.context.fetch(AssetSnapshot.fetchRequest())
                    let notification = try self.fetchNotificationSettings()

                    let payload = BackupPayload(
                        generatedAt: Date(),
                        accounts: accounts.map(BackupAccount.init),
                        goals: goals.map(BackupGoal.init),
                        snapshots: snapshots.map(BackupSnapshot.init),
                        notificationSettings: notification.map(BackupNotificationSettings.init)
                    )

                    guard !payload.accounts.isEmpty || !payload.goals.isEmpty else {
                        throw DataManagementError.emptyBackup
                    }

                    let data = try self.encoder.encode(payload)
                    let fileURL = self.makeExportURL()
                    try data.write(to: fileURL, options: .atomic)

                    continuation.resume(returning: fileURL)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // MARK: - Import

    func importData(from url: URL) async throws {
        let data = try Data(contentsOf: url)
        let payload = try decoder.decode(BackupPayload.self, from: data)

        try await withCheckedThrowingContinuation { continuation in
            coreDataStack.context.perform {
                do {
                    try self.clearEntities()
                    try self.restore(payload: payload)
                    try self.coreDataStack.save()
                    NotificationCenter.default.post(name: .dataStoreDidChange, object: nil)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // MARK: - Clear

    func clearData() async throws {
        try await withCheckedThrowingContinuation { continuation in
            coreDataStack.context.perform {
                do {
                    try self.clearEntities()
                    try self.coreDataStack.save()
                    NotificationCenter.default.post(name: .dataStoreDidChange, object: nil)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - Helpers

private extension DataManagementService {
    func fetchNotificationSettings() throws -> NotificationSettings? {
        let request: NSFetchRequest<NotificationSettings> = NotificationSettings.fetchRequest()
        request.fetchLimit = 1
        return try coreDataStack.context.fetch(request).first
    }

    func makeExportURL() -> URL {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        let fileName = "JellySaveBackup-\(formatter.string(from: Date())).json"
        return FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
    }

    func clearEntities() throws {
        try deleteAll(fetchRequest: Account.fetchRequest())
        try deleteAll(fetchRequest: SavingGoal.fetchRequest())
        try deleteAll(fetchRequest: AssetSnapshot.fetchRequest())
        try deleteAll(fetchRequest: NotificationSettings.fetchRequest())
    }

    func deleteAll<T: NSManagedObject>(fetchRequest: NSFetchRequest<T>) throws {
        let objects = try coreDataStack.context.fetch(fetchRequest)
        objects.forEach { coreDataStack.context.delete($0) }
    }

    func restore(payload: BackupPayload) throws {
        payload.accounts.forEach { accountPayload in
            let account = Account(context: coreDataStack.context)
            account.id = accountPayload.id
            account.name = accountPayload.name
            account.type = accountPayload.type
            account.currency = accountPayload.currency
            account.balance = NSDecimalNumber(decimal: accountPayload.balance)
            account.createdAt = accountPayload.createdAt
            account.updatedAt = accountPayload.updatedAt
            account.isActive = accountPayload.isActive
            account.notes = accountPayload.notes
        }

        payload.goals.forEach { goalPayload in
            let goal = SavingGoal(context: coreDataStack.context)
            goal.id = goalPayload.id
            goal.title = goalPayload.title
            goal.category = goalPayload.category
            goal.notes = goalPayload.notes
            goal.createdAt = goalPayload.createdAt
            goal.updatedAt = goalPayload.updatedAt
            goal.deadline = goalPayload.deadline
            goal.completedAt = goalPayload.completedAt
            goal.isCompleted = goalPayload.isCompleted
            goal.targetAmount = NSDecimalNumber(decimal: goalPayload.targetAmount)
            goal.currentAmount = NSDecimalNumber(decimal: goalPayload.currentAmount)
        }

        payload.snapshots.forEach { snapshotPayload in
            let snapshot = AssetSnapshot(context: coreDataStack.context)
            snapshot.id = snapshotPayload.id
            snapshot.date = snapshotPayload.date
            snapshot.createdAt = snapshotPayload.createdAt
            snapshot.totalAssets = NSDecimalNumber(decimal: snapshotPayload.totalAssets)
        }

        if let notificationPayload = payload.notificationSettings {
            let settings = NotificationSettings(context: coreDataStack.context)
            settings.id = notificationPayload.id
            settings.isEnabled = notificationPayload.isEnabled
            if let time = notificationPayload.notificationTime {
                settings.notificationTime = time
            } else {
                settings.notificationTime = Date()
            }
            settings.quoteCategory = QuoteCategory(rawValue: notificationPayload.quoteCategory) ?? .saving
            settings.updatedAt = notificationPayload.updatedAt
        }
    }
}

// MARK: - Payloads

private struct BackupPayload: Codable {
    let generatedAt: Date
    let accounts: [BackupAccount]
    let goals: [BackupGoal]
    let snapshots: [BackupSnapshot]
    let notificationSettings: BackupNotificationSettings?
}

private struct BackupAccount: Codable {
    let id: UUID
    let name: String
    let type: String
    let balance: Decimal
    let currency: String
    let createdAt: Date
    let updatedAt: Date
    let isActive: Bool
    let notes: String?

    init(account: Account) {
        id = account.id
        name = account.name
        type = account.type
        balance = account.balanceDecimal
        currency = account.currency
        createdAt = account.createdAt
        updatedAt = account.updatedAt
        isActive = account.isActive
        notes = account.notes
    }
}

private struct BackupGoal: Codable {
    let id: UUID
    let title: String
    let category: String?
    let notes: String?
    let createdAt: Date
    let updatedAt: Date
    let deadline: Date
    let completedAt: Date?
    let isCompleted: Bool
    let targetAmount: Decimal
    let currentAmount: Decimal

    init(goal: SavingGoal) {
        id = goal.id
        title = goal.title
        category = goal.category
        notes = goal.notes
        createdAt = goal.createdAt
        updatedAt = goal.updatedAt
        deadline = goal.deadline
        completedAt = goal.completedAt
        isCompleted = goal.isCompleted
        targetAmount = goal.targetAmountDecimal
        currentAmount = goal.currentAmountDecimal
    }
}

private struct BackupSnapshot: Codable {
    let id: UUID
    let date: Date
    let createdAt: Date
    let totalAssets: Decimal

    init(snapshot: AssetSnapshot) {
        id = snapshot.id
        date = snapshot.date
        createdAt = snapshot.createdAt
        totalAssets = snapshot.totalAssetsDecimal
    }
}

private struct BackupNotificationSettings: Codable {
    let id: UUID
    let isEnabled: Bool
    let notificationTime: Date?
    let quoteCategory: String
    let updatedAt: Date

    init(settings: NotificationSettings) {
        id = settings.id
        isEnabled = settings.isEnabled
        notificationTime = settings.notificationTime
        quoteCategory = settings.quoteCategory.rawValue
        updatedAt = settings.updatedAt
    }
}
