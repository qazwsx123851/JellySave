import SwiftUI

struct CustomButton: View {
    enum Style {
        case primary
        case secondary
        case outline
    }

    let title: String
    var icon: Image? = nil
    var style: Style = .primary
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var action: () -> Void

    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    private var foregroundColor: Color {
        switch style {
        case .outline:
            return Color.textPrimary
        case .primary, .secondary:
            return backgroundColor.accessibleTextColor(contrast: colorSchemeContrast)
        }
    }

    private var background: some View {
        RoundedRectangle(cornerRadius: Constants.CornerRadius.medium, style: .continuous)
            .fill(backgroundColor)
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return ThemeColor.primary.color.adjustedForHighContrast(colorSchemeContrast)
        case .secondary:
            return ThemeColor.accent.color.adjustedForHighContrast(colorSchemeContrast)
        case .outline:
            return Color.clear
        }
    }

    private var border: some View {
        RoundedRectangle(cornerRadius: Constants.CornerRadius.medium, style: .continuous)
            .strokeBorder(borderColor, lineWidth: style == .outline ? 2 : 0)
    }

    private var borderColor: Color {
        switch style {
        case .primary:
            return Color.clear
        case .secondary:
            return Color.clear
        case .outline:
            return ThemeColor.primary.color.adjustedForHighContrast(colorSchemeContrast)
        }
    }

    private var disabledOpacity: Double { isDisabled ? 0.4 : 1.0 }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Constants.Spacing.sm) {
                if let icon {
                    icon
                }

                Text(title)
                    .font(Constants.Typography.body.weight(.semibold))

                if isLoading {
                    Spacer(minLength: Constants.Spacing.sm)
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(foregroundColor)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: Constants.Layout.minTouchTarget)
            .padding(.horizontal, Constants.Spacing.md)
            .foregroundColor(foregroundColor)
            .background(background)
            .overlay(border)
            .opacity(disabledOpacity)
            .accessibilityLabel(accessibilityLabel)
        }
        .disabled(isDisabled || isLoading)
        .buttonStyle(PressedScaleButtonStyle())
    }

    private var accessibilityLabel: Text {
        Text(isLoading ? "\(title)（載入中）" : title)
    }
}

private struct PressedScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.2), value: configuration.isPressed)
    }
}

#Preview("CustomButton") {
    VStack(spacing: Constants.Spacing.md) {
        CustomButton(title: "主要操作", icon: Image(systemName: "arrow.right")) {}
        CustomButton(title: "次要操作", style: .secondary) {}
        CustomButton(title: "載入中", isLoading: true) {}
        CustomButton(title: "禁用狀態", isDisabled: true) {}
        CustomButton(title: "Outline", style: .outline) {}
    }
    .padding()
    .background(Color.appBackground)
}
