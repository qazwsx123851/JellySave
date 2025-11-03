import SwiftUI

enum CountingLabelStyle {
    case currency
    case percentage(maximumFractionDigits: Int)
    case plain(maximumFractionDigits: Int)

    func formattedValue(from value: Double) -> String {
        switch self {
        case .currency:
            let decimal = Decimal(value)
            return NumberFormatter.formattedCurrencyString(for: decimal)
        case .percentage(let digits):
            let formatter = NumberFormatter()
            formatter.numberStyle = .percent
            formatter.maximumFractionDigits = digits
            formatter.minimumFractionDigits = 0
            formatter.locale = Locale(identifier: "zh_TW")
            return formatter.string(from: NSNumber(value: value)) ?? "0%"
        case .plain(let digits):
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = digits
            formatter.minimumFractionDigits = 0
            formatter.groupingSeparator = ","
            formatter.locale = Locale(identifier: "zh_TW")
            return formatter.string(from: NSNumber(value: value)) ?? "0"
        }
    }
}

struct CountingLabel: View {
    var value: Double
    var style: CountingLabelStyle
    var animation: Animation = .easeOut(duration: 0.8)

    @State private var animatedValue: Double = 0

    var body: some View {
        AnimatableCountingText(value: animatedValue, style: style)
            .onAppear {
                animatedValue = value
            }
            .onChange(of: value) { newValue in
                withAnimation(animation) {
                    animatedValue = newValue
                }
            }
            .accessibilityLabel(Text(style.formattedValue(from: animatedValue)))
    }
}

private struct AnimatableCountingText: View, Animatable {
    var value: Double
    var style: CountingLabelStyle

    var animatableData: Double {
        get { value }
        set { value = newValue }
    }

    var body: some View {
        Text(style.formattedValue(from: value))
            .font(Constants.Typography.hero)
            .foregroundStyle(ThemeColor.primary.color)
    }
}

#Preview("CountingLabel") {
    VStack(spacing: Constants.Spacing.lg) {
        CountingLabel(value: 1245000, style: .currency)
        CountingLabel(value: 0.68, style: .percentage(maximumFractionDigits: 1))
        CountingLabel(value: 154, style: .plain(maximumFractionDigits: 0))
    }
    .padding()
    .background(Color.appBackground)
}
