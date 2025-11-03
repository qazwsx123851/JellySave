import SwiftUI

struct EmptyStateView: View {
    var iconName: String = "tray"
    var animationName: String? = nil
    var title: String
    var message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: Constants.Spacing.lg) {
            animationSection
                .frame(height: 160)

            VStack(spacing: Constants.Spacing.sm) {
                Text(title)
                    .font(Constants.Typography.subtitle)
                    .foregroundStyle(Color.textPrimary)
                Text(message)
                    .font(Constants.Typography.body)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle, let action {
                CustomButton(title: actionTitle, style: .primary, action: action)
                    .frame(maxWidth: 200)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Constants.Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: Constants.CornerRadius.large, style: .continuous)
                .fill(Color.surfacePrimary)
        )
        .cardShadow(.subtle)
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var animationSection: some View {
        if let animationName {
            LottieView(name: animationName)
        } else {
            ZStack {
                Circle()
                    .fill(ThemeColor.primary.color.opacity(0.12))
                Image(systemName: iconName)
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundStyle(ThemeColor.primary.color)
            }
        }
    }
}

#Preview("EmptyStateView") {
    EmptyStateView(
        title: "尚無資料",
        message: "新增第一個帳戶，立即開始追蹤你的資產狀況。",
        actionTitle: "新增帳戶",
        action: {}
    )
    .padding()
    .background(Color.appBackground)
}
