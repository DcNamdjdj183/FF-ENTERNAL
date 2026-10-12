import Foundation
import UIKit
import os

final class KernelManager: ObservableObject {
    static let shared = KernelManager()
    private let lock = os_unfair_lock_t.allocate(capacity: 1)
    private var bootAttempts = 0
    private let maxRetries = 3

    @Published var isKernelReady = false
    @Published var isUserlandFallback = false
    @Published var isBooting = false
    @Published var gamePid: Int32 = 0
    @Published var il2cppBase: UInt64 = 0
    @Published var detectedProcessName: String = ""
    @Published var lastScanTime: String = ""
    @Published var statusMessage: String = "Sẵn sàng khởi động"

    private var workerThread: Thread?

    private init() {
        lock.initialize(to: os_unfair_lock())
    }

    deinit {
        lock.deallocate()
    }

    func boot() {
        guard !isBooting else {
            AppLogger.shared.warn("Kernel đang trong quá trình khởi động, vui lòng chờ...")
            return
        }
        guard !isKernelReady else {
            AppLogger.shared.info("Kernel R/W đã sẵn sàng, bỏ qua boot.")
            resolveGame()
            return
        }

        DispatchQueue.main.async {
            self.isBooting = true
            self.statusMessage = "Đang kích hoạt Kernel Exploit..."
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.attemptKernel()
        }
    }

    func forceReboot() {
        bootAttempts = 0
        DispatchQueue.main.async {
            self.isKernelReady = false
            self.isUserlandFallback = false
            self.gamePid = 0
            self.il2cppBase = 0
            self.detectedProcessName = ""
        }
        AppLogger.shared.kernel("Yêu cầu kích hoạt lại Kernel Exploit từ đầu...")
        boot()
    }

    private func attemptKernel() {
        bootAttempts += 1
        AppLogger.shared.kernel("Bắt đầu thử nghiệm Kernel (Lần \(bootAttempts)/\(maxRetries))...")
        AppLogger.shared.info("Thiết bị: \(UIDevice.current.model), iOS \(UIDevice.current.systemVersion)")

        // Gọi core exploit opa334
        AppLogger.shared.info("Đang thực thi kexploit_opa334()...")
        let res = kexploit_opa334()

        if res == 0 {
            AppLogger.shared.success("kexploit_opa334() THÀNH CÔNG! Trả về mã: 0")

            AppLogger.shared.info("Khởi tạo cấu trúc offsets_init()...")
            offsets_init()

            let selfProc = proc_self()
            AppLogger.shared.success("proc_self: 0x\(String(selfProc, radix: 16))")

            if selfProc != 0 && selfProc != UInt64.max {
                AppLogger.shared.info("Thực hiện Sandbox Escape...")
                let sbRes = sandbox_escape(selfProc)
                if sbRes == 0 {
                    AppLogger.shared.success("Sandbox Escape THÀNH CÔNG!")
                } else {
                    AppLogger.shared.warn("Sandbox Escape trả về mã: \(sbRes)")
                }

                AppLogger.shared.info("Nâng quyền tiến trình lên Root (sandbox_elevate_to_root)...")
                let rootRes = sandbox_elevate_to_root(selfProc)
                let currentUid = getuid()
                if rootRes == 0 || currentUid == 0 {
                    AppLogger.shared.success("Đã nâng quyền Root thành công! UID: \(currentUid)")
                } else {
                    AppLogger.shared.warn("Nâng quyền Root hoàn tất với UID: \(currentUid)")
                }
            }

            DispatchQueue.main.async {
                self.isBooting = false
                self.isKernelReady = true
                self.isUserlandFallback = false
                self.statusMessage = "Kernel R/W Đang Hoạt Động"
                AppLogger.shared.success("Hệ thống Kernel R/W đã kích hoạt đầy đủ.")
                self.resolveGame()
            }
        } else if bootAttempts < maxRetries {
            AppLogger.shared.warn("kexploit_opa334() trả về mã \(res). Đang thử lại sau 1s...")
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.attemptKernel()
            }
        } else {
            AppLogger.shared.error("Không thể kích hoạt Kernel sau \(maxRetries) lần thử. Chuyển sang chế độ Userland Fallback.")
            DispatchQueue.main.async {
                self.isBooting = false
                self.isUserlandFallback = true
                self.isKernelReady = false
                self.statusMessage = "Userland Fallback (Kernel không hỗ trợ)"
                self.resolveGame()
            }
        }
    }

    func resolveGame() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let scanTime = formatter.string(from: Date())

        DispatchQueue.main.async {
            self.lastScanTime = scanTime
        }

        AppLogger.shared.info("Đang quét tìm tiến trình Free Fire...")

        // 1. Dùng hàm tìm kernel tối ưu
        let proc = proc_find_freefire()
        if proc != 0 && proc != UInt64.max {
            let pid = Int32(proc_get_pid(proc))
            let pName = proc_get_p_name(proc)
            let nameStr = pName != nil ? String(cString: pName!) : "FreeFire"

            AppLogger.shared.success("ĐÃ TÌM THẤY GAME! Tên: '\(nameStr)', PID: \(pid), Proc: 0x\(String(proc, radix: 16))")

            var baseAddr: UInt64 = 0x100000000
            let pTask = proc_task(proc)
            if pTask != 0 {
                let vmap = task_get_vm_map(pTask)
                if vmap != 0 {
                    baseAddr = 0x100000000
                    AppLogger.shared.info("Task: 0x\(String(pTask, radix: 16)), Map: 0x\(String(vmap, radix: 16))")
                }
            }

            DispatchQueue.main.async {
                self.gamePid = pid
                self.il2cppBase = baseAddr
                self.detectedProcessName = nameStr
                self.statusMessage = "Đã kết nối Free Fire (PID: \(pid))"

                // Khởi động quét thực thể game
                EntityManager.shared.startScan()
            }
            return
        }

        // 2. Nếu chưa thấy, in danh sách tiến trình ra log để chẩn đoán
        var buf = [CChar](repeating: 0, count: 2048)
        let total = proc_list_summary(&buf, 2048)
        let listStr = String(cString: buf)
        AppLogger.shared.warn("Chưa thấy tiến trình Free Fire (Đã quét \(total) tiến trình: \(listStr.prefix(220))...)")
        AppLogger.shared.info("Mẹo: Bấm 'Mở Free Fire' ở tab Home hoặc mở game trên máy rồi bấm 'Quét lại PID'.")

        DispatchQueue.main.async {
            if self.gamePid == 0 {
                self.statusMessage = "Chưa phát hiện game (Hãy mở Free Fire)"
            }
        }
    }

    func isKaddrValid(_ addr: UInt64) -> Bool {
        return is_kaddr_valid(addr)
    }

    func pauseThreads() {
        EntityManager.shared.stopScan()
    }

    func killThreads() {
        EntityManager.shared.stopScan()
        workerThread?.cancel()
        workerThread = nil
    }

    func reResolveIfNeeded() {
        if gamePid == 0 { resolveGame() }
    }
}
