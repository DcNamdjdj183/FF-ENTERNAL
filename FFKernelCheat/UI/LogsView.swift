import SwiftUI

struct LogsView: View {
    @ObservedObject var logger = AppLogger.shared
    @EnvironmentObject var kernel: KernelManager
    
    @State private var selectedFilter: LogLevel = .all
    @State private var autoScroll = true
    @State private var copiedAlert = false

    var filteredEntries: [LogEntry] {
        if selectedFilter == .all {
            return logger.entries
        }
        return logger.entries.filter { $0.level == selectedFilter }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 12) {
                    controlCard
                    filterBar
                    terminalView
                }
                .padding(.horizontal, 12)
                .padding(.top, 4)
            }
            .navigationTitle("Logs Tiến Trình")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: copyLogs) {
                        Image(systemName: "doc.on.doc")
                            .foregroundColor(.cyan)
                    }
                    Button(action: { logger.clear() }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red.opacity(0.8))
                    }
                }
            }
            .alert("Đã sao chép toàn bộ logs vào Clipboard!", isPresented: $copiedAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }

    private var controlCard: some View {
        VStack(spacing: 10) {
            HStack {
                Circle()
                    .fill(kernel.isKernelReady ? Color.green : (kernel.isBooting ? Color.yellow : Color.red))
                    .frame(width: 10, height: 10)
                Text(kernel.statusMessage)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .lineLimit(1)
                Spacer()
                if kernel.gamePid > 0 {
                    Text("PID: \(kernel.gamePid)")
                        .font(.system(.caption, design: .monospaced).bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(6)
                        .foregroundColor(.green)
                }
            }

            HStack(spacing: 10) {
                Button(action: { kernel.forceReboot() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.shield.fill")
                        Text("Kích hoạt lại Kernel")
                    }
                    .font(.caption.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.purple.opacity(0.25))
                    .foregroundColor(.purple)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.purple.opacity(0.5), lineWidth: 1)
                    )
                }

                Button(action: { kernel.resolveGame() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                        Text("Quét lại PID")
                    }
                    .font(.caption.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.cyan.opacity(0.2))
                    .foregroundColor(.cyan)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.cyan.opacity(0.5), lineWidth: 1)
                    )
                }
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.06))
        .cornerRadius(12)
    }

    private var filterBar: some View {
        HStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(LogLevel.allCases) { lvl in
                        Button(action: { selectedFilter = lvl }) {
                            Text(lvl.rawValue)
                                .font(.caption2.bold())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(selectedFilter == lvl ? lvl.color.opacity(0.3) : Color.white.opacity(0.08))
                                .foregroundColor(selectedFilter == lvl ? lvl.color : .gray)
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(selectedFilter == lvl ? lvl.color : Color.clear, lineWidth: 1)
                                )
                        }
                    }
                }
            }

            Spacer()

            Button(action: { autoScroll.toggle() }) {
                Image(systemName: autoScroll ? "arrow.down.to.line.circle.fill" : "arrow.down.to.line.circle")
                    .foregroundColor(autoScroll ? .cyan : .gray)
                    .font(.subheadline)
            }
        }
    }

    private var terminalView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 6) {
                    if filteredEntries.isEmpty {
                        Text("Không có nhật ký nào cho bộ lọc này.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(filteredEntries) { entry in
                            logRow(entry)
                                .id(entry.id)
                        }
                    }
                }
                .padding(10)
            }
            .background(Color(red: 0.05, green: 0.05, blue: 0.07))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .onChange(of: logger.entries.count) { _ in
                if autoScroll, let last = filteredEntries.last {
                    withAnimation(.easeOut(duration: 0.15)) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    private func logRow(_ entry: LogEntry) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text(entry.timeString)
                .font(.system(size: 10, weight: .regular, design: .monospaced))
                .foregroundColor(.gray.opacity(0.8))

            Text("[\(entry.level.rawValue)]")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(entry.level.color)

            Text(entry.message)
                .font(.system(size: 11, weight: .regular, design: .monospaced))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func copyLogs() {
        UIPasteboard.general.string = logger.exportText()
        copiedAlert = true
    }
}
