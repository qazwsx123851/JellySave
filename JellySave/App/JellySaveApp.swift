import SwiftUI

@main
struct JellySaveApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var themeService = ThemeService()

    init() {
        CoreDataStack.shared.seedIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(themeService)
                .preferredColorScheme(themeService.currentTheme.preferredColorScheme)
        }
    }
}
