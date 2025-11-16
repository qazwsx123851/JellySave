import SwiftUI
import UIKit

enum ThemeColor {
    case primary
    case secondary
    case accent
    case success
    case warning
    case appBackground
    case surface
    case surfaceSecondary
    case textPrimary
    case textSecondary
    case divider

    var color: Color {
        switch self {
        case .primary: return Color("PrimaryMint")
        case .secondary: return Color("SecondarySky")
        case .accent: return Color("AccentCoral")
        case .success: return Color("SuccessGreen")
        case .warning: return Color("WarningAmber")
        case .appBackground: return Color("AppBackground")
        case .surface: return Color("SurfacePrimary")
        case .surfaceSecondary: return Color("SurfaceSecondary")
        case .textPrimary: return Color("TextPrimary")
        case .textSecondary: return Color("TextSecondary")
        case .divider: return Color("Divider")
        }
    }
}

extension Color {
    static let primaryMint = ThemeColor.primary.color
    static let secondarySky = ThemeColor.secondary.color
    static let accentCoral = ThemeColor.accent.color
    static let successGreen = ThemeColor.success.color
    static let warningAmber = ThemeColor.warning.color
    static let appBackground = ThemeColor.appBackground.color
    static let surfacePrimary = ThemeColor.surface.color
    static let surfaceSecondary = ThemeColor.surfaceSecondary.color
    static let textPrimary = ThemeColor.textPrimary.color
    static let textSecondary = ThemeColor.textSecondary.color
    static let divider = ThemeColor.divider.color
}

extension UIColor {
    static let primaryMint = UIColor(named: "PrimaryMint") ?? UIColor.systemTeal
    static let secondarySky = UIColor(named: "SecondarySky") ?? UIColor.systemBlue
    static let accentCoral = UIColor(named: "AccentCoral") ?? UIColor.systemPink
    static let successGreen = UIColor(named: "SuccessGreen") ?? UIColor.systemGreen
    static let warningAmber = UIColor(named: "WarningAmber") ?? UIColor.systemOrange
    static let appBackground = UIColor(named: "AppBackground") ?? UIColor.systemBackground
    static let surfacePrimary = UIColor(named: "SurfacePrimary") ?? UIColor.secondarySystemBackground
    static let surfaceSecondary = UIColor(named: "SurfaceSecondary") ?? UIColor.tertiarySystemBackground
    static let textPrimary = UIColor(named: "TextPrimary") ?? UIColor.label
    static let textSecondary = UIColor(named: "TextSecondary") ?? UIColor.secondaryLabel
    static let divider = UIColor(named: "Divider") ?? UIColor.separator
}

// MARK: - Accessibility Helpers

extension Color {
    /// Calculates the WCAG relative luminance for the current color.
    private func relativeLuminance() -> CGFloat {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return 0
        }

        func convert(_ value: CGFloat) -> CGFloat {
            value <= 0.03928 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
        }

        return 0.2126 * convert(red) + 0.7152 * convert(green) + 0.0722 * convert(blue)
    }

    /// Returns either black or white depending on which offers better contrast against the color.
    func accessibleTextColor(contrast: ColorSchemeContrast) -> Color {
        let luminance = relativeLuminance()
        let whiteContrast = (1.0 + 0.05) / (luminance + 0.05)
        let blackContrast = (luminance + 0.05) / 0.05

        if contrast == .increased {
            return blackContrast >= whiteContrast ? .black : .white
        }

        return whiteContrast >= blackContrast ? .white : .black
    }

    /// Slightly darkens bright colors when the user requests increased contrast.
    func adjustedForHighContrast(_ contrast: ColorSchemeContrast) -> Color {
        guard contrast == .increased else { return self }

        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return self
        }

        let luminance = relativeLuminance()
        let factor: CGFloat = luminance > 0.45 ? 0.65 : 0.85

        return Color(
            red: Double(min(max(red * factor, 0), 1)),
            green: Double(min(max(green * factor, 0), 1)),
            blue: Double(min(max(blue * factor, 0), 1)),
            opacity: Double(alpha)
        )
    }
}
