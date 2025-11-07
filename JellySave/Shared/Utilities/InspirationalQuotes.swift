import Foundation

enum QuoteCategory: String, CaseIterable, Identifiable {
    case saving
    case investment

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .saving:
            return "儲蓄激勵"
        case .investment:
            return "投資建議"
        }
    }
}

struct MotivationalQuote: Identifiable {
    let id = UUID()
    let content: String
    let author: String
    let category: QuoteCategory

    var formatted: String {
        "\"\(content)\" — \(author)"
    }
}

final class QuoteRepository {
    private let quotes: [MotivationalQuote]

    init(quotes: [MotivationalQuote] = QuoteRepository.defaultQuotes) {
        self.quotes = quotes
    }

    func randomQuote(for category: QuoteCategory) -> MotivationalQuote {
        let filtered = quotes.filter { $0.category == category }
        return filtered.randomElement() ?? quotes.first!
    }

    func allQuotes() -> [MotivationalQuote] {
        quotes
    }
}

private extension QuoteRepository {
    static let defaultQuotes: [MotivationalQuote] = [
        MotivationalQuote(content: "存下的每一塊錢都在為夢想投票。", author: "未知", category: .saving),
        MotivationalQuote(content: "財富不是收入，而是你留住了多少。", author: "羅伯特·清崎", category: .saving),
        MotivationalQuote(content: "給每一筆花費一個目的，就能為每一天買回自由。", author: "未知", category: .saving),
        MotivationalQuote(content: "當你為未來儲蓄，其實也是在向過去的自己道謝。", author: "未知", category: .saving),
        MotivationalQuote(content: "先支付給自己，再支付給世界。", author: "大衛·巴赫", category: .saving),
        MotivationalQuote(content: "持續的小額儲蓄能擊敗偶爾的大筆衝動。", author: "未知", category: .saving),
        MotivationalQuote(content: "每日 1% 的進步，累積就是新的生活。", author: "詹姆斯·克利爾", category: .saving),
        MotivationalQuote(content: "把儲蓄視為固定支出，財務就會聽你的話。", author: "未知", category: .saving),
        MotivationalQuote(content: "為未來設下的每一個目標，都是投資自己的證明。", author: "未知", category: .saving),
        MotivationalQuote(content: "儲蓄不是犧牲，而是獲得選擇權。", author: "蘇西·歐曼", category: .saving),
        MotivationalQuote(content: "市場短期是投票機，長期是體重計。", author: "班傑明·葛拉漢", category: .investment),
        MotivationalQuote(content: "分散投資是唯一免費的午餐。", author: "哈利·馬可維茲", category: .investment),
        MotivationalQuote(content: "當別人恐懼時貪婪，當別人貪婪時恐懼。", author: "華倫·巴菲特", category: .investment),
        MotivationalQuote(content: "投資最重要的是了解自己能承擔的風險。", author: "瑞·達利歐", category: .investment),
        MotivationalQuote(content: "時間是投資者最好的朋友，也是最大的敵人。", author: "約翰·柏格", category: .investment),
        MotivationalQuote(content: "紀律與耐心，是任何策略成功的核心。", author: "彼得·林區", category: .investment),
        MotivationalQuote(content: "資產配置決定了投資成果的 90%。", author: "加里·布林森", category: .investment),
        MotivationalQuote(content: "不要預測市場，請準備好自己的組合。", author: "未知", category: .investment),
        MotivationalQuote(content: "現金流是企業的血液，也是投資的根本。", author: "菲利浦·費雪", category: .investment),
        MotivationalQuote(content: "學會等待正確的機會，勝過追逐每一次波動。", author: "查理·蒙格", category: .investment)
    ]
}
