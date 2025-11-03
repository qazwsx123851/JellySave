import SwiftUI

struct CardContainer<Content: View>: View {
    let title: String?
    let subtitle: String?
    let icon: Image?
    let actionTitle: String?
    let action: (() -> Void)?
    @ViewBuilder let content: Content

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
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var header: some View {
        HStack(alignment: .top, spacing: Constants.Spacing.md) {
            if let icon {
                icon
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(ThemeColor.primary.color)
                    .accessibilityHidden(true)
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
