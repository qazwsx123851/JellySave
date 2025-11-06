import SwiftUI

struct TotalAssetsCard: View {
    let summary: HomeSummary
    let lastUpdatedText: String
    let trendIconName: String
    let trendDescription: String
    let trendSubtitle: String

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.lg) {
            HStack(spacing: Constants.Spacing.sm) {
                Text("本月總資產")
                    .font(.caption.weight(.semibold))
                    .padding(.vertical, Constants.Spacing.xs)
                    .padding(.horizontal, Constants.Spacing.sm)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                    )
                    .foregroundStyle(Color.white)

                Text(lastUpdatedText)
                    .font(Constants.Typography.caption.weight(.medium))
                    .foregroundStyle(Color.white.opacity(0.72))
            }

            Text(NumberFormatter.formattedCurrencyString(for: summary.totalAssets))
                .font(Constants.Typography.hero)
                .foregroundStyle(Color.white)

            VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                HStack(spacing: Constants.Spacing.xs) {
                    Image(systemName: trendIconName)
                        .font(.system(size: 18, weight: .semibold))
                    Text(trendDescription)
                }
                .font(Constants.Typography.body.weight(.semibold))
                .foregroundStyle(Color.white)

                Text(trendSubtitle)
                    .font(Constants.Typography.caption)
                    .foregroundStyle(Color.white.opacity(0.8))
            }

            Divider()
                .background(Color.white.opacity(0.2))

            HStack(spacing: Constants.Spacing.lg) {
                ForEach(summary.highlights) { highlight in
                    VStack(alignment: .leading, spacing: Constants.Spacing.xxs) {
                        Text(highlight.title)
                            .font(Constants.Typography.caption)
                            .foregroundStyle(Color.white.opacity(0.75))
                        Text(highlight.value)
                            .font(Constants.Typography.body.weight(.semibold))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(Constants.Spacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(heroGradientBackground)
        .clipShape(RoundedRectangle(cornerRadius: Constants.CornerRadius.large, style: .continuous))
        .cardShadow(.medium)
        .accessibilityElement(children: .contain)
    }

    private var heroGradientBackground: some View {
        LinearGradient(
            colors: gradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var gradientColors: [Color] {
        switch colorScheme {
        case .dark:
            return [
                Color(red: 0.12, green: 0.36, blue: 0.33),
                Color(red: 0.10, green: 0.28, blue: 0.46)
            ]
        default:
            return [
                Color.primaryMint,
                Color.secondarySky
            ]
        }
    }
}
