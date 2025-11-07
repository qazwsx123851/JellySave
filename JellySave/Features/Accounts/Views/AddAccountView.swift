import SwiftUI

struct AddAccountView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var selectedType: AccountType = .cash
    @State private var initialBalance: Decimal = 0
    @State private var notes: String = ""

    var onCreate: (String, AccountType, Decimal, String?) -> Void

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("帳戶資訊") {
                    TextField("帳戶名稱", text: $name)

                    Picker("帳戶類型", selection: $selectedType) {
                        ForEach(AccountType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }

                    CurrencyTextField(value: $initialBalance, title: "初始餘額", placeholder: "輸入金額")
                }

                Section("備註") {
                    TextField("例如：主要薪資帳戶", text: $notes, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }
            }
            .navigationTitle("新增帳戶")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("儲存") {
                        onCreate(name, selectedType, initialBalance, notes.isEmpty ? nil : notes)
                        dismiss()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
}

#Preview {
    AddAccountView { _, _, _, _ in }
        .environmentObject(ThemeService())
}
