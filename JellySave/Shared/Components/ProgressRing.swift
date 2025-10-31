import SwiftUI

public struct ProgressRing: View {
    private let progress: Double
    private let title: String
    private let subtitle: String?
    private let lineWidth: CGFloat
    private let size: CGFloat
    private let animateOnAppear: Bool
    private let animationDuration: Double
    @State private var animatedProgress: Double = 0

    public init(progress: Double,
                title: String,
                subtitle: String? = nil,
                lineWidth: CGFloat = Constants.Progress.ringLineWidth,
                size: CGFloat = 120,
                animateOnAppear: Bool = false,
                animationDuration: Double = 0.6) {
        self.progress = min(max(progress, 0), 1)
        self.title = title
        self.subtitle = subtitle
        self.lineWidth = lineWidth
        self.size = size
        self.animateOnAppear = animateOnAppear
        self.animationDuration = animationDuration
    }

    public var body: some View {
        let effectiveProgress = animateOnAppear ? animatedProgress : progress

        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(ThemeColor.neutralLight.opacity(0.6), style: StrokeStyle(lineWidth: lineWidth))
                Circle()
                    .trim(from: 0, to: effectiveProgress)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [ThemeColor.primary, ThemeColor.highlight, ThemeColor.primary]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                Text(percentageText(for: effectiveProgress))
                    .font(Constants.Typography.headline)
                    .foregroundColor(ThemeColor.primary)
            }
            .frame(width: size, height: size)
            .onAppear {
                guard animateOnAppear else { return }
                animatedProgress = 0
                withAnimation(.easeInOut(duration: animationDuration)) {
                    animatedProgress = progress
                }
            }
            .onChange(of: progress) { newValue in
                guard animateOnAppear else { return }
                withAnimation(.easeInOut(duration: animationDuration)) {
                    animatedProgress = min(max(newValue, 0), 1)
                }
            }

            VStack(spacing: 4) {
                Text(title)
                    .font(Constants.Typography.subheadline)
                    .foregroundColor(ThemeColor.neutralDark.opacity(0.8))
                if let subtitle {
                    Text(subtitle)
                        .font(Constants.Typography.caption)
                        .foregroundColor(ThemeColor.neutralDark.opacity(0.6))
                }
            }
        }
    }

    private func percentageText(for value: Double) -> String {
        let percent = Int(value * 100)
        return "\(percent)%"
    }
}

#Preview {
    ProgressRing(progress: 0.64, title: "進度", subtitle: "剩餘 NT$12,500")
        .padding()
        .previewLayout(.sizeThatFits)
}
