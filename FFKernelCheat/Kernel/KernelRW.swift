import Foundation

final class KernelRW {
    static let shared = KernelRW()
    private let lock = os_unfair_lock_t.allocate(capacity: 1)

    private init() { lock.initialize(to: os_unfair_lock()) }
    deinit { lock.deallocate() }

    func read<T>(_ addr: UInt64) -> T? {
        os_unfair_lock_lock(lock)
        defer { os_unfair_lock_unlock(lock) }
        guard KernelManager.shared.isKaddrValid(addr) else { return nil }
        let size = MemoryLayout<T>.size
        var buffer = [UInt8](repeating: 0, count: size)
        kreadbuf(addr, &buffer, UInt64(size))
        return buffer.withUnsafeBytes { $0.load(as: T.self) }
    }

    func write<T>(_ addr: UInt64, value: T) -> Bool {
        os_unfair_lock_lock(lock)
        defer { os_unfair_lock_unlock(lock) }
        guard KernelManager.shared.isKaddrValid(addr) else { return false }
        var val = value
        kwritebuf(addr, &val, UInt64(MemoryLayout<T>.size))
        return true
    }

    func readBytes(_ addr: UInt64, count: Int) -> Data? {
        os_unfair_lock_lock(lock)
        defer { os_unfair_lock_unlock(lock) }
        guard KernelManager.shared.isKaddrValid(addr), count > 0 else { return nil }
        var buffer = [UInt8](repeating: 0, count: count)
        kreadbuf(addr, &buffer, UInt64(count))
        return Data(buffer)
    }
}
