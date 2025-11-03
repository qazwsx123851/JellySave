import SwiftUI

@main
struct JellySaveApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var themeService = ThemeService()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(themeService)
                .preferredColorScheme(themeService.currentTheme.preferredColorScheme)
        }
    }
}
