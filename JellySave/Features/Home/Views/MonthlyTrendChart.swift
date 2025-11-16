import Charts
import SwiftUI

struct MonthlyTrendChart: View {
    let points: [MonthlyTrendPoint]
    let summaryText: String

    var body: some View {
        if points.isEmpty {
            EmptyStateView(
                title: "暫無趨勢資料",
                message: "先新增幾筆帳戶紀錄，就能看到完整的資產走勢。"
            )
        } else {
            Chart(points) { point in
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
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("6 個月資產趨勢"))
            .accessibilityValue(Text(summaryText))
            .accessibilityHint(Text("根據最近的資產紀錄計算"))

            Divider()

            VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                Text("摘要")
                    .font(Constants.Typography.body.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                Text(summaryText)
                    .font(Constants.Typography.body)
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }
}
