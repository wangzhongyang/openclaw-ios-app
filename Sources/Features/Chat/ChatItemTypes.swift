import Foundation

// MARK: - ChatItem (对应 Web UI chat-types.ts ChatItem)
// 注意: ChatMessage 和 ToolCall 在 Core/Models/ChatModels.swift 中定义

enum ChatItem: Identifiable {
    case message(ChatMessageItem)
    case divider(ChatDivider)
    case stream(ChatStreamItem)
    case readingIndicator(ChatReadingIndicator)

    var id: String {
        switch self {
        case .message(let item): item.key
        case .divider(let item): item.key
        case .stream(let item): item.key
        case .readingIndicator(let item): item.key
        }
    }

    var kind: String {
        switch self {
        case .message: "message"
        case .divider: "divider"
        case .stream: "stream"
        case .readingIndicator: "reading-indicator"
        }
    }
}

struct ChatMessageItem: Identifiable {
    let key: String
    let message: ChatMessage
    var id: String { key }
}

struct ChatDivider: Identifiable {
    let key: String
    let label: String
    let timestamp: TimeInterval
    var id: String { key }
}

struct ChatStreamItem: Identifiable {
    let key: String
    let text: String
    let startedAt: TimeInterval
    var id: String { key }
}

struct ChatReadingIndicator: Identifiable {
    let key: String
    var id: String { key }
}

// MARK: - MessageGroup (对应 Web UI chat-types.ts MessageGroup)

struct MessageGroup: Identifiable {
    let key: String
    let role: String
    let senderLabel: String?
    let messages: [GroupedMessage]
    let timestamp: TimeInterval
    var isStreaming: Bool
    var id: String { key }
}

struct GroupedMessage {
    let key: String
    let message: ChatMessage
}

// MARK: - ToolCard (对应 Web UI chat-types.ts ToolCard)

struct ToolCard: Identifiable {
    let id: String
    let name: String
    let args: [String: Any]?
    let inputText: String?
    var outputText: String?
    var preview: ToolCardPreview?

    var displayName: String {
        // 类似 Web UI 的 resolveToolDisplay
        let known = KNOWN_TOOL_DISPLAYS[name.lowercased()]
        return known?.label ?? name
    }

    var displayIcon: String {
        let known = KNOWN_TOOL_DISPLAYS[name.lowercased()]
        return known?.icon ?? "wrench"
    }
}

struct ToolCardPreview {
    let kind: String        // "canvas"
    let surface: String     // "assistant_message"
    let render: String      // "url"
    let title: String?
    let preferredHeight: Int?
    let url: String?
    let viewId: String?
}

// 已知工具显示名映射（对应 Web UI tool-display.ts）
private let KNOWN_TOOL_DISPLAYS: [String: (label: String, icon: String)] = [
    "read_file": ("Read File", "doc"),
    "write_file": ("Write File", "doc.badge.plus"),
    "edit_file": ("Edit File", "pencil"),
    "bash": ("Terminal", "terminal"),
    "web_fetch": ("Web Fetch", "globe"),
    "web_search": ("Web Search", "magnifyingglass"),
    "notebook_add_cell": ("Notebook", "book"),
    "mcp__*": ("MCP Tool", "puzzlepiece"),
]

// MARK: - SlashCommand (对应 Web UI slash-commands.ts SlashCommandDef)

enum SlashCommandCategory: String, CaseIterable {
    case session, model, agents, tools

    var label: String {
        switch self {
        case .session: "Session"
        case .model: "Model"
        case .agents: "Agents"
        case .tools: "Tools"
        }
    }
}

enum SlashCommandTier: String {
    case essential, standard, power
}

struct SlashCommandDef: Identifiable {
    let key: String
    let name: String
    let aliases: [String]?
    let description: String
    let args: String?
    let icon: String?           // SF Symbol name
    let category: SlashCommandCategory
    let executeLocal: Bool
    let argOptions: [String]?   // 固定参数选项
    let shortcut: String?       // 键盘快捷键提示
    let tier: SlashCommandTier

    var id: String { key }

    var slashText: String {
        "/\(name)"
    }
}

// MARK: - ParsedSlashCommand

struct ParsedSlashCommand {
    let command: SlashCommandDef
    let args: String
}

// MARK: - ChatAttachment

struct ChatAttachment: Identifiable {
    let id: String
    let dataUrl: String
    let mimeType: String

    static func generateId() -> String {
        "att-\(Int(Date.now.timeIntervalSince1970 * 1000))-\(String(Int.random(in: 100000...999999)))"
    }
}

// MARK: - ChatQueueItem

struct ChatQueueItem: Identifiable {
    let id: String
    let text: String
    let attachments: [ChatAttachment]
}

// MARK: - ChatSideResult (对应 Web UI side-result.ts)

struct ChatSideResult {
    let runId: String
    let sessionKey: String
    let question: String
    let text: String
    let isError: Bool
    let ts: TimeInterval
}

// MARK: - CompactionStatus / FallbackStatus

struct CompactionStatus {
    let inProgress: Bool
    let lastCompactedAt: TimeInterval?
}

struct FallbackStatus {
    let active: Bool
    let reason: String?
}

// MARK: - InputHistory (对应 Web UI input-history.ts)

@MainActor
final class InputHistory {
    private var history: [String] = []
    private var index: Int = -1
    private let maxCount = 50

    func push(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if history.last == trimmed { return }
        history.append(trimmed)
        if history.count > maxCount {
            history.removeFirst(history.count - maxCount)
        }
        index = -1
    }

    func up() -> String? {
        guard !history.isEmpty else { return nil }
        if index == -1 {
            index = history.count - 1
        } else if index > 0 {
            index -= 1
        }
        return history[index]
    }

    func down() -> String? {
        guard index != -1 else { return nil }
        if index < history.count - 1 {
            index += 1
            return history[index]
        } else {
            index = -1
            return ""
        }
    }

    func reset() {
        index = -1
    }
}

// MARK: - PinnedMessages (对应 Web UI pinned-messages.ts)

@MainActor
final class PinnedMessages {
    private let sessionKey: String
    var indices: [Int] = []

    init(_ sessionKey: String) {
        self.sessionKey = sessionKey
    }

    func togglePin(_ index: Int) {
        if let pos = indices.firstIndex(of: index) {
            indices.remove(at: pos)
        } else {
            indices.append(index)
        }
    }

    func unpin(_ index: Int) {
        indices.removeAll { $0 == index }
    }

    var isPinned: Bool { !indices.isEmpty }
}

// MARK: - DeletedMessages (对应 Web UI deleted-messages.ts)

@MainActor
final class DeletedMessages {
    private let sessionKey: String
    private var deletedKeys: Set<String> = []

    init(_ sessionKey: String) {
        self.sessionKey = sessionKey
    }

    func delete(_ key: String) {
        deletedKeys.insert(key)
    }

    func has(_ key: String) -> Bool {
        deletedKeys.contains(key)
    }
}
