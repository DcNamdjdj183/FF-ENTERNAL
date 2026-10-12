import Foundation

final class KernelManager: ObservableObject {
    static let shared = KernelManager()
    private let lock = os_unfair_lock_t.allocate(capacity: 1)
    private var bootAttempts = 0
    private let maxRetries = 3
    @Published var isKernelReady = false
    @Published var isUserlandFallback = false
    @Published var gamePid: Int32 = 0
    @Published var il2cppBase: UInt64 = 0
    private var workerThread: Thread?

    private init() {
        lock.initialize(to: os_unfair_lock())
    }

    deinit {
        lock.deallocate()
    }

    func boot() {
        os_unfair_lock_lock(lock)
        defer { os_unfair_lock_unlock(lock) }
        guard !isKernelReady else { return }
        attemptKernel()
    }

    private func attemptKernel() {
        bootAttempts += 1
        let res = kexploit_opa334()
        if res == 0 {
            offsets_init()
            let selfProc = proc_self()
            if selfProc != 0 {
                _ = sandbox_escape(selfProc)
            }
            DispatchQueue.main.async {
                self.isKernelReady = true
                self.isUserlandFallback = false
                self.resolveGame()
            }
        } else if bootAttempts < maxRetries {
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.attemptKernel()
            }
        } else {
            DispatchQueue.main.async {
                self.isUserlandFallback = true
                self.isKernelReady = false
            }
        }
    }

    func resolveGame() {
        let targets = ["freefire", "FreeFire", "FreeFireMAX", "com.dts.freefireth", "com.dts.freefiremax"]
        for target in targets {
            let proc = proc_find_by_name(target)
            if proc != 0 && proc != UInt64.max {
                let pid = Int32(kread32(proc + UInt64(off_proc_p_pid)))
                if pid > 0 {
                    DispatchQueue.main.async {
                        self.gamePid = pid
                    }
                    break
                }
            }
        }
    }

    func isKaddrValid(_ addr: UInt64) -> Bool {
        return is_kaddr_valid(addr)
    }

    func pauseThreads() {
        // Pause feature loops
    }

    func killThreads() {
        workerThread?.cancel()
        workerThread = nil
    }

    func reResolveIfNeeded() {
        if gamePid == 0 { resolveGame() }
    }
}
