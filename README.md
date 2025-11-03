# JellySave

一款專為台灣用戶設計的離線優先個人財務管理 iOS 應用程式

## 專案簡介

JellySave 是一款現代化的個人財務管理應用程式，專注於本地資產追蹤、儲蓄目標管理和財務習慣養成。採用規格驅動開發模式，提供直觀且具激勵性的離線財務管理體驗。

### 核心功能

- 💰 **多元資產管理**: 支援現金、股票、外幣、保險、加密貨幣五種帳戶類型
- 🎯 **智能儲蓄目標**: 自動計算每月所需儲蓄金額，視覺化進度追蹤
- 📈 **趨勢分析**: 最近 6 個月資產趨勢圖表，支援動態數字動畫
- 🔔 **激勵通知**: 每日定時推送投資建議和儲蓄激勵名言
- 🔒 **隱私安全**: 完全本地儲存，支援 Face ID/Touch ID 解鎖
- 🎨 **現代設計**: 支援深淺色主題，豐富動畫效果和無障礙功能

## 技術架構

- **SwiftUI + MVVM** - 現代聲明式 UI 框架 (iOS 16+)
- **Core Data** - 本地資料持久化，完全離線運作
- **Combine** - 響應式編程和資料綁定
- **Swift Charts** - 原生圖表和趨勢分析
- **LocalAuthentication** - 生物識別安全認證
- **Lottie + SkeletonView** - 豐富動畫效果和載入狀態

## 專案結構

```
JellySave/
├── App/
│   ├── JellySaveApp.swift          # 應用程式入口點
│   └── AppDelegate.swift           # 通知權限和生命週期管理
├── Core/
│   ├── Data/
│   │   ├── CoreDataStack.swift     # Core Data 配置和管理
│   │   └── JellySave.xcdatamodeld  # 資料模型定義
│   └── Services/
│       ├── AccountService.swift    # 帳戶 CRUD 業務邏輯
│       ├── SavingGoalService.swift # 儲蓄目標管理服務
│       ├── NotificationService.swift # 本地通知服務
│       ├── ThemeService.swift      # 主題切換服務
│       ├── BiometricAuthService.swift # 生物識別認證
│       └── KeychainService.swift   # 安全資料儲存
├── Features/
│   ├── Home/
│   │   ├── Views/
│   │   │   ├── HomeView.swift      # 首頁主視圖
│   │   │   ├── TotalAssetsCard.swift # 總資產英雄卡片
│   │   │   └── MonthlyTrendChart.swift # Swift Charts 趨勢圖
│   │   └── ViewModels/
│   │       └── HomeViewModel.swift # 首頁業務邏輯
│   ├── Accounts/
│   │   ├── Views/
│   │   │   ├── AccountsListView.swift # 帳戶分組列表
│   │   │   ├── AddAccountView.swift   # 新增帳戶表單
│   │   │   └── AccountDetailView.swift # 帳戶詳情和編輯
│   │   └── ViewModels/
│   │       └── AccountsViewModel.swift # 帳戶管理邏輯
│   ├── SavingGoals/
│   │   ├── Views/
│   │   │   ├── GoalsListView.swift    # 目標列表和進度
│   │   │   ├── CreateGoalView.swift   # 創建儲蓄目標
│   │   │   ├── GoalDetailView.swift   # 目標詳情和更新
│   │   │   └── CelebrationView.swift  # Lottie 慶祝動畫
│   │   └── ViewModels/
│   │       └── GoalsViewModel.swift   # 目標管理邏輯
│   └── Settings/
│       ├── Views/
│       │   ├── SettingsView.swift     # 主設定頁面
│       │   └── NotificationSettingsView.swift # 通知設定
│       └── ViewModels/
│           └── SettingsViewModel.swift # 設定管理邏輯
├── Shared/
│   ├── Components/
│   │   ├── CustomButton.swift      # 可重用按鈕組件
│   │   ├── ProgressRing.swift      # 圓形進度指示器
│   │   ├── CardContainer.swift     # 通用卡片容器
│   │   ├── CurrencyTextField.swift # 新台幣輸入欄位
│   │   ├── CountingLabel.swift     # 數字計數動畫
│   │   ├── SkeletonLoadingView.swift # 骨架屏載入
│   │   └── EmptyStateView.swift    # 空狀態引導
│   ├── Extensions/
│   │   ├── Color+Theme.swift       # 主題色彩系統
│   │   ├── View+Extensions.swift   # SwiftUI 擴展
│   │   └── NumberFormatter+Currency.swift # 貨幣格式化
│   └── Utilities/
│       ├── Constants.swift         # 設計常數定義
│       ├── InspirationalQuotes.swift # 激勵名言資料庫
│       └── JellySaveError.swift    # 統一錯誤處理
└── Resources/
    ├── Assets.xcassets             # 圖片和色彩資源
    ├── Lottie/                     # 動畫資源檔案
    └── Info.plist                  # 應用程式配置
```

## 開發指南

- 主題與設計系統：`Shared/Extensions/Color+Theme.swift`、`Shared/Utilities/Constants.swift` 與 `ThemeService` 定義顏色、字體與主題切換邏輯，詳細說明見 `docs/DesignSystem.md`。
- 共用元件庫：`Shared/Components/` 內提供按鈕、卡片、指示器、輸入欄位與空狀態等 SwiftUI 元件。
- 動畫與骨架：`Shared/Components/Animations/` 與 `Shared/Components/Loading/` 封裝 Lottie 與 SkeletonView，使用方式參考 `docs/Animations.md`。

## 資料模型設計

### 支援的帳戶類型

```swift
enum AccountType: String, CaseIterable {
    case cash = "現金帳戶"           // dollarsign.circle
    case stock = "股票帳戶"          // chart.line.uptrend.xyaxis
    case foreignCurrency = "外幣帳戶"  // globe
    case insurance = "保險"          // shield.checkered
    case cryptocurrency = "加密貨幣"   // bitcoinsign.circle
}
```

### Core Data 實體

**Account (帳戶)**
- id: UUID (主鍵)
- name: String (帳戶名稱，最多 50 字元)
- type: String (帳戶類型，限定五種)
- balance: NSDecimalNumber (餘額，支援高精度)
- currency: String (固定 "TWD")
- createdAt: Date (建立時間)
- updatedAt: Date (最後更新時間)
- isActive: Bool (是否啟用)
- notes: String? (備註，可選)

**SavingGoal (儲蓄目標)**
- id: UUID (主鍵)
- title: String (目標名稱)
- targetAmount: NSDecimalNumber (目標金額)
- currentAmount: NSDecimalNumber (當前金額)
- deadline: Date (截止日期)
- createdAt: Date (建立時間)
- updatedAt: Date (最後更新時間)
- isCompleted: Bool (是否完成)
- completedAt: Date? (完成時間)
- category: String? (目標分類)
- notes: String? (備註)

**AssetSnapshot (資產快照)**
- id: UUID (主鍵)
- date: Date (快照日期)
- totalAssets: NSDecimalNumber (總資產)
- createdAt: Date (建立時間)

**NotificationSettings (通知設定)**
- id: UUID (主鍵)
- isEnabled: Bool (是否啟用通知)
- notificationTime: Date (每日通知時間)
- quoteType: String (名言類型：investment/motivation)
- updatedAt: Date (最後更新時間)

## 核心功能實作

### 1. 資產管理系統
- **即時總資產計算**: 使用 Combine 監聽 Core Data 變更
- **多幣別支援**: 主要以新台幣為基準，支援外幣帳戶
- **動態數字動畫**: CountingLabel 組件提供流暢的數字滾動效果
- **分類管理**: 五種帳戶類型的視覺化分組和圖示識別

### 2. 儲蓄目標追蹤
- **智能計算**: 自動計算每月所需儲蓄金額
  ```swift
  monthlySavingRequired = (targetAmount - currentAmount) / remainingMonths
  ```
- **視覺化進度**: ProgressRing 組件顯示完成百分比
- **達成慶祝**: Lottie 動畫慶祝目標完成
- **進度追蹤**: 歷史記錄和趨勢分析

### 3. 趨勢分析圖表
- **Swift Charts 整合**: 原生圖表庫提供流暢效能
- **月度快照**: 自動記錄每月資產總額
- **動態載入**: 漸進式動畫載入資料點
- **互動式圖表**: 支援點擊查看詳細資訊

### 4. 激勵通知系統
- **本地通知**: UNUserNotificationCenter 實作
- **智能排程**: 用戶自訂時間的每日通知
- **名言資料庫**: 投資建議和儲蓄激勵兩大類別
- **隨機選擇**: 演算法確保內容多樣性

### 5. 安全性保護
- **生物識別**: Face ID/Touch ID 應用程式解鎖
- **Keychain 儲存**: 敏感資料安全加密儲存
- **隱私保護**: 應用程式快照隱藏敏感資訊
- **本地優先**: 完全離線運作，無資料外洩風險

## UI/UX 設計系統

### 設計理念
- **簡約現代**: 清晰的視覺層次和溫暖的色彩搭配
- **可讀性優先**: 確保在任何光線條件下都能清晰閱讀
- **一致性體驗**: 深淺色模式間保持相同的視覺層次
- **無障礙友善**: 符合 WCAG 2.1 AA 標準
- **情感化設計**: 透過色彩和動畫傳達正向的財務管理體驗

### 色彩系統

#### 主要色彩
```swift
// 品牌色彩
static let primary = Color("BrandPrimary")      // 薄荷綠 #4ECDC4
static let secondary = Color(red: 0.36, green: 0.62, blue: 0.98)  // 天空藍
static let accent = Color("BrandAccent")        // 珊瑚粉 #FF6B6B

// 功能色彩
static let success = Color("Success")           // 翠綠 #2ECC71
static let warning = Color(red: 0.96, green: 0.73, blue: 0.31)  // 暖黃
static let error = Color(red: 0.91, green: 0.30, blue: 0.24)    // 溫和紅
```

#### 深色模式適配
- 所有文字與背景對比度 ≥ 4.5:1 (WCAG AA 標準)
- 品牌色在深色背景上提高亮度確保可讀性
- 使用淺色邊框和輕微陰影營造層次感

### 字體系統
```swift
static let hero = Font.system(size: 36, weight: .bold, design: .rounded)    // 總資產
static let title = Font.system(size: 24, weight: .semibold)                 // 頁面標題
static let subtitle = Font.system(size: 20, weight: .medium)                // 區塊標題
static let body = Font.system(size: 16, weight: .regular)                   // 一般內容
static let caption = Font.system(size: 14, weight: .regular)                // 輔助資訊
```

### 動畫規範
- **微互動**: 0.15s - 按鈕回饋
- **標準動畫**: 0.3s - 頁面切換
- **複雜動畫**: 0.5s - 數字計數
- **慶祝動畫**: 2.0s - 目標達成

### 頁面架構
1. **首頁**: 英雄卡片 → Swift Charts 趨勢圖 → 快速操作區域
2. **帳戶頁面**: 總覽卡片 → 分類帳戶列表 → 新增帳戶按鈕
3. **儲蓄目標**: 進行中目標 → 已完成目標 → 新增目標按鈕
4. **設定頁面**: 主題切換 → 通知設定 → 安全設定 → 資料管理

## 開發階段

### 里程碑 1: UI 設計系統 (2-3 週)
- 建立專案基礎架構和設計系統
- 實作所有共用 UI 組件
- 完成靜態 UI 頁面（使用假資料）
- 整合第三方動畫庫 (Lottie, SkeletonView)

### 里程碑 2: 資料層和服務 (1-2 週)
- 建立 Core Data 模型和實體
- 實作服務層架構 (AccountService, SavingGoalService)
- 建立安全性服務 (BiometricAuth, Keychain)
- 實作通知和主題服務

### 里程碑 3: 動態功能實作 (2-3 週)
- 建立所有 ViewModel 和業務邏輯
- 將靜態 UI 升級為動態版本
- 實作資料綁定和狀態管理
- 整合 Swift Charts 和動畫效果

### 里程碑 4: 進階功能和安全 (1-2 週)
- 實作慶祝動畫和激勵名言系統
- 完成生物識別認證和應用程式鎖定
- 實作資料管理和備份功能
- 安全性測試和隱私保護

### 里程碑 5: 優化和發布 (2-3 週)
- 效能優化和記憶體管理
- 完整的單元測試和 UI 測試
- 無障礙功能實作和驗證
- 發布準備和品質保證檢查

## 規格驅動開發

本專案採用嚴格的規格驅動開發模式，確保所有實作都符合預定的需求和設計標準。

### 規格文件
- **需求文件**: `.kiro/specs/jellysave-redesign/requirements.md` - 12 個核心需求和驗收標準
- **設計文件**: `.kiro/specs/jellysave-redesign/design.md` - 技術架構和實作策略
- **任務清單**: `.kiro/specs/jellysave-redesign/tasks.md` - 52 個具體開發任務
- **專案規則**: `JellySave-Project-Rules.md` - 完整的開發規範和品質標準

### 開發規範
- 所有功能必須對應明確的需求編號
- UI 實作必須嚴格遵循設計系統
- 程式碼必須符合 MVVM 架構模式
- 效能標準：啟動 < 2秒，動畫 60fps，記憶體 < 100MB

## 品質保證

### 效能標準
- 應用程式啟動時間 < 2 秒
- 所有動畫保持 60fps 流暢度
- 記憶體使用量 < 100MB
- 頁面切換時間 < 300 毫秒

### 無障礙功能
- 色彩對比度符合 WCAG 2.1 AA 標準 (≥ 4.5:1)
- 所有互動元素提供適當的無障礙標籤
- 支援 VoiceOver 螢幕閱讀器
- 支援動態字體大小調整

### 安全性
- 生物識別認證 (Face ID/Touch ID)
- Keychain 安全儲存敏感資料
- 應用程式背景模式隱私保護
- 完全本地儲存，無資料外洩風險

## 測試策略

### 單元測試
- Service 層業務邏輯測試覆蓋率 > 80%
- ViewModel 狀態管理和資料處理測試
- Core Data 操作和錯誤處理測試

### UI 測試
- 主要用戶流程自動化測試
- 帳戶管理操作流程驗證
- 儲蓄目標建立和更新流程測試
- 主題切換和設定功能測試

## 系統需求

- **iOS**: 16.0+
- **Xcode**: 15.0+
- **Swift**: 5.9+
- **裝置**: iPhone SE (最小支援) 到 iPhone 15 Pro Max

## 未來擴展

- 多幣別匯率轉換功能
- 收支記錄和分類統計
- 進階財務報表和分析
- 預算管理和支出追蹤
- Widget 小組件支援
- Apple Watch 配套應用程式

## 授權

Copyright © 2025 JellySave. All rights reserved.

---

**注意**: 本專案採用規格驅動開發模式，所有開發工作都必須嚴格遵循規格文件和專案規則。任何變更都需要先更新相關規格文件並獲得批准。
