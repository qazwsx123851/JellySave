import SwiftUI

struct CardContainer<Content: View>: View {
    let title: String?
    let subtitle: String?
    let icon: Image?
    let actionTitle: String?
    let action: (() -> Void)?
    @ViewBuilder let content: Content
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    init(
        title: String? = nil,
        subtitle: String? = nil,
        icon: Image? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.actionTitle = actionTitle
        self.action = action
        self.content = content()
    }

    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            if title != nil || subtitle != nil || icon != nil || action != nil {
                header
            }
            content
        }
        .padding(Constants.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Constants.CornerRadius.large, style: .continuous)
                .fill(Color.surfacePrimary)
        )
        .cardShadow()
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            withAnimation {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    isPressed = false
                }
                // If there is a general action for the card, it could be triggered here
                // But currently action is specific to the button in the header
            }
        }
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var header: some View {
        HStack(alignment: .top, spacing: Constants.Spacing.md) {
            if let icon {
                ZStack {
                    Circle()
                        .fill(iconBackgroundColor)
                    icon
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(iconForegroundColor)
                        .accessibilityHidden(true)
                }
                .frame(width: 36, height: 36)
            }

            VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                if let title {
                    Text(title)
                        .font(Constants.Typography.subtitle)
                        .foregroundStyle(Color.textPrimary)
                }

                if let subtitle {
                    Text(subtitle)
                        .font(Constants.Typography.body)
                        .foregroundStyle(Color.textSecondary)
                }
            }

            Spacer()

            if let actionTitle, let action {
                CustomButton(title: actionTitle, style: .outline, action: action)
                    .frame(width: 120)
            }
        }
    }

    private var iconBackgroundColor: Color {
        ThemeColor.primary.color.opacity(0.18).adjustedForHighContrast(colorSchemeContrast)
    }

    private var iconForegroundColor: Color {
        iconBackgroundColor.accessibleTextColor(contrast: colorSchemeContrast)
    }
}

#Preview("CardContainer") {
    CardContainer(
        title: "總資產",
        subtitle: "最新更新於今天 10:30",
        icon: Image(systemName: "creditcard"),
        actionTitle: "查看詳情",
        action: {}
    ) {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            Text("NT$ 1,245,000")
                .font(Constants.Typography.hero)
                .foregroundStyle(ThemeColor.primary.color)
            Text("較上月 +5.4%")
                .font(Constants.Typography.body)
                .foregroundStyle(Color.textSecondary)
        }
    }
    .padding()
    .background(Color.appBackground)
}
