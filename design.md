# JellySave 重新設計 - 技術設計文件

## 概覽

本設計文件基於 JellySave 重新設計需求，提供完整的技術架構、資料模型、UI 組件和實作策略。JellySave 是一款離線優先的個人財務管理 iOS 應用程式，採用 SwiftUI + MVVM 架構，支援五種帳戶類型和豐富的動畫效果。

## 系統架構

### 整體架構設計

```
┌─────────────────────────────────────────────────────────┐
│                    JellySave App                        │
├─────────────────────────────────────────────────────────┤
│  Presentation Layer (SwiftUI Views + ViewModels)       │
│  ┌─────────────┬─────────────┬─────────────┬──────────┐ │
│  │   HomeView  │ AccountsView│ GoalsView   │ Settings │ │
│  │             │             │             │   View   │ │
│  └─────────────┴─────────────┴─────────────┴──────────┘ │
├─────────────────────────────────────────────────────────┤
│  Business Logic Layer (Services)                       │
│  ┌─────────────┬─────────────┬─────────────┬──────────┐ │
│  │  Account    │ SavingGoal  │Notification │  Theme   │ │
│  │  Service    │  Service    │  Service    │ Service  │ │
│  └─────────────┴─────────────┴─────────────┴──────────┘ │
├─────────────────────────────────────────────────────────┤
│  Data Layer (Core Data + Local Storage)                │
│  ┌─────────────┬─────────────┬─────────────┬──────────┐ │
│  │ Core Data   │  UserDefaults│  Keychain   │ File     │ │
│  │ Stack       │             │  Service    │ Manager  │ │
│  └─────────────┴─────────────┴─────────────┴──────────┘ │
├─────────────────────────────────────────────────────────┤
│  Foundation Layer (iOS Frameworks)                     │
│  ┌─────────────┬─────────────┬─────────────┬──────────┐ │
│  │  SwiftUI    │  Combine    │ UserNotif.  │ LocalAuth│ │
│  │             │             │             │          │ │
│  └─────────────┴─────────────┴─────────────┴──────────┘ │
└─────────────────────────────────────────────────────────┘
```

### MVVM 架構實作

#### View Layer (SwiftUI)
- **職責**: 純 UI 呈現，處理用戶互動
- **特點**: 無業務邏輯，透過 `@StateObject` 和 `@ObservedObject` 與 ViewModel 綁定
- **動畫**: 使用 SwiftUI 內建動畫 + 第三方庫（Lottie, SkeletonView）

#### ViewModel Layer
- **職責**: 業務邏輯協調、狀態管理、資料格式化
- **特點**: 繼承 `ObservableObject`，使用 `@Published` 屬性
- **依賴注入**: 透過建構子注入 Service 依賴

#### Model Layer
- **職責**: 資料模型定義、Core Data 實體
- **特點**: 純資料結構，無業務邏輯

#### Service Layer
- **職責**: 業務邏輯實作、資料存取、外部服務整合
- **特點**: Protocol-based 設計，便於測試和擴展

## 資料模型設計

### Core Data 實體設計

#### Account 實體
```swift
@objc(Account)
public class Account: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var type: String // AccountType.rawValue
    @NSManaged public var balance: NSDecimalNumber
    @NSManaged public var currency: String // 預設 "TWD"
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var isActive: Bool
    @NSManaged public var notes: String?
    
    // 關聯
    @NSManaged public var snapshots: NSSet? // -> AssetSnapshot
}

enum AccountType: String, CaseIterable {
    case cash = "現金帳戶"
    case stock = "股票帳戶"
    case foreignCurrency = "外幣帳戶"
    case insurance = "保險"
    case cryptocurrency = "加密貨幣"
    
    var icon: String {
        switch self {
        case .cash: return "dollarsign.circle"
        case .stock: return "chart.line.uptrend.xyaxis"
        case .foreignCurrency: return "globe"
        case .insurance: return "shield.checkered"
        case .cryptocurrency: return "bitcoinsign.circle"
        }
    }
}
```

#### SavingGoal 實體
```swift
@objc(SavingGoal)
public class SavingGoal: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var targetAmount: NSDecimalNumber
    @NSManaged public var currentAmount: NSDecimalNumber
    @NSManaged public var deadline: Date
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var isCompleted: Bool
    @NSManaged public var completedAt: Date?
    @NSManaged public var category: String? // 目標分類
    @NSManaged public var notes: String?
    
    // 計算屬性
    var progress: Double {
        let current = currentAmount.doubleValue
        let target = targetAmount.doubleValue
        return target > 0 ? min(current / target, 1.0) : 0.0
    }
    
    var monthlySavingRequired: NSDecimalNumber {
        let remaining = targetAmount.subtracting(currentAmount)
        let monthsLeft = Calendar.current.dateComponents([.month], from: Date(), to: deadline).month ?? 1
        return remaining.dividing(by: NSDecimalNumber(value: max(monthsLeft, 1)))
    }
}
```

#### AssetSnapshot 實體
```swift
@objc(AssetSnapshot)
public class AssetSnapshot: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var totalAssets: NSDecimalNumber
    @NSManaged public var createdAt: Date
    
    // 關聯
    @NSManaged public var account: Account?
}
```

#### NotificationSettings 實體
```swift
@objc(NotificationSettings)
public class NotificationSettings: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var isEnabled: Bool
    @NSManaged public var notificationTime: Date
    @NSManaged public var quoteType: String // "investment" 或 "motivation"
    @NSManaged public var updatedAt: Date
}
```

### Core Data Stack 設計

```swift
class CoreDataStack {
    static let shared = CoreDataStack()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "JellySave")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Save error: \(error)")
            }
        }
    }
}
```

## 服務層設計

### AccountService
```swift
protocol AccountServiceProtocol {
    func fetchAccounts() -> AnyPublisher<[Account], Error>
    func createAccount(name: String, type: AccountType, balance: Decimal) -> AnyPublisher<Account, Error>
    func updateAccount(_ account: Account) -> AnyPublisher<Account, Error>
    func deleteAccount(_ account: Account) -> AnyPublisher<Void, Error>
    func getTotalAssets() -> AnyPublisher<Decimal, Error>
}

class AccountService: AccountServiceProtocol {
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }
    
    func fetchAccounts() -> AnyPublisher<[Account], Error> {
        let request: NSFetchRequest<Account> = Account.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Account.createdAt, ascending: false)]
        
        return Future { promise in
            do {
                let accounts = try self.coreDataStack.context.fetch(request)
                promise(.success(accounts))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // 其他方法實作...
}
```

### SavingGoalService
```swift
protocol SavingGoalServiceProtocol {
    func fetchGoals() -> AnyPublisher<[SavingGoal], Error>
    func createGoal(title: String, targetAmount: Decimal, deadline: Date) -> AnyPublisher<SavingGoal, Error>
    func updateGoalProgress(_ goal: SavingGoal, newAmount: Decimal) -> AnyPublisher<SavingGoal, Error>
    func completeGoal(_ goal: SavingGoal) -> AnyPublisher<SavingGoal, Error>
}

class SavingGoalService: SavingGoalServiceProtocol {
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }
    
    // 實作方法...
}
```

### NotificationService
```swift
protocol NotificationServiceProtocol {
    func requestPermission() -> AnyPublisher<Bool, Error>
    func scheduleDaily(at time: Date, type: QuoteType) -> AnyPublisher<Void, Error>
    func cancelAllNotifications()
}

class NotificationService: NotificationServiceProtocol {
    private let center = UNUserNotificationCenter.current()
    
    func requestPermission() -> AnyPublisher<Bool, Error> {
        Future { promise in
            self.center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(granted))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // 其他方法實作...
}
```

### ThemeService
```swift
enum AppTheme: String, CaseIterable {
    case light = "light"
    case dark = "dark"
    case system = "system"
}

class ThemeService: ObservableObject {
    @Published var currentTheme: AppTheme = .system
    
    private let userDefaults = UserDefaults.standard
    private let themeKey = "app_theme"
    
    init() {
        loadTheme()
    }
    
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        userDefaults.set(theme.rawValue, forKey: themeKey)
    }
    
    private func loadTheme() {
        let savedTheme = userDefaults.string(forKey: themeKey) ?? AppTheme.system.rawValue
        currentTheme = AppTheme(rawValue: savedTheme) ?? .system
    }
}
```

## UI 組件設計

### 共用組件

#### CustomButton
```swift
struct CustomButton: View {
    enum Style {
        case primary, secondary, outline
    }
    
    let title: String
    let iconName: String?
    let style: Style
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let iconName = iconName {
                    Image(systemName: iconName)
                }
                Text(title)
                    .font(.headline)
            }
            .padding(.horizontal, 24)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(CustomButtonStyle(style: style))
    }
}
```

#### ProgressRing
```swift
struct ProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [ThemeColor.primary, ThemeColor.secondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: progress)
        }
        .frame(width: size, height: size)
    }
}
```

#### CardContainer
```swift
struct CardContainer<Content: View>: View {
    let title: String?
    let subtitle: String?
    let iconName: String?
    let actionTitle: String?
    let action: (() -> Void)?
    let content: Content
    
    init(
        title: String? = nil,
        subtitle: String? = nil,
        iconName: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.iconName = iconName
        self.actionTitle = actionTitle
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let title = title {
                HStack {
                    HStack(spacing: 8) {
                        if let iconName = iconName {
                            Image(systemName: iconName)
                                .foregroundColor(ThemeColor.primary)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(title)
                                .font(.headline)
                                .foregroundColor(ThemeColor.neutralDark)
                            if let subtitle = subtitle {
                                Text(subtitle)
                                    .font(.caption)
                                    .foregroundColor(ThemeColor.neutralDark.opacity(0.7))
                            }
                        }
                    }
                    
                    Spacer()
                    
                    if let actionTitle = actionTitle, let action = action {
                        Button(actionTitle, action: action)
                            .font(.caption.weight(.semibold))
                            .foregroundColor(ThemeColor.primary)
                    }
                }
            }
            
            content
        }
        .padding(20)
        .background(ThemeColor.cardBackground(for: .light))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}
```

### 頁面組件

#### HomeView 設計
```swift
struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    
    init(viewModel: HomeViewModel = HomeViewModel()) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 24) {
                    totalAssetsCard
                    monthlyTrendCard
                    quickActionsSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 24)
            }
            .background(ThemeColor.background(for: colorScheme))
            .navigationTitle("首頁")
            .refreshable {
                await viewModel.refresh()
            }
        }
    }
    
    @Environment(\.colorScheme) private var colorScheme
}
```

#### HomeViewModel 設計
```swift
class HomeViewModel: ObservableObject {
    @Published var totalAssets: Decimal = 0
    @Published var monthlyTrend: [MonthlyTrendPoint] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let accountService: AccountServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(accountService: AccountServiceProtocol = AccountService()) {
        self.accountService = accountService
        loadData()
    }
    
    func loadData() {
        isLoading = true
        
        accountService.getTotalAssets()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    self.isLoading = false
                    if case .failure(let error) = completion {
                        self.error = error
                    }
                },
                receiveValue: { totalAssets in
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.totalAssets = totalAssets
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    @MainActor
    func refresh() async {
        loadData()
    }
}
```

## 動畫系統設計

### 第三方動畫庫整合

#### Lottie 整合
```swift
import Lottie

struct LottieView: UIViewRepresentable {
    let animationName: String
    let loopMode: LottieLoopMode
    
    func makeUIView(context: Context) -> LottieAnimationView {
        let animationView = LottieAnimationView(name: animationName)
        animationView.loopMode = loopMode
        animationView.contentMode = .scaleAspectFit
        return animationView
    }
    
    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        uiView.play()
    }
}

// 使用範例
struct CelebrationView: View {
    var body: some View {
        LottieView(animationName: "celebration", loopMode: .playOnce)
            .frame(width: 200, height: 200)
    }
}
```

#### SkeletonView 整合
```swift
struct SkeletonLoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(0..<3) { _ in
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 60)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.clear,
                                        Color.white.opacity(0.6),
                                        Color.clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .offset(x: isAnimating ? 300 : -300)
                    )
                    .clipped()
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}
```

#### 數字計數動畫
```swift
struct CountingLabel: View {
    let value: Decimal
    let formatter: NumberFormatter
    @State private var displayValue: Decimal = 0
    
    var body: some View {
        Text(formatter.string(from: displayValue as NSDecimalNumber) ?? "")
            .font(.system(size: 36, weight: .bold, design: .rounded))
            .onAppear {
                animateValue()
            }
            .onChange(of: value) { newValue in
                animateValue()
            }
    }
    
    private func animateValue() {
        let animation = Animation.easeOut(duration: 1.0)
        withAnimation(animation) {
            displayValue = value
        }
    }
}
```

### SwiftUI 內建動畫

#### 彈性動畫
```swift
extension Animation {
    static let customSpring = Animation.spring(
        response: 0.5,
        dampingFraction: 0.8,
        blendDuration: 0.1
    )
}

// 使用範例
Button("點擊我") {
    // 動作
}
.scaleEffect(isPressed ? 0.95 : 1.0)
.animation(.customSpring, value: isPressed)
```

#### 頁面轉場動畫
```swift
struct CustomTransition: ViewModifier {
    let isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .opacity(isActive ? 1 : 0)
            .scaleEffect(isActive ? 1 : 0.8)
            .animation(.easeInOut(duration: 0.3), value: isActive)
    }
}
```

## 安全性設計

### 生物識別認證
```swift
import LocalAuthentication

class BiometricAuthService: ObservableObject {
    @Published var isAuthenticated = false
    
    func authenticate() async -> Bool {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return false
        }
        
        do {
            let result = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "使用生物識別解鎖 JellySave"
            )
            
            await MainActor.run {
                isAuthenticated = result
            }
            
            return result
        } catch {
            return false
        }
    }
}
```

### Keychain 服務
```swift
import Security

class KeychainService {
    static let shared = KeychainService()
    
    private let service = "com.jellysave.app"
    
    func save(key: String, data: Data) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }
    
    func load(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        return status == errSecSuccess ? result as? Data : nil
    }
}
```

## 效能優化策略

### Core Data 優化
```swift
// NSFetchedResultsController 使用
class AccountsListViewModel: NSObject, ObservableObject {
    @Published var accounts: [Account] = []
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Account> = {
        let request: NSFetchRequest<Account> = Account.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Account.createdAt, ascending: false)]
        request.fetchBatchSize = 20
        
        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: CoreDataStack.shared.context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        controller.delegate = self
        return controller
    }()
    
    func loadAccounts() {
        do {
            try fetchedResultsController.performFetch()
            accounts = fetchedResultsController.fetchedObjects ?? []
        } catch {
            print("Fetch error: \(error)")
        }
    }
}

extension AccountsListViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        accounts = fetchedResultsController.fetchedObjects ?? []
    }
}
```

### 記憶體管理
```swift
// 圖片快取
class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    
    func image(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
}
```

### LazyVStack 使用
```swift
struct AccountsListView: View {
    let accounts: [Account]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(accounts, id: \.id) { account in
                    AccountRowView(account: account)
                        .onAppear {
                            // 預載入邏輯
                        }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
```

## 錯誤處理設計

### 錯誤類型定義
```swift
enum JellySaveError: LocalizedError {
    case coreDataError(Error)
    case validationError(String)
    case networkError(Error)
    case authenticationError
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .coreDataError(let error):
            return "資料儲存錯誤: \(error.localizedDescription)"
        case .validationError(let message):
            return "輸入驗證錯誤: \(message)"
        case .networkError(let error):
            return "網路錯誤: \(error.localizedDescription)"
        case .authenticationError:
            return "身份驗證失敗"
        case .unknownError:
            return "未知錯誤"
        }
    }
}
```

### 錯誤處理 ViewModel
```swift
class ErrorHandlingViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var showError = false
    
    func handleError(_ error: Error) {
        DispatchQueue.main.async {
            if let jellySaveError = error as? JellySaveError {
                self.errorMessage = jellySaveError.errorDescription
            } else {
                self.errorMessage = error.localizedDescription
            }
            self.showError = true
        }
    }
}
```

## 測試策略

### 單元測試設計
```swift
import XCTest
@testable import JellySave

class AccountServiceTests: XCTestCase {
    var accountService: AccountService!
    var mockCoreDataStack: MockCoreDataStack!
    
    override func setUp() {
        super.setUp()
        mockCoreDataStack = MockCoreDataStack()
        accountService = AccountService(coreDataStack: mockCoreDataStack)
    }
    
    func testCreateAccount() {
        // Given
        let name = "測試帳戶"
        let type = AccountType.cash
        let balance = Decimal(1000)
        
        // When
        let expectation = XCTestExpectation(description: "Create account")
        var createdAccount: Account?
        
        accountService.createAccount(name: name, type: type, balance: balance)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { account in
                    createdAccount = account
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertNotNil(createdAccount)
        XCTAssertEqual(createdAccount?.name, name)
        XCTAssertEqual(createdAccount?.type, type.rawValue)
    }
}
```

### UI 測試設計
```swift
import XCTest

class JellySaveUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
    }
    
    func testAddAccountFlow() {
        // 點擊帳戶標籤
        app.tabBars.buttons["帳戶"].tap()
        
        // 點擊新增帳戶按鈕
        app.buttons["新增帳戶"].tap()
        
        // 輸入帳戶資訊
        app.textFields["帳戶名稱"].tap()
        app.textFields["帳戶名稱"].typeText("測試帳戶")
        
        // 選擇帳戶類型
        app.buttons["現金帳戶"].tap()
        
        // 輸入餘額
        app.textFields["初始餘額"].tap()
        app.textFields["初始餘額"].typeText("1000")
        
        // 確認新增
        app.buttons["確認新增"].tap()
        
        // 驗證帳戶已新增
        XCTAssertTrue(app.staticTexts["測試帳戶"].exists)
    }
}
```

## 部署與發布

### 建置配置
```swift
// BuildConfiguration.swift
enum BuildConfiguration {
    case debug
    case release
    
    static var current: BuildConfiguration {
        #if DEBUG
        return .debug
        #else
        return .release
        #endif
    }
    
    var isDebug: Bool {
        return self == .debug
    }
}
```

### 版本管理
```swift
struct AppVersion {
    static let current = "1.0.0"
    static let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    static var fullVersion: String {
        return "\(current) (\(build))"
    }
}
```

這個設計文件提供了 JellySave 重新設計的完整技術架構，涵蓋了從資料模型到 UI 組件的所有層面，確保應用程式能夠滿足所有需求並提供優秀的用戶體驗。