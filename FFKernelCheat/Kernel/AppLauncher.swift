import Foundation
import UIKit

struct AppLauncher {
    static let freeFireThBundle = "com.dts.freefireth"
    static let freeFireMaxBundle = "com.dts.freefiremax"

    static let freeFireThScheme = "freefire://"
    static let freeFireMaxScheme = "freefiremax://"

    @discardableResult
    static func launchGame(bundleId: String, scheme: String) -> Bool {
        AppLogger.shared.info("Đang yêu cầu mở game (\(bundleId))...")

        var launched = false

        // 1. Dùng LSApplicationWorkspace (tối ưu cho thiết bị jailbreak / trollstore / sideload)
        if let workspaceClass = NSClassFromString("LSApplicationWorkspace") as? NSObject.Type,
           let defaultWorkspace = workspaceClass.perform(NSSelectorFromString("defaultWorkspace"))?.takeUnretainedValue() {
            let selector = NSSelectorFromString("openApplicationWithBundleID:")
            if defaultWorkspace.responds(to: selector) {
                _ = defaultWorkspace.perform(selector, with: bundleId)
                AppLogger.shared.success("Đã kích hoạt mở ứng dụng qua LSApplicationWorkspace: \(bundleId)")
                launched = true
            }
        }

        // 2. Fallback qua URL Scheme
        if !launched, let url = URL(string: scheme) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:]) { ok in
                    if ok {
                        AppLogger.shared.success("Đã mở game qua URL Scheme: \(scheme)")
                    } else {
                        AppLogger.shared.warn("URL Scheme \(scheme) mở không thành công.")
                    }
                }
                launched = true
            } else {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                launched = true
            }
        }

        if !launched {
            AppLogger.shared.error("Không thể mở \(bundleId). Hãy đảm bảo game đã được cài đặt trên máy.")
        } else {
            // Tự động kích hoạt quét lại PID sau 2 giây khi game bắt đầu khởi động
            DispatchQueue.global().asyncAfter(deadline: .now() + 2.5) {
                AppLogger.shared.info("Tự động quét lại tiến trình game sau khi mở...")
                KernelManager.shared.resolveGame()
            }
        }

        return launched
    }

    static func launchFreeFire() {
        launchGame(bundleId: freeFireThBundle, scheme: freeFireThScheme)
    }

    static func launchFreeFireMax() {
        launchGame(bundleId: freeFireMaxBundle, scheme: freeFireMaxScheme)
    }
}
