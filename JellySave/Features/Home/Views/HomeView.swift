import SwiftUI

struct HomeView: View {
    private let quickActions: [QuickAction] = [
        QuickAction(title: "新增帳戶", subtitle: "建立新的銀行或投資帳戶", iconName: "plus.circle"),
        QuickAction(title: "建立儲蓄目標", subtitle: "設定你想達成的里程碑", iconName: "target"),
        QuickAction(title: "查看報告", subtitle: "檢視月度趨勢與分析", iconName: "chart.bar.xaxis")
    ]

    private let recentInsights: [Insight] = [
        Insight(title: "本月已儲蓄", value: NumberFormatter.twdString(from: Decimal(18_500)), descriptor: "+ 12% vs 上月"),
        Insight(title: "距離目標", value: NumberFormatter.twdString(from: Decimal(31_500)), descriptor: "預估 3 個月達成"),
        Insight(title: "通知排程", value: "每日 21:00", descriptor: "提醒保持儲蓄節奏")
    ]

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
            VStack(alignment: .leading, spacing: 16) {
                Text("總資產")
                    .font(Constants.Typography.caption)
                    .foregroundStyle(Color.white.opacity(0.8))

                Text(NumberFormatter.twdString(from: Decimal(820_000)))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)

                HStack(spacing: 16) {
                    ForEach(recentInsights) { insight in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(insight.title)
                                .font(Constants.Typography.caption)
                                .foregroundStyle(Color.white.opacity(0.8))
                            Text(insight.value)
                                .font(Constants.Typography.body.weight(.semibold))
                                .foregroundStyle(Color.white)
                            Text(insight.descriptor)
                                .font(Constants.Typography.caption)
                                .foregroundStyle(Color.white.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                CustomButton("新增交易", iconName: "arrow.up.arrow.down", style: .secondary) {}
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity)
    }

    var monthlyTrendCard: some View {
        CardContainer(title: "月度趨勢", subtitle: "最近 6 個月", iconName: "chart.line.uptrend.xyaxis", actionTitle: "查看詳情") {
            placeholderChart
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
                                Text(action.subtitle)
                                    .font(Constants.Typography.caption)
                                    .foregroundColor(ThemeColor.neutralDark.opacity(0.6))
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(ThemeColor.neutralDark.opacity(0.4))
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: Constants.CornerRadius.medium, style: .continuous)
                                .fill(ThemeColor.cardBackground(for: colorScheme))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .cardBackground(showShadow: false)
    }

    var placeholderChart: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let width = geometry.size.width
            let points: [CGFloat] = [0.2, 0.35, 0.45, 0.4, 0.55, 0.72]
            let step = width / CGFloat(points.count - 1)

            Path { path in
                guard let first = points.first else { return }
                path.move(to: CGPoint(x: 0, y: height * (1 - first)))
                for (index, value) in points.enumerated() where index > 0 {
                    let point = CGPoint(x: CGFloat(index) * step, y: height * (1 - value))
                    path.addLine(to: point)
                }
            }
            .stroke(ThemeColor.primary.opacity(0.7), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            .background(
                RoundedRectangle(cornerRadius: Constants.CornerRadius.medium, style: .continuous)
                    .fill(ThemeColor.neutralLight.opacity(0.4))
            )
        }
        .frame(height: 180)
        .padding(.top, 12)
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
}

#Preview {
    HomeView()
}
