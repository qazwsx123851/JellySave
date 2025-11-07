import SwiftUI

struct CreateGoalView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var targetAmount: Decimal = 0
    @State private var currentAmount: Decimal = 0
    @State private var deadline: Date = Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()
    @State private var category: String = ""
    @State private var notes: String = ""

    var onCreate: (String, Decimal, Decimal, Date, String?, String?) -> Void

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && targetAmount > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("目標資訊") {
                    TextField("目標名稱", text: $title)

                    TextField("分類（選填）", text: $category)

                    DatePicker("截止日期", selection: $deadline, displayedComponents: .date)
                }

                Section("金額設定") {
                    CurrencyTextField(value: $targetAmount, title: "目標金額", placeholder: "設定目標金額")
                    CurrencyTextField(value: $currentAmount, title: "目前金額", placeholder: "已累積金額")
                }

                Section("備註") {
                    TextField("額外說明（選填）", text: $notes, axis: .vertical)
                        .lineLimit(4, reservesSpace: true)
                }
            }
            .navigationTitle("新增儲蓄目標")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("建立") {
                        let trimmedCategory = category.trimmingCharacters(in: .whitespaces)
                        let trimmedNotes = notes.trimmingCharacters(in: .whitespaces)
                        onCreate(
                            title,
                            targetAmount,
                            currentAmount,
                            deadline,
                            trimmedCategory.isEmpty ? nil : trimmedCategory,
                            trimmedNotes.isEmpty ? nil : trimmedNotes
                        )
                        dismiss()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
}

#Preview {
    CreateGoalView { _, _, _, _, _, _ in }
        .environmentObject(ThemeService())
}
