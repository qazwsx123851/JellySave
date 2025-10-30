import SwiftUI

@main
struct JellySaveApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}

private struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("首頁", systemImage: "house.fill") }

            AccountsListView()
                .tabItem { Label("帳戶", systemImage: "creditcard.fill") }

            GoalsListView()
                .tabItem { Label("目標", systemImage: "target") }

            SettingsView()
                .tabItem { Label("設置", systemImage: "gearshape.fill") }
        }
        .tint(ThemeColor.primary)
    }
}
