import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = Tab.home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("首頁", systemImage: "house.fill")
                }
                .tag(Tab.home)

            AccountsView()
                .tabItem {
                    Label("帳戶", systemImage: "creditcard.fill")
                }
                .tag(Tab.accounts)

            SavingGoalsView()
                .tabItem {
                    Label("目標", systemImage: "target")
                }
                .tag(Tab.goals)

            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gearshape.fill")
                }
                .tag(Tab.settings)
        }
    }
}

extension MainTabView {
    enum Tab: Hashable {
        case home
        case accounts
        case goals
        case settings
    }
}

#Preview {
    MainTabView()
        .environmentObject(ThemeService())
}
