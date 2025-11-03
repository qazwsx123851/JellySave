import Combine
import SwiftUI

// MARK: - Theme Definition

enum AppTheme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var preferredColorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    var displayName: String {
        switch self {
        case .system:
            return "跟隨系統"
        case .light:
            return "淺色模式"
        case .dark:
            return "深色模式"
        }
    }
}

// MARK: - Protocol

protocol ThemeServiceProtocol: ObservableObject {
    var currentTheme: AppTheme { get }
    var themePublisher: AnyPublisher<AppTheme, Never> { get }
    func setTheme(_ theme: AppTheme)
}

// MARK: - Service

final class ThemeService: ThemeServiceProtocol {
    @Published private(set) var currentTheme: AppTheme

    var themePublisher: AnyPublisher<AppTheme, Never> {
        $currentTheme.eraseToAnyPublisher()
    }

    private let storage: UserDefaults
    private let storageKey = "com.jellysave.theme"

    init(storage: UserDefaults = .standard) {
        self.storage = storage
        if let value = storage.string(forKey: storageKey),
           let savedTheme = AppTheme(rawValue: value) {
            currentTheme = savedTheme
        } else {
            currentTheme = .system
        }
    }

    func setTheme(_ theme: AppTheme) {
        guard currentTheme != theme else { return }
        currentTheme = theme
        if theme == .system {
            storage.removeObject(forKey: storageKey)
        } else {
            storage.set(theme.rawValue, forKey: storageKey)
        }
    }
}
