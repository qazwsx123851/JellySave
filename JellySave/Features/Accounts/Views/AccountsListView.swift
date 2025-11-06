import SwiftUI

struct AccountsListView: View {
    let summary: AccountOverviewSummary
    let sections: [AccountSection]
    let quickActions: [AccountQuickAction]
    let onCreateAccount: () -> Void

    var body: some View {
        LazyVStack(spacing: Constants.Spacing.xl) {
            totalBalanceCard

            ForEach(sections) { section in
                AccountSectionView(section: section)
            }

            AccountQuickActions(actions: quickActions)

            CustomButton(title: "新增帳戶", icon: Image(systemName: "plus.circle.fill")) {
                onCreateAccount()
            }
        }
    }

    private var totalBalanceCard: some View {
        CardContainer(
            title: "資產總覽",
            subtitle: "最新帳戶資訊",
            icon: Image(systemName: "creditcard.fill"),
            actionTitle: "查看報表",
            action: {}
        ) {
            VStack(alignment: .leading, spacing: Constants.Spacing.lg) {
                VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                    Text(NumberFormatter.formattedCurrencyString(for: summary.totalBalance))
                        .font(Constants.Typography.hero)
                        .foregroundStyle(Color.textPrimary)
                    Text(changeDescription)
                        .font(Constants.Typography.body)
                        .foregroundStyle(summary.monthlyChangeRatio >= 0 ? ThemeColor.success.color : ThemeColor.accent.color)
                }

                Divider()

                HStack(spacing: Constants.Spacing.lg) {
                    summaryHighlight(title: "帳戶數量", value: "\(summary.accountCount) 個")
                    summaryHighlight(title: "資產類別", value: "\(summary.categoryCount) 種")
                    summaryHighlight(title: "最後更新", value: lastUpdatedText)
                }
            }
        }
    }

    private var changeDescription: String {
        let percentFormatter = NumberFormatter()
        percentFormatter.numberStyle = .percent
        percentFormatter.maximumFractionDigits = 1
        percentFormatter.minimumFractionDigits = 0
        percentFormatter.locale = Locale(identifier: "zh_TW")
        let percentText = percentFormatter.string(from: NSNumber(value: summary.monthlyChangeRatio)) ?? "0%"
        let amountText = NumberFormatter.formattedCurrencyString(for: summary.monthlyChangeAmount)
        let prefix = summary.monthlyChangeRatio >= 0 ? "較上月 +" : "較上月 "
        return "\(prefix)\(percentText)（\(amountText)）"
    }

    private var lastUpdatedText: String {
        guard let date = summary.lastUpdated else { return "--" }
        let formatter = DateFormatter()
        formatter.dateFormat = "M 月 d 日"
        return formatter.string(from: date)
    }

    private func summaryHighlight(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.xxs) {
            Text(title)
                .font(Constants.Typography.caption)
                .foregroundStyle(Color.textSecondary)
            Text(value)
                .font(Constants.Typography.body.weight(.semibold))
                .foregroundStyle(Color.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Models

struct AccountQuickAction: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color

    static let sampleActions: [AccountQuickAction] = [
        AccountQuickAction(title: "資產再平衡", subtitle: "模擬 60/40 配置", icon: "slider.horizontal.3", color: ThemeColor.primary.color),
        AccountQuickAction(title: "設定預算", subtitle: "規劃下月支出", icon: "calendar.badge.checkmark", color: ThemeColor.accent.color),
        AccountQuickAction(title: "匯出報表", subtitle: "分享 PDF 報表", icon: "square.and.arrow.up", color: ThemeColor.secondary.color)
    ]
}

// MARK: - Subviews

private struct AccountSectionView: View {
    let section: AccountSection

    var body: some View {
        CardContainer(
            title: section.type.rawValue,
            subtitle: section.type.description,
            icon: Image(systemName: section.type.iconName)
        ) {
            VStack(spacing: Constants.Spacing.md) {
                ForEach(section.accounts, id: \.objectID) { account in
                    NavigationLink {
                        AccountDetailView(account: account)
                    } label: {
                        AccountRow(account: account, accentColor: section.type.color)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct AccountRow: View {
    let account: Account
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            HStack(spacing: Constants.Spacing.md) {
                Image(systemName: account.typeEnum.iconName)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: Constants.CornerRadius.medium, style: .continuous)
                            .fill(accentColor.opacity(0.9))
                    )

                VStack(alignment: .leading, spacing: Constants.Spacing.xxs) {
                    Text(account.name)
                        .font(Constants.Typography.subtitle.weight(.semibold))
                        .foregroundStyle(Color.textPrimary)
                    Text(account.formattedBalance)
                        .font(Constants.Typography.body)
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                Text(account.notes ?? "編輯備註")
                    .font(Constants.Typography.caption)
                    .foregroundStyle(Color.textSecondary.opacity(0.7))
            }
        }
        .padding(Constants.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Constants.CornerRadius.medium, style: .continuous)
                .fill(Color.surfaceSecondary)
        )
    }
}

private struct AccountQuickActions: View {
    let actions: [AccountQuickAction]

    var body: some View {
        CardContainer(
            title: "智能建議",
            subtitle: "持續優化資產結構",
            icon: Image(systemName: "lightbulb.max.fill")
        ) {
            VStack(spacing: Constants.Spacing.md) {
                ForEach(actions) { action in
                    HStack(spacing: Constants.Spacing.md) {
                        ZStack {
                            RoundedRectangle(cornerRadius: Constants.CornerRadius.small, style: .continuous)
                                .fill(action.color.opacity(0.18))
                            Image(systemName: action.icon)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(action.color)
                        }
                        .frame(width: 44, height: 44)

                        VStack(alignment: .leading, spacing: Constants.Spacing.xxs) {
                            Text(action.title)
                                .font(Constants.Typography.body.weight(.semibold))
                                .foregroundStyle(Color.textPrimary)
                            Text(action.subtitle)
                                .font(Constants.Typography.caption)
                                .foregroundStyle(Color.textSecondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.textSecondary.opacity(0.4))
                    }
                    .padding(Constants.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: Constants.CornerRadius.medium, style: .continuous)
                            .fill(Color.surfaceSecondary)
                    )
                }
            }
        }
    }
}
