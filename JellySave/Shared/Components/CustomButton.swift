import SwiftUI

public struct CustomButton: View {
    public enum Style {
        case primary
        case secondary
        case outline
    }

    private let title: String
    private let iconName: String?
    private let style: Style
    private let action: () -> Void

    public init(_ title: String, iconName: String? = nil, style: Style = .primary, action: @escaping () -> Void) {
        self.title = title
        self.iconName = iconName
        self.style = style
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let iconName {
                    Image(systemName: iconName)
                        .imageScale(.medium)
                }
                Text(title)
                    .font(Constants.Typography.headline)
            }
            .padding(.horizontal, Constants.Button.horizontalPadding)
            .frame(height: Constants.Button.height)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(ThemeButtonStyle(style: style))
    }
}

private struct ThemeButtonStyle: ButtonStyle {
    let style: CustomButton.Style
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(foregroundColor(isPressed: configuration.isPressed))
            .background(background(isPressed: configuration.isPressed))
            .clipShape(RoundedRectangle(cornerRadius: Constants.Button.cornerRadius, style: .continuous))
            .overlay(border)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }

    private func background(isPressed: Bool) -> some View {
        let baseOpacity: Double = isEnabled ? 1 : 0.5
        switch style {
        case .primary:
            return ThemeColor.primary.opacity(isPressed ? 0.8 : baseOpacity)
        case .secondary:
            return ThemeColor.accent.opacity(isPressed ? 0.8 : baseOpacity)
        case .outline:
            return ThemeColor.neutralLight.opacity(isPressed ? 0.9 : baseOpacity)
        }
    }

    private var border: some View {
        switch style {
        case .outline:
            return RoundedRectangle(cornerRadius: Constants.Button.cornerRadius, style: .continuous)
                .stroke(ThemeColor.primary, lineWidth: 1)
        default:
            return RoundedRectangle(cornerRadius: Constants.Button.cornerRadius, style: .continuous)
                .stroke(Color.clear, lineWidth: 0)
        }
    }

    private func foregroundColor(isPressed: Bool) -> Color {
        switch style {
        case .primary, .secondary:
            return Color.white.opacity(isPressed ? 0.8 : 1)
        case .outline:
            return ThemeColor.primary.opacity(isPressed ? 0.7 : 1)
        }
    }
}

#Preview("Primary") {
    CustomButton("新增帳戶", iconName: "plus") {}
        .padding()
        .previewLayout(.sizeThatFits)
}

#Preview("Outline") {
    VStack(spacing: 12) {
        CustomButton("設定提醒", iconName: "bell", style: .secondary) {}
        CustomButton("更多資訊", style: .outline) {}
            .disabled(true)
    }
    .padding()
    .previewLayout(.sizeThatFits)
}
