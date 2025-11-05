import Charts
import SwiftUI

struct HomeView: View {
    private let overview = HomeOverview.sample
    private let monthlyTrend = MonthlyTrendPoint.sampleSixMonths()
    private let quickActions = HomeQuickAction.sampleActions
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: Constants.Spacing.xl) {
                    heroCard
                    monthlyTrendSection
                    quickActionsSection
                }
                .padding(.horizontal, Constants.Spacing.md)
                .padding(.vertical, Constants.Spacing.xl)
                .maxWidthLayout()
                .frame(maxWidth: .infinity)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("首頁")
        }
    }
}

// MARK: - Sections

private extension HomeView {
    var heroCard: some View {
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
                Text(overview.lastUpdatedText)
                    .font(Constants.Typography.caption.weight(.medium))
                    .foregroundStyle(Color.white.opacity(0.72))
            }

            Text(overview.totalAssetsText)
                .font(Constants.Typography.hero)
                .foregroundStyle(Color.white)

            VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                HStack(spacing: Constants.Spacing.xs) {
                    Image(systemName: overview.trendIcon)
                        .font(.system(size: 18, weight: .semibold))
                    Text(overview.trendDescription)
                }
                .font(Constants.Typography.body.weight(.semibold))
                .foregroundStyle(Color.white)

                Text(overview.trendSubheadline)
                    .font(Constants.Typography.caption)
                    .foregroundStyle(Color.white.opacity(0.8))
            }

            Divider()
                .background(Color.white.opacity(0.2))

            HStack(spacing: Constants.Spacing.lg) {
                ForEach(overview.highlights) { highlight in
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

    var monthlyTrendSection: some View {
        CardContainer(
            title: "6 個月資產趨勢",
            subtitle: "依據靜態樣本資料顯示",
            icon: Image(systemName: "chart.line.uptrend.xyaxis")
        ) {
            Chart(monthlyTrend) { point in
                LineMark(
                    x: .value("月份", point.date),
                    y: .value("資產金額", point.amountDouble)
                )
                .foregroundStyle(
                    Gradient(colors: [
                        Color.primaryMint,
                        Color.secondarySky
                    ])
                )
                .interpolationMethod(.catmullRom)

                AreaMark(
                    x: .value("月份", point.date),
                    y: .value("資產金額", point.amountDouble)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color.primaryMint.opacity(0.35),
                            Color.primaryMint.opacity(0.05)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .month)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.narrow))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { y in
                    AxisGridLine()
                    AxisValueLabel {
                        if let amount = y.as(Double.self) {
                            Text(NumberFormatter.formattedCurrencyString(for: Decimal(amount)))
                                .font(Constants.Typography.caption)
                        }
                    }
                }
            }
            .frame(height: 240)
            .accessibilityElement(children: .contain)

            Divider()

            VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                Text("摘要")
                    .font(Constants.Typography.body.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                Text(overview.trendSummaryDescription)
                    .font(Constants.Typography.body)
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }

    var quickActionsSection: some View {
        CardContainer(
            title: "快速操作",
            subtitle: "常用功能捷徑",
            icon: Image(systemName: "bolt.fill")
        ) {
            LazyVGrid(columns: quickActionColumns, spacing: Constants.Spacing.md) {
                ForEach(quickActions) { action in
                    QuickActionCard(action: action)
                }
            }
        }
    }
}

// MARK: - Helpers

private extension HomeView {
    var heroGradientBackground: some View {
        LinearGradient(
            colors: heroGradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var quickActionColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: Constants.Spacing.md),
            GridItem(.flexible(), spacing: Constants.Spacing.md)
        ]
    }

    var heroGradientColors: [Color] {
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

// MARK: - Models

private struct HomeOverview {
    struct Highlight: Identifiable {
        let id = UUID()
        let title: String
        let value: String
    }

    let totalAssets: Double
    let monthlyChangeRatio: Double
    let monthlyChangeAmount: Double
    let lastUpdated: Date
    let highlights: [Highlight]

    var totalAssetsText: String {
        NumberFormatter.formattedCurrencyString(for: Decimal(totalAssets))
    }

    var lastUpdatedText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.dateFormat = "更新於 MMM d 日 HH:mm"
        return formatter.string(from: lastUpdated)
    }

    var trendIcon: String {
        monthlyChangeRatio >= 0 ? "arrow.up.right.circle.fill" : "arrow.down.right.circle.fill"
    }

    var trendDescription: String {
        let percentageFormatter = NumberFormatter()
        percentageFormatter.numberStyle = .percent
        percentageFormatter.maximumFractionDigits = 1
        percentageFormatter.minimumFractionDigits = 0
        percentageFormatter.locale = Locale(identifier: "zh_TW")
        let percentText = percentageFormatter.string(from: NSNumber(value: monthlyChangeRatio)) ?? "0%"
        let amountText = NumberFormatter.formattedCurrencyString(for: Decimal(monthlyChangeAmount))
        let direction = monthlyChangeRatio >= 0 ? "本月上升" : "本月下降"
        return "\(direction) \(percentText)（\(amountText)）"
    }

    var trendSubheadline: String {
        monthlyChangeRatio >= 0 ? "保持穩健表現，繼續朝目標邁進。" : "建議檢視近期支出，調整儲蓄策略。"
    }

    var trendSummaryDescription: String {
        let baseline = monthlyChangeRatio >= 0 ? "資產維持正向成長，" : "資產呈現下滑趨勢，"
        return baseline + "此趨勢圖表以假資料展示近六個月的變化，正式整合服務之前可用於檢查視覺設計與響應式排版。"
    }

    static let sample: HomeOverview = {
        HomeOverview(
            totalAssets: 1_284_500,
            monthlyChangeRatio: 0.052,
            monthlyChangeAmount: 63_500,
            lastUpdated: Date(),
            highlights: [
                Highlight(title: "帳戶總數", value: "5 個"),
                Highlight(title: "進行中目標", value: "3 項"),
                Highlight(title: "本月儲蓄", value: NumberFormatter.formattedCurrencyString(for: Decimal(25_800)))
            ]
        )
    }()
}

private struct MonthlyTrendPoint: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Decimal

    var amountDouble: Double {
        NSDecimalNumber(decimal: amount).doubleValue
    }

    static func sampleSixMonths(referenceDate: Date = Date()) -> [MonthlyTrendPoint] {
        let calendar = Calendar(identifier: .gregorian)
        let baseAmounts: [Decimal] = [
            1_120_000,
            1_165_000,
            1_190_000,
            1_235_000,
            1_260_000,
            1_284_500
        ]

        return baseAmounts.enumerated().compactMap { index, amount in
            guard let date = calendar.date(byAdding: .month, value: index - (baseAmounts.count - 1), to: referenceDate) else {
                return nil
            }
            return MonthlyTrendPoint(date: date, amount: amount)
        }
        .sorted { $0.date < $1.date }
    }
}

private struct HomeQuickAction: Identifiable {
    enum Style {
        case primary
        case secondary
        case accent
        case neutral
    }

    let id = UUID()
    let title: String
    let subtitle: String
    let iconName: String
    let style: Style

    static let sampleActions: [HomeQuickAction] = [
        HomeQuickAction(
            title: "新增帳戶",
            subtitle: "建立不同資產帳戶",
            iconName: "plus.app.fill",
            style: .primary
        ),
        HomeQuickAction(
            title: "記錄交易",
            subtitle: "更新最新的收支",
            iconName: "square.and.pencil",
            style: .secondary
        ),
        HomeQuickAction(
            title: "設定儲蓄目標",
            subtitle: "規劃下一個里程碑",
            iconName: "target",
            style: .accent
        ),
        HomeQuickAction(
            title: "查看分析",
            subtitle: "審視資產趨勢",
            iconName: "chart.bar.doc.horizontal",
            style: .neutral
        )
    ]
}

// MARK: - Subviews

private struct QuickActionCard: View {
    let action: HomeQuickAction
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Image(systemName: action.iconName)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(Color.white)
                .padding(Constants.Spacing.sm)
                .background(
                    Circle()
                        .fill(iconBackgroundColor)
                )

            VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                Text(action.title)
                    .font(Constants.Typography.body.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                Text(action.subtitle)
                    .font(Constants.Typography.caption)
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .padding(Constants.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Constants.CornerRadius.small, style: .continuous)
                .fill(cardFillColor)
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.CornerRadius.small, style: .continuous)
                        .stroke(borderColor, lineWidth: borderLineWidth)
                )
        )
        .shadow(color: shadowColor, radius: 6, x: 0, y: 4)
        .contentShape(RoundedRectangle(cornerRadius: Constants.CornerRadius.small, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityHint(Text(action.subtitle))
    }

    private var iconBackgroundColor: Color {
        switch action.style {
        case .primary:
            return ThemeColor.primary.color
        case .secondary:
            return ThemeColor.secondary.color
        case .accent:
            return ThemeColor.accent.color
        case .neutral:
            return Color.textPrimary.opacity(0.75)
        }
    }

    private var cardFillColor: Color {
        switch action.style {
        case .primary:
            return ThemeColor.primary.color.opacity(colorScheme == .dark ? 0.36 : 0.18)
        case .secondary:
            return ThemeColor.secondary.color.opacity(colorScheme == .dark ? 0.32 : 0.18)
        case .accent:
            return ThemeColor.accent.color.opacity(colorScheme == .dark ? 0.32 : 0.2)
        case .neutral:
            return colorScheme == .dark ? Color.surfaceSecondary : Color.surfaceSecondary
        }
    }

    private var borderColor: Color {
        switch action.style {
        case .primary:
            return ThemeColor.primary.color.opacity(colorScheme == .dark ? 0.45 : 0.25)
        case .secondary:
            return ThemeColor.secondary.color.opacity(colorScheme == .dark ? 0.4 : 0.25)
        case .accent:
            return ThemeColor.accent.color.opacity(colorScheme == .dark ? 0.4 : 0.25)
        case .neutral:
            return Color.white.opacity(colorScheme == .dark ? 0.1 : 0.08)
        }
    }

    private var borderLineWidth: CGFloat {
        1
    }

    private var shadowColor: Color {
        colorScheme == .dark ? Color.clear : Color.black.opacity(0.08)
    }

}

#Preview {
    HomeView()
        .environmentObject(ThemeService())
}
