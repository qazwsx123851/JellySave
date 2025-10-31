import SwiftUI

struct AddAccountView: View {
    @State private var accountName: String = "主要薪轉帳戶"
    @State private var selectedType: MockAccountCategory = .checking
    @State private var startingBalance: Decimal = 180_000
    @State private var note: String = "作為薪轉與日常支出使用"
    @FocusState private var focusedField: Field?
    @Environment(\.dismiss) private var dismiss

    private let typeOptions: [MockAccountCategory] = MockAccountCategory.allCases

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Constants.Layout.sectionSpacing) {
                    // 使用標籤說明目前為靜態示意資料。
                    TagLabel(text: "UI 範例", identifier: "bank", systemImage: "wand.and.sparkles")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    basicInfoSection
                    additionalInfoSection
                }
                .sectionPadding()
                .padding(.vertical, 24)
            }
            .background(ThemeColor.background(for: colorScheme).ignoresSafeArea())
            .navigationTitle("新增帳戶")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                        .foregroundColor(ThemeColor.neutralDark)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("儲存") {}
                        .disabled(true)
                        .foregroundColor(ThemeColor.neutralDark.opacity(0.5))
                }
            }
        }
    }

    @Environment(\.colorScheme) private var colorScheme
}

private extension AddAccountView {
    var basicInfoSection: some View {
        CardContainer(title: "基本資訊", subtitle: "帳戶名稱與類型", iconName: "creditcard") {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("帳戶名稱")
                        .font(Constants.Typography.caption)
                        .foregroundColor(ThemeColor.neutralDark.opacity(0.6))
                    TextField("例如：玉山銀行薪轉", text: $accountName)
                        .textInputAutocapitalization(.words)
                        .keyboardType(.default)
                        .submitLabel(.next)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 14)
                        .background(
                            RoundedRectangle(cornerRadius: Constants.CornerRadius.medium, style: .continuous)
                                .fill(ThemeColor.cardBackground(for: colorScheme))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Constants.CornerRadius.medium, style: .continuous)
                                .stroke(
                                    focusedField == .accountName ? ThemeColor.primary.opacity(0.55) : ThemeColor.neutralLight.opacity(0.8),
                                    lineWidth: focusedField == .accountName ? 1.5 : 1
                                )
                        )
                        .animation(.easeInOut(duration: 0.18), value: focusedField == .accountName)
                        .focused($focusedField, equals: .accountName)
                        .accessibilityHint(Text("便於後續辨識帳戶"))
                    if isAccountNameEmpty {
                        Text("請輸入帳戶名稱，以便快速辨識。")
                            .font(Constants.Typography.caption)
                            .foregroundColor(ThemeColor.warning)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("帳戶類型")
                        .font(Constants.Typography.caption)
                        .foregroundColor(ThemeColor.neutralDark.opacity(0.6))
                    Picker("帳戶類型", selection: $selectedType) {
                        ForEach(typeOptions) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
        }
    }

    var additionalInfoSection: some View {
        CardContainer(title: "起始餘額", subtitle: "可以日後再調整", iconName: "dollarsign.circle") {
            VStack(alignment: .leading, spacing: 16) {
                CurrencyTextField("目前餘額", value: $startingBalance)
                    .accessibilityHint(Text("輸入帳戶目前餘額"))
                Text("提示：可於任一時間更新餘額，JellySave 會保留歷史紀錄。")
                    .font(Constants.Typography.caption)
                    .foregroundColor(ThemeColor.neutralDark.opacity(0.55))
                VStack(alignment: .leading, spacing: 8) {
                    Text("備註")
                        .font(Constants.Typography.caption)
                        .foregroundColor(ThemeColor.neutralDark.opacity(0.6))
                    TextEditor(text: $note)
                        .frame(minHeight: 100)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: Constants.CornerRadius.medium, style: .continuous)
                                .fill(ThemeColor.cardBackground(for: colorScheme))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Constants.CornerRadius.medium, style: .continuous)
                                .stroke(
                                    focusedField == .note ? ThemeColor.primary.opacity(0.45) : ThemeColor.neutralLight.opacity(0.8),
                                    lineWidth: focusedField == .note ? 1.5 : 1
                                )
                        )
                        .focused($focusedField, equals: .note)
                        .accessibilityHint(Text("補充帳戶使用情境或注意事項"))
                        .animation(.easeInOut(duration: 0.18), value: focusedField == .note)
                    Text("\(note.count)/120")
                        .font(Constants.Typography.caption)
                        .foregroundColor(ThemeColor.neutralDark.opacity(0.4))
                        .monospacedDigit()
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
    }

    var isAccountNameEmpty: Bool {
        accountName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

private enum MockAccountCategory: String, CaseIterable, Identifiable {
    case checking
    case digital
    case investment
    case cash

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .checking: return "活儲"
        case .digital: return "數位帳戶"
        case .investment: return "投資"
        case .cash: return "現金"
        }
    }
}

private extension AddAccountView {
    enum Field: Hashable {
        case accountName
        case note
    }
}

#Preview {
    AddAccountView()
}
