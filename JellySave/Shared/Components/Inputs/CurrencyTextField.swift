import SwiftUI

struct CurrencyTextField: View {
    @Binding var value: Decimal
    var title: String
    var placeholder: String = "請輸入金額"

    @FocusState private var isFocused: Bool
    @State private var text: String = ""

    init(value: Binding<Decimal>, title: String, placeholder: String = "請輸入金額") {
        _value = value
        self.title = title
        self.placeholder = placeholder
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(Color.textSecondary)

            TextField(placeholder, text: $text)
                .focused($isFocused)
                .keyboardType(.numberPad)
                .font(Constants.Typography.title)
                .padding(Constants.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: Constants.CornerRadius.medium, style: .continuous)
                        .fill(Color.surfaceSecondary)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.CornerRadius.medium, style: .continuous)
                        .stroke(isFocused ? ThemeColor.primary.color : Color.clear, lineWidth: 2)
                )
                .accessibilityLabel(Text(title))
                .accessibilityValue(Text(formattedValue))
        }
        .onAppear(perform: configureInitialState)
        .onChange(of: value) { newValue in
            guard !isFocused else { return }
            text = formattedString(for: newValue)
        }
        .onChange(of: text, perform: handleTextChange)
        .onChange(of: isFocused, perform: handleFocusChange)
    }

    private var formattedValue: String {
        NumberFormatter.formattedCurrencyString(for: value)
    }

    private func configureInitialState() {
        text = formattedString(for: value)
    }

    private func handleTextChange(_ newValue: String) {
        guard isFocused else { return }
        let sanitized = newValue.filter { $0.isNumber }
        if sanitized != newValue {
            text = sanitized
        }

        if sanitized.isEmpty {
            value = 0
        } else if let decimal = Decimal(string: sanitized) {
            value = decimal
        }
    }

    private func handleFocusChange(_ focused: Bool) {
        if focused {
            text = value == 0 ? "" : plainString(for: value)
        } else {
            text = formattedString(for: value)
        }
    }

    private func formattedString(for value: Decimal) -> String {
        NumberFormatter.formattedCurrencyString(for: value)
    }

    private func plainString(for value: Decimal) -> String {
        NSDecimalNumber(decimal: value).stringValue
    }
}

#Preview("CurrencyTextField") {
    StatefulPreviewWrapper(Decimal(128000)) { binding in
        CurrencyTextField(value: binding, title: "初始餘額")
            .padding()
            .background(Color.appBackground)
    }
}

private struct StatefulPreviewWrapper<Value>: View {
    @State private var value: Value
    let content: (Binding<Value>) -> AnyView

    init(_ value: Value, content: @escaping (Binding<Value>) -> some View) {
        _value = State(initialValue: value)
        self.content = { binding in AnyView(content(binding)) }
    }

    var body: some View {
        content($value)
    }
}
