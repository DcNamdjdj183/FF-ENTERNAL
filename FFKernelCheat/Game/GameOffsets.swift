import Foundation

enum GameOffsets {
    static let localPlayerOffset:      UInt64 = 0x30
    static let localPlayerTeamOffset:  UInt64 = 0xA4
    static let localPlayerPosOffset:   UInt64 = 0x14
    static let localPlayerRotOffset:   UInt64 = 0x20
    static let localPlayerHealthOffset:UInt64 = 0x20
    static let entityListOffset:       UInt64 = 0x2C
    static let entityListCountOffset:  UInt64 = 0x24
    static let entityListItemsOffset:  UInt64 = 0x28
    static let entPosOffset:           UInt64 = 0x14
    static let entHeadPosOffset:       UInt64 = 0x58
    static let entHealthOffset:        UInt64 = 0x20
    static let entMaxHealthOffset:     UInt64 = 0x98
    static let entTeamOffset:          UInt64 = 0xA4
    static let entIsDeadOffset:        UInt64 = 0x40
    static let entIsVisibleOffset:     UInt64 = 0x58
    static let entCanBeLockedOffset:   UInt64 = 0x30
    static let entNameOffset:          UInt64 = 0x18
    static let entDistanceOffset:      UInt64 = 0x14
    static let cameraOffset:           UInt64 = 0x20
    static let cameraPosOffset:        UInt64 = 0x14
    static let cameraRotOffset:        UInt64 = 0x20
    static let viewMatrixOffset:       UInt64 = 0x1
    static let weaponOffset:           UInt64 = 0x10
    static let weaponRecoilOffset:     UInt64 = 0x10
    static let weaponSpreadOffset:     UInt64 = 0x50
    static let weaponAmmoOffset:       UInt64 = 0x30
    static let weaponDamageOffset:     UInt64 = 0x38
    static let aimTargetOffset:        UInt64 = 0x7C
    static let aimFovOffset:           UInt64 = 0x34
    static let aimSpeedOffset:         UInt64 = 0x0
    static let aimSensitivityOffset:   UInt64 = 0x20
    static let playerSpeedOffset:      UInt64 = 0x20
    static let playerJumpOffset:       UInt64 = 0x40
    static let playerArmorOffset:      UInt64 = 0x390
    static let playerStateOffset:      UInt64 = 0x28
    static let gameManagerOffset:      UInt64 = 0xBC
    static let matchInfoOffset:        UInt64 = 0x90
    static let mapInfoOffset:          UInt64 = 0x40
}
