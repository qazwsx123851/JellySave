import SwiftUI

struct GoalsListView: View {
    private let activeGoals: [GoalPreview] = [
        GoalPreview(title: "緊急預備金", targetAmount: Decimal(180_000), currentAmount: Decimal(120_000), deadlineDescription: "預計 4 個月內達成"),
        GoalPreview(title: "北海道旅行", targetAmount: Decimal(120_000), currentAmount: Decimal(45_000), deadlineDescription: "距離出發還有 7 個月")
    ]

    private let completedGoals: [GoalPreview] = [
        GoalPreview(title: "年度保險費", targetAmount: Decimal(50_000), currentAmount: Decimal(50_000), deadlineDescription: "已於 2 週前達成")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Constants.Layout.sectionSpacing) {
                    CardContainer(title: "進行中目標", subtitle: "目前共有 \(activeGoals.count) 個") {
                        VStack(spacing: 16) {
                            ForEach(activeGoals) { goal in
                                goalRow(goal)
                                if goal != activeGoals.last {
                                    Divider().background(ThemeColor.neutralLight)
                                }
                            }
                        }
                    }

                    CardContainer(title: "已完成", subtitle: "恭喜達成 \(completedGoals.count) 項目", iconName: "party.popper") {
                        VStack(spacing: 12) {
                            ForEach(completedGoals) { goal in
                                HStack(alignment: .center, spacing: 16) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(goal.title)
                                            .font(Constants.Typography.body.weight(.semibold))
                                            .foregroundColor(ThemeColor.neutralDark)
                                        Text(goal.deadlineDescription)
                                            .font(Constants.Typography.caption)
                                            .foregroundColor(ThemeColor.neutralDark.opacity(0.6))
                                    }
                                    Spacer()
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(ThemeColor.success)
                                }
                            }
                        }
                    }

                    CustomButton("新增儲蓄目標", iconName: "target") {}
                }
                .sectionPadding()
                .padding(.vertical, 24)
            }
            .background(ThemeColor.background(for: colorScheme).ignoresSafeArea())
            .navigationTitle("儲蓄目標")
        }
    }

    @Environment(\.colorScheme) private var colorScheme
}

private extension GoalsListView {
    func goalRow(_ goal: GoalPreview) -> some View {
        let progress = goal.progress
        return HStack(alignment: .center, spacing: 20) {
            ProgressRing(progress: progress, title: NumberFormatter.twdString(from: goal.currentAmount), subtitle: "目標 \(NumberFormatter.twdString(from: goal.targetAmount))")
                .frame(width: 140)

            VStack(alignment: .leading, spacing: 8) {
                Text(goal.title)
                    .font(Constants.Typography.headline)
                    .foregroundColor(ThemeColor.neutralDark)
                Text(goal.deadlineDescription)
                    .font(Constants.Typography.caption)
                    .foregroundColor(ThemeColor.neutralDark.opacity(0.6))
                Text("進度：\(Int(progress * 100))%")
                    .font(Constants.Typography.caption)
                    .foregroundColor(ThemeColor.primary)
            }
            Spacer()
        }
    }
}

private struct GoalPreview: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let targetAmount: Decimal
    let currentAmount: Decimal
    let deadlineDescription: String

    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        let ratio = NSDecimalNumber(decimal: currentAmount).doubleValue / NSDecimalNumber(decimal: targetAmount).doubleValue
        return min(max(ratio, 0), 1)
    }
}

#Preview {
    GoalsListView()
}
