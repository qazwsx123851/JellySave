import SwiftUI

struct SkeletonCardPlaceholder: View {
    var height: CGFloat = 160
    var cornerRadius: CGFloat = Constants.CornerRadius.large

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color.surfacePrimary)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .skeletonOverlay(isActive: true, cornerRadius: cornerRadius)
            .cardShadow()
    }
}

#Preview("SkeletonCardPlaceholder") {
    SkeletonCardPlaceholder()
        .padding()
        .background(Color.appBackground)
}
