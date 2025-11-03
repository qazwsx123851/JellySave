import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    var name: String
    var loopMode: LottieLoopMode = .loop
    var animationSpeed: CGFloat = 1.0

    func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: name)
        view.loopMode = loopMode
        view.animationSpeed = animationSpeed
        view.play()
        view.contentMode = .scaleAspectFit
        return view
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        uiView.animation = LottieAnimation.named(name)
        uiView.loopMode = loopMode
        uiView.animationSpeed = animationSpeed
        if !uiView.isAnimationPlaying {
            uiView.play()
        }
    }

    static func dismantleUIView(_ uiView: LottieAnimationView, coordinator: ()) {
        uiView.stop()
    }
}

#Preview("LottieView") {
    // Placeholder preview; requires animation asset named "celebration"
    LottieView(name: "celebration")
        .frame(width: 200, height: 200)
}
