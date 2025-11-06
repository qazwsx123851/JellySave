import SwiftUI

struct SavingGoalsView: View {
    @StateObject private var viewModel = GoalsViewModel()
    @State private var isPresentingCreateGoal = false
    @State private var showCelebration = false

    var body: some View {
        NavigationStack {
            ScrollView {
                GoalsListView(
                    activeGoals: viewModel.activeGoals,
                    completedGoals: viewModel.completedGoals,
                    onCreateGoal: { isPresentingCreateGoal = true },
                    onMarkCompleted: { goal in
                        viewModel.markCompleted(goal)
                    }
                )
                .environmentObject(viewModel)
                .padding(.horizontal, Constants.Spacing.md)
                .padding(.vertical, Constants.Spacing.xl)
                .maxWidthLayout()
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("儲蓄目標")
        }
        .sheet(isPresented: $isPresentingCreateGoal) {
            CreateGoalView { title, targetAmount, currentAmount, deadline, category, notes in
                viewModel.createGoal(
                    title: title,
                    targetAmount: targetAmount,
                    currentAmount: currentAmount,
                    deadline: deadline,
                    category: category,
                    notes: notes
                )
            }
        }
        .onChange(of: viewModel.celebrationContext) { context in
            showCelebration = context != nil
        }
        .sheet(isPresented: $showCelebration, onDismiss: {
            viewModel.celebrationContext = nil
        }) {
            if let context = viewModel.celebrationContext {
                CelebrationView(
                    title: "恭喜達成「\(context.title)」",
                    message: "已累積 \(context.finalAmountText)，成功完成目標 \(context.targetAmountText)。"
                ) {
                    showCelebration = false
                    viewModel.celebrationContext = nil
                }
            }
        }
    }
}

#Preview {
    SavingGoalsView()
        .environmentObject(ThemeService())
}
