import Foundation

final class KernelAutoLoader {
    static let shared = KernelAutoLoader()
    private init() {}

    func boot() {
        KernelManager.shared.boot()
    }
}
