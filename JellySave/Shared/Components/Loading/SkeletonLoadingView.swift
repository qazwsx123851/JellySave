import SwiftUI
import SkeletonView

struct SkeletonLoadingView: UIViewRepresentable {
    var isAnimating: Bool
    var cornerRadius: CGFloat = Constants.CornerRadius.medium
    var baseColor: UIColor = UIColor.surfaceSecondary
    var highlightColor: UIColor = UIColor.primaryMint.withAlphaComponent(0.3)

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.isSkeletonable = true
        view.layer.cornerRadius = cornerRadius
        view.clipsToBounds = true
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.layer.cornerRadius = cornerRadius
        uiView.backgroundColor = baseColor
        if isAnimating {
            let gradient = SkeletonGradient(baseColor: baseColor, secondaryColor: highlightColor)
            let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)
            uiView.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation, transition: .none)
        } else {
            uiView.hideSkeleton(reloadDataAfter: false, transition: .crossDissolve(0.25))
        }
    }
}

#Preview("SkeletonLoadingView") {
    SkeletonLoadingView(isAnimating: true)
        .frame(width: 200, height: 120)
        .padding()
}
