import Charts
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.colorScheme) private var colorScheme

    private let quickActions = HomeQuickAction.sampleActions

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: Constants.Spacing.xl) {
                    HomeHeaderView() // Added custom header
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
            // .navigationTitle("首頁") // Removed standard title
            .toolbar(.hidden, for: .navigationBar) // Hide default nav bar
            .refreshable {
                await viewModel.refresh()
            }
        }
    }
}

// MARK: - Sections

private extension HomeView {
    var heroCard: some View {
        TotalAssetsCard(
            summary: viewModel.summary,
            lastUpdatedText: lastUpdatedText,
            trendIconName: trendIcon,
            trendDescription: trendDescription,
            trendSubtitle: trendSubtitle
        )
        .skeletonOverlay(isActive: viewModel.isLoading, cornerRadius: Constants.CornerRadius.large)
    }

    var monthlyTrendSection: some View {
        CardContainer(
            title: "6 個月資產趨勢",
            subtitle: "依據最新資料計算",
            icon: Image(systemName: "chart.line.uptrend.xyaxis")
        ) {
            MonthlyTrendChart(
                points: viewModel.trendPoints,
                summaryText: trendSummary
            )
        }
        .skeletonOverlay(isActive: viewModel.isLoading, cornerRadius: Constants.CornerRadius.large)
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
        .skeletonOverlay(isActive: viewModel.isLoading, cornerRadius: Constants.CornerRadius.large)
    }

    var trendIcon: String {
        viewModel.summary.monthlyChangeRatio >= 0 ? "arrow.up.right.circle.fill" : "arrow.down.right.circle.fill"
    }

    var trendDescription: String {
        let percentFormatter = NumberFormatter()
        percentFormatter.numberStyle = .percent
        percentFormatter.maximumFractionDigits = 1
        percentFormatter.minimumFractionDigits = 0
        percentFormatter.locale = Locale(identifier: "zh_TW")
        let percentText = percentFormatter.string(from: NSNumber(value: viewModel.summary.monthlyChangeRatio)) ?? "0%"
        let amountText = NumberFormatter.formattedCurrencyString(for: viewModel.summary.monthlyChangeAmount)
        let direction = viewModel.summary.monthlyChangeRatio >= 0 ? "本月上升" : "本月下降"
        return "\(direction) \(percentText)（\(amountText)）"
    }

    var trendSubtitle: String {
        viewModel.summary.monthlyChangeRatio >= 0 ? "保持穩健表現，繼續朝目標邁進。" : "建議檢視近期支出，調整儲蓄策略。"
    }

    var trendSummary: String {
        guard let latest = viewModel.trendPoints.last else {
            return "目前尚未取得資產趨勢資訊。"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy 年 M 月"
        let latestText = formatter.string(from: latest.date)
        return "已根據最近 \(viewModel.trendPoints.count) 筆紀錄計算趨勢，最新資料為 \(latestText)。"
    }

    var lastUpdatedText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.dateFormat = "更新於 MMM d 日 HH:mm"
        return formatter.string(from: viewModel.summary.lastUpdated)
    }
}

// MARK: - Helpers

private extension HomeView {
    var quickActionColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: Constants.Spacing.md),
            GridItem(.flexible(), spacing: Constants.Spacing.md)
        ]
    }
}

// MARK: - Models

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
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Image(systemName: action.iconName)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(iconForegroundColor)
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
            return ThemeColor.primary.color.adjustedForHighContrast(colorSchemeContrast)
        case .secondary:
            return ThemeColor.secondary.color.adjustedForHighContrast(colorSchemeContrast)
        case .accent:
            return ThemeColor.accent.color.adjustedForHighContrast(colorSchemeContrast)
        case .neutral:
            return Color.textPrimary.opacity(0.75)
        }
    }

    private var iconForegroundColor: Color {
        iconBackgroundColor.accessibleTextColor(contrast: colorSchemeContrast)
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

// MARK: - Header View

struct HomeHeaderView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingText)
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                
                Text("Mark") // Placeholder for user name
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.textPrimary)
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                // Notification Button
                Button {
                    // Action
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Color.textPrimary)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(Color.surfaceSecondary)
                            )
                        
                        // Badge
                        Circle()
                            .fill(ThemeColor.accent.color)
                            .frame(width: 10, height: 10)
                            .offset(x: 0, y: 0)
                            .overlay(
                                Circle()
                                    .stroke(Color.appBackground, lineWidth: 2)
                            )
                    }
                }
                
                // Profile/Settings Button
                Button {
                    // Action
                } label: {
                    Image(systemName: "person.circle.fill") // Placeholder for avatar
                        .font(.system(size: 40))
                        .foregroundStyle(Color.textSecondary)
                        .background(
                            Circle()
                                .fill(Color.surfaceSecondary)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.surfaceSecondary, lineWidth: 2)
                        )
                }
            }
        }
        .padding(.bottom, Constants.Spacing.sm)
    }
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "早安，準備好開始新的一天了嗎？"
        case 12..<18: return "午安，記得休息一下喔"
        case 18..<22: return "晚安，今天過得如何？"
        default: return "夜深了，早點休息吧"
        }
    }
}
