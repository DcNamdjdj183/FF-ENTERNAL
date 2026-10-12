import Foundation
import SwiftUI

enum LogLevel: String, CaseIterable, Identifiable {
    case all = "Tất cả"
    case info = "INFO"
    case success = "OK"
    case warning = "WARN"
    case error = "ERR"
    case kernel = "KERNEL"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .all: return .gray
        case .info: return .cyan
        case .success: return .green
        case .warning: return .orange
        case .error: return .red
        case .kernel: return .purple
        }
    }
}

struct LogEntry: Identifiable, Equatable {
    let id = UUID()
    let timestamp: Date
    let level: LogLevel
    let message: String

    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: timestamp)
    }
}

final class AppLogger: ObservableObject {
    static let shared = AppLogger()
    
    @Published var entries: [LogEntry] = []
    private let maxEntries = 600
    private let lock = NSLock()

    private init() {
        log("Hệ thống FFKernelCheat khởi tạo sẵn sàng.", level: .info)
    }

    func log(_ message: String, level: LogLevel = .info) {
        let entry = LogEntry(timestamp: Date(), level: level, message: message)
        NSLog("[%@] %@", level.rawValue, message)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.lock.lock()
            self.entries.append(entry)
            if self.entries.count > self.maxEntries {
                self.entries.removeFirst(self.entries.count - self.maxEntries)
            }
            self.lock.unlock()
        }
    }

    func info(_ msg: String) { log(msg, level: .info) }
    func success(_ msg: String) { log(msg, level: .success) }
    func warn(_ msg: String) { log(msg, level: .warning) }
    func error(_ msg: String) { log(msg, level: .error) }
    func kernel(_ msg: String) { log(msg, level: .kernel) }

    func clear() {
        lock.lock()
        entries.removeAll()
        lock.unlock()
        log("Đã xóa toàn bộ nhật ký.", level: .info)
    }

    func exportText() -> String {
        lock.lock()
        defer { lock.unlock() }
        return entries.map { "[\($0.timeString)] [\($0.level.rawValue)] \($0.message)" }.joined(separator: "\n")
    }
}
