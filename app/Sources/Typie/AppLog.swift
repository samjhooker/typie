import Foundation

/// Lightweight file logger — everything lands in
/// ~/Library/Application Support/typie/typie.log so problems can be
/// diagnosed after the fact.
enum AppLog {
    private static let logURL = AppPaths.supportDir.appendingPathComponent("typie.log")
    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss.SSS"
        return f
    }()
    private static let queue = DispatchQueue(label: "app.typie.log")

    static func event(_ message: String) {
        queue.async {
            let line = "\(formatter.string(from: Date()))  \(message)\n"
            if let handle = try? FileHandle(forWritingTo: logURL) {
                defer { try? handle.close() }
                _ = try? handle.seekToEnd()
                handle.write(line.data(using: .utf8)!)
            } else {
                try? line.data(using: .utf8)?.write(to: logURL)
            }
        }
    }
}
