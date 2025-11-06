import SwiftUI

struct GoalsListView: View {
    let activeGoals: [SavingGoal]
    let completedGoals: [SavingGoal]
    let onCreateGoal: () -> Void
    let onMarkCompleted: (SavingGoal) -> Void
    @EnvironmentObject private var goalsViewModel: GoalsViewModel

    var body: some View {
        LazyVStack(spacing: Constants.Spacing.xl) {
            overviewCard
            activeGoalsSection
            completedGoalsSection
            CustomButton(title: "新增儲蓄目標", icon: Image(systemName: "target")) {
                onCreateGoal()
            }
        }
    }

    private var overviewCard: some View {
        CardContainer(
            title: "目標進度總覽",
            subtitle: "依據最新儲蓄資料",
            icon: Image(systemName: "sparkles")
        ) {
            VStack(spacing: Constants.Spacing.lg) {
                HStack(spacing: Constants.Spacing.lg) {
                    VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                        Text("整體完成度")
                            .font(Constants.Typography.caption)
                            .foregroundStyle(Color.textSecondary)
                        ProgressRing(progress: overallProgress)
                            .frame(width: 88, height: 88)
                    }

                    VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                        Text(totalSavedText)
                            .font(Constants.Typography.subtitle.weight(.semibold))
                            .foregroundStyle(Color.textPrimary)
                        Text("已完成 \(completedGoals.count)/\(totalGoals) 個目標")
                            .font(Constants.Typography.body)
                            .foregroundStyle(Color.textSecondary)
                        Capsule()
                            .fill(LinearGradient(colors: [ThemeColor.primary.color, ThemeColor.secondary.color], startPoint: .leading, endPoint: .trailing))
                            .frame(height: 6)
                            .overlay(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.8))
                                    .frame(width: 6)
                            }
                    }
                }

                Divider()

                HStack(spacing: Constants.Spacing.lg) {
                    summaryHighlight(title: "本月儲蓄", value: monthlySavingText)
                    summaryHighlight(title: "平均完成率", value: averageProgressText)
                    summaryHighlight(title: "進行中", value: "\(activeGoals.count) 個")
                }
            }
        }
    }

    private var activeGoalsSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("進行中的目標")
                .sectionTitleStyle()

            if activeGoals.isEmpty {
                EmptyStateView(
                    title: "還沒有正在努力的目標",
                    message: "設定一個新的儲蓄目標，讓 JellySave 幫你追蹤進度。"
                )
            } else {
                LazyVStack(spacing: Constants.Spacing.md) {
                    ForEach(activeGoals, id: \.objectID) { goal in
                        NavigationLink {
                            GoalDetailView(goal: goal)
                                .environmentObject(goalsViewModel)
                        } label: {
                            GoalCard(goal: goal)
                        }
                        .buttonStyle(.plain)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button {
                                onMarkCompleted(goal)
                            } label: {
                                Label("標記完成", systemImage: "checkmark.circle.fill")
                            }
                            .tint(ThemeColor.success.color)
                        }
                    }
                }
            }
        }
    }

    private var completedGoalsSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            HStack {
                Text("已完成的目標")
                    .sectionTitleStyle()
                Spacer()
                TagLabel(text: "近 6 個月", style: .outline)
            }

            if completedGoals.isEmpty {
                EmptyStateView(
                    title: "尚未完成任何目標",
                    message: "堅持儲蓄計畫，完成後會在這裡幫你紀錄。"
                )
            } else {
                LazyVStack(spacing: Constants.Spacing.md) {
                    ForEach(completedGoals, id: \.objectID) { goal in
                        NavigationLink {
                            GoalDetailView(goal: goal)
                                .environmentObject(goalsViewModel)
                        } label: {
                            GoalCompletedCard(goal: goal)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var totalGoals: Int {
        activeGoals.count + completedGoals.count
    }

    private var overallProgress: Double {
        let goals = activeGoals + completedGoals
        guard !goals.isEmpty else { return 0 }
        let total = goals.reduce(0.0) { $0 + $1.progress }
        return total / Double(goals.count)
    }

    private var totalSavedText: String {
        let amount = (activeGoals + completedGoals).reduce(Decimal(0)) { $0 + $1.currentAmountDecimal }
        return NumberFormatter.formattedCurrencyString(for: amount)
    }

    private var monthlySavingText: String {
        let amount = activeGoals.reduce(Decimal(0)) { $0 + $1.monthlySavingRequired() }
        return NumberFormatter.formattedCurrencyString(for: amount)
    }

    private var averageProgressText: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: overallProgress)) ?? "0%"
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

// MARK: - Subviews

private struct GoalCard: View {
    let goal: SavingGoal

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            HStack(alignment: .top, spacing: Constants.Spacing.md) {
                ProgressRing(progress: goal.progress)
                    .frame(width: 72, height: 72)

                VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                    Text(goal.title)
                        .font(Constants.Typography.subtitle.weight(.semibold))
                        .foregroundStyle(Color.textPrimary)
                    Text(goal.notes ?? goal.goalDescription)
                        .font(Constants.Typography.body)
                        .foregroundStyle(Color.textSecondary)
                    Text(goal.deadlineText)
                        .font(Constants.Typography.caption)
                        .foregroundStyle(Color.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: Constants.Spacing.xs) {
                    Text(NumberFormatter.formattedCurrencyString(for: goal.currentAmountDecimal))
                        .font(Constants.Typography.subtitle.weight(.semibold))
                        .foregroundStyle(Color.textPrimary)
                    Text("目標 \(NumberFormatter.formattedCurrencyString(for: goal.targetAmountDecimal))")
                        .font(Constants.Typography.caption)
                        .foregroundStyle(Color.textSecondary)
                }
            }

            VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.divider.opacity(0.3))
                            .frame(height: 8)
                        Capsule()
                            .fill(LinearGradient(colors: [ThemeColor.primary.color, ThemeColor.secondary.color], startPoint: .leading, endPoint: .trailing))
                            .frame(width: proxy.size.width * goal.progress, height: 8)
                    }
                }
                .frame(height: 8)

                HStack {
                    Text("尚需 \(NumberFormatter.formattedCurrencyString(for: goal.remainingAmount))")
                        .font(Constants.Typography.caption)
                        .foregroundStyle(Color.textSecondary)
                    Spacer()
                    Text("\(Int(goal.progress * 100))%")
                        .font(Constants.Typography.caption.weight(.semibold))
                        .foregroundStyle(Color.textPrimary)
                }
            }

            HStack {
                if let category = goal.category {
                    TagLabel(text: category)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.textSecondary.opacity(0.4))
            }
        }
        .padding(Constants.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Constants.CornerRadius.large, style: .continuous)
                .fill(Color.surfacePrimary)
        )
        .cardShadow()
    }
}

private struct GoalCompletedCard: View {
    let goal: SavingGoal

    var body: some View {
        HStack(spacing: Constants.Spacing.md) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(ThemeColor.success.color)
                .frame(width: 48, height: 48)
                .background(
                    RoundedRectangle(cornerRadius: Constants.CornerRadius.medium, style: .continuous)
                        .fill(ThemeColor.success.color.opacity(0.15))
                )

            VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                Text(goal.title)
                    .font(Constants.Typography.body.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                Text(goal.completionText)
                    .font(Constants.Typography.caption)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            Text(NumberFormatter.formattedCurrencyString(for: goal.targetAmountDecimal))
                .font(Constants.Typography.body.weight(.semibold))
                .foregroundStyle(Color.textPrimary)
        }
        .padding(Constants.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Constants.CornerRadius.medium, style: .continuous)
                .fill(Color.surfaceSecondary)
        )
    }
}

// MARK: - SavingGoal Helpers

private extension SavingGoal {
    var goalDescription: String {
        notes ?? "持續累積目標基金"
    }

    var deadlineText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd 截止"
        return formatter.string(from: deadline)
    }

    var completionText: String {
        if let completedAt {
            let formatter = DateFormatter()
            formatter.dateFormat = "完成於 yyyy/MM/dd"
            return formatter.string(from: completedAt)
        }
        return "尚未完成"
    }
}
