import Foundation
import simd

final class GameReader {
    static let shared = GameReader()
    private init() {}

    func localPlayerBase() -> UInt64 {
        let base = KernelManager.shared.il2cppBase
        guard base != 0 else { return 0 }
        return KernelRW.shared.read(base + GameOffsets.localPlayerOffset) ?? 0
    }

    func entityListBase() -> UInt64 {
        let base = KernelManager.shared.il2cppBase
        return KernelRW.shared.read(base + GameOffsets.entityListOffset) ?? 0
    }

    func entityCount() -> Int {
        let list = entityListBase()
        return Int(KernelRW.shared.read(list + GameOffsets.entityListCountOffset) ?? 0)
    }

    func readPosition(_ entity: UInt64) -> SIMD3<Float> {
        let x: Float = KernelRW.shared.read(entity + GameOffsets.entPosOffset) ?? 0
        let y: Float = KernelRW.shared.read(entity + GameOffsets.entPosOffset + 4) ?? 0
        let z: Float = KernelRW.shared.read(entity + GameOffsets.entPosOffset + 8) ?? 0
        return SIMD3(x, y, z)
    }

    func readHealth(_ entity: UInt64) -> Float {
        return KernelRW.shared.read(entity + GameOffsets.entHealthOffset) ?? 0
    }

    func readTeam(_ entity: UInt64) -> Int {
        return Int(KernelRW.shared.read(entity + GameOffsets.entTeamOffset) ?? 0)
    }

    func isDead(_ entity: UInt64) -> Bool {
        return (KernelRW.shared.read(entity + GameOffsets.entIsDeadOffset) ?? 0) != 0
    }

    func viewMatrix() -> simd_float4x4 {
        let cam = KernelManager.shared.il2cppBase + GameOffsets.cameraOffset
        // Placeholder matrix read
        return matrix_identity_float4x4
    }
}
