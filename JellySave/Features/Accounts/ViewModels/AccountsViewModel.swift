import Combine
import CoreData
import Foundation

struct AccountSection: Identifiable {
    let id = UUID()
    let type: AccountType
    let accounts: [Account]

    var totalBalance: Decimal {
        accounts.reduce(0) { $0 + $1.balanceDecimal }
    }
}

struct AccountOverviewSummary {
    let totalBalance: Decimal
    let accountCount: Int
    let categoryCount: Int
    let monthlyChangeRatio: Double
    let monthlyChangeAmount: Decimal
    let lastUpdated: Date?

    static let placeholder = AccountOverviewSummary(totalBalance: 0, accountCount: 0, categoryCount: 0, monthlyChangeRatio: 0, monthlyChangeAmount: 0, lastUpdated: nil)
}

@MainActor
final class AccountsViewModel: ObservableObject {
    @Published var sections: [AccountSection] = []
    @Published var summary: AccountOverviewSummary = .placeholder
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText: String = "" {
        didSet {
            updateSections()
        }
    }

    private let accountService: AccountServiceProtocol
    private let coreDataStack: CoreDataStack
    private var cancellables = Set<AnyCancellable>()
    private var allAccounts: [Account] = []

    init(accountService: AccountServiceProtocol = AccountService(), coreDataStack: CoreDataStack = .shared) {
        self.accountService = accountService
        self.coreDataStack = coreDataStack
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

        accountService.fetchAccounts()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] accounts in
                guard let self else { return }
                self.allAccounts = accounts
                self.summary = self.makeSummary(from: accounts)
                self.updateSections()
            }
            .store(in: &cancellables)
    }

    func delete(_ account: Account) {
        accountService.deleteAccount(account)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] in
                self?.load()
            }
            .store(in: &cancellables)
    }

    func createAccount(name: String, type: AccountType, balance: Decimal, notes: String?) {
        accountService.createAccount(name: name, type: type, balance: balance, notes: notes)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.load()
            }
            .store(in: &cancellables)
    }

    func createSampleAccount() {
        let amount = Decimal(Int.random(in: 10_000...80_000))
        createAccount(name: "臨時帳戶", type: .cash, balance: amount, notes: nil)
    }

    private func makeSections(from accounts: [Account]) -> [AccountSection] {
        let grouped = Dictionary(grouping: accounts) { $0.typeEnum }
        return AccountType.allCases.compactMap { type in
            guard let accounts = grouped[type], !accounts.isEmpty else { return nil }
            return AccountSection(type: type, accounts: accounts)
        }
    }

    private func updateSections() {
        let filtered = filteredAccounts(from: allAccounts)
        sections = makeSections(from: filtered)
    }

    private func filteredAccounts(from accounts: [Account]) -> [Account] {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyword.isEmpty else { return accounts }

        return accounts.filter { account in
            account.name.localizedCaseInsensitiveContains(keyword) ||
            (account.notes?.localizedCaseInsensitiveContains(keyword) ?? false)
        }
    }

    private func makeSummary(from accounts: [Account]) -> AccountOverviewSummary {
        let total = accounts.reduce(Decimal(0)) { $0 + $1.balanceDecimal }
        let categories = Set(accounts.map { $0.type }).count
        let lastUpdated = accounts.map(\.updatedAt).max()

        let request: NSFetchRequest<AssetSnapshot> = AssetSnapshot.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AssetSnapshot.date, ascending: false)]
        request.fetchLimit = 2

        var changeAmount: Decimal = 0
        var changeRatio: Double = 0

        coreDataStack.context.performAndWait {
            if let snapshots = try? coreDataStack.context.fetch(request), snapshots.count == 2 {
                let current = snapshots.first!.totalAssetsDecimal
                let previous = snapshots.last!.totalAssetsDecimal
                changeAmount = current - previous
                if previous != 0 {
                    let currentValue = NSDecimalNumber(decimal: current).doubleValue
                    let previousValue = NSDecimalNumber(decimal: previous).doubleValue
                    changeRatio = (currentValue - previousValue) / previousValue
                }
            }
        }

        return AccountOverviewSummary(
            totalBalance: total,
            accountCount: accounts.count,
            categoryCount: categories,
            monthlyChangeRatio: changeRatio,
            monthlyChangeAmount: changeAmount,
            lastUpdated: lastUpdated
        )
    }
}
