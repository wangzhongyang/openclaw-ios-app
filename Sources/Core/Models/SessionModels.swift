import Foundation

// MARK: - Session Models

/// Server returns: { ts, path, count, defaults, sessions }
/// Matches SessionsListResultBase<GatewaySessionsDefaults, GatewaySessionRow> from server.
struct SessionsListResult: Codable {
    let ts: TimeInterval
    let path: String
    let count: Int
    let defaults: GatewaySessionsDefaults?
    let sessions: [GatewaySessionRow]
}

struct GatewaySessionsDefaults: Codable {
    let modelProvider: String?
    let model: String?
    let contextTokens: Int?
}

struct GatewayAgentRow: Codable, Identifiable {
    let agentId: String
    let name: String
    let model: String?
    let workspace: String?

    var id: String { agentId }

    enum CodingKeys: String, CodingKey {
        case agentId = "id"
        case name, model, workspace
    }
}

struct GatewaySessionRow: Codable, Identifiable {
    let key: String
    let spawnedBy: String?
    let kind: String           // "direct" | "group" | "global" | "unknown"
    let label: String?
    let displayName: String?
    let surface: String?
    let subject: String?
    let room: String?
    let space: String?
    let updatedAt: TimeInterval?
    let sessionId: String?
    let systemSent: Bool?
    let abortedLastRun: Bool?
    let thinkingLevel: String?
    let thinkingOptions: [String]?
    let thinkingDefault: String?
    let fastMode: Bool?
    let verboseLevel: String?
    let reasoningLevel: String?
    let elevatedLevel: String?
    let inputTokens: Int?
    let outputTokens: Int?
    let totalTokens: Int?
    let totalTokensFresh: Bool?
    let status: String?        // "running" | "done" | "failed" | "killed" | "timeout"
    let startedAt: TimeInterval?
    let endedAt: TimeInterval?
    let runtimeMs: TimeInterval?
    let childSessions: [String]?
    let model: String?
    let modelProvider: String?
    let contextTokens: Int?
    let compactionCheckpointCount: Int?
    let latestCompactionCheckpoint: SessionCompactionCheckpoint?

    var id: String { key }
}

struct SessionCompactionCheckpoint: Codable, Identifiable {
    let checkpointId: String
    let sessionKey: String
    let sessionId: String
    let createdAt: TimeInterval
    let reason: String         // "manual" | "auto-threshold" | "overflow-retry" | "timeout-retry"
    let tokensBefore: Int?
    let tokensAfter: Int?
    let summary: String?
    let firstKeptEntryId: String?
    let preCompaction: CompactionTranscriptRef
    let postCompaction: CompactionTranscriptRef

    var id: String { checkpointId }
}

struct CompactionTranscriptRef: Codable {
    let sessionId: String
    let sessionFile: String?
    let leafId: String?
    let entryId: String?
}

struct SessionsCompactionListResult: Codable {
    let ok: Bool
    let key: String
    let checkpoints: [SessionCompactionCheckpoint]
}

struct SessionsPatchResult: Codable {
    let ok: Bool
    let sessionId: String
    let updatedAt: TimeInterval?
    let thinkingLevel: String?
    let fastMode: Bool?
}
