import AudioToolbox
import SwiftUI
import UIKit

struct CelebrationView: View {
    var animationName: String = "goalCelebration"
    var title: String = "恭喜達成目標！"
    var message: String = "持續儲蓄，下一個里程碑就在不遠處。"
    var onDismiss: () -> Void = {}
    @State private var hasTriggeredFeedback = false
    private let celebrationSoundID: SystemSoundID = 1105

    var body: some View {
        VStack(spacing: Constants.Spacing.xl) {
            if animationAvailable {
                LottieView(name: animationName, loopMode: .loop)
                    .frame(height: 200)
                    .padding(.horizontal, Constants.Spacing.lg)
                    .accessibilityHidden(true)
            } else {
                Image(systemName: "sparkles")
                    .font(.system(size: 72, weight: .semibold))
                    .foregroundStyle(ThemeColor.primary.color)
                    .frame(height: 180)
                    .accessibilityHidden(true)
            }

            VStack(spacing: Constants.Spacing.md) {
                Text(title)
                    .font(Constants.Typography.title.weight(.bold))
                    .foregroundStyle(Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, Constants.Spacing.lg)

                Text(message)
                    .font(Constants.Typography.body.weight(.medium))
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, Constants.Spacing.lg)
            }

            CustomButton(title: "繼續努力", icon: Image(systemName: "arrow.uturn.right.circle")) {
                onDismiss()
            }
            .frame(maxWidth: 260)
        }
        .padding(.vertical, Constants.Spacing.xxl)
        .padding(.horizontal, Constants.Spacing.xl)
        .maxWidthLayout()
        .background(
            RoundedRectangle(cornerRadius: Constants.CornerRadius.large, style: .continuous)
                .fill(Color.surfacePrimary)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 8)
        )
        .padding()
        .onAppear(perform: triggerFeedback)
        .accessibilityElement(children: .contain)
        .accessibilityHint(Text("目標達成提示，點擊繼續努力關閉"))
    }
}

#Preview {
    CelebrationView()
        .environmentObject(ThemeService())
}

private extension CelebrationView {
    func triggerFeedback() {
        guard !hasTriggeredFeedback else { return }
        hasTriggeredFeedback = true

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        AudioServicesPlaySystemSound(celebrationSoundID)
    }

    var animationAvailable: Bool {
        Bundle.main.path(forResource: animationName, ofType: "json") != nil
    }
}
