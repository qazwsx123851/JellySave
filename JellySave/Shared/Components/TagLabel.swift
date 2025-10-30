import SwiftUI

/// 以主題色快速標記資料類型的徽章。
struct TagLabel: View {
    let text: String
    let identifier: String
    let systemImage: String?

    var body: some View {
        HStack(spacing: 6) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.caption)
            }
            Text(text)
                .font(Constants.Typography.caption.weight(.semibold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .foregroundColor(ThemeBadge.foreground(for: identifier))
        .background(
            Capsule(style: .continuous)
                .fill(ThemeBadge.background(for: identifier))
        )
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        TagLabel(text: "銀行帳戶", identifier: "bank", systemImage: "building.columns")
        TagLabel(text: "投資", identifier: "investment", systemImage: "chart.line.uptrend.xyaxis")
        TagLabel(text: "現金", identifier: "cash", systemImage: "dollarsign")
    }
    .padding()
}
