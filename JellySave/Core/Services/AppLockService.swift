import Combine
import SwiftUI

struct AppLockConfiguration: Codable, Equatable {
    var isEnabled: Bool
    var useBiometrics: Bool
    var autoLockInterval: TimeInterval

    static let `default` = AppLockConfiguration(isEnabled: false, useBiometrics: true, autoLockInterval: AppLockInterval.oneMinute.duration)
}

enum AppLockError: LocalizedError {
    case passcodeNotSet
    case invalidCurrentPasscode
    case mismatchedPasscode
    case biometricNotAvailable

    var errorDescription: String? {
        switch self {
        case .passcodeNotSet:
            return "請先設定解鎖密碼。"
        case .invalidCurrentPasscode:
            return "目前密碼不正確。"
        case .mismatchedPasscode:
            return "兩次輸入的密碼不一致。"
        case .biometricNotAvailable:
            return "無法使用 Face ID/Touch ID。"
        }
    }
}

enum AppLockInterval: CaseIterable, Identifiable {
    case immediately
    case thirtySeconds
    case oneMinute
    case fiveMinutes

    var id: String { title }

    var duration: TimeInterval {
        switch self {
        case .immediately: return 0
        case .thirtySeconds: return 30
        case .oneMinute: return 60
        case .fiveMinutes: return 300
        }
    }

    var title: String {
        switch self {
        case .immediately: return "立即"
        case .thirtySeconds: return "30 秒"
        case .oneMinute: return "1 分鐘"
        case .fiveMinutes: return "5 分鐘"
        }
    }

    init(duration: TimeInterval) {
        switch duration {
        case 0: self = .immediately
        case ..<45: self = .thirtySeconds
        case ..<180: self = .oneMinute
        default: self = .fiveMinutes
        }
    }
}

@MainActor
final class AppLockService: ObservableObject {
    @Published private(set) var configuration: AppLockConfiguration = .default
    @Published private(set) var isLocked: Bool = false

    var supportsBiometrics: Bool {
        biometricService.canEvaluatePolicy()
    }

    var canUseBiometrics: Bool {
        configuration.isEnabled && configuration.useBiometrics && biometricService.canEvaluatePolicy()
    }

    private let keychain: KeychainServiceProtocol
    private let biometricService: BiometricAuthServiceProtocol
    private let defaults: UserDefaults
    private let configKey = "com.jellysave.applock.configuration"
    private let passcodeKey = "com.jellysave.applock.passcode"
    private var cancellables = Set<AnyCancellable>()
    private var backgroundDate: Date?

    init(keychain: KeychainServiceProtocol = KeychainService(),
         biometricService: BiometricAuthServiceProtocol = BiometricAuthService(),
         defaults: UserDefaults = .standard) {
        self.keychain = keychain
        self.biometricService = biometricService
        self.defaults = defaults

        let initialConfiguration: AppLockConfiguration
        if let data = defaults.data(forKey: configKey),
           let config = try? JSONDecoder().decode(AppLockConfiguration.self, from: data) {
            initialConfiguration = config
        } else {
            initialConfiguration = .default
        }
        configuration = initialConfiguration
        isLocked = initialConfiguration.isEnabled
    }

    func hasPasscode() -> Bool {
        guard let data = (try? keychain.read(for: passcodeKey)) ?? nil else {
            return false
        }
        return !data.isEmpty
    }

    func setPasscode(newValue: String, currentPasscode: String? = nil) throws {
        if hasPasscode() {
            guard let currentPasscode, !currentPasscode.isEmpty else {
                throw AppLockError.invalidCurrentPasscode
            }

            guard verify(passcode: currentPasscode) else {
                throw AppLockError.invalidCurrentPasscode
            }
        }
        try keychain.save(Data(newValue.utf8), for: passcodeKey)
    }

    func enableLock(autoLock: TimeInterval, useBiometrics: Bool) throws {
        guard hasPasscode() else {
            throw AppLockError.passcodeNotSet
        }
        configuration.isEnabled = true
        configuration.autoLockInterval = autoLock
        configuration.useBiometrics = useBiometrics
        persistConfiguration()
        lock()
    }

    func disableLock() {
        configuration.isEnabled = false
        persistConfiguration()
        isLocked = false
    }

    func updateAutoLock(interval: AppLockInterval) {
        configuration.autoLockInterval = interval.duration
        persistConfiguration()
    }

    func updateBiometricPreference(enabled: Bool) {
        configuration.useBiometrics = enabled
        persistConfiguration()
    }

    func unlock(with passcode: String) -> Bool {
        guard verify(passcode: passcode) else { return false }
        isLocked = false
        return true
    }

    func lock() {
        guard configuration.isEnabled else { return }
        isLocked = true
    }

    func authenticateWithBiometrics() -> AnyPublisher<Void, Error> {
        guard canUseBiometrics else {
            return Fail(error: AppLockError.biometricNotAvailable).eraseToAnyPublisher()
        }
        return biometricService.authenticate(reason: "解鎖 JellySave")
            .handleEvents(receiveOutput: { [weak self] in
                self?.isLocked = false
            })
            .eraseToAnyPublisher()
    }

    func handleScenePhaseChange(_ phase: ScenePhase) {
        guard configuration.isEnabled else { return }
        switch phase {
        case .background:
            if configuration.autoLockInterval == 0 {
                lock()
            } else {
                backgroundDate = Date()
            }
        case .active:
            guard let backgroundDate else { return }
            if Date().timeIntervalSince(backgroundDate) >= configuration.autoLockInterval {
                lock()
            }
            self.backgroundDate = nil
        default:
            break
        }
    }

    // MARK: - Private

    private func verify(passcode: String) -> Bool {
        guard let data = (try? keychain.read(for: passcodeKey)) ?? nil,
              let stored = String(data: data, encoding: .utf8) else {
            return false
        }
        return stored == passcode
    }

    private func persistConfiguration() {
        guard let data = try? JSONEncoder().encode(configuration) else { return }
        defaults.set(data, forKey: configKey)
    }
}
