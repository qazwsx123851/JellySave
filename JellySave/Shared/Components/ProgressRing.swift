import SwiftUI

public struct ProgressRing: View {
    private let progress: Double
    private let title: String
    private let subtitle: String?
    private let lineWidth: CGFloat

    public init(progress: Double, title: String, subtitle: String? = nil, lineWidth: CGFloat = Constants.Progress.ringLineWidth) {
        self.progress = min(max(progress, 0), 1)
        self.title = title
        self.subtitle = subtitle
        self.lineWidth = lineWidth
    }

    public var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(ThemeColor.neutralLight.opacity(0.6), style: StrokeStyle(lineWidth: lineWidth))
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [ThemeColor.primary, ThemeColor.highlight, ThemeColor.primary]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.4), value: progress)

                Text(percentageText)
                    .font(Constants.Typography.headline)
                    .foregroundColor(ThemeColor.primary)
            }
            .frame(width: 120, height: 120)

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

    private var percentageText: String {
        let percent = Int(progress * 100)
        return "\(percent)%"
    }
}

#Preview {
    ProgressRing(progress: 0.64, title: "進度", subtitle: "剩餘 NT$12,500")
        .padding()
        .previewLayout(.sizeThatFits)
}
