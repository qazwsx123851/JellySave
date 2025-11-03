import SwiftUI

struct TagLabel: View {
    enum Style {
        case primary
        case outline
    }

    let text: String
    var style: Style = .primary

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return ThemeColor.primary.color.opacity(0.15)
        case .outline:
            return ThemeColor.secondary.color.opacity(0.12)
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:
            return ThemeColor.primary.color
        case .outline:
            return ThemeColor.secondary.color
        }
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
                    .stroke(foregroundColor.opacity(style == .outline ? 0.6 : 0), lineWidth: 1)
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
