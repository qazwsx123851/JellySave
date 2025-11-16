import SwiftUI

struct TagLabel: View {
    enum Style {
        case primary
        case outline
    }

    let text: String
    var style: Style = .primary
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return ThemeColor.primary.color.opacity(0.15).adjustedForHighContrast(colorSchemeContrast)
        case .outline:
            return ThemeColor.secondary.color.opacity(0.12).adjustedForHighContrast(colorSchemeContrast)
        }
    }

    private var foregroundColor: Color {
        backgroundColor.accessibleTextColor(contrast: colorSchemeContrast)
    }

    private var borderColor: Color {
        ThemeColor.secondary.color.adjustedForHighContrast(colorSchemeContrast)
    }

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.vertical, Constants.Spacing.xs)
            .padding(.horizontal, Constants.Spacing.sm)
            .background(
                Capsule()
                    .fill(backgroundColor)
            )
            .overlay(
                Capsule()
                    .stroke(borderColor.opacity(style == .outline ? 0.8 : 0), lineWidth: 1)
            )
            .foregroundStyle(foregroundColor)
            .accessibilityLabel(Text(text))
    }
}

#Preview("TagLabel") {
    HStack(spacing: Constants.Spacing.md) {
        TagLabel(text: "現金帳戶")
        TagLabel(text: "股票", style: .outline)
    }
    .padding()
    .background(Color.appBackground)
}
