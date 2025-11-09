import Combine
import CoreData
import Foundation

struct HomeSummaryHighlight: Identifiable {
    let id = UUID()
    let title: String
    let value: String
}

struct HomeSummary {
    let totalAssets: Decimal
    let monthlyChangeAmount: Decimal
    let monthlyChangeRatio: Double
    let lastUpdated: Date
    let highlights: [HomeSummaryHighlight]

    static let placeholder = HomeSummary(
        totalAssets: 0,
        monthlyChangeAmount: 0,
        monthlyChangeRatio: 0,
        lastUpdated: Date(),
        highlights: []
    )
}

struct MonthlyTrendPoint: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Decimal

    var amountDouble: Double {
        NSDecimalNumber(decimal: amount).doubleValue
    }
}

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var summary: HomeSummary = .placeholder
    @Published var trendPoints: [MonthlyTrendPoint] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let accountService: AccountServiceProtocol
    private let savingGoalService: SavingGoalServiceProtocol
    private let coreDataStack: CoreDataStack
    private let errorHandler = ErrorHandler.shared
    private let performanceMonitor = PerformanceMonitor.shared
    private var cancellables = Set<AnyCancellable>()

    init(accountService: AccountServiceProtocol = AccountService(),
         savingGoalService: SavingGoalServiceProtocol = SavingGoalService(),
         coreDataStack: CoreDataStack = .shared) {
        self.accountService = accountService
        self.savingGoalService = savingGoalService
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

        Publishers.Zip(accountService.fetchAccounts(), savingGoalService.fetchGoals())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = self.errorHandler.handle(error)
                }
            } receiveValue: { [weak self] accounts, goals in
                guard let self else { return }
                let trend = self.loadTrend(accounts: accounts)
                self.summary = self.makeSummary(accounts: accounts, goals: goals, trend: trend)
                self.trendPoints = trend
                self.isLoading = false
            }
            .store(in: &cancellables)
    }

    func refresh() async {
        await withCheckedContinuation { continuation in
            load()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                continuation.resume()
            }
        }
    }

    private func makeSummary(accounts: [Account], goals: [SavingGoal], trend: [MonthlyTrendPoint]) -> HomeSummary {
        let totalAssets = accounts.reduce(Decimal(0)) { $0 + $1.balanceDecimal }

        let highlights: [HomeSummaryHighlight] = [
            HomeSummaryHighlight(title: "帳戶數量", value: "\(accounts.count) 個"),
            HomeSummaryHighlight(title: "進行中目標", value: "\(goals.filter { !$0.isCompleted }.count) 項"),
            HomeSummaryHighlight(title: "每月儲蓄", value: NumberFormatter.formattedCurrencyString(for: goals.filter { !$0.isCompleted }.reduce(Decimal(0)) { $0 + $1.monthlySavingRequired() }))
        ]

        let monthlyChangeAmount = calculateMonthlyChangeAmount(from: trend)
        let monthlyChangeRatio = calculateMonthlyChangeRatio(from: trend)
        let lastUpdated = accounts.map(\.updatedAt).max() ?? Date()

        return HomeSummary(
            totalAssets: totalAssets,
            monthlyChangeAmount: monthlyChangeAmount,
            monthlyChangeRatio: monthlyChangeRatio,
            lastUpdated: lastUpdated,
            highlights: highlights
        )
    }

    private func loadTrend(accounts: [Account]) -> [MonthlyTrendPoint] {
        let request: NSFetchRequest<AssetSnapshot> = AssetSnapshot.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \AssetSnapshot.date, ascending: true)
        ]
        request.fetchLimit = 12

        let context = coreDataStack.context
        var snapshots: [AssetSnapshot] = []
        context.performAndWait {
            snapshots = (try? self.performanceMonitor.measure(operation: "HomeViewModel.trendFetch") {
                try context.fetch(request)
            }) ?? []
        }

        if snapshots.isEmpty {
            // fallback to synthetic data from accounts if no snapshots exist
            let totalAssets = accounts.reduce(Decimal(0)) { $0 + $1.balanceDecimal }
            let months = (0..<6).compactMap { offset -> Date? in
                Calendar.current.date(byAdding: .month, value: -offset, to: Date())
            }.sorted()

            return months.enumerated().map { index, date in
                let factor = 1 - Double(6 - index) * 0.02
                let amount = totalAssets * Decimal(factor > 0 ? factor : 0.5)
                return MonthlyTrendPoint(date: date, amount: amount)
            }
        }

        return snapshots.map { MonthlyTrendPoint(date: $0.date, amount: $0.totalAssetsDecimal) }
    }

    private func calculateMonthlyChangeAmount(from trend: [MonthlyTrendPoint]) -> Decimal {
        guard let latest = trend.last?.amount,
              let previous = trend.dropLast().last?.amount else {
            return 0
        }
        return latest - previous
    }

    private func calculateMonthlyChangeRatio(from trend: [MonthlyTrendPoint]) -> Double {
        guard let latest = trend.last?.amount,
              let previous = trend.dropLast().last?.amount,
              previous != 0 else {
            return 0
        }
        let latestValue = NSDecimalNumber(decimal: latest).doubleValue
        let previousValue = NSDecimalNumber(decimal: previous).doubleValue
        return (latestValue - previousValue) / previousValue
    }
}
