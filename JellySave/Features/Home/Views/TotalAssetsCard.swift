import SwiftUI

struct TotalAssetsCard: View {
    let summary: HomeSummary
    let lastUpdatedText: String
    let trendIconName: String
    let trendDescription: String
    let trendSubtitle: String

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    var body: some View {
        ZStack {
            // 1. 背景層：豐富漸層 + 裝飾
            heroGradientBackground

            // 2. 內容層
            VStack(alignment: .leading, spacing: Constants.Spacing.lg) {
                // 頂部：標題與更新時間
                HStack {
                    Text("本月總資產")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.white.opacity(0.9))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())

                    Spacer()

                    Text(lastUpdatedText)
                        .font(.caption)
                        .foregroundStyle(Color.white.opacity(0.8))
                }

                // 中間：金額顯示
                CountingLabel(
                    value: summary.totalAssets.doubleValue,
                    style: .currency,
                    font: .system(size: 40, weight: .bold, design: .rounded),
                    foregroundColor: .white
                )
                .contentTransition(.numericText())

                // 趨勢指標
                HStack(spacing: 8) {
                    Image(systemName: trendIconName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(trendColor)
                        .padding(6)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text(trendDescription)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                        Text(trendSubtitle)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                .padding(.vertical, 4)

                Divider()
                    .background(Color.white.opacity(0.3))

                // 底部：亮點數據
                HStack(spacing: 20) {
                    ForEach(summary.highlights) { highlight in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(highlight.title)
                                .font(.caption)
                                .foregroundStyle(Color.white.opacity(0.7))
                            Text(highlight.value)
                                .font(.callout.weight(.semibold))
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: ThemeColor.primary.color.opacity(0.3), radius: 20, x: 0, y: 10) // 彩色陰影
        .accessibilityElement(children: .contain)
        .accessibilityHint(Text("包含總資產、月變化與亮點摘要"))
    }

    private var heroGradientBackground: some View {
        ZStack {
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // 裝飾性光暈 1
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 200, height: 200)
                .offset(x: -80, y: -80)
                .blur(radius: 30)

            // 裝飾性光暈 2
            Circle()
                .fill(ThemeColor.secondary.color.opacity(0.2))
                .frame(width: 150, height: 150)
                .offset(x: 100, y: 60)
                .blur(radius: 40)
        }
    }

    private var gradientColors: [Color] {
        switch colorScheme {
        case .dark:
            return [
                Color(red: 0.05, green: 0.25, blue: 0.25), // 深薄荷
                Color(red: 0.10, green: 0.20, blue: 0.40), // 深藍
                Color(red: 0.20, green: 0.10, blue: 0.30)  // 深紫
            ]
        default:
            return [
                ThemeColor.primary.color,
                ThemeColor.secondary.color,
                Color(red: 0.6, green: 0.4, blue: 0.9) // 增加一點紫色調
            ]
        }
    }

    private var trendColor: Color {
        summary.monthlyChangeRatio >= 0 ? .white : Color(red: 1.0, green: 0.9, blue: 0.9)
    }
}
