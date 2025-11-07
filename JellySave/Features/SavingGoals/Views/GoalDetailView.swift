import SwiftUI

struct GoalDetailView: View {
    @ObservedObject var goal: SavingGoal
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: GoalsViewModel
    @State private var isEditing = false
    @State private var editor: GoalEditor

    init(goal: SavingGoal) {
        self.goal = goal
        _editor = State(initialValue: GoalEditor(goal: goal))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Constants.Spacing.xl) {
                progressCard
                detailsCard
            }
            .padding(.horizontal, Constants.Spacing.md)
            .padding(.vertical, Constants.Spacing.xl)
            .maxWidthLayout()
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle(goal.title)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if !goal.isCompleted {
                    Button("標記完成") {
                        viewModel.markCompleted(goal)
                        dismiss()
                    }
                }

                Button("編輯") {
                    editor = GoalEditor(goal: goal)
                    isEditing = true
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            EditGoalView(editor: $editor) { updated in
                viewModel.editGoal(goal, with: updated)
            }
        }
    }

    private var progressCard: some View {
        CardContainer(
            title: goal.title,
            subtitle: "目標進度",
            icon: Image(systemName: "target")
        ) {
            VStack(alignment: .leading, spacing: Constants.Spacing.lg) {
                HStack(alignment: .center, spacing: Constants.Spacing.lg) {
                    ProgressRing(progress: goal.progress)
                        .frame(width: 96, height: 96)

                    VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                        Text("達成率")
                            .font(Constants.Typography.caption)
                            .foregroundStyle(Color.textSecondary)
                        Text("\(Int(goal.progress * 100))%")
                            .font(Constants.Typography.hero)
                            .foregroundStyle(Color.textPrimary)
                    }
                }

                Divider()

                HStack(spacing: Constants.Spacing.lg) {
                    amountColumn(title: "目前金額", value: goal.currentAmountDecimal)
                    amountColumn(title: "目標金額", value: goal.targetAmountDecimal)
                    amountColumn(title: "尚需金額", value: goal.remainingAmount)
                }
            }
        }
    }

    private var detailsCard: some View {
        CardContainer(
            title: "目標詳情",
            subtitle: "進度與備註",
            icon: Image(systemName: "doc.text.magnifyingglass")
        ) {
            VStack(alignment: .leading, spacing: Constants.Spacing.lg) {
                InfoRow(label: "分類", value: goal.category ?? "未分類")
                InfoRow(label: "截止日期", value: dateFormatter.string(from: goal.deadline))
                InfoRow(label: "建立時間", value: dateFormatter.string(from: goal.createdAt))
                if let completedAt = goal.completedAt {
                    InfoRow(label: "完成時間", value: dateFormatter.string(from: completedAt))
                }

                VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                    Text("備註")
                        .font(Constants.Typography.body.weight(.semibold))
                        .foregroundStyle(Color.textPrimary)
                    Text(goal.notes ?? "目前沒有任何備註。")
                        .font(Constants.Typography.body)
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
    }

    private func amountColumn(title: String, value: Decimal) -> some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.xxs) {
            Text(title)
                .font(Constants.Typography.caption)
                .foregroundStyle(Color.textSecondary)
            Text(NumberFormatter.formattedCurrencyString(for: value))
                .font(Constants.Typography.body.weight(.semibold))
                .foregroundStyle(Color.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
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
