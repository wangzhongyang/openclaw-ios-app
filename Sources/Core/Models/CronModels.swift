import Foundation

// MARK: - Cron Models

struct CronJob: Codable, Identifiable {
    let id: String
    let name: String
    let enabled: Bool
    let schedule: CronSchedule
    let sessionTarget: String
    let wakeMode: String?
    let payload: CronPayload
    let delivery: CronDelivery?
    let failureAlert: CronFailureAlert?
    let createdAt: TimeInterval?
    let updatedAt: TimeInterval?
    let state: CronJobState?

    enum CodingKeys: String, CodingKey {
        case id, name, enabled, schedule
        case sessionTarget = "target"
        case wakeMode = "wake"
        case payload, delivery
        case failureAlert = "failureAlert"
        case createdAt, updatedAt, state
    }
}

enum CronSchedule: Codable {
    case at(at: String)
    case every(everyMs: Int, anchorMs: TimeInterval?)
    case cron(expr: String, tz: String?, staggerMs: Int?)

    enum CodingKeys: String, CodingKey {
        case kind, at, everyMs, anchorMs, expr, tz, staggerMs
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(String.self, forKey: .kind)
        switch kind {
        case "at":
            let at = try container.decode(String.self, forKey: .at)
            self = .at(at: at)
        case "every":
            let everyMs = try container.decode(Int.self, forKey: .everyMs)
            let anchorMs = try container.decodeIfPresent(TimeInterval.self, forKey: .anchorMs)
            self = .every(everyMs: everyMs, anchorMs: anchorMs)
        case "cron":
            let expr = try container.decode(String.self, forKey: .expr)
            let tz = try container.decodeIfPresent(String.self, forKey: .tz)
            let staggerMs = try container.decodeIfPresent(Int.self, forKey: .staggerMs)
            self = .cron(expr: expr, tz: tz, staggerMs: staggerMs)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .kind, in: container, debugDescription: "Unknown cron schedule kind: \(kind)")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .at(let at):
            try container.encode("at", forKey: .kind)
            try container.encode(at, forKey: .at)
        case .every(let everyMs, let anchorMs):
            try container.encode("every", forKey: .kind)
            try container.encode(everyMs, forKey: .everyMs)
            try container.encodeIfPresent(anchorMs, forKey: .anchorMs)
        case .cron(let expr, let tz, let staggerMs):
            try container.encode("cron", forKey: .kind)
            try container.encode(expr, forKey: .expr)
            try container.encodeIfPresent(tz, forKey: .tz)
            try container.encodeIfPresent(staggerMs, forKey: .staggerMs)
        }
    }
}

enum CronPayload: Codable {
    case systemEvent(text: String)
    case agentTurn(message: String, model: String?, fallbacks: [String]?, thinking: String?,
                   timeoutSeconds: Int?, allowUnsafeExternalContent: Bool?, lightContext: Bool?,
                   deliver: Bool?, channel: String?, to: String?, bestEffortDeliver: Bool?)

    enum CodingKeys: String, CodingKey { case kind }
    enum PayloadKind: String, Codable { case systemEvent, agentTurn }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(PayloadKind.self, forKey: .kind)
        switch kind {
        case .systemEvent:
            let allContainer = try decoder.container(keyedBy: AllCodingKeys.self)
            let text = try allContainer.decode(String.self, forKey: .text)
            self = .systemEvent(text: text)
        case .agentTurn:
            let allContainer = try decoder.container(keyedBy: AllCodingKeys.self)
            let message = try allContainer.decode(String.self, forKey: .message)
            let model = try allContainer.decodeIfPresent(String.self, forKey: .model)
            let fallbacks = try allContainer.decodeIfPresent([String].self, forKey: .fallbacks)
            let thinking = try allContainer.decodeIfPresent(String.self, forKey: .thinking)
            let timeoutSeconds = try allContainer.decodeIfPresent(Int.self, forKey: .timeoutSeconds)
            let allowUnsafe = try allContainer.decodeIfPresent(Bool.self, forKey: .allowUnsafeExternalContent)
            let lightContext = try allContainer.decodeIfPresent(Bool.self, forKey: .lightContext)
            let deliver = try allContainer.decodeIfPresent(Bool.self, forKey: .deliver)
            let channel = try allContainer.decodeIfPresent(String.self, forKey: .channel)
            let to = try allContainer.decodeIfPresent(String.self, forKey: .to)
            let bestEffort = try allContainer.decodeIfPresent(Bool.self, forKey: .bestEffortDeliver)
            self = .agentTurn(message: message, model: model, fallbacks: fallbacks,
                             thinking: thinking, timeoutSeconds: timeoutSeconds,
                             allowUnsafeExternalContent: allowUnsafe, lightContext: lightContext,
                             deliver: deliver, channel: channel, to: to, bestEffortDeliver: bestEffort)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .systemEvent(let text):
            try container.encode(PayloadKind.systemEvent, forKey: .kind)
            var allContainer = encoder.container(keyedBy: AllCodingKeys.self)
            try allContainer.encode(text, forKey: .text)
        case .agentTurn(let message, let model, let fallbacks, let thinking,
                        let timeout, let allowUnsafe, let lightContext,
                        let deliver, let channel, let to, let bestEffort):
            try container.encode(PayloadKind.agentTurn, forKey: .kind)
            var allContainer = encoder.container(keyedBy: AllCodingKeys.self)
            try allContainer.encode(message, forKey: .message)
            try allContainer.encodeIfPresent(model, forKey: .model)
            try allContainer.encodeIfPresent(fallbacks, forKey: .fallbacks)
            try allContainer.encodeIfPresent(thinking, forKey: .thinking)
            try allContainer.encodeIfPresent(timeout, forKey: .timeoutSeconds)
            try allContainer.encodeIfPresent(allowUnsafe, forKey: .allowUnsafeExternalContent)
            try allContainer.encodeIfPresent(lightContext, forKey: .lightContext)
            try allContainer.encodeIfPresent(deliver, forKey: .deliver)
            try allContainer.encodeIfPresent(channel, forKey: .channel)
            try allContainer.encodeIfPresent(to, forKey: .to)
            try allContainer.encodeIfPresent(bestEffort, forKey: .bestEffortDeliver)
        }
    }
}

struct CronDelivery: Codable {
    let mode: String
    let channel: String?
    let to: String?
    let accountId: String?
    let bestEffort: Bool?
}

struct CronFailureAlert: Codable {
    let after: Int?
    let channel: String?
    let to: String?
    let cooldownMs: TimeInterval?
    let mode: String?
    let accountId: String?
}

struct CronJobState: Codable {
    let nextRunAtMs: TimeInterval?
    let runningAtMs: TimeInterval?
    let lastRunAtMs: TimeInterval?
    let lastRunStatus: String?
    let lastStatus: String?
    let lastError: String?
    let lastErrorReason: String?
    let lastDurationMs: TimeInterval?
    let consecutiveErrors: Int?
    let lastDelivered: Bool?
    let lastDeliveryStatus: String?
    let lastDeliveryError: String?
    let lastFailureAlertAtMs: TimeInterval?
}

struct CronStatus: Codable {
    let enabled: Bool
    let jobs: Int
    let nextWakeAtMs: TimeInterval?
}

struct CronJobsListResult: Codable {
    let jobs: [CronJob]
    let total: Int?
    let limit: Int?
    let offset: Int?
    let nextOffset: Int?
    let hasMore: Bool?
}

struct CronRunLogEntry: Codable, Identifiable {
    let ts: TimeInterval
    let jobId: String
    let action: String?
    let status: String?
    let durationMs: TimeInterval?
    let error: String?
    let summary: String?
    let delivered: Bool?
    let deliveryStatus: String?
    let deliveryError: String?
    let sessionId: String?
    let sessionKey: String?
    let runAtMs: TimeInterval?
    let nextRunAtMs: TimeInterval?
    let model: String?
    let provider: String?
    let usage: CronRunUsage?
    let jobName: String?

    var id: String { "\(jobId)-\(ts)" }
}

struct CronRunUsage: Codable {
    let inputTokens: Int?
    let outputTokens: Int?
    let totalTokens: Int?
    let cacheReadTokens: Int?
    let cacheWriteTokens: Int?

    enum CodingKeys: String, CodingKey {
        case inputTokens = "input_tokens"
        case outputTokens = "output_tokens"
        case totalTokens = "total_tokens"
        case cacheReadTokens = "cache_read_tokens"
        case cacheWriteTokens = "cache_write_tokens"
    }
}

struct CronRunsResult: Codable {
    let entries: [CronRunLogEntry]
    let total: Int?
    let limit: Int?
    let offset: Int?
    let nextOffset: Int?
    let hasMore: Bool?
}

// Generic coding keys for discriminated unions
private enum AllCodingKeys: String, CodingKey {
    case kind, at, everyMs, anchorMs, expr, tz, staggerMs
    case text, message, model, fallbacks, thinking, timeoutSeconds
    case allowUnsafeExternalContent, lightContext, deliver, channel, to
    case bestEffortDeliver
}
