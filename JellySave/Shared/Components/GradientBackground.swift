import SwiftUI

public struct GradientBackground: View {
    public enum Style {
        case hero
        case accent
        case surface
    }

    private let style: Style
    private let cornerRadius: CGFloat

    public init(style: Style = .hero, cornerRadius: CGFloat = Constants.CornerRadius.large) {
        self.style = style
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(gradient)
    }

    private var gradient: LinearGradient {
        switch style {
        case .hero:
            return LinearGradient(colors: [ThemeColor.primary, ThemeColor.primary.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .accent:
            return LinearGradient(colors: [ThemeColor.accent, ThemeColor.highlight], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .surface:
            return LinearGradient(colors: [ThemeColor.neutralLight.opacity(0.9), ThemeColor.neutralLight], startPoint: .top, endPoint: .bottom)
        }
    }
}

#Preview {
    GradientBackground(style: .hero)
        .frame(width: 200, height: 120)
        .padding()
}
