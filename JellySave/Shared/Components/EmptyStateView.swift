import SwiftUI

/// 友善的空狀態提示，提供文案與可選擇的 CTA。
struct EmptyStateView: View {
    let title: String
    let message: String
    let actionTitle: String?
    let systemImage: String
    var action: (() -> Void)?

    init(title: String, message: String, actionTitle: String? = nil, systemImage: String = "sparkles", action: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 42))
                .foregroundColor(ThemeColor.primary)
                .padding(24)
                .background(
                    Circle()
                        .fill(ThemeColor.primary.opacity(0.15))
                )
            Text(title)
                .font(Constants.Typography.headline)
                .foregroundColor(ThemeColor.neutralDark)
            Text(message)
                .font(Constants.Typography.body)
                .multilineTextAlignment(.center)
                .foregroundColor(ThemeColor.neutralDark.opacity(0.7))
                .padding(.horizontal, 24)
            if let actionTitle, let action {
                CustomButton(actionTitle, style: .secondary, action: action)
                    .frame(maxWidth: 240)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: Constants.CornerRadius.large, style: .continuous)
                .fill(ThemeColor.neutralLight.opacity(0.6))
        )
    }
}

#Preview {
    EmptyStateView(
        title: "尚未新增帳戶",
        message: "加上一個薪轉或投資帳戶，開始追蹤你的財務狀況。",
        actionTitle: "新增帳戶",
        systemImage: "wallet.pass"
    ) {}
    .padding()
}
