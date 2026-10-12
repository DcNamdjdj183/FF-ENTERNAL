import SwiftUI

struct HomeView: View {
    @EnvironmentObject var kernel: KernelManager
    @State private var manualPidText = ""
    @State private var showManualPid = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        statusCard
                        gameLauncherSection
                        quickActionsSection
                        if showManualPid {
                            manualPidSection
                        }
                        guideSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Trang Chủ")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // ═══════════════════════════════════════════════════════════
    // THẺ TRẠNG THÁI HỆ THỐNG
    // ═══════════════════════════════════════════════════════════
    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(kernel.isKernelReady ? Color.green : (kernel.isBooting ? Color.yellow : (kernel.isUserlandFallback ? Color.orange : Color.red)))
                    .frame(width: 12, height: 12)
                Text(kernel.isKernelReady ? "Kernel R/W: Đã Kích Hoạt" : (kernel.isBooting ? "Đang kích hoạt Kernel..." : (kernel.isUserlandFallback ? "Userland Fallback" : "Kernel Chưa Kích Hoạt")))
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                if kernel.isBooting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                        .scaleEffect(0.8)
                }
            }

            Divider().background(Color.white.opacity(0.1))

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("TIẾN TRÌNH GAME")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                    Text(kernel.gamePid > 0 ? "\(kernel.detectedProcessName.isEmpty ? "FreeFire" : kernel.detectedProcessName) (PID: \(kernel.gamePid))" : "Chưa phát hiện")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(kernel.gamePid > 0 ? .green : .red.opacity(0.8))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("IL2CPP BASE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                    Text("0x\(String(kernel.il2cppBase, radix: 16))")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.cyan)
                }
            }

            if !kernel.lastScanTime.isEmpty {
                Text("Lần quét gần nhất: \(kernel.lastScanTime)")
                    .font(.caption2)
                    .foregroundColor(.gray.opacity(0.8))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(kernel.isKernelReady ? Color.green.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }

    // ═══════════════════════════════════════════════════════════
    // MỤC MỞ GAME TRỰC TIẾP
    // ═══════════════════════════════════════════════════════════
    private var gameLauncherSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("MỞ GAME TRỰC TIẾP")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.gray)

            // Nút mở Free Fire Thường
            Button(action: { AppLauncher.launchFreeFire() }) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 44, height: 44)
                        Image(systemName: "flame.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Mở Free Fire")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                        Text("com.dts.freefireth")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Image(systemName: "arrow.up.right.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
                .padding(12)
                .background(Color.white.opacity(0.05))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
            }

            // Nút mở Free Fire MAX
            Button(action: { AppLauncher.launchFreeFireMax() }) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 44, height: 44)
                        Image(systemName: "bolt.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Mở Free Fire MAX")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                        Text("com.dts.freefiremax")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Image(systemName: "arrow.up.right.circle.fill")
                        .font(.title2)
                        .foregroundColor(.cyan)
                }
                .padding(12)
                .background(Color.white.opacity(0.05))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }

    // ═══════════════════════════════════════════════════════════
    // THAO TÁC NHANH
    // ═══════════════════════════════════════════════════════════
    private var quickActionsSection: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Button(action: { kernel.resolveGame() }) {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Quét lại Game PID")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.cyan.opacity(0.2))
                    .foregroundColor(.cyan)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.cyan.opacity(0.4), lineWidth: 1))
                }

                Button(action: { kernel.forceReboot() }) {
                    HStack {
                        Image(systemName: "bolt.badge.clock.fill")
                        Text("Kích hoạt lại Kernel")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.purple.opacity(0.2))
                    .foregroundColor(.purple)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.purple.opacity(0.4), lineWidth: 1))
                }
            }

            Button(action: { showManualPid.toggle() }) {
                HStack {
                    Text(showManualPid ? "Ẩn nhập PID thủ công" : "Nhập PID thủ công (Tùy chọn)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Image(systemName: showManualPid ? "chevron.up" : "chevron.down")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding(.top, 4)
            }
        }
    }

    // ═══════════════════════════════════════════════════════════
    // NHẬP PID THỦ CÔNG
    // ═══════════════════════════════════════════════════════════
    private var manualPidSection: some View {
        HStack(spacing: 8) {
            TextField("Nhập PID game...", text: $manualPidText)
                .keyboardType(.numberPad)
                .font(.system(size: 13, design: .monospaced))
                .padding(10)
                .background(Color.white.opacity(0.08))
                .cornerRadius(8)
                .foregroundColor(.white)

            Button("Áp dụng") {
                if let pid = Int32(manualPidText), pid > 0 {
                    kernel.gamePid = pid
                    kernel.il2cppBase = 0x100000000
                    AppLogger.shared.success("Đã gán PID thủ công: \(pid)")
                    EntityManager.shared.startScan()
                }
            }
            .font(.caption.bold())
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.green.opacity(0.25))
            .foregroundColor(.green)
            .cornerRadius(8)
        }
        .padding(10)
        .background(Color.white.opacity(0.03))
        .cornerRadius(10)
    }

    // ═══════════════════════════════════════════════════════════
    // HƯỚNG DẪN KÍCH HOẠT
    // ═══════════════════════════════════════════════════════════
    private var guideSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("HƯỚNG DẪN KÍCH HOẠT")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.gray)

            VStack(alignment: .leading, spacing: 6) {
                guideItem(number: "1", text: "Kiểm tra tab Logs: Kernel R/W phải báo OK và mã 0.")
                guideItem(number: "2", text: "Bấm nút 'Mở Free Fire' hoặc mở game từ màn hình chính.")
                guideItem(number: "3", text: "Quay lại app FFKernelCheat -> PID game sẽ tự động nhận diện.")
                guideItem(number: "4", text: "Chuyển sang tab Features để kích hoạt Aimbot / ESP.")
            }
            .padding(12)
            .background(Color.white.opacity(0.03))
            .cornerRadius(12)
        }
    }

    private func guideItem(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(number)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.black)
                .frame(width: 16, height: 16)
                .background(Color.cyan)
                .clipShape(Circle())
            Text(text)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}
