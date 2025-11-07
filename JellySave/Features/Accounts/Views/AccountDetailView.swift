import SwiftUI

struct AccountDetailView: View {
    let account: Account

    var body: some View {
        ScrollView {
            VStack(spacing: Constants.Spacing.xl) {
                headerCard
                metadataSection
            }
            .padding(.horizontal, Constants.Spacing.md)
            .padding(.vertical, Constants.Spacing.xl)
            .maxWidthLayout()
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle(account.name)
    }

    private var headerCard: some View {
        CardContainer(
            title: account.name,
            subtitle: account.typeEnum.description,
            icon: Image(systemName: account.typeEnum.iconName),
            actionTitle: "編輯帳戶",
            action: {}
        ) {
            VStack(alignment: .leading, spacing: Constants.Spacing.lg) {
                HStack(alignment: .center, spacing: Constants.Spacing.lg) {
                    Image(systemName: account.typeEnum.iconName)
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .frame(width: 72, height: 72)
                        .background(
                            RoundedRectangle(cornerRadius: Constants.CornerRadius.large, style: .continuous)
                                .fill(account.typeEnum.color)
                        )

                    VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                        Text("目前餘額")
                            .font(Constants.Typography.caption)
                            .foregroundStyle(Color.textSecondary)
                        Text(account.formattedBalance)
                            .font(Constants.Typography.hero)
                            .foregroundStyle(Color.textPrimary)
                    }
                }

                Divider()

                VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                    Text("帳戶備註")
                        .font(Constants.Typography.body.weight(.semibold))
                        .foregroundStyle(Color.textPrimary)
                    Text(account.notes ?? "尚未新增備註內容。")
                        .font(Constants.Typography.body)
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
    }

    private var metadataSection: some View {
        CardContainer(
            title: "帳戶資訊",
            subtitle: "歷史紀錄",
            icon: Image(systemName: "clock.arrow.circlepath")
        ) {
            VStack(alignment: .leading, spacing: Constants.Spacing.md) {
                InfoRow(label: "建立時間", value: createdDateText)
                InfoRow(label: "最後更新", value: updatedDateText)
                InfoRow(label: "帳戶狀態", value: account.isActive ? "啟用中" : "已停用")
                InfoRow(label: "幣別", value: account.currency)
            }
        }
    }

    private var createdDateText: String {
        dateFormatter.string(from: account.createdAt)
    }

    private var updatedDateText: String {
        dateFormatter.string(from: account.updatedAt)
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter
    }
}

private struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(Constants.Typography.caption)
                .foregroundStyle(Color.textSecondary)
            Spacer()
            Text(value)
                .font(Constants.Typography.body.weight(.semibold))
                .foregroundStyle(Color.textPrimary)
        }
    }
}
