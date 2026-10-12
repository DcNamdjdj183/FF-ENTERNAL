import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        KernelAutoLoader.shared.boot()
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        KernelManager.shared.pauseThreads()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        AppLogger.shared.info("Quay lại ứng dụng, tự động quét tìm game...")
        KernelManager.shared.resolveGame()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        KernelManager.shared.killThreads()
    }
}
