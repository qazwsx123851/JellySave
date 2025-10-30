import SwiftUI

struct CreateGoalView: View {
    @State private var title: String = "2025 北海道旅行"
    @State private var targetAmount: Decimal = 120_000
    @State private var currentAmount: Decimal = 45_000
    @State private var deadline: Date = Calendar.current.date(byAdding: .month, value: 7, to: Date()) ?? Date()
    @State private var motivation: String = "想在 2025 秋季完成 10 天旅程"
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Constants.Layout.sectionSpacing) {
                    // 顯示靜態預覽提示，避免與真實資料混淆。
                    TagLabel(text: "靜態預覽", identifier: "goal-active", systemImage: "sparkles")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    basicsSection
                    progressPreviewSection
                }
                .sectionPadding()
                .padding(.vertical, 24)
            }
            .background(ThemeColor.background(for: colorScheme).ignoresSafeArea())
            .navigationTitle("建立儲蓄目標")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                        .foregroundColor(ThemeColor.neutralDark)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("儲存") {}
                        .disabled(true)
                        .foregroundColor(ThemeColor.neutralDark.opacity(0.5))
                }
            }
        }
    }

    @Environment(\.colorScheme) private var colorScheme
}

private extension CreateGoalView {
    var basicsSection: some View {
        CardContainer(title: "目標設定", subtitle: "定義標題與金額", iconName: "target") {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("目標名稱")
                        .font(Constants.Typography.caption)
                        .foregroundColor(ThemeColor.neutralDark.opacity(0.6))
                    TextField("例如：緊急預備金", text: $title)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: Constants.CornerRadius.medium, style: .continuous)
                                .fill(ThemeColor.cardBackground(for: colorScheme))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Constants.CornerRadius.medium, style: .continuous)
                                .stroke(ThemeColor.neutralLight.opacity(0.8), lineWidth: 1)
                        )
                    if isTitleEmpty {
                        Text("請輸入具體的目標名稱。")
                            .font(Constants.Typography.caption)
                            .foregroundColor(ThemeColor.warning)
                    }
                }

                CurrencyTextField("目標金額", value: $targetAmount)
                CurrencyTextField("目前已存", value: $currentAmount)

                VStack(alignment: .leading, spacing: 6) {
                    Text("預計完成日期")
                        .font(Constants.Typography.caption)
                        .foregroundColor(ThemeColor.neutralDark.opacity(0.6))
                    DatePicker("預計完成日期", selection: $deadline, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("動機備註")
                        .font(Constants.Typography.caption)
                        .foregroundColor(ThemeColor.neutralDark.opacity(0.6))
                    TextEditor(text: $motivation)
                        .frame(minHeight: 100)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: Constants.CornerRadius.medium, style: .continuous)
                                .fill(ThemeColor.cardBackground(for: colorScheme))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Constants.CornerRadius.medium, style: .continuous)
                                .stroke(ThemeColor.neutralLight.opacity(0.8), lineWidth: 1)
                        )
                    Text("\(motivation.count)/160")
                        .font(Constants.Typography.caption)
                        .foregroundColor(ThemeColor.neutralDark.opacity(0.4))
                }
            }
        }
    }

    var progressPreviewSection: some View {
        CardContainer(title: "進度預覽", subtitle: "僅供展示", iconName: "chart.pie") {
            VStack(spacing: 18) {
                let progress = progressValue
                ProgressRing(progress: progress, title: NumberFormatter.twdString(from: currentAmount), subtitle: "目標 \(NumberFormatter.twdString(from: targetAmount))")
                    .frame(maxWidth: .infinity)
                Text("預估已達成 \(Int(progress * 100))% ，維持每月存款可於 \(formattedDeadline) 達成目標。")
                    .font(Constants.Typography.caption)
                    .foregroundColor(ThemeColor.neutralDark.opacity(0.7))
                Divider()
                    .background(ThemeColor.neutralLight)
                VStack(alignment: .leading, spacing: 8) {
                    Text("下一步建議")
                        .font(Constants.Typography.caption.weight(.semibold))
                        .foregroundColor(ThemeColor.neutralDark.opacity(0.8))
                    // 靜態建議文案，後續可替換為動態分析結果。
                    Text("本週再增加 NT$2,500 存款，進度可提前一週完成。")
                        .font(Constants.Typography.caption)
                        .foregroundColor(ThemeColor.neutralDark.opacity(0.6))
                }
            }
        }
    }

    var progressValue: Double {
        guard targetAmount > 0 else { return 0 }
        let ratio = NSDecimalNumber(decimal: currentAmount).doubleValue / NSDecimalNumber(decimal: targetAmount).doubleValue
        return min(max(ratio, 0), 1)
    }

    var formattedDeadline: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: deadline)
    }

    var isTitleEmpty: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

#Preview {
    CreateGoalView()
}
