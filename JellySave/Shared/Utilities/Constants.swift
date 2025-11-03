import SwiftUI

enum Constants {
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 20
    }

    enum Layout {
        static let minTouchTarget: CGFloat = 44
        static let cardElevation: CGFloat = 4
        static let maxContentWidth: CGFloat = 720
    }

    enum Typography {
        static let hero = Font.system(size: 36, weight: .bold, design: .rounded)
        static let title = Font.system(size: 24, weight: .semibold)
        static let subtitle = Font.system(size: 20, weight: .medium)
        static let body = Font.system(size: 16, weight: .regular)
        static let caption = Font.system(size: 14, weight: .regular)
    }

    struct ShadowStyle {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat

        static let subtle = ShadowStyle(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        static let medium = ShadowStyle(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 8)
    }
}

extension View {
    func cardShadow(_ style: Constants.ShadowStyle = .subtle) -> some View {
        shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }

    func maxWidthLayout() -> some View {
        frame(maxWidth: Constants.Layout.maxContentWidth, alignment: .center)
    }
}
