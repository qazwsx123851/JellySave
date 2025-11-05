import SwiftUI

struct SavingGoalsView: View {
    private let overview = GoalsOverview.sample
    private let activeGoals = SavingGoalItem.sampleActive
    private let completedGoals = SavingGoalItem.sampleCompleted

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: Constants.Spacing.xl) {
                    overviewCard
                    activeGoalsSection
                    completedGoalsSection
                    CustomButton(title: "新增儲蓄目標", icon: Image(systemName: "target"), action: {})
                }
                .padding(.horizontal, Constants.Spacing.md)
                .padding(.vertical, Constants.Spacing.xl)
                .maxWidthLayout()
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("儲蓄目標")
        }
    }
}

// MARK: - Sections

private extension SavingGoalsView {
    var overviewCard: some View {
        CardContainer(
            title: "目標進度總覽",
            subtitle: "依據靜態樣本資料顯示",
            icon: Image(systemName: "sparkles")
        ) {
            VStack(spacing: Constants.Spacing.lg) {
                HStack(spacing: Constants.Spacing.lg) {
                    VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                        Text("整體完成度")
                            .font(Constants.Typography.caption)
                            .foregroundStyle(Color.textSecondary)
                        ProgressRing(progress: overview.overallProgress)
                            .frame(width: 88, height: 88)
                    }

                    VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                        Text(overview.totalSavedText)
                            .font(Constants.Typography.subtitle.weight(.semibold))
                            .foregroundStyle(Color.textPrimary)
                        Text("已完成 \(overview.completedGoals)/\(overview.totalGoals) 個目標")
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

    var activeGoalsSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("進行中的目標")
                .sectionTitleStyle()

            LazyVStack(spacing: Constants.Spacing.md) {
                ForEach(activeGoals) { goal in
                    GoalCard(goal: goal)
                }
            }
        }
    }

    var completedGoalsSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            HStack {
                Text("已完成的目標")
                    .sectionTitleStyle()
                Spacer()
                TagLabel(text: "近 6 個月", style: .outline)
            }

            LazyVStack(spacing: Constants.Spacing.md) {
                ForEach(completedGoals) { goal in
                    GoalCompletedCard(goal: goal)
                }
            }
        }
    }
}

// MARK: - Models

private struct GoalsOverview {
    struct Highlight: Identifiable {
        let id = UUID()
        let title: String
        let value: String
    }

    let totalSaved: Decimal
    let totalGoals: Int
    let completedGoals: Int
    let totalProgress: Double
    let monthlySaving: Decimal

    var overallProgress: Double { totalProgress }
    var totalSavedText: String { NumberFormatter.formattedCurrencyString(for: totalSaved) }

    var highlights: [Highlight] {
        [
            Highlight(title: "本月儲蓄", value: NumberFormatter.formattedCurrencyString(for: monthlySaving)),
            Highlight(title: "平均完成率", value: "\(Int(totalProgress * 100))%"),
            Highlight(title: "進行中", value: "\(totalGoals - completedGoals) 個")
        ]
    }

    static let sample = GoalsOverview(
        totalSaved: 365_800,
        totalGoals: 5,
        completedGoals: 2,
        totalProgress: 0.68,
        monthlySaving: 28_000
    )
}

private struct SavingGoalItem: Identifiable {
    enum Status {
        case active
        case completed
    }

    let id = UUID()
    let title: String
    let description: String
    let targetAmount: Decimal
    let savedAmount: Decimal
    let dueDate: String
    let progress: Double
    let status: Status
    let tags: [String]

    var targetAmountText: String { NumberFormatter.formattedCurrencyString(for: targetAmount) }
    var savedAmountText: String { NumberFormatter.formattedCurrencyString(for: savedAmount) }
    var remainingAmountText: String { NumberFormatter.formattedCurrencyString(for: targetAmount - savedAmount) }

    static let sampleActive: [SavingGoalItem] = [
        SavingGoalItem(
            title: "北海道冬季旅行",
            description: "2025 年 1 月和家人一起旅行",
            targetAmount: 180_000,
            savedAmount: 120_000,
            dueDate: "剩餘 4 個月",
            progress: 0.67,
            status: .active,
            tags: ["家庭", "旅遊基金"]
        ),
        SavingGoalItem(
            title: "緊急預備金",
            description: "維持 6 個月生活費",
            targetAmount: 240_000,
            savedAmount: 168_000,
            dueDate: "長期目標",
            progress: 0.7,
            status: .active,
            tags: ["安全網", "長期"]
        ),
        SavingGoalItem(
            title: "MacBook Pro 更新",
            description: "2024 Q4 之前購買",
            targetAmount: 75_000,
            savedAmount: 36_500,
            dueDate: "剩餘 2 個月",
            progress: 0.49,
            status: .active,
            tags: ["工作投資"]
        )
    ]

    static let sampleCompleted: [SavingGoalItem] = [
        SavingGoalItem(
            title: "婚禮基金",
            description: "已達成",
            targetAmount: 320_000,
            savedAmount: 320_000,
            dueDate: "完成於 2024/06",
            progress: 1.0,
            status: .completed,
            tags: ["人生里程碑"]
        ),
        SavingGoalItem(
            title: "機車頭期款",
            description: "完成於 2024/03",
            targetAmount: 90_000,
            savedAmount: 90_000,
            dueDate: "完成於 2024/03",
            progress: 1.0,
            status: .completed,
            tags: ["交通升級"]
        )
    ]
}

// MARK: - Views

private struct GoalCard: View {
    let goal: SavingGoalItem

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            HStack(alignment: .top, spacing: Constants.Spacing.md) {
                ProgressRing(progress: goal.progress)
                    .frame(width: 72, height: 72)

                VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                    Text(goal.title)
                        .font(Constants.Typography.subtitle.weight(.semibold))
                        .foregroundStyle(Color.textPrimary)
                    Text(goal.description)
                        .font(Constants.Typography.body)
                        .foregroundStyle(Color.textSecondary)
                    Text(goal.dueDate)
                        .font(Constants.Typography.caption)
                        .foregroundStyle(Color.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: Constants.Spacing.xs) {
                    Text(goal.savedAmountText)
                        .font(Constants.Typography.subtitle.weight(.semibold))
                        .foregroundStyle(Color.textPrimary)
                    Text("目標 \(goal.targetAmountText)")
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
                    Text("尚需 \(goal.remainingAmountText)")
                        .font(Constants.Typography.caption)
                        .foregroundStyle(Color.textSecondary)
                    Spacer()
                    Text("\(Int(goal.progress * 100))%")
                        .font(Constants.Typography.caption.weight(.semibold))
                        .foregroundStyle(Color.textPrimary)
                }
            }

            HStack {
                ForEach(goal.tags, id: \.self) { tag in
                    TagLabel(text: tag)
                }
                Spacer()
                CustomButton(title: "調整計畫", style: .outline, action: {})
                    .frame(width: 120)
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
    let goal: SavingGoalItem

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
                Text(goal.dueDate)
                    .font(Constants.Typography.caption)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            Text(goal.savedAmountText)
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

#Preview {
    SavingGoalsView()
        .environmentObject(ThemeService())
}
