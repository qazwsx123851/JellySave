import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    private let performanceMonitor = PerformanceMonitor.shared

    override init() {
        super.init()
        performanceMonitor.markLaunchStart()
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        performanceMonitor.markLaunchEnd()
        performanceMonitor.start()
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        performanceMonitor.stop()
    }
}
