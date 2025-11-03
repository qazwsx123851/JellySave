import SwiftUI

struct GradientBackground: View {
    var colors: [Color] = [Color.primaryMint, Color.secondarySky]
    var startPoint: UnitPoint = .topLeading
    var endPoint: UnitPoint = .bottomTrailing

    var body: some View {
        LinearGradient(colors: colors, startPoint: startPoint, endPoint: endPoint)
            .ignoresSafeArea()
    }
}

#Preview("GradientBackground") {
    ZStack {
        GradientBackground()
        Text("JellySave")
            .font(Constants.Typography.hero)
            .foregroundStyle(.white)
    }
}
