import Foundation
import SwiftUI

final class ESP: ObservableObject {
    static let shared = ESP()
    @Published var enabled = false
    @Published var showBox = true
    @Published var showHealth = true
    @Published var showName = true
    @Published var color: Color = .red

    private init() {}
}
