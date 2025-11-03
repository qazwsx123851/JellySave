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
