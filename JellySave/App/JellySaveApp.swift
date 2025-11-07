import SwiftUI

@main
struct JellySaveApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var themeService = ThemeService()
    @StateObject private var appLockService = AppLockService()

    init() {
        CoreDataStack.shared.seedIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(themeService)
                .environmentObject(appLockService)
                .preferredColorScheme(themeService.currentTheme.preferredColorScheme)
        }
    }
}

private struct AppRootView: View {
    @EnvironmentObject private var themeService: ThemeService
    @EnvironmentObject private var appLockService: AppLockService
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            MainTabView()

            if appLockService.configuration.isEnabled && appLockService.isLocked {
                AppLockOverlayView()
            }
        }
        .onChange(of: scenePhase) { phase in
            appLockService.handleScenePhaseChange(phase)
        }
    }
}
