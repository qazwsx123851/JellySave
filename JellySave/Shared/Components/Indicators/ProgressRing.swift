import SwiftUI

struct ProgressRing: View {
    var progress: Double
    var lineWidth: CGFloat = 8
    var gradient: Gradient = Gradient(colors: [Color.primaryMint, Color.secondarySky])
    var animationDuration: Double = 1.0

    @State private var displayedProgress: Double = 0

    private var clampedProgress: Double {
        max(0, min(1, progress))
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.divider.opacity(0.3), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: displayedProgress)
                .stroke(
                    AngularGradient(gradient: gradient, center: .center),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: ThemeColor.primary.color.opacity(0.2), radius: 3, x: 0, y: 2)
        }
        .animation(.easeInOut(duration: animationDuration), value: displayedProgress)
        .onAppear { animateProgress(to: clampedProgress) }
        .onChange(of: clampedProgress) { animateProgress(to: $0) }
        .accessibilityElement()
        .accessibilityLabel("完成進度")
        .accessibilityValue(Text("\(Int(clampedProgress * 100))%"))
    }

    private func animateProgress(to value: Double) {
        displayedProgress = value
    }
}

#Preview("ProgressRing") {
    VStack(spacing: Constants.Spacing.lg) {
        ProgressRing(progress: 0.72, lineWidth: 12)
            .frame(width: 120, height: 120)

        ProgressRing(progress: 0.35, gradient: Gradient(colors: [Color.accentCoral, Color.secondarySky]))
            .frame(width: 100, height: 100)
    }
    .padding()
    .background(Color.appBackground)
}
