import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var notificationTime = DateComponents(hour: 9, minute: 30)
    @State private var selectedQuoteType = 0
    @State private var selectedTheme: AppTheme = .system
    @State private var biometricEnabled = true
    @State private var autoLockDuration = 30
    @State private var analyticsEnabled = false

    private let quoteTypes = ["儲蓄激勵", "投資建議"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Constants.Spacing.xl) {
                    notificationSection
                    themeSection
                    securitySection
                    dataManagementSection
                    aboutSection
                }
                .padding(.horizontal, Constants.Spacing.md)
                .padding(.vertical, Constants.Spacing.xl)
                .maxWidthLayout()
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("設定")
        }
    }
}

// MARK: - Sections

private extension SettingsView {
    var notificationSection: some View {
        SettingsCard(title: "通知設定", icon: "bell.badge.fill", accent: ThemeColor.primary.color) {
            Toggle(isOn: $notificationsEnabled) {
                VStack(alignment: .leading, spacing: Constants.Spacing.xxs) {
                    Text("啟用每日提醒")
                        .font(Constants.Typography.body.weight(.semibold))
                    Text("在指定時間推送激勵通知")
                        .font(Constants.Typography.caption)
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: ThemeColor.primary.color))

            Divider()

            VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                Text("通知時間")
                    .font(Constants.Typography.body.weight(.semibold))
                TimeSelector(time: $notificationTime)

                Picker("通知內容", selection: $selectedQuoteType) {
                    ForEach(quoteTypes.indices, id: \.self) { index in
                        Text(quoteTypes[index]).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .disabled(!notificationsEnabled)
            .opacity(notificationsEnabled ? 1 : 0.5)
        }
    }

    var themeSection: some View {
        SettingsCard(title: "主題外觀", icon: "paintpalette.fill", accent: ThemeColor.secondary.color) {
            VStack(alignment: .leading, spacing: Constants.Spacing.md) {
                Text("顏色模式")
                    .font(Constants.Typography.body.weight(.semibold))

                ForEach(AppTheme.allCases) { theme in
                    HStack {
                        VStack(alignment: .leading, spacing: Constants.Spacing.xxs) {
                            Text(theme.displayName)
                                .font(Constants.Typography.body)
                            Text(themeDescription(for: theme))
                                .font(Constants.Typography.caption)
                                .foregroundStyle(Color.textSecondary)
                        }
                        Spacer()
                        RadioIndicator(isSelected: selectedTheme == theme)
                    }
                    .padding(Constants.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: Constants.CornerRadius.medium, style: .continuous)
                            .fill(Color.surfaceSecondary)
                    )
                    .onTapGesture {
                        selectedTheme = theme
                    }
                }

                CustomButton(title: "同步系統今日色彩", style: .outline, action: {})
            }
        }
    }

    var securitySection: some View {
        SettingsCard(title: "安全與隱私", icon: "lock.shield.fill", accent: ThemeColor.success.color) {
            Toggle(isOn: $biometricEnabled) {
                VStack(alignment: .leading, spacing: Constants.Spacing.xxs) {
                    Text("啟用 Face ID")
                        .font(Constants.Typography.body.weight(.semibold))
                    Text("提升應用程式解鎖安全性")
                        .font(Constants.Typography.caption)
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: ThemeColor.success.color))

            Divider()

            VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                Text("自動鎖定")
                    .font(Constants.Typography.body.weight(.semibold))
                Stepper(value: $autoLockDuration, in: 15...120, step: 15) {
                    Text("閒置 \(autoLockDuration) 秒後鎖定")
                        .font(Constants.Typography.body)
                        .foregroundStyle(Color.textPrimary)
                }
            }

            Toggle(isOn: $analyticsEnabled) {
                VStack(alignment: .leading, spacing: Constants.Spacing.xxs) {
                    Text("匿名字分析")
                        .font(Constants.Typography.body.weight(.semibold))
                    Text("協助優化體驗，不傳送個人資料")
                        .font(Constants.Typography.caption)
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: ThemeColor.success.color))
        }
    }

    var dataManagementSection: some View {
        SettingsCard(title: "資料管理", icon: "externaldrive.fill", accent: ThemeColor.accent.color) {
            VStack(spacing: Constants.Spacing.md) {
                DataManagementRow(
                    title: "匯出資料備份",
                    subtitle: "產生加密檔案並儲存到 iCloud Drive",
                    icon: "arrow.down.circle.fill"
                )

                DataManagementRow(
                    title: "從備份還原",
                    subtitle: "匯入先前匯出的 JellySave 備份檔",
                    icon: "arrow.up.circle.fill"
                )

                DataManagementRow(
                    title: "清除本機資料",
                    subtitle: "刪除所有帳戶與目標資料",
                    icon: "trash.fill",
                    iconColor: ThemeColor.accent.color.opacity(0.85)
                )
            }
        }
    }

    var aboutSection: some View {
        SettingsCard(title: "應用程式資訊", icon: "info.circle.fill", accent: Color.textSecondary) {
            VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                InfoRow(label: "版本", value: "2.0.0 (靜態範例)")
                InfoRow(label: "資料儲存", value: "完全離線 / Core Data")
                InfoRow(label: "開發團隊", value: "JellySave Studio")

                Divider()

                VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                    Text("聯絡與支援")
                        .font(Constants.Typography.body.weight(.semibold))
                    HStack(spacing: Constants.Spacing.md) {
                        SupportLink(title: "支援中心", systemImage: "lifepreserver")
                        SupportLink(title: "使用者指南", systemImage: "book.fill")
                        SupportLink(title: "隱私政策", systemImage: "lock.doc.fill")
                    }
                }
            }
        }
    }

    func themeDescription(for theme: AppTheme) -> String {
        switch theme {
        case .system:
            return "依照系統設定自動切換"
        case .light:
            return "以亮色背景呈現資訊"
        case .dark:
            return "降低炫光、適合夜間使用"
        }
    }
}

// MARK: - Subviews

private struct SettingsCard<Content: View>: View {
    let title: String
    let icon: String
    let accent: Color
    @ViewBuilder var content: Content

    var body: some View {
        CardContainer(
            title: title,
            subtitle: nil,
            icon: Image(systemName: icon)
        ) {
            VStack(alignment: .leading, spacing: Constants.Spacing.lg) {
                content
            }
        }
    }
}

private struct TimeSelector: View {
    @Binding var time: DateComponents

    var body: some View {
        HStack(spacing: Constants.Spacing.md) {
            Picker("時", selection: Binding(get: { time.hour ?? 0 }, set: { time.hour = $0 })) {
                ForEach(0..<24) { hour in
                    Text(String(format: "%02d 時", hour)).tag(hour)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(maxWidth: 140)

                Picker("分", selection: Binding(get: { time.minute ?? 0 }, set: { time.minute = $0 })) {
                    ForEach(Array(stride(from: 0, through: 55, by: 5)), id: \.self) { minute in
                    Text(String(format: "%02d 分", minute)).tag(minute)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(maxWidth: 140)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .background(
            RoundedRectangle(cornerRadius: Constants.CornerRadius.medium, style: .continuous)
                .fill(Color.surfaceSecondary)
        )
    }
}

private struct RadioIndicator: View {
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.divider, lineWidth: 2)
                .frame(width: 24, height: 24)
            if isSelected {
                Circle()
                    .fill(ThemeColor.primary.color)
                    .frame(width: 12, height: 12)
            }
        }
    }
}

private struct DataManagementRow: View {
    let title: String
    let subtitle: String
    let icon: String
    var iconColor: Color = ThemeColor.accent.color

    var body: some View {
        HStack(spacing: Constants.Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: Constants.CornerRadius.medium, style: .continuous)
                    .fill(iconColor.opacity(0.18))
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(iconColor)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: Constants.Spacing.xxs) {
                Text(title)
                    .font(Constants.Typography.body.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                Text(subtitle)
                    .font(Constants.Typography.caption)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.textSecondary.opacity(0.6))
        }
        .padding(Constants.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Constants.CornerRadius.medium, style: .continuous)
                .fill(Color.surfaceSecondary)
        )
    }
}

private struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(Constants.Typography.body)
                .foregroundStyle(Color.textSecondary)
            Spacer()
            Text(value)
                .font(Constants.Typography.body.weight(.semibold))
                .foregroundStyle(Color.textPrimary)
        }
    }
}

private struct SupportLink: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack(spacing: Constants.Spacing.xs) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
            Text(title)
                .font(Constants.Typography.caption)
        }
        .padding(.vertical, Constants.Spacing.xs)
        .padding(.horizontal, Constants.Spacing.sm)
        .background(
            Capsule()
                .fill(Color.surfaceSecondary)
        )
        .foregroundStyle(Color.textPrimary)
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeService())
}
