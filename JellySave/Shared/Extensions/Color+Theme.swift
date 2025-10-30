import SwiftUI

/// Strongly typed accessors for the app's brand color palette.
public enum ThemeColor {
    /// Mint primary brand color used for primary actions and totals.
    public static let primary = Color("BrandPrimary")
    /// 珊瑚色輔助色，用於提醒或強調狀態。
    public static let accent = Color("BrandAccent")
    /// 天藍色次要主題色，搭配主視覺漸層與進度徽章。
    public static let secondary = Color(red: 0.36, green: 0.62, blue: 0.98)
    /// 嗨亮色，用於慶祝或達成的瞬間效果。
    public static let highlight = Color("BrandHighlight")
    /// Neutral dark tone for text on light backgrounds.
    public static let neutralDark = Color("NeutralDark")
    /// Neutral light background color for grouping content.
    public static let neutralLight = Color("NeutralLight")
    /// 成功狀態顏色，對應確認或進度已完成。
    public static let success = Color("Success")
    /// 藍橘中間值，用於表單警示與待處理狀態。
    public static let warning = Color(red: 0.96, green: 0.73, blue: 0.31)
    /// Default accent used across the app, aligned with Xcode's accent asset.
    public static let accentDefault = Color.accentColor

    /// Standard background color that adapts to light/dark appearance.
    public static func background(for colorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .light:
            return neutralLight
        case .dark:
            return Color(.systemBackground)
        @unknown default:
            return neutralLight
        }
    }

    /// Card background used for grouping data blocks.
    public static func cardBackground(for colorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .light:
            return Color.white
        case .dark:
            return Color(.secondarySystemBackground)
        @unknown default:
            return Color.white
        }
    }
}

public enum ThemeGradient {
    /// Gradient for hero cards (e.g. total assets) blending mint and sky blue hues.
    public static let hero = LinearGradient(
        colors: [
            ThemeColor.primary,
            ThemeColor.secondary.opacity(0.9),
            ThemeColor.primary.opacity(0.7)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Subtle background gradient for grouped sections.
    public static let surface = LinearGradient(
        colors: [ThemeColor.neutralLight.opacity(0.8), ThemeColor.neutralLight],
        startPoint: .top,
        endPoint: .bottom
    )
}

public enum ThemeShadow {
    /// Default soft shadow for cards to create elevation without harsh contrast.
    public static let card = ShadowStyle(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
}

public struct ShadowStyle {
    public let color: Color
    public let radius: CGFloat
    public let x: CGFloat
    public let y: CGFloat

    public init(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
}

public enum ThemeBadge {
    public static func background(for identifier: String) -> Color {
        switch identifier {
        case "bank":
            return ThemeColor.primary.opacity(0.16)
        case "investment":
            return ThemeColor.highlight.opacity(0.18)
        case "cash":
            return ThemeColor.accent.opacity(0.18)
        case "goal-active":
            return ThemeColor.secondary.opacity(0.22)
        case "goal-complete":
            return ThemeColor.success.opacity(0.2)
        default:
            return ThemeColor.neutralLight.opacity(0.5)
        }
    }

    public static func foreground(for identifier: String) -> Color {
        switch identifier {
        case "bank":
            return ThemeColor.primary
        case "investment":
            return ThemeColor.highlight
        case "cash":
            return ThemeColor.accent
        case "goal-active":
            return ThemeColor.secondary
        case "goal-complete":
            return ThemeColor.success
        default:
            return ThemeColor.neutralDark
        }
    }
}
