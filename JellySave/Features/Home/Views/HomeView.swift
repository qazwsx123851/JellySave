import SwiftUI
import Charts

struct HomeView: View {
    private let quickActions: [QuickAction] = [
        QuickAction(title: "新增帳戶", subtitle: "建立新的銀行或投資帳戶", iconName: "plus.circle"),
        QuickAction(title: "建立儲蓄目標", subtitle: "設定你想達成的里程碑", iconName: "target"),
        QuickAction(title: "查看報告", subtitle: "檢視月度趨勢與分析", iconName: "chart.bar.xaxis")
    ]

    private let recentInsights: [Insight] = [
        Insight(
            title: "本月已儲蓄",
            value: NumberFormatter.twdString(from: Decimal(18_500)),
            descriptor: "+ 12% vs 上月",
            systemImage: "arrow.up.right"
        ),
        Insight(
            title: "距離目標",
            value: NumberFormatter.twdString(from: Decimal(31_500)),
            descriptor: "預估 3 個月達成",
            systemImage: "target"
        ),
        Insight(
            title: "通知排程",
            value: "每日 21:00",
            descriptor: "提醒保持儲蓄節奏",
            systemImage: "bell.badge"
        )
    ]
    private let monthlyTrend: [MonthlyTrendPoint] = [
        MonthlyTrendPoint(label: "5 月", value: 680_000),
        MonthlyTrendPoint(label: "6 月", value: 702_500),
        MonthlyTrendPoint(label: "7 月", value: 719_000),
        MonthlyTrendPoint(label: "8 月", value: 735_500),
        MonthlyTrendPoint(label: "9 月", value: 789_200),
        MonthlyTrendPoint(label: "10 月", value: 820_000)
    ]

    @State private var displayedMonthlyTrend: [MonthlyTrendPoint] = []
    @State private var trendAnimationTask: Task<Void, Never>?
    @State private var hasAnimatedMonthlyTrend = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Constants.Layout.sectionSpacing) {
                    totalAssetsCard
                    monthlyTrendCard
                    quickActionsSection
                }
                .sectionPadding()
                .padding(.vertical, 24)
                .onDisappear(perform: cancelTrendAnimation)
            }
            .background(ThemeColor.background(for: colorScheme).ignoresSafeArea())
            .navigationTitle("首頁")
        }
    }

    @Environment(\.colorScheme) private var colorScheme
}

private extension HomeView {
    var totalAssetsCard: some View {
        ZStack(alignment: .leading) {
            GradientBackground(style: .hero, cornerRadius: Constants.CornerRadius.large)
                // 透過放射漸層與陰影營造主視覺焦點。
                .overlay(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.32),
                            Color.white.opacity(0.08)
                        ],
                        center: .topTrailing,
                        startRadius: 10,
                        endRadius: 220
                    )
                    .clipShape(RoundedRectangle(cornerRadius: Constants.CornerRadius.large, style: .continuous))
                )
                .shadow(color: ThemeColor.primary.opacity(0.23), radius: 18, x: 0, y: 12)
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.22))
                            .frame(width: 48, height: 48)
                        Image(systemName: "leaf.fill")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("總資產")
                            .font(Constants.Typography.caption)
                            .foregroundStyle(Color.white.opacity(0.85))
                        Text("以最新匯入資料更新")
                            .font(Constants.Typography.caption)
                            .foregroundStyle(Color.white.opacity(0.65))
                    }
                }

                Text(NumberFormatter.twdString(from: Decimal(820_000)))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                    .minimumScaleFactor(0.85)

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(recentInsights.enumerated()), id: \.element.id) { index, insight in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: insight.systemImage)
                                .foregroundStyle(Color.white.opacity(0.8))
                                .font(.title3)
                                .accessibilityHidden(true)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(insight.title)
                                    .font(Constants.Typography.caption)
                                    .foregroundStyle(Color.white.opacity(0.9))
                                Text(insight.value)
                                    .font(Constants.Typography.body.weight(.semibold))
                                    .foregroundStyle(Color.white)
                                    .lineLimit(2)
                                Text(insight.descriptor)
                                    .font(Constants.Typography.caption)
                                    .foregroundStyle(Color.white.opacity(0.7))
                            }
                            Spacer()
                        }
                        if index != recentInsights.count - 1 {
                            Divider()
                                .background(Color.white.opacity(0.2))
                        }
                    }
                }
                .dynamicTypeSize(.medium ... .accessibility3)

                CustomButton("新增交易", iconName: "sparkles", style: .secondary) {}
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity)
        .dynamicTypeSize(.medium ... .accessibility3)
    }

    var monthlyTrendCard: some View {
        CardContainer(title: "月度趨勢", subtitle: "最近 6 個月", iconName: "chart.line.uptrend.xyaxis", actionTitle: "查看詳情") {
            // 透過 Swift Charts 呈現折線與面積，並帶入漸進動畫。
            Chart(displayedMonthlyTrend) { point in
                AreaMark(
                    x: .value("月份", point.label),
                    y: .value("資產", point.value)
                )
                .foregroundStyle(
                    .linearGradient(
                        Gradient(colors: [ThemeColor.primary.opacity(0.35), ThemeColor.secondary.opacity(0.1)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                LineMark(
                    x: .value("月份", point.label),
                    y: .value("資產", point.value)
                )
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                .foregroundStyle(ThemeColor.primary)
                .interpolationMethod(.catmullRom)
                PointMark(
                    x: .value("月份", point.label),
                    y: .value("資產", point.value)
                )
                .foregroundStyle(ThemeColor.primary)
                .symbolSize(40)
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisValueLabel(format: .currency(code: "TWD"))
                        .foregroundStyle(ThemeColor.neutralDark.opacity(0.7))
                }
            }
            .chartXAxis {
                AxisMarks(values: displayedMonthlyTrend.map(\.label))
            }
            .chartPlotStyle { plot in
                plot.background(Color.clear)
                    .cornerRadius(Constants.CornerRadius.medium)
            }
            .frame(height: 200)
            .padding(.top, 12)
            .animation(.easeInOut(duration: 0.3), value: displayedMonthlyTrend)
            .onAppear(perform: animateMonthlyTrendIfNeeded)
            .onDisappear(perform: cancelTrendAnimation)
        }
    }

    var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("快速操作")
                .font(Constants.Typography.headline)
                .foregroundColor(ThemeColor.neutralDark)

            VStack(spacing: 14) {
                ForEach(quickActions) { action in
                    Button(action: {}) {
                        HStack(spacing: 16) {
                            Image(systemName: action.iconName)
                                .font(.title3)
                                .foregroundColor(ThemeColor.primary)
                                .frame(width: 36, height: 36)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(action.title)
                                    .font(Constants.Typography.body.weight(.semibold))
                                    .foregroundColor(ThemeColor.neutralDark)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.9)
                                Text(action.subtitle)
                                    .font(Constants.Typography.caption)
                                    .foregroundColor(ThemeColor.neutralDark.opacity(0.6))
                                    .lineLimit(2)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(ThemeColor.neutralDark.opacity(0.4))
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: Constants.CornerRadius.medium, style: .continuous)
                                .fill(ThemeColor.cardBackground(for: colorScheme).opacity(0.92))
                                .overlay(
                                    RoundedRectangle(cornerRadius: Constants.CornerRadius.medium, style: .continuous)
                                        .stroke(ThemeColor.primary.opacity(0.12), lineWidth: 1)
                                )
                        )
                        // 讓快捷卡片在點擊時有微縮放回饋，感受更輕快。
                        .shadow(color: ThemeColor.primary.opacity(0.08), radius: 10, x: 0, y: 6)
                    }
                    .buttonStyle(.plain)
                    .pressableCardStyle()
                    .contentShape(Rectangle())
                    .accessibilityLabel(Text("\(action.title)，\(action.subtitle)"))
                }
            }
        }
        .cardBackground(showShadow: false)
    }
}

private struct QuickAction: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let iconName: String
}

private struct Insight: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let descriptor: String
    let systemImage: String
}

private struct MonthlyTrendPoint: Identifiable, Equatable {
    let id = UUID()
    let label: String
    let value: Double
}

private extension HomeView {
    /// 只在初次出現時觸發折線動畫。
    func animateMonthlyTrendIfNeeded() {
        guard !hasAnimatedMonthlyTrend, displayedMonthlyTrend.isEmpty else { return }
        hasAnimatedMonthlyTrend = true
        trendAnimationTask?.cancel()
        trendAnimationTask = Task {
            for (index, point) in monthlyTrend.enumerated() {
                if Task.isCancelled { break }
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        displayedMonthlyTrend.append(point)
                    }
                }
                if index != monthlyTrend.count - 1 {
                    try? await Task.sleep(nanoseconds: 160_000_000)
                }
            }
            trendAnimationTask = nil
        }
    }

    /// 離開畫面時中止動畫，避免重複排程。
    func cancelTrendAnimation() {
        trendAnimationTask?.cancel()
        trendAnimationTask = nil
        displayedMonthlyTrend = []
        hasAnimatedMonthlyTrend = false
    }
}


#Preview {
    HomeView()
}
