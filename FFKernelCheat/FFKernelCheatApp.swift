import SwiftUI

@main
struct FFKernelCheatApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var kernel = KernelManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(kernel)
                .preferredColorScheme(.dark)
        }
    }
}
