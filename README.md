# JellySave

一個幫助用戶達成儲蓄目標與資產管理的 iOS 應用程式

## 專案簡介

JellySave 是一款現代化的個人財務管理 APP,專注於幫助用戶追蹤資產、設定儲蓄目標,並通過視覺化分析和激勵通知來達成財務目標。

### 核心功能

- 📊 **資產管理**: 管理銀行帳戶、股票帳戶、現金帳戶(新台幣)
- 🎯 **儲蓄目標**: 創建儲蓄計劃,自動計算每月所需存款,達成時顯示慶祝動畫
- 📈 **動態分析**: 總資產概覽和月度趨勢圖表
- 🔔 **激勵通知**: 每日固定時段推送投資或激勵名言
- ☁️ **iCloud 同步**: 多設備數據自動同步

## 技術棧

- **SwiftUI** - 現代聲明式 UI 框架(iOS 16+)
- **MVVM 架構** - Model-View-ViewModel 分層設計
- **Core Data + CloudKit** - 本地數據持久化與 iCloud 同步
- **Swift Charts** - Apple 原生圖表庫
- **UserNotifications** - 本地推播通知
- **Combine** - 響應式編程框架

## 專案結構

```
JellySave/
├── App/
│   ├── JellySaveApp.swift          # App 入口
│   └── AppDelegate.swift           # 通知權限處理
├── Core/
│   ├── Data/
│   │   ├── CoreDataStack.swift     # Core Data 配置
│   │   ├── JellySave.xcdatamodeld  # 數據模型
│   │   └── CloudKitManager.swift   # iCloud 同步管理
│   ├── Models/
│   │   ├── Account.swift           # 帳戶模型
│   │   ├── AccountType.swift       # 帳戶類型枚舉
│   │   ├── SavingGoal.swift        # 儲蓄目標模型
│   │   └── MonthlySnapshot.swift   # 月度快照
│   └── Services/
│       ├── AccountService.swift    # 帳戶業務邏輯
│       ├── SavingGoalService.swift # 儲蓄目標邏輯
│       └── NotificationService.swift # 通知服務
├── Features/
│   ├── Home/
│   │   ├── Views/
│   │   │   ├── HomeView.swift      # 首頁主視圖
│   │   │   ├── TotalAssetsCard.swift # 總資產卡片
│   │   │   └── MonthlyTrendChart.swift # 月度趨勢圖表
│   │   └── ViewModels/
│   │       └── HomeViewModel.swift
│   ├── Accounts/
│   │   ├── Views/
│   │   │   ├── AccountsListView.swift # 帳戶列表
│   │   │   ├── AddAccountView.swift   # 新增帳戶
│   │   │   └── AccountDetailView.swift # 帳戶詳情
│   │   └── ViewModels/
│   │       └── AccountsViewModel.swift
│   ├── SavingGoals/
│   │   ├── Views/
│   │   │   ├── GoalsListView.swift    # 目標列表
│   │   │   ├── CreateGoalView.swift   # 創建目標
│   │   │   ├── GoalDetailView.swift   # 目標詳情
│   │   │   └── CelebrationView.swift  # 慶祝動畫
│   │   └── ViewModels/
│   │       └── GoalsViewModel.swift
│   └── Settings/
│       ├── Views/
│       │   ├── SettingsView.swift     # 設置頁面
│       │   └── NotificationSettingsView.swift
│       └── ViewModels/
│           └── SettingsViewModel.swift
├── Shared/
│   ├── Components/
│   │   ├── CustomButton.swift      # 通用按鈕
│   │   ├── CurrencyTextField.swift # 金額輸入框
│   │   ├── ProgressRing.swift      # 進度環
│   │   ├── TagLabel.swift          # 標籤樣式
│   │   └── EmptyStateView.swift    # 空狀態呈現
│   ├── Extensions/
│   │   ├── Color+Theme.swift       # 主題顏色
│   │   ├── View+Extensions.swift   # View 擴展
│   │   └── NumberFormatter+Currency.swift
│   └── Utilities/
│       ├── Constants.swift         # 常量定義
│       └── InspirationalQuotes.swift # 激勵名言庫
└── Resources/
    ├── Assets.xcassets             # 圖片資源
    ├── Localizable.strings         # 多語言(未來擴展)
    └── Info.plist
```

## 核心數據模型

### Core Data Entities

**Account (帳戶)**
- id: UUID
- name: String (帳戶名稱)
- type: String (銀行/股票/現金)
- balance: Decimal (餘額)
- currency: String (預設 TWD)
- createdAt: Date
- updatedAt: Date

**SavingGoal (儲蓄目標)**
- id: UUID
- title: String (目標名稱)
- targetAmount: Decimal (目標金額)
- currentAmount: Decimal (當前金額)
- deadline: Date (截止日期)
- createdAt: Date
- isCompleted: Bool
- completedAt: Date?
- monthlySavingRequired: Decimal (計算值)

**MonthlySnapshot (月度快照)**
- id: UUID
- month: Date (月份標記)
- totalAssets: Decimal (總資產)
- createdAt: Date

**NotificationSettings (通知設置)**
- id: UUID
- isEnabled: Bool
- notificationTime: Date (每日通知時間)
- selectedQuoteType: String (投資/激勵)

## 關鍵功能實現

### 1. 首頁總資產計算
- 即時計算所有帳戶餘額總和
- 使用 Combine 監聽 Core Data 變更
- 顯示動態數字動畫效果

### 2. 月度趨勢圖表
- 使用 Swift Charts LineChart
- 每月自動創建快照記錄
- 支持最近 6-12 個月數據展示

### 3. 儲蓄目標計算
- 公式: (目標金額 - 當前金額) / 剩餘月份
- 進度百分比視覺化
- 達成時觸發 SwiftUI 動畫

### 4. 本地推播通知
- 使用 UNUserNotificationCenter
- 每日固定時間觸發
- 從名言庫隨機選擇
- 支持用戶自定義時間

### 5. iCloud 同步
- Core Data + NSPersistentCloudKitContainer
- 自動處理衝突解決
- 多設備數據同步

## UI/UX 設計原則

### 設計風格
- **簡約現代**: 大量留白,清晰層次
- **卡片式布局**: 使用圓角卡片分組內容
- **漸層色彩**: 柔和的漸層背景
- **流暢動畫**: 頁面切換和數據更新動畫
- **視覺焦點**: 首頁英雄卡片搭配漸層光暈與圖示貼紙，凸顯資產重點

### 主題色彩
- 主色調: 薄荷綠/天空藍(代表成長和希望)
- 輔助色: 珊瑚粉(強調和成就)
- 中性色: 深灰/淺灰(文字和背景)
- 成功色: 翠綠(目標達成)
- 警示色: 暖黃色(表單提示與待辦提醒)

### 互動細節
- 快捷操作與卡片採用縮放陰影回饋，點擊體驗更輕快
- 列表以 `TagLabel` 顯示類型/進度，搭配時間資訊提升辨識度
- 空狀態使用 `EmptyStateView` 提供友善引導與呼叫行動
- 表單欄位提供即時字數/提示訊息，協助使用者輸入正確資料

### 關鍵頁面佈局
1. **首頁**: 總資產卡片 → 月度趨勢圖 → 快捷操作
2. **帳戶頁**: 分類標籤 → 帳戶列表 → 新增按鈕
3. **目標頁**: 進行中目標 → 已完成目標 → 新增按鈕
4. **設置頁**: 通知設置 → iCloud 狀態 → 關於

## 開發階段

### Phase 1: 核心功能 (MVP)
1. Core Data 模型與基礎 CRUD
2. 帳戶管理功能
3. 首頁總資產顯示
4. 基礎 UI 框架
5. 完成當次迭代後進行 UX/產品審核與 TestFlight Smoke 測試

### Phase 2: 進階功能
1. 儲蓄目標完整流程
2. 月度趨勢圖表
3. 本地推播通知
4. 慶祝動畫
5. 透過 CI（建議 GitHub Actions 或 Xcode Cloud）自動化執行單元/UI 測試並準備 Beta 發佈流程

### Phase 3: 優化與擴展
1. iCloud 同步調試
2. UI/UX 細節打磨
3. 性能優化
4. 單元測試
5. 版本封版前執行完整 CI/CD 管線（自動測試、TestFlight 審核、發布檢查清單）

## 未來擴展方向

- 多幣別支持與匯率轉換
- 收支記錄與分類統計
- 財務報表與分析
- 預算管理功能
- 支持多個儲蓄目標並行
- 社交分享與成就系統
- Widget 小組件支持
- Apple Watch 配套 App

## 技術注意事項

1. **性能優化**: 使用 NSFetchedResultsController 管理大數據集
2. **數據安全**: 敏感數據使用 Keychain 存儲
3. **錯誤處理**: 完善的錯誤處理和用戶提示
4. **測試覆蓋**: ViewModels 單元測試,UI 測試關鍵流程
5. **無障礙支持**: VoiceOver 和動態字體支持
6. **隱私稽核**: 每次主要版本提交前檢查 CloudKit 權限、Keychain 使用與 Crash/分析工具的匿名化設定，並更新安全檢查清單

## 系統需求

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## 授權

Copyright © 2025 JellySave. All rights reserved.
