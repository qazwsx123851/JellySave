import Foundation

extension NumberFormatter {
    static let twdCurrency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.numberStyle = .currency
        formatter.currencyCode = "TWD"
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        return formatter
    }()

    static func formattedCurrencyString(for value: Decimal) -> String {
        let number = NSDecimalNumber(decimal: value)
        return twdCurrency.string(from: number) ?? number.stringValue
    }
}
