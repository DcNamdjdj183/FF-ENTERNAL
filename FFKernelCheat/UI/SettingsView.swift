import SwiftUI

struct SettingsView: View {
    @State private var opacity: Double = 0.8
    @State private var autoBoot = true

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                Form {
                    Section("UI") {
                        Slider(value: $opacity, in: 0.3...1) { Text("Overlay Opacity") }
                    }
                    Section("Boot") {
                        Toggle("Auto Kernel Boot", isOn: $autoBoot)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
        }
    }
}
