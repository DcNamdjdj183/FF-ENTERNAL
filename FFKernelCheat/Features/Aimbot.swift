import Foundation
import simd

final class Aimbot: ObservableObject {
    static let shared = Aimbot()
    @Published var enabled = false
    @Published var fov: Float = 90
    @Published var smoothness: Float = 5
    @Published var targetBone: String = "Head"
    private var timer: Timer?

    private init() {}

    func start() {
        AppLogger.shared.info("Aimbot: Đã BẬT (FOV: \(Int(fov)), Smooth: \(Int(smoothness)))")
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func stop() {
        AppLogger.shared.info("Aimbot: Đã TẮT")
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        guard enabled, KernelManager.shared.isKernelReady || KernelManager.shared.isUserlandFallback else { return }
        let local = GameReader.shared.localPlayerBase()
        guard local != 0 else { return }
        let localTeam = GameReader.shared.readTeam(local)
        var best: Entity?
        var bestDist: Float = fov
        for ent in EntityManager.shared.entities where !ent.isDead && ent.team != localTeam {
            let dist = distance(ent.position, SIMD3(0,0,0))
            if dist < bestDist {
                bestDist = dist
                best = ent
            }
        }
        guard let target = best else { return }
        let aimAddr = local + GameOffsets.aimTargetOffset
        _ = KernelRW.shared.write(aimAddr, value: target.head)
    }
}
