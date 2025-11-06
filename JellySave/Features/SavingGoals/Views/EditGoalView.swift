import SwiftUI

struct EditGoalView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var editor: GoalEditor
    var onSave: (GoalEditor) -> Void

    private var isSaveDisabled: Bool {
        !editor.isSaveEnabled
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("基本資訊") {
                    TextField("目標名稱", text: $editor.title)
                    TextField("分類（選填）", text: $editor.category)
                }

                Section("金額設定") {
                    CurrencyTextField(value: $editor.targetAmount, title: "目標金額", placeholder: "設定儲蓄目標")
                    CurrencyTextField(value: $editor.currentAmount, title: "目前金額", placeholder: "已累積金額")
                }

                Section("截止日期") {
                    DatePicker("截止日期", selection: $editor.deadline, displayedComponents: .date)
                }

                Section("備註") {
                    TextEditor(text: $editor.notes)
                        .frame(minHeight: 120)
                }
            }
            .navigationTitle("編輯儲蓄目標")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("儲存") {
                        onSave(editor)
                        dismiss()
                    }
                    .disabled(isSaveDisabled)
                }
            }
        }
    }
}
