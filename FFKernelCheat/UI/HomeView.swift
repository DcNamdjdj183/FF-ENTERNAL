import SwiftUI

struct HomeView: View {
    @EnvironmentObject var kernel: KernelManager

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 24) {
                    statusCard
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Home")
        }
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(kernel.isKernelReady ? .green : .orange)
                    .frame(width: 12, height: 12)
                Text(kernel.isKernelReady ? "Kernel R/W Active" : kernel.isUserlandFallback ? "Userland Fallback" : "Booting...")
                    .foregroundColor(.white)
            }
            Text("Game PID: \(kernel.gamePid)")
                .foregroundColor(.gray)
            Text("il2cpp Base: 0x\(String(kernel.il2cppBase, radix: 16))")
                .foregroundColor(.gray)
                .font(.system(.caption, design: .monospaced))
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}
