import SwiftUI

private struct CardBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let cornerRadius: CGFloat
    let showShadow: Bool

    func body(content: Content) -> some View {
        let background = ThemeColor.cardBackground(for: colorScheme)

        return content
            .padding(Constants.Layout.cardContentSpacing)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(background)
            )
            .if(showShadow) { view in
                view.shadow(
                    color: ThemeColor.neutralDark.opacity(Constants.Shadow.cardOpacity),
                    radius: Constants.Shadow.cardRadius,
                    x: Constants.Shadow.cardX,
                    y: Constants.Shadow.cardY
                )
            }
    }
}

private struct FullWidthModifier: ViewModifier {
    let alignment: Alignment

    func body(content: Content) -> some View {
        content.frame(maxWidth: .infinity, alignment: alignment)
    }
}

public extension View {
    /// Applies a card-style background with default padding and optional shadow.
    func cardBackground(cornerRadius: CGFloat = Constants.CornerRadius.large, showShadow: Bool = true) -> some View {
        modifier(CardBackgroundModifier(cornerRadius: cornerRadius, showShadow: showShadow))
    }

    /// Expands the view to fill the horizontal width with the provided alignment.
    func fillWidth(alignment: Alignment = .center) -> some View {
        modifier(FullWidthModifier(alignment: alignment))
    }

    /// Adds the standard horizontal padding used for top-level sections.
    func sectionPadding() -> some View {
        padding(.horizontal, Constants.Layout.horizontalPadding)
    }

    /// Conditionally applies a transformation to the view.
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
