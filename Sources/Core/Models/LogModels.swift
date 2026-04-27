import Foundation

// MARK: - Log Models

struct LogEntry: Codable, Identifiable {
    let raw: String
    let time: String?
    let level: String?    // "trace" | "debug" | "info" | "warn" | "error" | "fatal"
    let subsystem: String?
    let message: String?
    let meta: AnyCodable?

    var id: String { raw }
}

struct LogsResult: Codable {
    let entries: [LogEntry]
    let cursor: Int?
    let truncated: Bool?
}
