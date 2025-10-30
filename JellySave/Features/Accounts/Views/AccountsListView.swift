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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Constants.Layout.sectionSpacing) {
                    summaryHeader

                    ForEach(groupedAccounts) { section in
                        CardContainer(title: section.title, subtitle: "共 \(section.accounts.count) 個") {
                            VStack(spacing: 12) {
                                ForEach(section.accounts) { account in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(account.name)
                                                .font(Constants.Typography.body.weight(.semibold))
                                                .foregroundColor(ThemeColor.neutralDark)
                                            Text(account.type)
                                                .font(Constants.Typography.caption)
                                                .foregroundColor(ThemeColor.neutralDark.opacity(0.6))
                                        }
                                        Spacer()
                                        Text(NumberFormatter.twdString(from: account.balance))
                                            .font(Constants.Typography.body.weight(.semibold))
                                            .foregroundColor(ThemeColor.neutralDark)
                                    }
                                    if account != section.accounts.last {
                                        Divider()
                                            .background(ThemeColor.neutralLight)
                                    }
                                }
                            }
                        }
                    }

                    CustomButton("新增帳戶", iconName: "plus") {}
                        .padding(.top, 8)
                }
                .sectionPadding()
                .padding(.vertical, 24)
            }
            .background(ThemeColor.background(for: colorScheme).ignoresSafeArea())
            .navigationTitle("帳戶")
        }
    }

    @Environment(\.colorScheme) private var colorScheme
}

private extension AccountsListView {
    var summaryHeader: some View {
        CardContainer(title: "總覽", subtitle: "帳戶總覽", iconName: "wallet.pass") {
            VStack(alignment: .leading, spacing: 12) {
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

                VStack(alignment: .leading, spacing: 8) {
                    Label("3 個帳戶連結 iCloud 同步", systemImage: "icloud")
                        .font(Constants.Typography.caption)
                        .foregroundColor(ThemeColor.neutralDark.opacity(0.7))
                    Label("1 個帳戶尚未設定通知", systemImage: "bell")
                        .font(Constants.Typography.caption)
                        .foregroundColor(ThemeColor.neutralDark.opacity(0.7))
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

#Preview {
    AccountsListView()
}
