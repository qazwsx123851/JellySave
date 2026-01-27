import Combine
import CoreData
import Foundation

protocol SavingGoalServiceProtocol {
    func fetchGoals() -> AnyPublisher<[SavingGoal], Error>
    func createGoal(title: String, targetAmount: Decimal, currentAmount: Decimal, deadline: Date, category: String?, notes: String?) -> AnyPublisher<SavingGoal, Error>
    func updateGoal(_ goal: SavingGoal, currentAmount: Decimal, notes: String?) -> AnyPublisher<SavingGoal, Error>
    func completeGoal(_ goal: SavingGoal) -> AnyPublisher<SavingGoal, Error>
    func editGoal(_ goal: SavingGoal,
                  title: String,
                  targetAmount: Decimal,
                  currentAmount: Decimal,
                  deadline: Date,
                  category: String?,
                  notes: String?) -> AnyPublisher<SavingGoal, Error>
}

final class SavingGoalService: SavingGoalServiceProtocol {
    private let coreDataStack: CoreDataStack
    private let performanceMonitor = PerformanceMonitor.shared
    private let notificationCenter: NotificationCenter

    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
        self.notificationCenter = .default
    }

    func fetchGoals() -> AnyPublisher<[SavingGoal], Error> {
        perform { context in
            let request: NSFetchRequest<SavingGoal> = SavingGoal.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \SavingGoal.isCompleted, ascending: true),
                NSSortDescriptor(keyPath: \SavingGoal.deadline, ascending: true)
            ]
            return try self.performanceMonitor.measure(operation: "SavingGoalService.fetchGoals") {
                try context.fetch(request)
            }
        }
    }

    func createGoal(title: String, targetAmount: Decimal, currentAmount: Decimal, deadline: Date, category: String?, notes: String?) -> AnyPublisher<SavingGoal, Error> {
        perform { context in
            let goal = SavingGoal(context: context)
            goal.id = UUID()
            goal.title = title
            goal.targetAmount = NSDecimalNumber(decimal: targetAmount)
            goal.currentAmount = NSDecimalNumber(decimal: currentAmount)
            goal.deadline = deadline
            goal.createdAt = Date()
            goal.updatedAt = Date()
            goal.category = category
            goal.notes = notes
            goal.isCompleted = false

            try self.coreDataStack.save(context: context)
            self.notifyDataChanged()
            return goal
        }
    }

    func updateGoal(_ goal: SavingGoal, currentAmount: Decimal, notes: String?) -> AnyPublisher<SavingGoal, Error> {
        perform { context in
            goal.updateProgress(to: currentAmount)
            goal.notes = notes
            goal.updatedAt = Date()

            try self.coreDataStack.save(context: context)
            self.notifyDataChanged()
            return goal
        }
    }

    func completeGoal(_ goal: SavingGoal) -> AnyPublisher<SavingGoal, Error> {
        perform { context in
            goal.isCompleted = true
            goal.completedAt = Date()
            goal.updatedAt = Date()
            try self.coreDataStack.save(context: context)
            self.notifyDataChanged()
            return goal
        }
    }

    func editGoal(_ goal: SavingGoal,
                  title: String,
                  targetAmount: Decimal,
                  currentAmount: Decimal,
                  deadline: Date,
                  category: String?,
                  notes: String?) -> AnyPublisher<SavingGoal, Error> {
        perform { context in
            goal.title = title
            goal.targetAmount = NSDecimalNumber(decimal: targetAmount)
            goal.deadline = deadline
            goal.category = category
            goal.notes = notes

            if currentAmount < targetAmount {
                goal.resetCompletion()
            }
            goal.updateProgress(to: currentAmount)
            goal.updatedAt = Date()

            try self.coreDataStack.save(context: context)
            self.notifyDataChanged()
            return goal
        }
    }

    // MARK: - Helpers

    private func perform<T>(_ block: @escaping (NSManagedObjectContext) throws -> T) -> AnyPublisher<T, Error> {
        Future { promise in
            let context = self.coreDataStack.context
            context.perform {
                do {
                    let value = try block(context)
                    promise(.success(value))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private func notifyDataChanged() {
        DispatchQueue.main.async {
            self.notificationCenter.post(name: .dataStoreDidChange, object: nil)
        }
    }
}
