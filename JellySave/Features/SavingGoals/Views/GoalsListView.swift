import SwiftUI

struct GoalsListView: View {
    private let activeGoals: [GoalPreview] = [
        GoalPreview(title: "緊急預備金", targetAmount: Decimal(180_000), currentAmount: Decimal(120_000), deadlineDescription: "預計 4 個月內達成"),
        GoalPreview(title: "北海道旅行", targetAmount: Decimal(120_000), currentAmount: Decimal(45_000), deadlineDescription: "距離出發還有 7 個月")
    ]

    private let completedGoals: [GoalPreview] = [
        GoalPreview(title: "年度保險費", targetAmount: Decimal(50_000), currentAmount: Decimal(50_000), deadlineDescription: "已於 2 週前達成")
    ]

    @State private var isPresentingCreateGoal = false

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
                                    TagLabel(text: "已完成", identifier: "goal-complete", systemImage: "checkmark.seal.fill")
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(ThemeColor.success)
                                }
                            }
                        }
                    }

                    CustomButton("新增儲蓄目標", iconName: "target") {
                        isPresentingCreateGoal = true
                    }

                    if activeGoals.isEmpty && completedGoals.isEmpty {
                        // 空狀態下引導使用者快速建立第一個儲蓄目標。
                        EmptyStateView(
                            title: "尚未設定儲蓄目標",
                            message: "建立第一個目標來追蹤進度，JellySave 會提醒你保持好習慣。",
                            actionTitle: "建立目標",
                            systemImage: "target"
                        ) {
                            isPresentingCreateGoal = true
                        }
                    }
                }
                .sectionPadding()
                .padding(.vertical, 24)
            }
            .background(ThemeColor.background(for: colorScheme).ignoresSafeArea())
            .navigationTitle("儲蓄目標")
            .sheet(isPresented: $isPresentingCreateGoal) {
                CreateGoalView()
            }
        }
    }

    @Environment(\.colorScheme) private var colorScheme
}

private extension GoalsListView {
    func goalRow(_ goal: GoalPreview) -> some View {
        let progress = goal.progress
        return HStack(alignment: .top, spacing: 20) {
            // 增加留白避免進度環貼近文字。
            ProgressRing(
                progress: progress,
                title: "",
                subtitle: nil,
                lineWidth: Constants.Progress.ringLineWidth,
                size: 104,
                animateOnAppear: true,
                animationDuration: 0.65
            )
            .padding(4)
            .background(
                Circle()
                    .fill(ThemeColor.cardBackground(for: colorScheme).opacity(0.15))
            )
            .padding(.vertical, 2)

            VStack(alignment: .leading, spacing: 12) {
                Text(goal.title)
                    .font(Constants.Typography.headline)
                    .foregroundColor(ThemeColor.neutralDark)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                Text(goal.deadlineDescription)
                    .font(Constants.Typography.caption)
                    .foregroundColor(ThemeColor.neutralDark.opacity(0.6))
                TagLabel(
                    text: "\(Int(progress * 100))% 已完成",
                    identifier: "goal-active",
                    systemImage: "hourglass.tophalf.fill"
                )
                Divider()
                    .background(ThemeColor.neutralLight.opacity(0.6))
                VStack(alignment: .leading, spacing: 6) {
                    Text("已存 \(NumberFormatter.twdString(from: goal.currentAmount)) / 目標 \(NumberFormatter.twdString(from: goal.targetAmount))")
                        .font(Constants.Typography.body.weight(.semibold))
                        .foregroundColor(ThemeColor.neutralDark.opacity(0.75))
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                    // 提醒使用者維持儲蓄節奏。
                    Text("維持每月存款可於 \(goal.estimatedCompletion) 達成")
                        .font(Constants.Typography.caption)
                        .foregroundColor(ThemeColor.neutralDark.opacity(0.55))
                        .lineLimit(2)
                }
            }
            .layoutPriority(1)
            .dynamicTypeSize(.medium ... .accessibility3)
            Spacer()
        }
        .padding(.vertical, 8)
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

    var estimatedCompletion: String {
        "約 \(Int((1 - progress) * 6) + 1) 個月內"
    }
}

#Preview {
    GoalsListView()
}
