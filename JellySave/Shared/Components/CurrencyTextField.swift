import SwiftUI

public struct CurrencyTextField: View {
    private let title: String
    @Binding private var value: Decimal
    private let includeSymbol: Bool
    @State private var text: String
    @FocusState private var isFocused: Bool

    public init(_ title: String, value: Binding<Decimal>, includeSymbol: Bool = true) {
        self.title = title
        self._value = value
        self.includeSymbol = includeSymbol
        let formatter = includeSymbol
            ? NumberFormatter.twdCurrencyFormatter(includeSymbol: true)
            : NumberFormatter.twdCurrencyFormatter(includeSymbol: false)
        self._text = State(initialValue: formatter.string(from: NSDecimalNumber(decimal: value.wrappedValue)) ?? "")
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(Constants.Typography.subheadline)
                .foregroundColor(ThemeColor.neutralDark.opacity(0.7))

            TextField(title, text: $text)
                .focused($isFocused)
                .keyboardType(.decimalPad)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: Constants.CornerRadius.medium, style: .continuous)
                        .fill(ThemeColor.cardBackground(for: colorScheme))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.CornerRadius.medium, style: .continuous)
                        .stroke(isFocused ? ThemeColor.primary : ThemeColor.neutralLight.opacity(0.8), lineWidth: 1)
                )
                .onChange(of: text, perform: handleTextChange)
                .onChange(of: isFocused) { handleFocusChange($0) }
                .onChange(of: value) { newValue in
                    guard !isFocused else { return }
                    let formatter = includeSymbol ? currencyFormatter : plainFormatter
                    text = formatter.string(from: NSDecimalNumber(decimal: newValue)) ?? ""
                }
        }
    }

    @Environment(\.colorScheme) private var colorScheme

    private func handleTextChange(_ newValue: String) {
        guard isFocused else { return }
        let sanitized = sanitizeInput(newValue)
        if sanitized != newValue {
            text = sanitized
        }
        if let decimal = Decimal(string: sanitized, locale: Locale(identifier: "en_US_POSIX")) {
            value = decimal
        }
    }

    private func handleFocusChange(_ isFocused: Bool) {
        if isFocused {
            if includeSymbol {
                let plain = plainFormatter.string(from: NSDecimalNumber(decimal: value)) ?? ""
                text = plain
            }
        } else {
            let formatter = includeSymbol
                ? currencyFormatter
                : plainFormatter
            let formatted = formatter.string(from: NSDecimalNumber(decimal: value))
            text = formatted ?? ""
        }
    }

    private func sanitizeInput(_ string: String) -> String {
        let allowed = Set("0123456789.")
        var hasDecimalSeparator = false
        let filtered = string.filter { character in
            if character == "." {
                if hasDecimalSeparator {
                    return false
                }
                hasDecimalSeparator = true
                return true
            }
            return allowed.contains(character)
        }
        return filtered
    }
}

private extension CurrencyTextField {
    var currencyFormatter: NumberFormatter {
        NumberFormatter.twdCurrencyFormatter(includeSymbol: includeSymbol)
    }

    var plainFormatter: NumberFormatter {
        NumberFormatter.twdCurrencyFormatter(includeSymbol: false)
    }
}

#Preview {
    StatefulPreviewWrapper(Decimal(12500)) { binding in
        CurrencyTextField("每月存款金額", value: binding)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}

private struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    private let content: (Binding<Value>) -> Content

    init(_ initialValue: Value, content: @escaping (Binding<Value>) -> Content) {
        _value = State(initialValue: initialValue)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}
