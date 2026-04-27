import Foundation

// MARK: - Config Models

struct ConfigSnapshot: Codable {
    let path: String?
    let exists: Bool?
    let raw: String?
    let hash: String?
    let parsed: AnyCodable?
    let valid: Bool?
    let config: AnyCodable?
    let issues: [ConfigSnapshotIssue]?
}

struct ConfigSnapshotIssue: Codable, Identifiable {
    let path: String
    let message: String

    var id: String { "\(path)-\(message)" }
}

struct ConfigSchemaResponse: Codable {
    let schema: AnyCodable
    let uiHints: ConfigUiHints
    let version: String
    let generatedAt: String
}

struct ConfigUiHints: Codable {
    let hide: [String]?
    let descriptions: [String: String]?
    let titles: [String: String]?
    let groupOrder: [String]?
}

struct ConfigApplyResult: Codable {
    let ok: Bool
    let restartRequired: Bool?
}

struct ConfigValidateResult: Codable {
    let ok: Bool
    let valid: Bool?
    let issues: [ConfigSnapshotIssue]?
}

// MARK: - Presence

struct PresenceEntry: Codable, Identifiable {
    let instanceId: String?
    let host: String?
    let ip: String?
    let version: String?
    let platform: String?
    let deviceFamily: String?
    let modelIdentifier: String?
    let roles: [String]?
    let scopes: [String]?
    let mode: String?
    let lastInputSeconds: TimeInterval?
    let reason: String?
    let text: String?
    let ts: TimeInterval?

    var id: String { instanceId ?? UUID().uuidString }
}

// MARK: - Update Available

struct UpdateAvailable: Codable {
    let version: String
    let releaseNotes: String?
    let downloadUrl: String?
}
