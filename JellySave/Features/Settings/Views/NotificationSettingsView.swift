import SwiftUI

struct NotificationSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        SettingsCard(title: "通知設定", icon: "bell.badge.fill", accent: ThemeColor.primary.color) {
            Toggle(isOn: $viewModel.notificationsEnabled) {
                VStack(alignment: .leading, spacing: Constants.Spacing.xxs) {
                    Text("啟用每日提醒")
                        .font(Constants.Typography.body.weight(.semibold))
                    Text("在指定時間推送激勵通知")
                        .font(Constants.Typography.caption)
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: ThemeColor.primary.color))
            .onChange(of: viewModel.notificationsEnabled) { _ in
                viewModel.saveNotificationSettings()
            }

            Divider()

            VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                Text("通知時間")
                    .font(Constants.Typography.body.weight(.semibold))
                TimeSelector(time: Binding(
                    get: { viewModel.notificationTime },
                    set: { viewModel.notificationTime = $0; viewModel.saveNotificationSettings() }
                ))

                Picker("通知內容", selection: Binding(
                    get: { viewModel.selectedCategory },
                    set: { viewModel.selectedCategory = $0; viewModel.saveNotificationSettings() }
                )) {
                    ForEach(QuoteCategory.allCases) { category in
                        Text(category.displayName).tag(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                if let preview = viewModel.latestQuotePreview {
                    Text("範例：\n\(preview.formatted)")
                        .font(Constants.Typography.caption)
                        .foregroundStyle(Color.textSecondary)
                        .padding(.top, Constants.Spacing.sm)
                }

                CustomButton(title: "更新通知排程", style: .outline) {
                    viewModel.saveNotificationSettings()
                }
                .disabled(viewModel.isSaving)
            }
            .disabled(!viewModel.notificationsEnabled)
            .opacity(viewModel.notificationsEnabled ? 1 : 0.5)

            CustomButton(title: "請求通知權限", style: .secondary) {
                viewModel.requestNotificationPermission()
            }
            .padding(.top, Constants.Spacing.sm)
        }
    }
}

struct TimeSelector: View {
    @Binding var time: DateComponents

    var body: some View {
        HStack(spacing: Constants.Spacing.md) {
            Picker("時", selection: Binding(get: { time.hour ?? 0 }, set: { time.hour = $0 })) {
                ForEach(0..<24, id: \.self) { hour in
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
