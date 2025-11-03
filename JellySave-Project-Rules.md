# JellySave Project Rules

## 專案概覽

JellySave 是一款專為台灣用戶設計的離線優先個人財務管理 iOS 應用程式，採用規格驅動開發模式。本文件定義了開發過程中必須遵循的規則和標準。

## 規格驅動開發原則

### 📋 核心原則
本專案嚴格遵循規格驅動開發 (Specification-Driven Development) 方法論，確保所有開發活動都基於明確定義的規格文件。

#### 🎯 規格文件體系
- **需求文件** (`requirements.md`): 12個EARS格式需求和驗收標準
- **設計文件** (`design.md`): 完整技術架構和實作策略  
- **任務清單** (`tasks.md`): 52個具體開發任務，分13個階段
- **專案規則** (`JellySave-Project-Rules.md`): 開發規範和品質標準

#### ⚡ 強制性規範
1. **需求追溯性**: 每個功能實作必須對應明確的需求編號
2. **設計一致性**: 所有技術決策必須符合設計文件規範
3. **任務導向**: 開發工作必須按照任務清單的順序執行
4. **規則遵循**: 所有程式碼必須符合本文件的品質標準

#### 🚫 嚴格禁止
- **需求外開發**: 禁止實作未在需求文件中定義的功能
- **架構偏離**: 禁止使用設計文件未批准的技術或架構
- **規範違反**: 禁止違反本文件定義的任何開發規範
- **文件不同步**: 禁止在未更新規格文件的情況下進行重大變更

#### 📝 變更管理流程
1. **提出變更**: 任何功能或技術變更必須先提出正式申請
2. **更新規格**: 變更獲批後必須先更新相關規格文件
3. **審核批准**: 規格文件變更必須經過審核和批准
4. **實作執行**: 只有在規格文件更新完成後才能開始實作

#### 🔍 品質保證檢查點
- **開發前**: 確認任務對應的需求和設計規範
- **開發中**: 定期檢查實作是否符合規格要求
- **開發後**: 驗證功能是否滿足驗收標準
- **發布前**: 全面檢查所有功能的規格符合性

## 平台限制

### 🎯 目標平台
- **僅限 iPhone**: 此專案只開發 iPhone 應用程式
- **iOS 版本**: 最低支援 iOS 16.0+
- **裝置範圍**: iPhone SE (最小) 到 iPhone 15 Pro Max
- **禁止**: 不得開發 iPad、macOS、Android、Web 或其他平台版本

### 📱 技術限制
- 使用 SwiftUI + MVVM 架構模式
- 採用 Core Data 進行本地資料持久化
- 完全離線運作，不得使用網路 API
- 必須支援 Face ID/Touch ID 生物識別認證

## 架構規範

### 🏗️ 專案結構
```
JellySave/
├── App/                    # 應用程式入口點
├── Core/                   # 核心服務和資料層
│   ├── Data/              # Core Data 相關
│   └── Services/          # 業務邏輯服務
├── Features/              # 功能模組
│   ├── Home/             # 首頁功能
│   ├── Accounts/         # 帳戶管理
│   ├── SavingGoals/      # 儲蓄目標
│   └── Settings/         # 設定頁面
├── Shared/               # 共用組件和工具
│   ├── Components/       # UI 組件
│   ├── Extensions/       # 擴展方法
│   └── Utilities/        # 工具類別
└── Resources/            # 資源檔案
```

### 🎨 MVVM 架構要求
- **View**: 純 UI 呈現，無業務邏輯
- **ViewModel**: 繼承 `ObservableObject`，使用 `@Published` 屬性
- **Model**: 純資料結構，Core Data 實體
- **Service**: Protocol-based 設計，處理業務邏輯

## 程式碼規範

### 📝 命名規則
- **檔案名稱**: PascalCase (例: `HomeView.swift`)
- **類別/結構**: PascalCase (例: `AccountService`)
- **變數/方法**: camelCase (例: `totalAssets`)
- **常數**: UPPER_SNAKE_CASE (例: `MAX_ACCOUNT_NAME_LENGTH`)
- **協議**: 以 `Protocol` 結尾 (例: `AccountServiceProtocol`)

### 🔧 程式碼品質
- 所有 Service 必須基於 Protocol 設計
- 使用 Combine 處理非同步操作
- 錯誤處理必須使用統一的 `JellySaveError` 類型
- 所有 UI 組件必須支援深淺色主題
- 必須提供適當的無障礙標籤

### 📊 資料管理
- 僅使用 Core Data 進行資料持久化
- 敏感資料必須使用 iOS Keychain 儲存
- 所有金額使用 `NSDecimalNumber` 確保精度
- 貨幣格式固定為新台幣 (TWD)

## UI/UX 設計規範

### 🎨 設計系統
- **主色調**: 薄荷綠 `#4ECDC4`
- **次要色調**: 天空藍 `#5DADE2`
- **強調色**: 珊瑚粉 `#FF6B6B`
- **字體**: SF Pro 系統字體，數字使用 SF Pro Rounded
- **圓角**: 小(8pt)、中(12pt)、大(20pt)
- **間距**: 4pt, 8pt, 16pt, 24pt, 32pt, 48pt

### 🌓 主題支援
- 必須同時支援淺色和深色主題
- 色彩對比度必須符合 WCAG 2.1 AA 標準 (≥ 4.5:1)
- 主題切換必須在 0.3 秒內完成，無閃爍
- 所有 UI 組件必須在兩種主題下正常運作

### 📱 響應式設計
- 支援 iPhone SE 到 iPhone 15 Pro Max 所有尺寸
- 完整支援 iOS Dynamic Type
- 最小觸控區域 44x44pt
- 頁面邊距統一為 16pt

## 功能需求

### 💰 核心功能
1. **多元資產管理**: 支援現金、股票、外幣、保險、加密貨幣五種帳戶
2. **儲蓄目標追蹤**: 自動計算每月所需儲蓄金額，視覺化進度
3. **趨勢分析**: 最近 6 個月資產趨勢圖表 (Swift Charts)
   - 月度資產變化線圖
   - 帳戶類型分布圓餅圖  
   - 互動式圖表，支援點擊查看詳情
   - 漸進式動畫載入效果
4. **激勵通知**: 每日本地通知，投資建議和儲蓄激勵
5. **安全認證**: Face ID/Touch ID 應用程式解鎖

### 🔒 安全要求
- 完全本地儲存，禁止任何網路傳輸
- 使用 iOS Keychain 儲存敏感資料
- 支援生物識別認證
- 應用程式背景模式隱私保護
- 提供完整的本地資料清除功能

## 效能標準

### ⚡ 效能要求
- **啟動時間**: < 2 秒
- **動畫流暢度**: 60fps (iPhone 12+)
- **記憶體使用**: < 100MB
- **頁面切換**: < 300 毫秒
- **資料查詢**: 使用 NSFetchedResultsController 優化

### 🎬 動畫規範
- **微互動**: 0.15s (按鈕回饋)
- **標準動畫**: 0.3s (頁面切換)
- **複雜動畫**: 0.5s (數字計數)
- **慶祝動畫**: 2.0s (目標達成)
- 使用 Spring 動畫提供彈性回饋

## 第三方庫使用

### 📚 允許的第三方庫

#### 🎬 動畫相關
- **Lottie-iOS**: 用於慶祝動畫和載入動畫
- **SkeletonView**: 實現骨架屏載入狀態
- **SwiftUI 內建動畫**: 用於所有其他動畫效果
  - Spring 動畫：按鈕和卡片互動回饋
  - 數字計數動畫：金額變化的滾動效果
  - 彈性動畫：頁面轉場和微互動
  - 不需要額外的 CountUp、Spring、Advance、Pop 等第三方庫

#### 🎯 動畫技術決策說明
基於 iOS 16+ 目標版本和簡化依賴的原則，本專案採用以下動畫策略：

1. **SwiftUI 內建動畫優先**: 利用 iOS 16+ 的強大動畫能力
2. **最小化第三方依賴**: 只保留必要的 Lottie 和 SkeletonView
3. **效能最佳化**: SwiftUI 原生動畫提供最佳效能
4. **維護簡化**: 減少第三方庫的版本管理和相容性問題

**具體實作方案**:
- 數字滾動動畫：使用 SwiftUI `withAnimation` + 自訂 `CountingLabel`
- 彈性互動：使用 `Animation.spring()` 
- 頁面轉場：使用 SwiftUI `transition` 和 `matchedGeometryEffect`
- 微互動：使用 `scaleEffect` + `Animation.easeInOut`

#### 📊 圖表相關
- **Swift Charts**: Apple 官方原生圖表庫 (iOS 16+)
  - 完美支援 SwiftUI 和深淺色主題
  - 用於月度資產趨勢圖、帳戶分布圓餅圖
  - 效能優異，符合離線優先原則
  - 內建無障礙功能支援

### 🚫 禁止的依賴
- 任何網路請求庫 (Alamofire, URLSession 等)
- 雲端服務 SDK (Firebase, AWS 等)
- 跨平台框架 (React Native, Flutter 等)
- 第三方分析工具 (Google Analytics 等)
- **額外動畫庫**: CountUp、Spring、Advance、Pop 等 (使用 SwiftUI 內建動畫替代)

## 測試要求

### 🧪 測試標準
- Service 層單元測試覆蓋率 > 80%
- 所有 ViewModel 必須有對應測試
- 主要用戶流程必須有 UI 測試
- Core Data 操作必須有測試覆蓋

### 🔍 測試重點
- 帳戶 CRUD 操作
- 儲蓄目標計算邏輯
- 主題切換功能
- 生物識別認證流程
- 資料持久化和恢復

## 無障礙功能

### ♿ 無障礙要求
- 所有互動元素必須提供無障礙標籤
- 支援 VoiceOver 螢幕閱讀器
- 色彩對比度符合 WCAG 2.1 AA 標準
- 支援動態字體大小調整
- 提供適當的語義化 UI 結構

## 資料模型規範

### 🗄️ Core Data 實體
1. **Account**: 帳戶資訊 (id, name, type, balance, currency)
2. **SavingGoal**: 儲蓄目標 (id, title, targetAmount, currentAmount, deadline)
3. **AssetSnapshot**: 資產快照 (id, date, totalAssets)
4. **NotificationSettings**: 通知設定 (id, isEnabled, notificationTime, quoteType)

### 💱 資料格式
- **金額**: 使用 `NSDecimalNumber` 確保精度
- **貨幣**: 固定為 "TWD" (新台幣)
- **日期**: 使用 `Date` 類型，UTC 時區
- **帳戶類型**: 限定五種 (現金、股票、外幣、保險、加密貨幣)

## 版本控制

### 📋 提交規範
- 使用語義化提交訊息 (feat, fix, docs, style, refactor, test)
- **強制要求**: 每個提交必須包含對應的需求編號 (例: `feat: 實作總資產顯示功能 [需求1.1]`)
- **規格追溯**: 提交訊息必須說明符合哪個設計規範或任務項目
- 提交前必須通過所有測試和 SwiftLint 檢查
- UI 變更必須包含深淺色主題的截圖
- **禁止提交**: 任何未在規格文件中定義的功能或變更

### 🏷️ 版本管理
- 遵循語義化版本 (Semantic Versioning)
- 主版本號變更需要完整的回歸測試
- 每個版本必須更新 CHANGELOG.md

## 發布準備

### 📦 建置要求
- Release 建置必須啟用程式碼最佳化
- 移除所有 Debug 相關程式碼
- 確保所有資源檔案正確包含
- 驗證應用程式圖示和啟動畫面

### 🔐 安全檢查
- 確認沒有硬編碼的敏感資訊
- 驗證 Keychain 存取權限設定
- 檢查應用程式權限請求 (通知、生物識別)
- 確認隱私政策和使用條款

## 開發工具

### 🛠️ 必要工具
- **Xcode**: 15.0+
- **Swift**: 5.9+
- **iOS Simulator**: 測試不同裝置尺寸
- **Accessibility Inspector**: 無障礙功能測試

### 📊 品質工具
- SwiftLint: 程式碼風格檢查
- XCTest: 單元測試和 UI 測試
- Instruments: 效能分析和記憶體檢測

## 注意事項

### ⚠️ 重要提醒
1. **絕對禁止**: 任何形式的網路連線或資料外傳
2. **隱私優先**: 所有資料必須保留在用戶裝置上
3. **iPhone 專屬**: 不得考慮其他平台的相容性
4. **規格驅動**: 所有開發必須嚴格遵循規格文件體系
5. **品質保證**: 效能和無障礙功能不可妥協

### 📋 規格驅動開發檢查清單
開發過程中必須遵循以下檢查清單：

#### 開始開發前
- [ ] 確認任務在 `tasks.md` 中有明確定義
- [ ] 檢查對應的需求編號和驗收標準
- [ ] 查閱設計文件中的相關技術規範
- [ ] 確認不違反本文件的任何規則

#### 開發過程中
- [ ] 實作功能嚴格按照設計文件規範
- [ ] 使用指定的技術棧和架構模式
- [ ] 遵循程式碼品質和命名規範
- [ ] 確保 UI 符合設計系統標準

#### 完成開發後
- [ ] 驗證功能滿足所有驗收標準
- [ ] 確認效能符合規定指標
- [ ] 測試無障礙功能正常運作
- [ ] 更新任務狀態為完成

#### 提交程式碼前
- [ ] 通過所有單元測試和 UI 測試
- [ ] 符合 SwiftLint 程式碼風格檢查
- [ ] 提交訊息包含對應的需求編號
- [ ] 深淺色主題都正常運作

### 🎯 開發重點
- 優先實作核心功能，再添加進階特性
- 重視用戶體驗和視覺設計品質
- 確保應用程式在所有支援的 iPhone 機型上運行流暢
- 定期進行效能測試和記憶體洩漏檢查

---

**最後更新**: 2025年1月
**版本**: 1.0.0
**適用專案**: JellySave iOS App

此規則文件是 JellySave 專案開發的最高指導原則，所有開發活動都必須嚴格遵循。

## 規格驅動開發執行指南

### 🎯 開發工作流程
1. **選擇任務**: 從 `tasks.md` 選擇下一個待執行任務
2. **研讀規格**: 詳細閱讀對應的需求和設計規範
3. **規劃實作**: 確認技術方案符合設計文件要求
4. **編寫程式碼**: 嚴格按照規格進行實作
5. **測試驗證**: 確保滿足所有驗收標準
6. **提交程式碼**: 包含需求編號的規範化提交

### 📚 規格文件使用指南
- **requirements.md**: 查找功能的驗收標準和業務邏輯
- **design.md**: 查找技術實作方案和架構設計
- **tasks.md**: 查找具體的開發任務和實作順序
- **JellySave-Project-Rules.md**: 查找程式碼規範和品質標準

### 🚨 違規處理
任何違反規格驅動開發原則的行為將被視為嚴重違規：
- **輕微違規**: 程式碼風格不符合規範 → 要求重新提交
- **中度違規**: 功能實作偏離設計規範 → 要求重新開發
- **嚴重違規**: 實作未定義功能或使用禁止技術 → 回退所有變更

### ✅ 成功標準
專案成功的唯一標準是完全符合規格文件的所有要求：
- 所有需求的驗收標準都得到滿足
- 技術實作完全符合設計文件規範
- 程式碼品質達到本文件定義的標準
- 效能指標符合規定的數值要求

## 圖表實作指南

### 📊 圖表類型和用途

#### 1. 月度趨勢線圖 (Swift Charts)
```swift
import Charts

struct MonthlyTrendChart: View {
    let data: [MonthlyTrendPoint]
    
    var body: some View {
        Chart(data) { point in
            LineMark(
                x: .value("月份", point.date),
                y: .value("資產", point.amount)
            )
            .foregroundStyle(ThemeColor.primary)
            .interpolationMethod(.catmullRom)
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.abbreviated))
            }
        }
    }
}
```

#### 2. 帳戶分布圓餅圖 (Swift Charts)
```swift
struct AccountDistributionChart: View {
    let accounts: [Account]
    
    var body: some View {
        Chart(accounts, id: \.type) { account in
            SectorMark(
                angle: .value("金額", account.balance),
                innerRadius: .ratio(0.5),
                angularInset: 2
            )
            .foregroundStyle(by: .value("類型", account.type))
        }
        .chartForegroundStyleScale([
            "現金帳戶": ThemeColor.primary,
            "股票帳戶": ThemeColor.secondary,
            "外幣帳戶": ThemeColor.accent,
            "保險": Color.green,
            "加密貨幣": Color.orange
        ])
    }
}
```

#### 3. 圓形進度指示器 (自訂 SwiftUI)
```swift
struct ProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat = 8
    
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
    }
}
```

### 🎨 圖表設計規範

#### 色彩使用
- **主要資料線**: 薄荷綠 `#4ECDC4`
- **次要資料線**: 天空藍 `#5DADE2`
- **強調資料點**: 珊瑚粉 `#FF6B6B`
- **網格線**: 中性灰 `#E5E5E5` (淺色) / `#3A3A3C` (深色)

#### 動畫效果
- **圖表載入**: 0.8 秒漸進式動畫
- **資料更新**: 0.5 秒平滑過渡
- **互動回饋**: 0.2 秒縮放效果
- **進度環**: 1.0 秒填充動畫

#### 無障礙支援
- 提供圖表資料的文字描述
- 支援 VoiceOver 朗讀資料點
- 確保色彩對比度符合標準
- 提供替代的表格檢視選項

### 📱 響應式圖表設計

#### iPhone 尺寸適配
- **iPhone SE**: 最小圖表高度 200pt
- **iPhone 標準**: 標準圖表高度 250pt  
- **iPhone Plus/Max**: 最大圖表高度 300pt
- **橫向模式**: 自動調整比例和標籤

#### 效能最佳化
- 限制資料點數量 (最多 180 個點，6個月每日)
- 使用資料採樣減少渲染負擔
- 實作虛擬化長列表圖表
- 快取已渲染的圖表影像

### 🔧 圖表互動功能

#### 觸控互動
- **點擊**: 顯示具體數值提示
- **長按**: 顯示詳細資訊彈窗
- **滑動**: 在時間軸上導航
- **縮放**: 雙指縮放查看細節 (可選)

#### 資料提示
- 顯示確切的日期和金額
- 計算與前期的變化百分比
- 提供趨勢方向指示 (上升/下降/持平)
- 支援多語言格式化 (繁體中文數字格式)

---

**文件完整性檢查**: ✅ 已確認所有內容一致性，無衝突或重複