import Combine
import Foundation

struct GoalSection: Identifiable {
    enum State {
        case active
        case completed

        var title: String {
            switch self {
            case .active: return "進行中的目標"
            case .completed: return "已完成的目標"
            }
        }
    }

    let id = UUID()
    let state: State
    let goals: [SavingGoal]
}

@MainActor
final class GoalsViewModel: ObservableObject {
    @Published var activeGoals: [SavingGoal] = []
    @Published var completedGoals: [SavingGoal] = []
    @Published var celebrationContext: GoalCelebrationContext?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let savingGoalService: SavingGoalServiceProtocol
    private let errorHandler = ErrorHandler.shared
    private var cancellables = Set<AnyCancellable>()

    init(savingGoalService: SavingGoalServiceProtocol = SavingGoalService()) {
        self.savingGoalService = savingGoalService
        load()

        NotificationCenter.default.publisher(for: .dataStoreDidChange)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.load()
            }
            .store(in: &cancellables)
    }

    func load() {
        isLoading = true
        errorMessage = nil

        savingGoalService.fetchGoals()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = self.errorHandler.handle(error)
                }
            } receiveValue: { [weak self] goals in
                guard let self else { return }
                self.activeGoals = goals.filter { !$0.isCompleted }
                self.completedGoals = goals.filter { $0.isCompleted }
            }
            .store(in: &cancellables)
    }

    func createGoal(title: String, targetAmount: Decimal, currentAmount: Decimal, deadline: Date, category: String?, notes: String?) {
        savingGoalService.createGoal(
            title: title,
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            deadline: deadline,
            category: category,
            notes: notes
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            if case .failure(let error) = completion {
                self?.errorMessage = self?.errorHandler.handle(error)
            }
        } receiveValue: { [weak self] _ in
            self?.load()
        }
        .store(in: &cancellables)
    }

    func update(goal: SavingGoal, amount: Decimal) {
        savingGoalService.updateGoal(goal, currentAmount: amount, notes: goal.notes)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = self?.errorHandler.handle(error)
                }
            } receiveValue: { [weak self] _ in
                self?.load()
            }
            .store(in: &cancellables)
    }

    func markCompleted(_ goal: SavingGoal) {
        savingGoalService.completeGoal(goal)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = self?.errorHandler.handle(error)
                }
            } receiveValue: { [weak self] _ in
                self?.celebrationContext = GoalCelebrationContext(goal: goal)
                self?.load()
            }
            .store(in: &cancellables)
    }

    func editGoal(_ goal: SavingGoal, with editor: GoalEditor) {
        let willComplete = !goal.isCompleted && editor.currentAmount >= editor.targetAmount

        savingGoalService.editGoal(
            goal,
            title: editor.title.trimmingCharacters(in: .whitespacesAndNewlines),
            targetAmount: editor.targetAmount,
            currentAmount: editor.currentAmount,
            deadline: editor.deadline,
            category: editor.trimmedCategory,
            notes: editor.trimmedNotes
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            if case .failure(let error) = completion {
                self?.errorMessage = error.localizedDescription
            }
        } receiveValue: { [weak self] updatedGoal in
            if willComplete {
                self?.celebrationContext = GoalCelebrationContext(goal: updatedGoal)
            }
            self?.load()
        }
        .store(in: &cancellables)
    }
}

struct GoalCelebrationContext: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let targetAmount: Decimal
    let finalAmount: Decimal
    let message: String

    init(goal: SavingGoal) {
        title = goal.title
        targetAmount = goal.targetAmountDecimal
        finalAmount = goal.currentAmountDecimal
        message = goal.notes ?? "恭喜完成儲蓄目標，值得好好犒賞自己！"
    }

    var targetAmountText: String {
        NumberFormatter.formattedCurrencyString(for: targetAmount)
    }

    var finalAmountText: String {
        NumberFormatter.formattedCurrencyString(for: finalAmount)
    }
}

struct GoalEditor: Equatable {
    var title: String
    var targetAmount: Decimal
    var currentAmount: Decimal
    var deadline: Date
    var category: String
    var notes: String

    init(goal: SavingGoal) {
        title = goal.title
        targetAmount = goal.targetAmountDecimal
        currentAmount = goal.currentAmountDecimal
        deadline = goal.deadline
        category = goal.category ?? ""
        notes = goal.notes ?? ""
    }

    var trimmedCategory: String? {
        let value = category.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }

    var trimmedNotes: String? {
        let value = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }

    var isSaveEnabled: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && targetAmount > 0 && currentAmount >= 0
    }
}
