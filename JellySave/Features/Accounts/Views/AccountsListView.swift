import SwiftUI

struct AccountsListView: View {
    private let groupedAccounts: [AccountSection] = [
        AccountSection(title: "銀行帳戶", accounts: [
            AccountSummary(name: "玉山銀行 - 薪轉", type: "活儲", balance: Decimal(180_000)),
            AccountSummary(name: "台新銀行 - Richart", type: "數位帳戶", balance: Decimal(65_200))
        ]),
        AccountSection(title: "投資帳戶", accounts: [
            AccountSummary(name: "元大證券", type: "股票", balance: Decimal(280_500)),
            AccountSummary(name: "富邦證券 - ETF", type: "ETF", balance: Decimal(120_400))
        ]),
        AccountSection(title: "現金", accounts: [
            AccountSummary(name: "現金錢包", type: "現金", balance: Decimal(8_500))
        ])
    ]

    @State private var isPresentingAddAccount = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Constants.Layout.sectionSpacing) {
                    summaryHeader

                    ForEach(groupedAccounts) { section in
                        CardContainer(title: section.title, subtitle: "共 \(section.accounts.count) 個") {
                            VStack(spacing: 16) {
                                ForEach(section.accounts) { account in
                                    VStack(spacing: 12) {
                                        HStack(alignment: .top, spacing: 16) {
                                            accountIcon(for: account)
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text(account.name)
                                                    .font(Constants.Typography.body.weight(.semibold))
                                                    .foregroundColor(ThemeColor.neutralDark)
                                                    .lineLimit(2)
                                                TagLabel(
                                                    text: account.type,
                                                    identifier: badgeIdentifier(for: account),
                                                    systemImage: badgeIcon(for: account)
                                                )
                                                Label("最後更新 2 天前", systemImage: "clock")
                                                    .font(Constants.Typography.caption)
                                                    .foregroundColor(ThemeColor.neutralDark.opacity(0.55))
                                                    .lineLimit(1)
                                            }
                                            Spacer()
                                            VStack(alignment: .trailing, spacing: 8) {
                                                Text(NumberFormatter.twdString(from: account.balance))
                                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                    .foregroundColor(ThemeColor.neutralDark)
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.85)
                                                Text("月增幅 +2.1%")
                                                    .font(Constants.Typography.caption)
                                                    .foregroundColor(ThemeColor.success)
                                            }
                                        }
                                        HStack(spacing: 12) {
                                            Button {
                                                // 引導使用者前往帳戶設定。
                                            } label: {
                                                Label("管理", systemImage: "slider.horizontal.3")
                                                    .labelStyle(.titleAndIcon)
                                                    .font(Constants.Typography.caption.weight(.semibold))
                                            }
                                            .buttonStyle(.borderedProminent)
                                            .tint(ThemeColor.primary.opacity(0.85))

                                            Button {
                                                // 安排通知設定快速入口。
                                            } label: {
                                                Label("通知", systemImage: "bell.badge")
                                                    .font(Constants.Typography.caption.weight(.semibold))
                                            }
                                            .buttonStyle(.bordered)
                                            .tint(ThemeColor.primary.opacity(0.4))
                                            Spacer()
                                        }
                                    }
                                    if account != section.accounts.last {
                                        Divider()
                                            .background(ThemeColor.neutralLight)
                                    }
                                }
                            }
                        }
                    }

                    CustomButton("新增帳戶", iconName: "plus") {
                        isPresentingAddAccount = true
                    }
                        .padding(.top, 8)

                    if groupedAccounts.isEmpty {
                        // 顯示空狀態，提醒使用者新增第一個帳戶。
                        EmptyStateView(
                            title: "尚未新增帳戶",
                            message: "加上一個薪轉或投資帳戶，開始追蹤你的財務狀況。",
                            actionTitle: "新增帳戶",
                            systemImage: "wallet.pass"
                        ) {
                            isPresentingAddAccount = true
                        }
                    }
                }
                .sectionPadding()
                .padding(.vertical, 24)
            }
            .background(ThemeColor.background(for: colorScheme).ignoresSafeArea())
            .navigationTitle("帳戶")
            .sheet(isPresented: $isPresentingAddAccount) {
                AddAccountView()
            }
        }
    }

    @Environment(\.colorScheme) private var colorScheme
}

private extension AccountsListView {
    func badgeIdentifier(for account: AccountSummary) -> String {
        switch account.type {
        case let type where type.contains("銀行"):
            return "bank"
        case let type where type.contains("證券") || type.contains("ETF"):
            return "investment"
        case let type where type.contains("現金"):
            return "cash"
        default:
            return "default"
        }
    }

    func badgeIcon(for account: AccountSummary) -> String {
        switch badgeIdentifier(for: account) {
        case "bank":
            return "building.columns"
        case "investment":
            return "chart.line.uptrend.xyaxis"
        case "cash":
            return "dollarsign"
        default:
            return "creditcard"
        }
    }

    var summaryHeader: some View {
        CardContainer(title: "總覽", subtitle: "帳戶總覽", iconName: "wallet.pass") {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("總資產")
                            .font(Constants.Typography.caption)
                            .foregroundColor(ThemeColor.neutralDark.opacity(0.7))
                        Text(NumberFormatter.twdString(from: Decimal(654_200)))
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(ThemeColor.neutralDark)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 6) {
                        Text("月增幅")
                            .font(Constants.Typography.caption)
                            .foregroundColor(ThemeColor.neutralDark.opacity(0.7))
                        Text("+3.2%")
                            .font(Constants.Typography.body.weight(.semibold))
                            .foregroundColor(ThemeColor.success)
                    }
                }

                Divider()
                    .background(ThemeColor.neutralLight)

                VStack(alignment: .leading, spacing: 12) {
                    Label("3 個帳戶連結 iCloud 同步", systemImage: "icloud")
                        .font(Constants.Typography.caption)
                        .foregroundColor(ThemeColor.neutralDark.opacity(0.7))
                    Label("1 個帳戶尚未設定通知", systemImage: "bell")
                        .font(Constants.Typography.caption)
                        .foregroundColor(ThemeColor.neutralDark.opacity(0.7))
                    HStack(spacing: 8) {
                        summaryChip(title: "同步正常", systemImage: "checkmark.circle.fill")
                        summaryChip(title: "通知待設定", systemImage: "bell.badge")
                    }
                }
            }
        }
    }
}

private struct AccountSection: Identifiable {
    let id = UUID()
    let title: String
    let accounts: [AccountSummary]
}

private struct AccountSummary: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let type: String
    let balance: Decimal
}

private extension AccountsListView {
    @ViewBuilder
    func accountIcon(for account: AccountSummary) -> some View {
        let identifier = badgeIdentifier(for: account)
        let baseColor: Color = {
            switch identifier {
            case "bank": return ThemeColor.primary.opacity(0.15)
            case "investment": return ThemeColor.warning.opacity(0.18)
            case "cash": return ThemeColor.success.opacity(0.18)
            default: return ThemeColor.neutralLight.opacity(0.45)
            }
        }()
        ZStack {
            RoundedRectangle(cornerRadius: Constants.CornerRadius.medium, style: .continuous)
                .fill(baseColor)
                .frame(width: 48, height: 48)
            Image(systemName: badgeIcon(for: account))
                .foregroundColor(ThemeColor.neutralDark)
                .font(.title3)
        }
        .accessibilityHidden(true)
    }

    @ViewBuilder
    func summaryChip(title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(Constants.Typography.caption.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .fill(ThemeColor.neutralLight.opacity(0.4))
            )
            .foregroundColor(ThemeColor.neutralDark.opacity(0.75))
    }
}

#Preview {
    AccountsListView()
}
