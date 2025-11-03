import SwiftUI

extension View {
    func primaryCardBackground() -> some View {
        background(
            RoundedRectangle(cornerRadius: Constants.CornerRadius.large, style: .continuous)
                .fill(Color.surfacePrimary)
        )
    }

    func secondaryCardBackground() -> some View {
        background(
            RoundedRectangle(cornerRadius: Constants.CornerRadius.medium, style: .continuous)
                .fill(Color.surfaceSecondary)
        )
    }

    func sectionTitleStyle() -> some View {
        font(Constants.Typography.subtitle)
            .foregroundStyle(Color.textPrimary)
    }

    func skeletonOverlay(isActive: Bool, cornerRadius: CGFloat = Constants.CornerRadius.medium) -> some View {
        overlay {
            if isActive {
                SkeletonLoadingView(isAnimating: true, cornerRadius: cornerRadius)
            }
        }
    }
}
