import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()

    private lazy var persistentContainer: NSPersistentContainer = {
        let model = Self.makeManagedObjectModel()
        let container = NSPersistentContainer(name: "JellySave", managedObjectModel: model)
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Core Data load error: \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    private static func makeManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // Account entity
        let account = NSEntityDescription()
        account.name = "Account"
        account.managedObjectClassName = NSStringFromClass(Account.self)

        let accountId = makeAttribute(name: "id", type: .UUIDAttributeType)
        accountId.isIndexed = true
        let accountName = makeAttribute(name: "name", type: .stringAttributeType)
        let accountType = makeAttribute(name: "type", type: .stringAttributeType)
        let accountCurrency = makeAttribute(name: "currency", type: .stringAttributeType, defaultValue: "TWD")
        let accountBalance = makeAttribute(name: "balance", type: .decimalAttributeType)
        accountBalance.defaultValue = NSDecimalNumber.zero
        let accountCreatedAt = makeAttribute(name: "createdAt", type: .dateAttributeType)
        let accountUpdatedAt = makeAttribute(name: "updatedAt", type: .dateAttributeType)
        let accountIsActive = makeAttribute(name: "isActive", type: .booleanAttributeType, defaultValue: true)
        let accountNotes = makeAttribute(name: "notes", type: .stringAttributeType, optional: true)

        account.properties = [
            accountId, accountName, accountType, accountCurrency, accountBalance,
            accountCreatedAt, accountUpdatedAt, accountIsActive, accountNotes
        ]

        // AssetSnapshot entity
        let snapshot = NSEntityDescription()
        snapshot.name = "AssetSnapshot"
        snapshot.managedObjectClassName = NSStringFromClass(AssetSnapshot.self)

        let snapshotId = makeAttribute(name: "id", type: .UUIDAttributeType)
        let snapshotDate = makeAttribute(name: "date", type: .dateAttributeType)
        let snapshotCreatedAt = makeAttribute(name: "createdAt", type: .dateAttributeType)
        let snapshotTotal = makeAttribute(name: "totalAssets", type: .decimalAttributeType)
        snapshotTotal.defaultValue = NSDecimalNumber.zero

        snapshot.properties = [snapshotId, snapshotDate, snapshotCreatedAt, snapshotTotal]

        // SavingGoal entity
        let goal = NSEntityDescription()
        goal.name = "SavingGoal"
        goal.managedObjectClassName = NSStringFromClass(SavingGoal.self)

        let goalId = makeAttribute(name: "id", type: .UUIDAttributeType)
        let goalTitle = makeAttribute(name: "title", type: .stringAttributeType)
        let goalCategory = makeAttribute(name: "category", type: .stringAttributeType, optional: true)
        let goalNotes = makeAttribute(name: "notes", type: .stringAttributeType, optional: true)
        let goalCreatedAt = makeAttribute(name: "createdAt", type: .dateAttributeType)
        let goalUpdatedAt = makeAttribute(name: "updatedAt", type: .dateAttributeType)
        let goalDeadline = makeAttribute(name: "deadline", type: .dateAttributeType)
        let goalCompletedAt = makeAttribute(name: "completedAt", type: .dateAttributeType, optional: true)
        let goalIsCompleted = makeAttribute(name: "isCompleted", type: .booleanAttributeType, defaultValue: false)
        let goalTarget = makeAttribute(name: "targetAmount", type: .decimalAttributeType)
        goalTarget.defaultValue = NSDecimalNumber.zero
        let goalCurrent = makeAttribute(name: "currentAmount", type: .decimalAttributeType)
        goalCurrent.defaultValue = NSDecimalNumber.zero

        goal.properties = [
            goalId, goalTitle, goalCategory, goalNotes,
            goalCreatedAt, goalUpdatedAt, goalDeadline, goalCompletedAt,
            goalIsCompleted, goalTarget, goalCurrent
        ]

        // NotificationSettings entity
        let settings = NSEntityDescription()
        settings.name = "NotificationSettings"
        settings.managedObjectClassName = NSStringFromClass(NotificationSettings.self)

        let settingsId = makeAttribute(name: "id", type: .UUIDAttributeType)
        let settingsEnabled = makeAttribute(name: "isEnabled", type: .booleanAttributeType, defaultValue: false)
        let settingsTime = makeAttribute(name: "notificationTime", type: .dateAttributeType)
        let settingsQuoteType = makeAttribute(name: "quoteType", type: .stringAttributeType, defaultValue: "saving")
        let settingsUpdated = makeAttribute(name: "updatedAt", type: .dateAttributeType)

        settings.properties = [settingsId, settingsEnabled, settingsTime, settingsQuoteType, settingsUpdated]

        // Relationships
        let accountToSnapshots = NSRelationshipDescription()
        accountToSnapshots.name = "snapshots"
        accountToSnapshots.destinationEntity = snapshot
        accountToSnapshots.minCount = 0
        accountToSnapshots.maxCount = 0
        accountToSnapshots.deleteRule = .cascadeDeleteRule

        let snapshotToAccount = NSRelationshipDescription()
        snapshotToAccount.name = "account"
        snapshotToAccount.destinationEntity = account
        snapshotToAccount.minCount = 0
        snapshotToAccount.maxCount = 1
        snapshotToAccount.deleteRule = .nullifyDeleteRule

        accountToSnapshots.inverseRelationship = snapshotToAccount
        snapshotToAccount.inverseRelationship = accountToSnapshots

        account.properties.append(accountToSnapshots)
        snapshot.properties.append(snapshotToAccount)

        model.entities = [account, snapshot, goal, settings]
        return model
    }

    private static func makeAttribute(name: String, type: NSAttributeType, optional: Bool = false, defaultValue: Any? = nil) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type
        attribute.isOptional = optional
        attribute.defaultValue = defaultValue
        return attribute
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        context.automaticallyMergesChangesFromParent = true
        return context
    }

    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask { context in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            context.automaticallyMergesChangesFromParent = true
            block(context)
        }
    }

    func save(context: NSManagedObjectContext? = nil) throws {
        let context = context ?? self.context
        guard context.hasChanges else { return }

        try context.performAndWait {
            do {
                try context.save()
            } catch {
                context.rollback()
                throw error
            }
        }
    }

    func seedIfNeeded() {
        let request = NSFetchRequest<NSManagedObjectID>(entityName: "Account")
        request.resultType = .managedObjectIDResultType
        request.fetchLimit = 1

        do {
            let existingCount = try context.count(for: request)
            guard existingCount == 0 else { return }
        } catch {
            print("Seed check error: \(error)")
            return
        }

        let backgroundContext = newBackgroundContext()
        backgroundContext.perform {
            let now = Date()
            let accountDefinitions: [(String, AccountType, Decimal, String?)] = [
                ("玉山活儲", .cash, 185_200, "主要薪資戶")
            ]

            accountDefinitions.forEach { name, type, balance, note in
                let account = Account(context: backgroundContext)
                account.id = UUID()
                account.name = name
                account.typeEnum = type
                account.balance = NSDecimalNumber(decimal: balance)
                account.currency = "TWD"
                account.createdAt = now
                account.updatedAt = now
                account.isActive = true
                account.notes = note
            }

            let calendar = Calendar.current
            let dates = (0..<6).compactMap { offset -> Date? in
                calendar.date(byAdding: .month, value: -offset, to: now)
            }.sorted()

            let baseTotal: Decimal = 880_000
            dates.enumerated().forEach { index, date in
                let total = baseTotal + Decimal(index) * 42_500
                let snapshot = AssetSnapshot(context: backgroundContext)
                snapshot.id = UUID()
                snapshot.date = date
                snapshot.createdAt = date
                snapshot.totalAssets = NSDecimalNumber(decimal: total)
            }

            let goalDefinitions: [(String, Decimal, Decimal, Int, String?)] = [
                ("北海道冬季旅行", 180_000, 120_000, 4, "2025 年 1 月家庭旅遊"),
                ("緊急預備金", 240_000, 168_000, 12, "維持 6 個月生活費"),
                ("MacBook Pro 更新", 75_000, 36_500, 2, "工作用設備升級")
            ]

            goalDefinitions.forEach { title, target, current, months, note in
                let goal = SavingGoal(context: backgroundContext)
                goal.id = UUID()
                goal.title = title
                goal.targetAmount = NSDecimalNumber(decimal: target)
                goal.currentAmount = NSDecimalNumber(decimal: current)
                goal.createdAt = now
                goal.updatedAt = now
                goal.deadline = calendar.date(byAdding: .month, value: months, to: now) ?? now
                goal.isCompleted = false
                goal.notes = note
            }

            let settingsRequest: NSFetchRequest<NotificationSettings> = NotificationSettings.fetchRequest()
            settingsRequest.fetchLimit = 1
            let settings = (try? backgroundContext.fetch(settingsRequest).first) ?? NotificationSettings(context: backgroundContext)
            if settings.isInserted {
                settings.id = UUID()
            }
            settings.isEnabled = true
            settings.notificationTime = calendar.date(from: DateComponents(hour: 9, minute: 30)) ?? now
            settings.quoteCategory = .saving
            settings.updatedAt = now

            do {
                try backgroundContext.save()
            } catch {
                backgroundContext.rollback()
                print("Seed error: \(error)")
            }
        }
    }
}
