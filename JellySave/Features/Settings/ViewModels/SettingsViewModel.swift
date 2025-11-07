import Combine
import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var notificationsEnabled = false
    @Published var notificationTime = DateComponents(hour: 9, minute: 30)
    @Published var selectedCategory: QuoteCategory = .saving
    @Published var latestQuotePreview: MotivationalQuote?
    @Published var permissionGranted: Bool?
    @Published var isSaving = false
    @Published var isProcessingBackup = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var exportedFileURL: URL?
    @Published var selectedTheme: AppTheme

    private let notificationService: NotificationServiceProtocol
    private let dataManagementService: DataManagementServiceProtocol
    private weak var themeService: ThemeService?
    private var cancellables = Set<AnyCancellable>()

    init(notificationService: NotificationServiceProtocol = NotificationService(),
         dataManagementService: DataManagementServiceProtocol = DataManagementService(),
         themeService: ThemeService? = nil) {
        self.notificationService = notificationService
        self.dataManagementService = dataManagementService
        self.themeService = themeService
        self.selectedTheme = themeService?.currentTheme ?? .system
        loadSettings()
    }

    func loadSettings() {
        notificationService.fetchSettings()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] settings in
                guard let self else { return }
                self.notificationsEnabled = settings.isEnabled
                self.notificationTime = settings.timeComponents
                self.selectedCategory = settings.quoteCategory
                self.latestQuotePreview = self.notificationService.randomQuote(for: settings.quoteCategory)
            }
            .store(in: &cancellables)
    }

    func requestNotificationPermission() {
        notificationService.requestPermission()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] granted in
                self?.permissionGranted = granted
                if granted && self?.notificationsEnabled == true {
                    self?.scheduleNotifications()
                }
            }
            .store(in: &cancellables)
    }

    func saveNotificationSettings() {
        isSaving = true
        errorMessage = nil

        notificationService.updateSettings(isEnabled: notificationsEnabled, time: notificationTime, category: selectedCategory)
            .receive(on: DispatchQueue.main)
            .flatMap { [weak self] settings -> AnyPublisher<Void, Error> in
                guard let self else { return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher() }
                if settings.isEnabled {
                    return self.notificationService.scheduleDailyNotification(time: self.notificationTime, category: self.selectedCategory)
                } else {
                    self.notificationService.cancelAllNotifications()
                    return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
            }
            .sink { [weak self] completion in
                guard let self else { return }
                self.isSaving = false
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                } else {
                    self.latestQuotePreview = self.notificationService.randomQuote(for: self.selectedCategory)
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }

    func changeTheme(to theme: AppTheme) {
        selectedTheme = theme
        themeService?.setTheme(theme)
    }

    func refreshQuotePreview() {
        latestQuotePreview = notificationService.randomQuote(for: selectedCategory)
    }

    func exportBackup() async {
        isProcessingBackup = true
        errorMessage = nil
        successMessage = nil

        do {
            let url = try await dataManagementService.exportData()
            exportedFileURL = url
            successMessage = "匯出完成，可分享備份檔案。"
        } catch {
            errorMessage = error.localizedDescription
        }

        isProcessingBackup = false
    }

    func importBackup(from url: URL) async {
        isProcessingBackup = true
        errorMessage = nil
        successMessage = nil

        do {
            try await dataManagementService.importData(from: url)
            successMessage = "資料已成功還原。"
        } catch {
            errorMessage = error.localizedDescription
        }

        isProcessingBackup = false
    }

    func clearAllData() async {
        isProcessingBackup = true
        errorMessage = nil
        successMessage = nil

        do {
            try await dataManagementService.clearData()
            successMessage = "所有本機資料已清除。"
        } catch {
            errorMessage = error.localizedDescription
        }

        isProcessingBackup = false
    }

    func resetExportedFileURL() {
        exportedFileURL = nil
    }

    private func scheduleNotifications() {
        notificationService.scheduleDailyNotification(time: notificationTime, category: selectedCategory)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }

    func updateThemeService(_ themeService: ThemeService) {
        self.themeService = themeService
        selectedTheme = themeService.currentTheme
    }
}
