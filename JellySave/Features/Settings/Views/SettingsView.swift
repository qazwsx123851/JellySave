import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @EnvironmentObject private var themeService: ThemeService
    @EnvironmentObject private var appLockService: AppLockService
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showShareSheet = false
    @State private var isImportingBackup = false
    @State private var showClearAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Constants.Spacing.xl) {
                    NotificationSettingsView(viewModel: viewModel)
                    themeSection
                    securitySection
                    dataManagementSection
                    aboutSection
                }
                .padding(.horizontal, Constants.Spacing.md)
                .padding(.vertical, Constants.Spacing.xl)
                .maxWidthLayout()
                .onAppear {
                    viewModel.updateThemeService(themeService)
                    viewModel.updateAppLockService(appLockService)
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("設定")
        }
        .sheet(isPresented: $showShareSheet, onDismiss: {
            viewModel.resetExportedFileURL()
        }) {
            if let url = viewModel.exportedFileURL {
                ShareSheet(activityItems: [url])
            } else {
                Text("匯出檔案不存在")
                    .padding()
            }
        }
        .sheet(isPresented: $viewModel.isPresentingPasscodeSheet, onDismiss: {
            viewModel.cancelPasscodeSetup()
        }) {
            PasscodeSetupSheet(
                requiresCurrentPasscode: viewModel.passcodeExists,
                onSubmit: { current, new, confirm in
                    viewModel.submitPasscode(current: current, new: new, confirm: confirm)
                }
            )
        }
        .fileImporter(isPresented: $isImportingBackup, allowedContentTypes: [.json]) { result in
            switch result {
            case .success(let url):
                let securityScoped = url.startAccessingSecurityScopedResource()
                Task {
                    defer {
                        if securityScoped {
                            url.stopAccessingSecurityScopedResource()
                        }
                    }
                    await viewModel.importBackup(from: url)
                }
            case .failure(let error):
                viewModel.errorMessage = error.localizedDescription
            }
        }
        .alert("清除本機資料？", isPresented: $showClearAlert) {
            Button("取消", role: .cancel) {}
            Button("清除", role: .destructive) {
                Task {
                    await viewModel.clearAllData()
                }
            }
        } message: {
            Text("此操作會刪除所有帳戶、儲蓄目標與通知設定，且無法復原。")
        }
        .alert("發生錯誤", isPresented: errorAlertBinding) {
            Button("確定", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .alert("操作完成", isPresented: successAlertBinding) {
            Button("了解", role: .cancel) {}
        } message: {
            Text(viewModel.successMessage ?? "")
        }
    }
}

// MARK: - Sections

private extension SettingsView {
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
                        RadioIndicator(isSelected: viewModel.selectedTheme == theme)
                    }
                    .padding(Constants.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: Constants.CornerRadius.medium, style: .continuous)
                            .fill(Color.surfaceSecondary)
                    )
                    .onTapGesture {
                        viewModel.changeTheme(to: theme)
                    }
                }

                CustomButton(title: "同步系統設定", style: .outline) {
                    viewModel.changeTheme(to: .system)
                }
            }
        }
    }

    var securitySection: some View {
        SettingsCard(title: "安全與隱私", icon: "lock.shield.fill", accent: ThemeColor.success.color) {
            Toggle(isOn: Binding(
                get: { viewModel.appLockEnabled },
                set: { viewModel.handleAppLockToggle($0) }
            )) {
                VStack(alignment: .leading, spacing: Constants.Spacing.xxs) {
                    Text("啟用 App 鎖定")
                        .font(Constants.Typography.body.weight(.semibold))
                    Text("離開應用後需透過密碼或 Face ID 解鎖")
                        .font(Constants.Typography.caption)
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: ThemeColor.success.color))

            if viewModel.appLockEnabled {
                Divider()

                VStack(alignment: .leading, spacing: Constants.Spacing.md) {
                    if viewModel.supportsBiometricUnlock {
                        Toggle(isOn: Binding(
                            get: { viewModel.useBiometricUnlock },
                            set: { viewModel.handleBiometricToggle($0) }
                        )) {
                            VStack(alignment: .leading, spacing: Constants.Spacing.xxs) {
                                Text("使用 Face ID / Touch ID")
                                    .font(Constants.Typography.body.weight(.semibold))
                                Text("快速驗證後自動解鎖")
                                    .font(Constants.Typography.caption)
                                    .foregroundStyle(Color.textSecondary)
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: ThemeColor.success.color))
                    } else {
                        Text("此裝置不支援 Face ID/Touch ID。")
                            .font(Constants.Typography.caption)
                            .foregroundStyle(Color.textSecondary)
                    }

                    VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                        Text("自動鎖定時間")
                            .font(Constants.Typography.body.weight(.semibold))
                        Picker("自動鎖定", selection: Binding(
                            get: { viewModel.autoLockSelection },
                            set: { viewModel.updateAutoLockSelection($0) }
                        )) {
                            ForEach(AppLockInterval.allCases) { interval in
                                Text(interval.title).tag(interval)
                            }
                        }
                        .pickerStyle(.segmented)
                        Text("背景離開超過指定時間後，系統會自動上鎖。")
                            .font(Constants.Typography.caption)
                            .foregroundStyle(Color.textSecondary)
                    }
                }
            }

            CustomButton(
                title: viewModel.passcodeExists ? "變更解鎖密碼" : "設定解鎖密碼",
                style: .outline
            ) {
                viewModel.presentPasscodeSetup()
            }
        }
    }

    var dataManagementSection: some View {
        SettingsCard(title: "資料管理", icon: "externaldrive.fill", accent: ThemeColor.accent.color) {
            VStack(spacing: Constants.Spacing.md) {
                exportButton

                Button {
                    isImportingBackup = true
                } label: {
                    DataManagementRow(
                        title: "從備份還原",
                        subtitle: "匯入先前匯出的 JellySave 備份檔",
                        icon: "arrow.up.circle.fill"
                    )
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isProcessingBackup)

                Button {
                    showClearAlert = true
                } label: {
                    DataManagementRow(
                        title: "清除本機資料",
                        subtitle: "刪除所有帳戶與目標資料",
                        icon: "trash.fill",
                        iconColor: ThemeColor.accent.color.opacity(0.85)
                    )
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isProcessingBackup)
            }
            if viewModel.isProcessingBackup {
                ProgressView()
                    .progressViewStyle(.circular)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }

    var aboutSection: some View {
        SettingsCard(title: "應用程式資訊", icon: "info.circle.fill", accent: Color.textSecondary) {
            VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                InfoRow(label: "版本", value: "2.0.0 (示範)")
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

private extension SettingsView {
    var exportButton: some View {
        Button {
            Task {
                await viewModel.exportBackup()
                if viewModel.exportedFileURL != nil {
                    showShareSheet = true
                }
            }
        } label: {
            DataManagementRow(
                title: "匯出資料備份",
                subtitle: "產生加密檔案並儲存到 iCloud Drive",
                icon: "arrow.down.circle.fill"
            )
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isProcessingBackup)
    }

    var errorAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { newValue in
                if !newValue {
                    viewModel.errorMessage = nil
                }
            }
        )
    }

    var successAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.successMessage != nil },
            set: { newValue in
                if !newValue {
                    viewModel.successMessage = nil
                }
            }
        )
    }
}

// MARK: - Subviews

struct SettingsCard<Content: View>: View {
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

private struct PasscodeSetupSheet: View {
    @Environment(\.dismiss) private var dismiss
    var requiresCurrentPasscode: Bool
    var onSubmit: (_ current: String?, _ new: String, _ confirm: String) -> String?

    @State private var currentPasscode: String = ""
    @State private var newPasscode: String = ""
    @State private var confirmPasscode: String = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                if requiresCurrentPasscode {
                    SecureField("目前密碼", text: $currentPasscode)
                        .keyboardType(.numberPad)
                        .textContentType(.password)
                }

                SecureField("新密碼（4-6 位數）", text: $newPasscode)
                    .keyboardType(.numberPad)
                    .textContentType(.newPassword)

                SecureField("再次輸入新密碼", text: $confirmPasscode)
                    .keyboardType(.numberPad)
                    .textContentType(.newPassword)

                if let errorMessage {
                    Text(errorMessage)
                        .font(Constants.Typography.caption)
                        .foregroundStyle(Color.accentCoral)
                }
            }
            .navigationTitle("設定解鎖密碼")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("儲存") {
                        handleSave()
                    }
                }
            }
        }
    }

    private func handleSave() {
        let error = onSubmit(requiresCurrentPasscode ? currentPasscode : nil, newPasscode, confirmPasscode)
        if let error {
            errorMessage = error
        } else {
            dismiss()
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeService())
        .environmentObject(AppLockService())
}
