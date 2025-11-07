import SwiftUI

enum AccountType: String, CaseIterable, Identifiable {
    case cash = "現金帳戶"
    case stock = "股票帳戶"
    case foreignCurrency = "外幣帳戶"
    case insurance = "保險"
    case cryptocurrency = "加密貨幣"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .cash:
            return "dollarsign.circle.fill"
        case .stock:
            return "chart.line.uptrend.xyaxis"
        case .foreignCurrency:
            return "globe.asia.australia.fill"
        case .insurance:
            return "shield.checkerboard"
        case .cryptocurrency:
            return "bitcoinsign.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .cash:
            return ThemeColor.primary.color
        case .stock:
            return ThemeColor.secondary.color
        case .foreignCurrency:
            return ThemeColor.accent.color
        case .insurance:
            return ThemeColor.success.color
        case .cryptocurrency:
            return Color.orange
        }
    }

    var description: String {
        switch self {
        case .cash:
            return "日常收支與即時現金"
        case .stock:
            return "股票投資與股息收入"
        case .foreignCurrency:
            return "旅遊或多幣別資產"
        case .insurance:
            return "保險保障與長期年金"
        case .cryptocurrency:
            return "高波動數位資產"
        }
    }
}

