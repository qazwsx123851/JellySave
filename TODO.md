# JellySave iOS 開發 TODO 清單

## 📋 任務概覽
總計：**60 個任務** (重新排序 + 新增測試任務)
- 每個階段完成前需完成 UX/產品審核與資料安全檢查清單，通過後方可進入下一階段

---

## 🏗️ Phase 1: 專案基礎設置 (3 個任務)

- [x] **project-setup** - 創建 Xcode 專案並配置基本設置 (Bundle ID: com.jellysave.app, iOS 16+ target, SwiftUI)
- [x] **assets-catalog** - 創建 Assets.xcassets - 圖片資源管理
- [x] **info-plist-config** - 配置 Info.plist - 通知權限與基本設置

---

## 🎨 Phase 2: 靜態 UI 設計與主題系統 (12 個任務)

### 主題與設計系統
- [ ] **theme-colors** - 實現 Color+Theme.swift - 主題顏色系統 (薄荷綠/天空藍/珊瑚粉)
- [ ] **constants** - 實現 Constants.swift - 常量定義 (字體、間距、圓角等)
- [ ] **view-extensions** - 實現 View+Extensions.swift - 通用 View 擴展
- [ ] **currency-formatter** - 實現 NumberFormatter+Currency.swift - 台幣格式化

### 基礎 UI 組件
- [ ] **custom-button** - 實現 CustomButton.swift - 通用按鈕組件
- [ ] **currency-textfield** - 實現 CurrencyTextField.swift - 金額輸入框組件
- [ ] **progress-ring** - 實現 ProgressRing.swift - 進度環組件
- [ ] **card-container** - 實現 CardContainer.swift - 卡片容器組件
- [ ] **gradient-background** - 實現 GradientBackground.swift - 漸層背景組件

### 靜態頁面設計
- [ ] **home-view-static** - 實現 HomeView.swift 靜態版本 (無數據綁定)
- [ ] **accounts-list-view-static** - 實現 AccountsListView.swift 靜態版本
- [ ] **goals-list-view-static** - 實現 GoalsListView.swift 靜態版本
- [ ] **settings-view-static** - 實現 SettingsView.swift 靜態版本

---

## 🗄️ Phase 3: 數據層與業務邏輯 (10 個任務)

### 數據模型
- [ ] **data-models** - 創建 Core Data 數據模型 (Account, SavingGoal, MonthlySnapshot, NotificationSettings)
- [ ] **account-type-enum** - 實現 AccountType 枚舉 (銀行/股票/現金)
- [ ] **core-data-stack** - 實現 CoreDataStack.swift - Core Data 配置與 CloudKit 整合

### 業務邏輯服務
- [ ] **account-service** - 實現 AccountService.swift - 帳戶業務邏輯 (CRUD 操作)
- [ ] **saving-goal-service** - 實現 SavingGoalService.swift - 儲蓄目標業務邏輯
- [ ] **notification-service** - 實現 NotificationService.swift - 本地推播通知服務
- [ ] **cloudkit-manager** - 實現 CloudKitManager.swift - iCloud 同步管理

### App 配置
- [ ] **app-entry** - 實現 JellySaveApp.swift - App 入口點
- [ ] **app-delegate** - 實現 AppDelegate.swift - 通知權限處理
- [ ] **inspirational-quotes** - 實現 InspirationalQuotes.swift - 激勵名言庫

---

## 🔗 Phase 4: 數據綁定與動態功能 (15 個任務)

### ViewModels 實現
- [ ] **home-viewmodel** - 實現 HomeViewModel.swift - 首頁業務邏輯
- [ ] **accounts-viewmodel** - 實現 AccountsViewModel.swift - 帳戶管理業務邏輯
- [ ] **goals-viewmodel** - 實現 GoalsViewModel.swift - 儲蓄目標業務邏輯
- [ ] **settings-viewmodel** - 實現 SettingsViewModel.swift - 設置頁面業務邏輯

### 動態頁面實現
- [ ] **home-view-dynamic** - 將 HomeView 升級為動態版本 (數據綁定)
- [ ] **total-assets-card** - 實現 TotalAssetsCard.swift - 總資產卡片組件
- [ ] **monthly-trend-chart** - 實現 MonthlyTrendChart.swift - 月度趨勢圖表 (Swift Charts)
- [ ] **accounts-list-view-dynamic** - 將 AccountsListView 升級為動態版本
- [ ] **add-account-view** - 實現 AddAccountView.swift - 新增帳戶頁面
- [ ] **account-detail-view** - 實現 AccountDetailView.swift - 帳戶詳情頁面
- [ ] **goals-list-view-dynamic** - 將 GoalsListView 升級為動態版本
- [ ] **create-goal-view** - 實現 CreateGoalView.swift - 創建儲蓄目標頁面
- [ ] **goal-detail-view** - 實現 GoalDetailView.swift - 儲蓄目標詳情頁面
- [ ] **celebration-view** - 實現 CelebrationView.swift - 目標達成慶祝動畫
- [ ] **settings-view-dynamic** - 將 SettingsView 升級為動態版本
- [ ] **notification-settings-view** - 實現 NotificationSettingsView.swift - 通知設置頁面

---

## 🔧 Phase 5: 核心功能實現 (8 個任務)

- [ ] **home-total-assets-calculation** - 實現首頁總資產即時計算功能 (Combine 監聽 Core Data)
- [ ] **home-dynamic-animation** - 實現總資產數字動畫效果
- [ ] **monthly-snapshot-automation** - 實現每月自動創建快照記錄功能
- [ ] **saving-goal-calculation** - 實現儲蓄目標計算公式 ((目標金額-當前金額)/剩餘月份)
- [ ] **saving-goal-progress-visualization** - 實現儲蓄目標進度百分比視覺化
- [ ] **saving-goal-celebration-animation** - 實現目標達成時的 SwiftUI 慶祝動畫
- [ ] **notification-scheduling** - 實現每日固定時間推播通知功能
- [ ] **notification-quote-selection** - 實現從名言庫隨機選擇推播內容
- [ ] **notification-custom-time** - 實現用戶自定義推播時間功能

---

## ☁️ Phase 6: iCloud 同步 (2 個任務)

- [ ] **icloud-sync-setup** - 配置 NSPersistentCloudKitContainer 實現 iCloud 同步
- [ ] **icloud-conflict-resolution** - 實現 iCloud 數據衝突解決機制

---

## 🎨 Phase 7: UI/UX 優化 (3 個任務)

- [ ] **ui-card-layout** - 實現卡片式布局設計 (圓角卡片分組內容)
- [ ] **ui-gradient-backgrounds** - 實現漸層背景設計
- [ ] **ui-smooth-animations** - 實現頁面切換和數據更新動畫

---

## 🚀 Phase 8: 性能優化與安全性 (3 個任務)

- [ ] **performance-optimization** - 使用 NSFetchedResultsController 優化大數據集管理
- [ ] **keychain-security** - 實現敏感數據 Keychain 存儲
- [ ] **error-handling** - 實現完善的錯誤處理和用戶提示

---

## 🧪 Phase 9: 自動測試實現 (10 個任務)

### 單元測試
- [ ] **unit-tests-account-service** - AccountService 單元測試
- [ ] **unit-tests-saving-goal-service** - SavingGoalService 單元測試
- [ ] **unit-tests-notification-service** - NotificationService 單元測試
- [ ] **unit-tests-home-viewmodel** - HomeViewModel 單元測試
- [ ] **unit-tests-accounts-viewmodel** - AccountsViewModel 單元測試
- [ ] **unit-tests-goals-viewmodel** - GoalsViewModel 單元測試

### UI 測試
- [ ] **ui-tests-account-flow** - 帳戶管理流程 UI 測試 (新增、編輯、刪除)
- [ ] **ui-tests-saving-goal-flow** - 儲蓄目標流程 UI 測試 (創建、追蹤、完成)
- [ ] **ui-tests-navigation** - 頁面導航 UI 測試
- [ ] **ui-tests-notification-settings** - 通知設置 UI 測試

### 整合測試
- [ ] **integration-tests-data-sync** - 數據同步整合測試
- [ ] **integration-tests-icloud** - iCloud 同步整合測試

### 無障礙測試
- [ ] **accessibility-tests** - VoiceOver 和動態字體支持測試

---

## 📊 開發階段說明

### Phase 1-2: UI 優先開發
**目標**: 完成所有靜態 UI 設計，確保視覺效果符合設計要求
**時間**: 2-3 週
**重點**: 主題系統、組件庫、靜態頁面設計

### Phase 3-4: 功能實現
**目標**: 實現數據層和動態功能
**時間**: 3-4 週  
**重點**: Core Data、業務邏輯、數據綁定

### Phase 5-7: 進階功能
**目標**: 完成核心功能和優化
**時間**: 2-3 週
**重點**: 圖表、動畫、iCloud 同步

### Phase 8-9: 測試與優化
**目標**: 確保品質和穩定性
**時間**: 2-3 週
**重點**: 性能優化、自動測試、無障礙支持

---

## 🧪 自動測試策略

### 測試金字塔
```
        E2E Tests (2-3 個)
       /                \
   UI Tests (4-5 個)    Integration Tests (2-3 個)
  /                    \
Unit Tests (6-8 個)    Accessibility Tests (1 個)
```

### 測試覆蓋率目標
- **單元測試**: 80%+ 業務邏輯覆蓋率
- **UI 測試**: 100% 關鍵用戶流程覆蓋
- **整合測試**: 100% 外部依賴覆蓋

### 持續整合 (CI/CD)
- 每次 commit 觸發單元測試
- 每次 PR 觸發完整測試套件
- 每日自動執行性能測試
- 每週自動執行無障礙測試

---

## 📝 使用說明

- 使用 `[x]` 標記已完成的任務
- 使用 `[進行中]` 標記正在進行的任務
- 使用 `[待審核]` 標記需要審核的任務
- 建議嚴格按照階段順序進行開發
- UI 設計完成後需要設計審核才能進入下一階段

---

**最後更新**: 2025年1月
**總任務數**: 60個 (原50個 + 新增10個測試任務)
**預估開發時間**: 10-13週 (全職開發)
**測試時間**: 2-3週 (包含在總時間內)

---

## 📊 開發階段建議

### Phase 1: 核心功能 (MVP)
1. 專案基礎設置
2. 數據模型與服務層
3. 基礎 UI 組件
4. 帳戶管理功能
5. 首頁總資產顯示

### Phase 2: 進階功能
1. 儲蓄目標完整流程
2. 月度趨勢圖表
3. 本地推播通知
4. 慶祝動畫效果

### Phase 3: 優化與擴展
1. iCloud 同步功能
2. UI/UX 細節打磨
3. 性能優化
4. 測試與無障礙支持

---

## 📝 使用說明

- 使用 `[x]` 標記已完成的任務
- 使用 `[ ]` 標記待完成的任務
- 可以添加 `[進行中]` 標記正在進行的任務
- 建議按階段順序進行開發

---

**最後更新**: 2025年1月
**總任務數**: 50個
**預估開發時間**: 8-12週 (全職開發)

---

## 🗒️ 開發日誌

- 2025-10-29: 建立 SwiftUI App 入口 (`JellySave/App/JellySaveApp.swift`) 與通知委派 (`JellySave/App/AppDelegate.swift`)。
- 2025-10-29: 新增專案資源 (`JellySave/Resources/Info.plist`, `Assets.xcassets`, `Preview Content`)。
- 2025-10-29: 建立 `JellySave.xcodeproj` 與共享 scheme，完成基本 build 設定。
