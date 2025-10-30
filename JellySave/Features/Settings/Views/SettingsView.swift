import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var selectedQuoteType = 0
    @State private var notificationTime = DateComponents(hour: 21, minute: 0)

    private let quoteOptions = ["投資啟發", "激勵語錄", "節省提醒"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Constants.Layout.sectionSpacing) {
                    notificationSection
                    syncSection
                    aboutSection
                }
                .sectionPadding()
                .padding(.vertical, 24)
            }
            .background(ThemeColor.background(for: colorScheme).ignoresSafeArea())
            .navigationTitle("設置")
        }
    }

    @Environment(\.colorScheme) private var colorScheme
}

private extension SettingsView {
    var notificationSection: some View {
        CardContainer(title: "通知", subtitle: "每日提醒與激勵內容", iconName: "bell.badge.fill") {
            VStack(alignment: .leading, spacing: 16) {
                Toggle(isOn: $notificationsEnabled) {
                    Text("啟用每日通知")
                        .font(Constants.Typography.body)
                        .foregroundColor(ThemeColor.neutralDark)
                }
                .toggleStyle(SwitchToggleStyle(tint: ThemeColor.primary))

                VStack(alignment: .leading, spacing: 8) {
                    Text("通知時間")
                        .font(Constants.Typography.caption)
                        .foregroundColor(ThemeColor.neutralDark.opacity(0.6))

                    HStack(spacing: 12) {
                        Image(systemName: "clock")
                            .foregroundColor(ThemeColor.primary)
                        Text(String(format: "%02d:%02d", notificationTime.hour ?? 21, notificationTime.minute ?? 0))
                            .font(Constants.Typography.body.weight(.semibold))
                            .foregroundColor(ThemeColor.neutralDark)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(ThemeColor.neutralDark.opacity(0.4))
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: Constants.CornerRadius.medium, style: .continuous)
                            .fill(ThemeColor.cardBackground(for: colorScheme))
                    )
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("通知類型")
                        .font(Constants.Typography.caption)
                        .foregroundColor(ThemeColor.neutralDark.opacity(0.6))

                    ForEach(quoteOptions.indices, id: \.self) { index in
                        HStack {
                            Text(quoteOptions[index])
                                .font(Constants.Typography.body)
                                .foregroundColor(ThemeColor.neutralDark)
                            Spacer()
                            if selectedQuoteType == index {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(ThemeColor.primary)
                            }
                        }
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedQuoteType = index
                        }
                        if index != quoteOptions.indices.last {
                            Divider().background(ThemeColor.neutralLight)
                        }
                    }
                }
            }
        }
    }

    var syncSection: some View {
        CardContainer(title: "同步與資料", subtitle: "iCloud 與匯出") {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("iCloud 同步啟用", systemImage: "icloud.fill")
                        .foregroundColor(ThemeColor.primary)
                    Spacer()
                    Text("已連線")
                        .font(Constants.Typography.caption)
                        .foregroundColor(ThemeColor.success)
                }

                Divider().background(ThemeColor.neutralLight)

                Label("上次同步：5 分鐘前", systemImage: "arrow.clockwise")
                    .font(Constants.Typography.caption)
                    .foregroundColor(ThemeColor.neutralDark.opacity(0.7))

                CustomButton("匯出交易紀錄", iconName: "square.and.arrow.up", style: .outline) {}
                    .fillWidth()
            }
        }
    }

    var aboutSection: some View {
        CardContainer(title: "關於 JellySave", subtitle: "版本 1.0.0") {
            VStack(alignment: .leading, spacing: 12) {
                Text("JellySave 是你的個人財務助手，協助掌握資產、目標與每日激勵提醒。")
                    .font(Constants.Typography.body)
                    .foregroundColor(ThemeColor.neutralDark.opacity(0.8))

                Divider().background(ThemeColor.neutralLight)

                VStack(alignment: .leading, spacing: 6) {
                    Label("隱私政策", systemImage: "lock.shield")
                    Label("使用條款", systemImage: "doc.text")
                    Label("聯絡我們", systemImage: "envelope")
                }
                .font(Constants.Typography.caption)
                .foregroundColor(ThemeColor.primary)
            }
        }
    }
}

#Preview {
    SettingsView()
}
