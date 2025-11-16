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
    @Published var appLockEnabled = false
    @Published var useBiometricUnlock = false
    @Published var autoLockSelection: AppLockInterval = .oneMinute
    @Published var supportsBiometricUnlock = false
    @Published var isPresentingPasscodeSheet = false

    private let notificationService: NotificationServiceProtocol
    private let dataManagementService: DataManagementServiceProtocol
    private weak var themeService: ThemeService?
    private let errorHandler = ErrorHandler.shared
    private weak var appLockService: AppLockService?
    private var cancellables = Set<AnyCancellable>()
    private var pendingEnableAfterPasscode = false

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
                    self?.errorMessage = self?.errorHandler.handle(error)
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
                    self?.errorMessage = self?.errorHandler.handle(error)
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
                    self.errorMessage = self.errorHandler.handle(error)
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
            errorMessage = errorHandler.handle(error)
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
            errorMessage = errorHandler.handle(error)
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
            errorMessage = errorHandler.handle(error)
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
                    self?.errorMessage = self?.errorHandler.handle(error)
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }

    func updateThemeService(_ themeService: ThemeService) {
        self.themeService = themeService
        selectedTheme = themeService.currentTheme
    }

    func updateAppLockService(_ service: AppLockService) {
        appLockService = service
        supportsBiometricUnlock = service.supportsBiometrics
        appLockEnabled = service.configuration.isEnabled
        useBiometricUnlock = service.configuration.useBiometrics
        autoLockSelection = AppLockInterval(duration: service.configuration.autoLockInterval)

        service.$configuration
            .receive(on: RunLoop.main)
            .sink { [weak self] config in
                guard let self else { return }
                self.appLockEnabled = config.isEnabled
                self.useBiometricUnlock = config.useBiometrics
                self.autoLockSelection = AppLockInterval(duration: config.autoLockInterval)
            }
            .store(in: &cancellables)
    }

    var passcodeExists: Bool {
        appLockService?.hasPasscode() ?? false
    }

    func handleAppLockToggle(_ isEnabled: Bool) {
        guard let service = appLockService else { return }
        if isEnabled {
            guard passcodeExists else {
                pendingEnableAfterPasscode = true
                isPresentingPasscodeSheet = true
                return
            }
            do {
                try service.enableLock(autoLock: autoLockSelection.duration, useBiometrics: useBiometricUnlock)
                appLockEnabled = true
            } catch {
                appLockEnabled = false
                errorMessage = errorHandler.handle(error)
            }
        } else {
            service.disableLock()
            appLockEnabled = false
        }
    }

    func handleBiometricToggle(_ isEnabled: Bool) {
        useBiometricUnlock = isEnabled
        appLockService?.updateBiometricPreference(enabled: isEnabled)
    }

    func updateAutoLockSelection(_ interval: AppLockInterval) {
        autoLockSelection = interval
        if appLockEnabled {
            appLockService?.updateAutoLock(interval: interval)
        }
    }

    func presentPasscodeSetup() {
        isPresentingPasscodeSheet = true
    }

    func submitPasscode(current: String?, new: String, confirm: String) -> String? {
        if passcodeExists {
            guard let current, !current.isEmpty else {
                return "請輸入目前使用中的密碼。"
            }
        }

        guard !new.isEmpty, new.count >= 4, new.count <= 6, new.allSatisfy(\.isNumber) else {
            return "請輸入 4-6 位數字密碼。"
        }

        guard new == confirm else {
            return "兩次輸入的密碼不一致。"
        }

        do {
            try appLockService?.setPasscode(newValue: new, currentPasscode: passcodeExists ? current : nil)
            isPresentingPasscodeSheet = false
            if pendingEnableAfterPasscode {
                pendingEnableAfterPasscode = false
                handleAppLockToggle(true)
            }
            return nil
        } catch {
            return errorHandler.handle(error)
        }
    }

    func cancelPasscodeSetup() {
        if pendingEnableAfterPasscode {
            pendingEnableAfterPasscode = false
            appLockEnabled = false
        }
    }
}
