import SwiftUI

struct AccountsView: View {
    @StateObject private var viewModel = AccountsViewModel()
    @State private var isPresentingAddAccount = false

    private let quickActions = AccountQuickAction.sampleActions

    var body: some View {
        NavigationStack {
            ScrollView {
                AccountsListView(
                    summary: viewModel.summary,
                    sections: viewModel.sections,
                    quickActions: quickActions,
                    isLoading: viewModel.isLoading,
                    onCreateAccount: { isPresentingAddAccount = true }
                )
                .padding(.horizontal, Constants.Spacing.md)
                .padding(.vertical, Constants.Spacing.xl)
                .maxWidthLayout()
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("帳戶")
        }
        .searchable(text: $viewModel.searchText, prompt: "搜尋帳戶或備註")
        .sheet(isPresented: $isPresentingAddAccount) {
            AddAccountView { name, type, balance, notes in
                viewModel.createAccount(name: name, type: type, balance: balance, notes: notes)
            }
        }
    }
}

#Preview {
    AccountsView()
}
