import SwiftUI

public struct CardContainer<Content: View>: View {
    private let title: String?
    private let subtitle: String?
    private let iconName: String?
    private let actionTitle: String?
    private let action: (() -> Void)?
    private let content: Content

    public init(title: String? = nil,
                subtitle: String? = nil,
                iconName: String? = nil,
                actionTitle: String? = nil,
                action: (() -> Void)? = nil,
                @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.iconName = iconName
        self.actionTitle = actionTitle
        self.action = action
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if title != nil || subtitle != nil || iconName != nil || actionTitle != nil {
                header
            }

            content
        }
        .cardBackground()
    }

    @ViewBuilder
    private var header: some View {
        HStack(alignment: .top) {
            HStack(spacing: 10) {
                if let iconName {
                    Image(systemName: iconName)
                        .foregroundStyle(ThemeColor.primary)
                }
                VStack(alignment: .leading, spacing: 4) {
                    if let title {
                        Text(title)
                            .font(Constants.Typography.headline)
                            .foregroundColor(ThemeColor.neutralDark)
                    }
                    if let subtitle {
                        Text(subtitle)
                            .font(Constants.Typography.caption)
                            .foregroundColor(ThemeColor.neutralDark.opacity(0.6))
                    }
                }
            }

            Spacer(minLength: 12)

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(Constants.Typography.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: Constants.CornerRadius.small, style: .continuous)
                                .fill(ThemeColor.primary.opacity(0.12))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    CardContainer(title: "金融帳戶", subtitle: "3 個帳戶", iconName: "creditcard", actionTitle: "管理") {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(0..<2) { index in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("玉山銀行 - 往來 \(index + 1)")
                            .font(Constants.Typography.body)
                            .foregroundColor(ThemeColor.neutralDark)
                        Text("主帳戶")
                            .font(Constants.Typography.caption)
                            .foregroundColor(ThemeColor.neutralDark.opacity(0.6))
                    }
                    Spacer()
                    Text(NumberFormatter.twdString(from: Decimal(180000)))
                        .font(Constants.Typography.body.weight(.semibold))
                        .foregroundColor(ThemeColor.neutralDark)
                }
            }
        }
    }
    .sectionPadding()
    .previewLayout(.sizeThatFits)
}
