import Foundation

// MARK: - Health Models

struct HealthSummary: Codable {
    let ok: Bool
    let ts: TimeInterval
    let durationMs: TimeInterval
    let heartbeatSeconds: Int
    let defaultAgentId: String
    let agents: [HealthAgentInfo]
    let sessions: HealthSessionsInfo
}

struct HealthAgentInfo: Codable {
    let id: String
    let name: String?
}

struct HealthSessionsInfo: Codable {
    let path: String
    let count: Int
    let recent: [HealthSessionRecent]
}

struct HealthSessionRecent: Codable {
    let key: String
    let updatedAt: TimeInterval?
    let age: TimeInterval?
}

struct GatewayHelloResponse: Codable {
    let type: String
    let `protocol`: Int
    let server: ServerInfo?
    let features: FeatureInfo?
    let auth: AuthInfo?
    let canvasHostUrl: String?
    let policy: PolicyInfo?
    let snapshot: GatewaySnapshot?
}

struct GatewaySnapshot: Codable {
    let presence: [SnapshotPresenceEntry]?
    let stateVersion: StateVersion?
    let uptimeMs: Int?
    let configPath: String?
    let stateDir: String?
    let sessionDefaults: SessionDefaults?
    let authMode: String?
    let updateAvailable: SnapshotUpdateAvailable?
}

struct SnapshotPresenceEntry: Codable {
    let instanceId: String?
    let deviceId: String?
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

    var id: String { instanceId ?? deviceId ?? UUID().uuidString }
}

struct StateVersion: Codable {
    let presence: Int
    let health: Int
}

struct SessionDefaults: Codable {
    let defaultAgentId: String
    let mainKey: String
    let mainSessionKey: String
    let scope: String?
}

struct SnapshotUpdateAvailable: Codable {
    let currentVersion: String
    let latestVersion: String
    let channel: String
}

struct ServerInfo: Codable {
    let version: String?
    let connId: String?
}

struct FeatureInfo: Codable {
    let methods: [String]?
    let events: [String]?
}

struct AuthInfo: Codable {
    let deviceToken: String?
    let role: String?
    let scopes: [String]?
    let issuedAtMs: TimeInterval?
}

struct PolicyInfo: Codable {
    let tickIntervalMs: Int?
}
