import SwiftUI

struct AccountsView: View {
    private let overview = AccountsOverview.sample
    private let groups = AccountGroup.sampleGroups
    private let quickActions = AccountQuickAction.sampleActions

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: Constants.Spacing.xl) {
                    totalBalanceCard

                    ForEach(groups) { group in
                        AccountGroupSection(group: group)
                    }

                    AccountQuickActions(actions: quickActions)

                    VStack(spacing: Constants.Spacing.md) {
                        CustomButton(title: "新增帳戶", icon: Image(systemName: "plus.circle.fill")) {}
                        CustomButton(title: "匯入帳戶資料", style: .outline, action: {})
                    }
                }
                .padding(.horizontal, Constants.Spacing.md)
                .padding(.vertical, Constants.Spacing.xl)
                .maxWidthLayout()
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("帳戶")
        }
    }
}

// MARK: - Sections

private extension AccountsView {
    var totalBalanceCard: some View {
        CardContainer(
            title: "資產總覽",
            subtitle: "依據靜態樣本資料顯示",
            icon: Image(systemName: "creditcard.fill"),
            actionTitle: "查看報表",
            action: {}
        ) {
            VStack(alignment: .leading, spacing: Constants.Spacing.lg) {
                VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                    Text(overview.totalBalanceText)
                        .font(Constants.Typography.hero)
                        .foregroundStyle(Color.textPrimary)
                    Text("較上月 \(overview.monthlyChangeText)")
                        .font(Constants.Typography.body)
                        .foregroundStyle(overview.monthlyChangeIsPositive ? ThemeColor.success.color : ThemeColor.accent.color)
                }

                Divider()

                HStack(spacing: Constants.Spacing.lg) {
                    ForEach(overview.highlights) { highlight in
                        VStack(alignment: .leading, spacing: Constants.Spacing.xxs) {
                            Text(highlight.title)
                                .font(Constants.Typography.caption)
                                .foregroundStyle(Color.textSecondary)
                            Text(highlight.value)
                                .font(Constants.Typography.body.weight(.semibold))
                                .foregroundStyle(Color.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }
}

// MARK: - Models

private struct AccountsOverview {
    struct Highlight: Identifiable {
        let id = UUID()
        let title: String
        let value: String
    }

    let totalBalance: Decimal
    let monthlyChange: Decimal
    let accountCount: Int
    let groups: Int
    let lastUpdate: String
    let highlights: [Highlight]

    var totalBalanceText: String { NumberFormatter.formattedCurrencyString(for: totalBalance) }

    var monthlyChangeText: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        formatter.locale = Locale(identifier: "zh_TW")
        let percent = formatter.string(from: NSDecimalNumber(decimal: monthlyChange)) ?? "0%"
        return "\(monthlyChangeIsPositive ? "+" : "")\(percent)"
    }

    var monthlyChangeIsPositive: Bool { (monthlyChange as NSDecimalNumber).doubleValue >= 0 }

    static let sample = AccountsOverview(
        totalBalance: 1_284_500,
        monthlyChange: 0.032,
        accountCount: 12,
        groups: 5,
        lastUpdate: "更新於今天 10:24",
        highlights: [
            Highlight(title: "帳戶數量", value: "12 個"),
            Highlight(title: "類別", value: "5 種"),
            Highlight(title: "上次更新", value: "今天 10:24")
        ]
    )
}

private struct AccountGroup: Identifiable {
    struct AccountItem: Identifiable {
        let id = UUID()
        let name: String
        let iconName: String
        let balance: Decimal
        let changeText: String
        let changeIsPositive: Bool
        let badges: [String]
    }

    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let accounts: [AccountItem]

    static let sampleGroups: [AccountGroup] = [
        AccountGroup(
            title: "現金帳戶",
            subtitle: "日常收支與緊急預備金",
            icon: "dollarsign.circle.fill",
            color: ThemeColor.primary.color,
            accounts: [
                AccountItem(name: "玉山活儲", iconName: "building.columns.fill", balance: 185_200, changeText: "+12,500", changeIsPositive: true, badges: ["薪資入帳"]),
                AccountItem(name: "現金錢包", iconName: "wallet.pass.fill", balance: 12_800, changeText: "-2,300", changeIsPositive: false, badges: ["生活支出"])
            ]
        ),
        AccountGroup(
            title: "股票帳戶",
            subtitle: "投資部位與股息回報",
            icon: "chart.line.uptrend.xyaxis",
            color: ThemeColor.secondary.color,
            accounts: [
                AccountItem(name: "證券戶 - 元大", iconName: "chart.bar.xaxis", balance: 520_000, changeText: "+3.2%", changeIsPositive: true, badges: ["ETF 長期持有"]),
                AccountItem(name: "證券戶 - 富邦", iconName: "chart.pie.fill", balance: 215_500, changeText: "+1.1%", changeIsPositive: true, badges: ["美股成長"])
            ]
        ),
        AccountGroup(
            title: "外幣帳戶",
            subtitle: "旅遊與國際支付",
            icon: "globe.asia.australia.fill",
            color: ThemeColor.accent.color,
            accounts: [
                AccountItem(name: "美元活存", iconName: "banknote.fill", balance: 96_400, changeText: "+250", changeIsPositive: true, badges: ["匯率 31.2"]),
                AccountItem(name: "日圓儲蓄", iconName: "yensign.circle.fill", balance: 45_300, changeText: "-0.8%", changeIsPositive: false, badges: ["旅遊基金"])
            ]
        ),
        AccountGroup(
            title: "保險",
            subtitle: "保障與年金規劃",
            icon: "shield.checkerboard",
            color: ThemeColor.success.color,
            accounts: [
                AccountItem(name: "儲蓄保單", iconName: "shield.lefthalf.filled", balance: 180_000, changeText: "+2.1%", changeIsPositive: true, badges: ["保單到期 2027"]),
                AccountItem(name: "醫療險", iconName: "cross.case.fill", balance: 48_000, changeText: "+0%", changeIsPositive: true, badges: ["每月扣款 2,000"])
            ]
        ),
        AccountGroup(
            title: "加密貨幣",
            subtitle: "高風險波動資產",
            icon: "bitcoinsign.circle.fill",
            color: Color.orange,
            accounts: [
                AccountItem(name: "BTC 儲備", iconName: "bitcoinsign.circle.fill", balance: 86_300, changeText: "+5.6%", changeIsPositive: true, badges: ["冷錢包"]),
                AccountItem(name: "ETH 資產", iconName: "bolt.horizontal.circle.fill", balance: 64_200, changeText: "-3.2%", changeIsPositive: false, badges: ["質押 15 ETH"])
            ]
        )
    ]
}

private struct AccountQuickAction: Identifiable {
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

// MARK: - Views

private struct AccountGroupSection: View {
    let group: AccountGroup

    var body: some View {
        CardContainer(
            title: group.title,
            subtitle: group.subtitle,
            icon: Image(systemName: group.icon)
        ) {
            VStack(spacing: Constants.Spacing.md) {
                ForEach(group.accounts) { account in
                    AccountRow(account: account, accentColor: group.color)
                }
            }
        }
    }
}

private struct AccountRow: View {
    let account: AccountGroup.AccountItem
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            HStack(spacing: Constants.Spacing.md) {
                Image(systemName: account.iconName)
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
                    Text(NumberFormatter.formattedCurrencyString(for: account.balance))
                        .font(Constants.Typography.body)
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                Text(account.changeText)
                    .font(Constants.Typography.body.weight(.semibold))
                    .foregroundStyle(account.changeIsPositive ? ThemeColor.success.color : ThemeColor.accent.color)
            }

            HStack {
                ForEach(account.badges, id: \.self) { badge in
                    TagLabel(text: badge, style: .outline)
                }
                Spacer()
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
                            .foregroundStyle(Color.textSecondary.opacity(0.6))
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

#Preview {
    AccountsView()
        .environmentObject(ThemeService())
}
