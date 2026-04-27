import Foundation

// MARK: - Chat Models

struct ChatMessage: Codable, Identifiable, Equatable {
    let id: String?
    let role: String          // "user" | "assistant" | "system" | "tool"
    var content: String
    let timestamp: TimeInterval?
    let runId: String?
    var toolCalls: [ToolCall]?
    let toolCallId: String?   // For tool result messages
    let queued: Bool?
    let error: String?

    var stableId: String { 
        if let id = id, !id.isEmpty {
            return id
        }
        // Generate unique ID for messages without ID to avoid SwiftUI rendering issues
        let timestamp = Date().timeIntervalSince1970
        return "missing-\(Int(timestamp * 1000))-\(UUID().uuidString.prefix(8))"
    }

    init(
        id: String? = nil,
        role: String,
        content: String,
        timestamp: TimeInterval? = nil,
        runId: String? = nil,
        toolCalls: [ToolCall]? = nil,
        toolCallId: String? = nil,
        queued: Bool? = false,
        error: String? = nil
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
        self.runId = runId
        self.toolCalls = toolCalls
        self.toolCallId = toolCallId
        self.queued = queued
        self.error = error
    }

    enum CodingKeys: String, CodingKey {
        case id, role, content, timestamp, runId, toolCalls, toolCallId, queued, error
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        role = try container.decode(String.self, forKey: .role)
        timestamp = try container.decodeIfPresent(TimeInterval.self, forKey: .timestamp)
        runId = try container.decodeIfPresent(String.self, forKey: .runId)
        toolCalls = try container.decodeIfPresent([ToolCall].self, forKey: .toolCalls)
        toolCallId = try container.decodeIfPresent(String.self, forKey: .toolCallId)
        queued = try container.decodeIfPresent(Bool.self, forKey: .queued)
        error = try container.decodeIfPresent(String.self, forKey: .error)

        // content 可以是字符串或数组，灵活解码
        if let stringContent = try? container.decode(String.self, forKey: .content) {
            content = stringContent
        } else if let contentArray = try? container.decode([AnyCodable].self, forKey: .content) {
            // 从 content 数组中提取文本
            let texts = contentArray.compactMap { block -> String? in
                if let dict = block.value as? [String: Any], let text = dict["text"] as? String {
                    return text
                }
                return nil
            }
            content = texts.joined(separator: "\n\n")
        } else {
            content = ""
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(role, forKey: .role)
        try container.encode(content, forKey: .content)
        try container.encodeIfPresent(timestamp, forKey: .timestamp)
        try container.encodeIfPresent(runId, forKey: .runId)
        try container.encodeIfPresent(toolCalls, forKey: .toolCalls)
        try container.encodeIfPresent(toolCallId, forKey: .toolCallId)
        try container.encodeIfPresent(queued, forKey: .queued)
        try container.encodeIfPresent(error, forKey: .error)
    }
}

struct ToolCall: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let input: String
    var output: String?
    var status: ToolCallStatus
}

enum ToolCallStatus: String, Codable, Equatable {
    case running, completed, failed
}

struct ChatHistoryResult: Codable {
    let messages: [ChatMessage]
    let sessionKey: String
}

struct ChatSendResult: Codable {
    let runId: String
    let sessionKey: String
}

struct ChatAbortResult: Codable {
    let ok: Bool
}

struct ChatEventPayload: Codable {
    let state: String?        // "delta" | "final" | "aborted" | "error"
    let sessionKey: String?
    let runId: String?
    let message: AnyCodable?  // assistant message object
    let errorMessage: String?
}

struct ToolCallEvent: Codable {
    let id: String
    let name: String
    let input: String?
    let output: String?
    let status: String?
}

// MARK: - Chat Attachment

struct ChatAttachmentPayload: Codable {
    let type: String
    let data: String
    let mimeType: String?
    let fileName: String?
}
