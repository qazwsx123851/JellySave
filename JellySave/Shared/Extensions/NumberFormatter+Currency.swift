import Foundation

public extension NumberFormatter {
    /// Shared formatter for New Taiwan Dollar values.
    static func twdCurrencyFormatter(includeSymbol: Bool = true) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.numberStyle = .currency
        formatter.currencyCode = "TWD"
        formatter.currencySymbol = includeSymbol ? "NT$" : ""
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.generatesDecimalNumbers = true
        formatter.groupingSeparator = ","
        formatter.decimalSeparator = "."
        formatter.usesGroupingSeparator = true
        if !includeSymbol {
            formatter.positivePrefix = ""
            formatter.negativePrefix = "-"
        }
        return formatter
    }

    /// Formats a decimal amount into a display string.
    static func twdString(from amount: Decimal, includeSymbol: Bool = true) -> String {
        let formatter = twdCurrencyFormatter(includeSymbol: includeSymbol)
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? ""
    }

    /// Parses a currency string (with or without symbol) back into a decimal amount.
    static func twdDecimal(from string: String) -> Decimal? {
        let sanitized = string
            .replacingOccurrences(of: "NT$", with: "")
            .replacingOccurrences(of: Locale(identifier: "zh_TW").currencySymbol ?? "", with: "")
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !sanitized.isEmpty else { return nil }

        if let decimal = Decimal(string: sanitized, locale: Locale(identifier: "en_US_POSIX")) {
            return decimal
        }
        return nil
    }
}
