import SwiftUI

struct FeaturesView: View {
    @StateObject private var aim = Aimbot.shared
    @StateObject private var esp = ESP.shared
    @StateObject private var anti = AntiBan.shared

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                Form {
                    Section("Aimbot") {
                        Toggle("Enable", isOn: $aim.enabled)
                        Slider(value: $aim.fov, in: 30...180) { Text("FOV \(Int(aim.fov))") }
                        Slider(value: $aim.smoothness, in: 1...20) { Text("Smooth \(Int(aim.smoothness))") }
                    }
                    .listRowBackground(Color.white.opacity(0.05))

                    Section("ESP") {
                        Toggle("Enable", isOn: $esp.enabled)
                        Toggle("Box", isOn: $esp.showBox)
                        Toggle("Health", isOn: $esp.showHealth)
                        ColorPicker("Color", selection: $esp.color)
                    }
                    .listRowBackground(Color.white.opacity(0.05))

                    Section("Anti-Ban") {
                        Toggle("HWID Spoof", isOn: $anti.hwidSpoof)
                        Toggle("Memory Clean", isOn: $anti.memoryClean)
                        Toggle("Behavior Realism", isOn: $anti.behaviorRealism)
                        Button("Apply") { anti.apply() }
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                }
                .hideScrollContentBackground()
            }
            .navigationTitle("Features")
        }
        .onChange(of: aim.enabled) { isEnabled in
            if isEnabled { aim.start() } else { aim.stop() }
        }
    }
}
