import Foundation

// MARK: - Usage Models

struct SessionsUsageResult: Codable {
    let ok: Bool
    let totals: SessionsUsageTotals
    let daily: [CostUsageDailyEntry]
    let entries: [SessionsUsageEntry]
}

struct SessionsUsageTotals: Codable {
    let inputTokens: Int
    let outputTokens: Int
    let totalTokens: Int
    let cacheReadTokens: Int?
    let cacheWriteTokens: Int?
    let cost: Double?
    let currency: String?

    enum CodingKeys: String, CodingKey {
        case inputTokens = "input_tokens"
        case outputTokens = "output_tokens"
        case totalTokens = "total_tokens"
        case cacheReadTokens = "cache_read_tokens"
        case cacheWriteTokens = "cache_write_tokens"
        case cost, currency
    }
}

struct CostUsageDailyEntry: Codable {
    let date: String
    let inputTokens: Int
    let outputTokens: Int
    let totalTokens: Int
    let cost: Double?
    let sessionCount: Int

    enum CodingKeys: String, CodingKey {
        case date
        case inputTokens = "input_tokens"
        case outputTokens = "output_tokens"
        case totalTokens = "total_tokens"
        case cost, sessionCount = "session_count"
    }
}

struct SessionsUsageEntry: Codable, Identifiable {
    let sessionKey: String
    let kind: String?
    let label: String?
    let channel: String?
    let agent: String?
    let model: String?
    let modelProvider: String?
    let inputTokens: Int
    let outputTokens: Int
    let totalTokens: Int
    let cost: Double?
    let messageCount: Int
    let toolCallCount: Int?
    let errorCount: Int?
    let firstAt: TimeInterval?
    let lastAt: TimeInterval?
    let durationMs: TimeInterval?

    var id: String { sessionKey }

    enum CodingKeys: String, CodingKey {
        case sessionKey, kind, label, channel, agent, model
        case modelProvider = "model_provider"
        case inputTokens = "input_tokens"
        case outputTokens = "output_tokens"
        case totalTokens = "total_tokens"
        case cost
        case messageCount = "message_count"
        case toolCallCount = "tool_call_count"
        case errorCount = "error_count"
        case firstAt = "first_at"
        case lastAt = "last_at"
        case durationMs = "duration_ms"
    }
}

struct CostUsageSummary: Codable {
    let totalCost: Double
    let currency: String
    let dailyBreakdown: [CostUsageDailyEntry]

    enum CodingKeys: String, CodingKey {
        case totalCost = "total_cost"
        case currency
        case dailyBreakdown = "daily"
    }
}

struct SessionUsageTimeSeries: Codable {
    let points: [SessionUsageTimePoint]
    let totalCounts: Bool?
    let byAgent: [String: SessionUsageTimeSeries]?
}

struct SessionUsageTimePoint: Codable {
    let ts: TimeInterval
    let inputTokens: Int
    let outputTokens: Int
    let totalTokens: Int
    let cost: Double?

    enum CodingKeys: String, CodingKey {
        case ts
        case inputTokens = "input_tokens"
        case outputTokens = "output_tokens"
        case totalTokens = "total_tokens"
        case cost
    }
}
