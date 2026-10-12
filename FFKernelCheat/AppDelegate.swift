import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        KernelAutoLoader.shared.boot()
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        KernelManager.shared.pauseThreads()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        KernelManager.shared.killThreads()
    }
}
