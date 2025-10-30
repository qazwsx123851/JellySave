import SwiftUI

/// Strongly typed accessors for the app's brand color palette.
public enum ThemeColor {
    /// Mint primary brand color used for primary actions and totals.
    public static let primary = Color("BrandPrimary")
    /// Coral accent for highlights, alerts, or completion states.
    public static let accent = Color("BrandAccent")
    /// Vibrant highlight reserved for key celebratory UI.
    public static let highlight = Color("BrandHighlight")
    /// Neutral dark tone for text on light backgrounds.
    public static let neutralDark = Color("NeutralDark")
    /// Neutral light background color for grouping content.
    public static let neutralLight = Color("NeutralLight")
    /// Success state color for confirmations or progress indicators.
    public static let success = Color("Success")
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
        colors: [ThemeColor.primary, ThemeColor.primary.opacity(0.6)],
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
