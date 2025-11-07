import CoreData
import Foundation

@objc(Account)
class Account: NSManagedObject {}

@objc(SavingGoal)
class SavingGoal: NSManagedObject {}

@objc(AssetSnapshot)
class AssetSnapshot: NSManagedObject {}

@objc(NotificationSettings)
class NotificationSettings: NSManagedObject {}

// MARK: - Account

extension Account {
    @nonobjc
    class func fetchRequest() -> NSFetchRequest<Account> {
        NSFetchRequest<Account>(entityName: "Account")
    }

    @NSManaged var balance: NSDecimalNumber
    @NSManaged var createdAt: Date
    @NSManaged var currency: String
    @NSManaged var id: UUID
    @NSManaged var isActive: Bool
    @NSManaged var name: String
    @NSManaged var notes: String?
    @NSManaged var type: String
    @NSManaged var updatedAt: Date
    @NSManaged var snapshots: NSSet?
}

extension Account {
    var balanceDecimal: Decimal {
        balance.decimalValue
    }

    var typeEnum: AccountType {
        get { AccountType(rawValue: type) ?? .cash }
        set { type = newValue.rawValue }
    }

    var formattedBalance: String {
        NumberFormatter.formattedCurrencyString(for: balanceDecimal)
    }

    func updateTimestamps() {
        updatedAt = Date()
    }

    func applyBalance(_ newValue: Decimal) {
        balance = NSDecimalNumber(decimal: newValue)
        updateTimestamps()
    }

    func addSnapshot(_ value: Decimal, on date: Date = Date(), context: NSManagedObjectContext) {
        let snapshot = AssetSnapshot(context: context)
        snapshot.id = UUID()
        snapshot.date = date
        snapshot.totalAssets = NSDecimalNumber(decimal: value)
        snapshot.createdAt = Date()
        snapshot.account = self
    }

    var allSnapshots: [AssetSnapshot] {
        (snapshots as? Set<AssetSnapshot>)?.sorted { $0.date < $1.date } ?? []
    }
}

// MARK: - SavingGoal

extension SavingGoal {
    @nonobjc
    class func fetchRequest() -> NSFetchRequest<SavingGoal> {
        NSFetchRequest<SavingGoal>(entityName: "SavingGoal")
    }

    @NSManaged var category: String?
    @NSManaged var completedAt: Date?
    @NSManaged var createdAt: Date
    @NSManaged var currentAmount: NSDecimalNumber
    @NSManaged var deadline: Date
    @NSManaged var id: UUID
    @NSManaged var isCompleted: Bool
    @NSManaged var notes: String?
    @NSManaged var targetAmount: NSDecimalNumber
    @NSManaged var title: String
    @NSManaged var updatedAt: Date
}

extension SavingGoal {
    var currentAmountDecimal: Decimal { currentAmount.decimalValue }
    var targetAmountDecimal: Decimal { targetAmount.decimalValue }

    var progress: Double {
        let target = targetAmountDecimal
        guard target > 0 else { return 0 }
        let value = (currentAmountDecimal as NSDecimalNumber).doubleValue / (target as NSDecimalNumber).doubleValue
        return min(max(value, 0), 1)
    }

    var remainingAmount: Decimal {
        max(targetAmountDecimal - currentAmountDecimal, 0)
    }

    func monthlySavingRequired(from referenceDate: Date = Date()) -> Decimal {
        guard remainingAmount > 0 else { return 0 }
        let components = Calendar.current.dateComponents([.month], from: referenceDate, to: deadline)
        let monthsLeft = max(components.month ?? 0, 1)
        let amount = remainingAmount / Decimal(monthsLeft)
        return amount < 0 ? 0 : amount
    }

    func updateProgress(to amount: Decimal) {
        currentAmount = NSDecimalNumber(decimal: amount)
        updatedAt = Date()
        if progress >= 1 {
            isCompleted = true
            completedAt = Date()
        }
    }

    func resetCompletion() {
        isCompleted = false
        completedAt = nil
    }
}

// MARK: - AssetSnapshot

extension AssetSnapshot {
    @nonobjc
    class func fetchRequest() -> NSFetchRequest<AssetSnapshot> {
        NSFetchRequest<AssetSnapshot>(entityName: "AssetSnapshot")
    }

    @NSManaged var createdAt: Date
    @NSManaged var date: Date
    @NSManaged var id: UUID
    @NSManaged var totalAssets: NSDecimalNumber
    @NSManaged var account: Account?

    var totalAssetsDecimal: Decimal {
        totalAssets.decimalValue
    }
}

// MARK: - NotificationSettings

extension NotificationSettings {
    @nonobjc
    class func fetchRequest() -> NSFetchRequest<NotificationSettings> {
        NSFetchRequest<NotificationSettings>(entityName: "NotificationSettings")
    }

    @NSManaged var id: UUID
    @NSManaged var isEnabled: Bool
    @NSManaged var notificationTime: Date
    @NSManaged var quoteType: String
    @NSManaged var updatedAt: Date
}

extension NotificationSettings {
    var timeComponents: DateComponents {
        Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
    }

    var quoteCategory: QuoteCategory {
        get { QuoteCategory(rawValue: quoteType) ?? .saving }
        set { quoteType = newValue.rawValue }
    }

    func updateTime(_ components: DateComponents) {
        guard let hour = components.hour, let minute = components.minute else { return }
        notificationTime = Calendar.current.date(from: DateComponents(hour: hour, minute: minute)) ?? notificationTime
        updatedAt = Date()
    }
}
