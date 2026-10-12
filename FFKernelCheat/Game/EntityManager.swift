import Foundation
import simd

struct Entity {
    let address: UInt64
    let position: SIMD3<Float>
    let head: SIMD3<Float>
    let health: Float
    let team: Int
    let isDead: Bool
    let name: String
}

final class EntityManager: ObservableObject {
    static let shared = EntityManager()
    @Published var entities: [Entity] = []
    private var timer: Timer?

    private init() {}

    func startScan() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.scan()
        }
    }

    func stopScan() {
        timer?.invalidate()
        timer = nil
    }

    private func scan() {
        KernelManager.shared.reResolveIfNeeded()
        guard KernelManager.shared.gamePid > 0 else { return }
        var list: [Entity] = []
        let count = GameReader.shared.entityCount()
        let items = GameReader.shared.entityListBase() + GameOffsets.entityListItemsOffset
        for i in 0..<min(count, 64) {
            let entAddr: UInt64 = KernelRW.shared.read(items + UInt64(i * 8)) ?? 0
            guard entAddr != 0, KernelManager.shared.isKaddrValid(entAddr) else { continue }
            let pos = GameReader.shared.readPosition(entAddr)
            let health = GameReader.shared.readHealth(entAddr)
            let team = GameReader.shared.readTeam(entAddr)
            let dead = GameReader.shared.isDead(entAddr)
            list.append(Entity(address: entAddr, position: pos, head: pos, health: health, team: team, isDead: dead, name: ""))
        }
        DispatchQueue.main.async {
            self.entities = list
        }
    }
}
