import Charts
import SwiftUI

struct MonthlyTrendChart: View {
    let points: [MonthlyTrendPoint]
    let summaryText: String

    @State private var selectedDate: Date?
    @State private var selectedTab: TrendTab = .totalAssets
    @Environment(\.colorScheme) private var colorScheme

    private enum TrendTab: String, CaseIterable {
        case totalAssets = "總資產"
        case monthlyChange = "月變化"
    }

    var body: some View {
        if points.isEmpty {
            EmptyStateView(
                title: "暫無趨勢資料",
                message: "先新增幾筆帳戶紀錄，就能看到完整的資產走勢。"
            )
        } else {
            VStack(alignment: .leading, spacing: Constants.Spacing.md) {
                // 1. 標題、數值與切換器
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(headerDateText)
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)
                        
                        Text(headerAmountText)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(headerColor)
                            .contentTransition(.numericText())
                    }
                    
                    Spacer()
                    
                    Picker("顯示模式", selection: $selectedTab) {
                        ForEach(TrendTab.allCases, id: \.self) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 140)
                }
                .padding(.horizontal, Constants.Spacing.xs)

                // 2. 互動式圖表
                Chart {
                    if selectedTab == .totalAssets {
                        totalAssetsLayers
                    } else {
                        monthlyChangeLayers
                    }

                    // 選取時的指標 (共用)
                    if let selectedDate {
                        RuleMark(
                            x: .value("Selected", selectedDate)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .foregroundStyle(Color.textSecondary.opacity(0.5))
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .month)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(date, format: .dateTime.month(.abbreviated))
                                    .font(.caption2)
                                    .foregroundStyle(Color.textSecondary)
                            }
                        }
                    }
                }
                .chartYAxis(.hidden)
                .chartOverlay { proxy in
                    GeometryReader { geometry in
                        Rectangle().fill(.clear).contentShape(Rectangle())
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let x = value.location.x - geometry[proxy.plotAreaFrame].origin.x
                                        if let date: Date = proxy.value(atX: x) {
                                            findClosestDate(to: date)
                                        }
                                    }
                                    .onEnded { _ in
                                        selectedDate = nil
                                    }
                            )
                    }
                }
                .frame(height: 220)
                .animation(.easeInOut, value: selectedTab)
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel(Text("資產趨勢圖表"))
            .accessibilityHint(Text("可切換總資產或月變化，長按並拖曳可查看詳細數值"))
        }
    }

    // MARK: - Chart Layers

    @ChartContentBuilder
    private var totalAssetsLayers: some ChartContent {
        ForEach(points) { point in
            // 漸層區域
            AreaMark(
                x: .value("月份", point.date),
                y: .value("資產金額", point.amountDouble)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        ThemeColor.primary.color.opacity(0.3),
                        ThemeColor.primary.color.opacity(0.02)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .interpolationMethod(.catmullRom)

            // 折線
            LineMark(
                x: .value("月份", point.date),
                y: .value("資產金額", point.amountDouble)
            )
            .foregroundStyle(ThemeColor.primary.color)
            .interpolationMethod(.catmullRom)
            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
        }

        if let selectedDate, let point = points.first(where: { Calendar.current.isDate($0.date, equalTo: selectedDate, toGranularity: .month) }) {
            PointMark(
                x: .value("Selected", point.date),
                y: .value("Amount", point.amountDouble)
            )
            .foregroundStyle(.white)
            .symbolSize(100)
        }
    }

    @ChartContentBuilder
    private var monthlyChangeLayers: some ChartContent {
        ForEach(monthlyChanges) { point in
            BarMark(
                x: .value("月份", point.date),
                y: .value("變化金額", point.changeDouble)
            )
            .foregroundStyle(point.changeDouble >= 0 ? ThemeColor.success.color : ThemeColor.accent.color)
            .cornerRadius(4)
        }
    }

    // MARK: - Helpers

    private var monthlyChanges: [MonthlyChangePoint] {
        guard points.count > 1 else { return [] }
        return zip(points.dropFirst(), points).map { current, previous in
            MonthlyChangePoint(date: current.date, change: current.amount - previous.amount)
        }
    }

    private func findClosestDate(to date: Date) {
        let dataPoints = selectedTab == .totalAssets ? points.map { $0.date } : monthlyChanges.map { $0.date }
        if let closest = dataPoints.min(by: { abs($0.timeIntervalSince(date)) < abs($1.timeIntervalSince(date)) }) {
            selectedDate = closest
        }
    }

    private var headerDateText: String {
        let date = selectedDate ?? points.last?.date ?? Date()
        return date.formatted(.dateTime.year().month())
    }

    private var headerAmountText: String {
        if selectedTab == .totalAssets {
            let amount = points.first(where: { Calendar.current.isDate($0.date, equalTo: selectedDate ?? points.last?.date ?? Date(), toGranularity: .month) })?.amount ?? points.last?.amount ?? 0
            return NumberFormatter.formattedCurrencyString(for: amount)
        } else {
            let date = selectedDate ?? monthlyChanges.last?.date ?? Date()
            let amount = monthlyChanges.first(where: { Calendar.current.isDate($0.date, equalTo: date, toGranularity: .month) })?.change ?? 0
            let prefix = amount > 0 ? "+" : ""
            return prefix + NumberFormatter.formattedCurrencyString(for: amount)
        }
    }

    private var headerColor: Color {
        if selectedTab == .monthlyChange {
            let date = selectedDate ?? monthlyChanges.last?.date ?? Date()
            let amount = monthlyChanges.first(where: { Calendar.current.isDate($0.date, equalTo: date, toGranularity: .month) })?.change ?? 0
            return amount >= 0 ? ThemeColor.success.color : ThemeColor.accent.color
        }
        return Color.textPrimary
    }

    private struct MonthlyChangePoint: Identifiable {
        let id = UUID()
        let date: Date
        let change: Decimal
        var changeDouble: Double { NSDecimalNumber(decimal: change).doubleValue }
    }
}
