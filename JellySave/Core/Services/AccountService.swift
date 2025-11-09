import Combine
import CoreData
import Foundation

protocol AccountServiceProtocol {
    func fetchAccounts() -> AnyPublisher<[Account], Error>
    func createAccount(name: String, type: AccountType, balance: Decimal, notes: String?) -> AnyPublisher<Account, Error>
    func updateAccount(_ account: Account) -> AnyPublisher<Account, Error>
    func deleteAccount(_ account: Account) -> AnyPublisher<Void, Error>
    func getTotalAssets() -> AnyPublisher<Decimal, Error>
}

final class AccountService: AccountServiceProtocol {
    private let coreDataStack: CoreDataStack
    private let performanceMonitor = PerformanceMonitor.shared

    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }

    func fetchAccounts() -> AnyPublisher<[Account], Error> {
        perform { context in
            let request: NSFetchRequest<Account> = Account.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \Account.createdAt, ascending: false)
            ]
            return try self.performanceMonitor.measure(operation: "AccountService.fetchAccounts") {
                try context.fetch(request)
            }
        }
    }

    func createAccount(name: String, type: AccountType, balance: Decimal, notes: String?) -> AnyPublisher<Account, Error> {
        perform { context in
            let account = Account(context: context)
            account.id = UUID()
            account.name = name
            account.typeEnum = type
            account.currency = "TWD"
            account.balance = NSDecimalNumber(decimal: balance)
            account.createdAt = Date()
            account.updatedAt = Date()
            account.isActive = true
            account.notes = notes

            try self.coreDataStack.save(context: context)
            return account
        }
    }

    func updateAccount(_ account: Account) -> AnyPublisher<Account, Error> {
        perform { context in
            account.updateTimestamps()
            try self.coreDataStack.save(context: context)
            return account
        }
    }

    func deleteAccount(_ account: Account) -> AnyPublisher<Void, Error> {
        perform { context in
            context.delete(account)
            try self.coreDataStack.save(context: context)
        }
    }

    func getTotalAssets() -> AnyPublisher<Decimal, Error> {
        perform { context in
            let request: NSFetchRequest<NSDictionary> = NSFetchRequest(entityName: "Account")
            request.resultType = .dictionaryResultType
            let balanceExpression = NSExpressionDescription()
            balanceExpression.name = "totalBalance"
            balanceExpression.expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "balance")])
            balanceExpression.expressionResultType = .decimalAttributeType
            request.propertiesToFetch = [balanceExpression]

            let result = try self.performanceMonitor.measure(operation: "AccountService.totalAssets") {
                try context.fetch(request)
            }
            if let dict = result.first, let sum = dict["totalBalance"] as? NSDecimalNumber {
                return sum as Decimal
            }
            return 0
        }
    }

    // MARK: - Helpers

    private func perform<T>(_ block: @escaping (NSManagedObjectContext) throws -> T) -> AnyPublisher<T, Error> {
        Future { promise in
            let context = self.coreDataStack.context
            context.perform {
                do {
                    let result = try block(context)
                    promise(.success(result))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
