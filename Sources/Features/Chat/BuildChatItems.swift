import Foundation

// MARK: - BuildChatItems (对应 Web UI build-chat-items.ts)

/// 将原始消息列表转换为渲染用的 ChatItem 数组
@MainActor
func buildChatItems(
    messages: [ChatMessage],
    toolMessages: [ChatMessage],
    streamSegments: [(text: String, ts: TimeInterval)],
    stream: String?,
    streamStartedAt: TimeInterval?,
    showToolCalls: Bool,
    searchOpen: Bool,
    searchQuery: String,
    sessionKey: String
) -> [ChatItem] {

    let renderLimit = 200
    var items: [ChatItem] = []
    let history = messages
    let tools = toolMessages

    // 历史记录截断提示
    let historyStart = max(0, history.count - renderLimit)
    if historyStart > 0 {
        items.append(.message(ChatMessageItem(
            key: "chat:history:notice",
            message: ChatMessage(
                role: "system",
                content: "Showing last \(renderLimit) messages (\(historyStart) hidden)."
            )
        )))
    }

    for i in historyStart..<history.count {
        let msg = history[i]

        // 搜索过滤
        if searchOpen && !searchQuery.isEmpty && !messageMatchesSearch(msg, query: searchQuery) {
            continue
        }

        items.append(.message(ChatMessageItem(
            key: messageKey(msg, index: i),
            message: msg
        )))
    }

    // 合并 stream segments 和 tool messages
    let maxLen = max(streamSegments.count, tools.count)
    for i in 0..<maxLen {
        if i < streamSegments.count && !streamSegments[i].text.trimmingCharacters(in: .whitespaces).isEmpty {
            items.append(.stream(ChatStreamItem(
                key: "stream-seg:\(sessionKey):\(i)",
                text: streamSegments[i].text,
                startedAt: streamSegments[i].ts
            )))
        }
        if i < tools.count && showToolCalls {
            items.append(.message(ChatMessageItem(
                key: messageKey(tools[i], index: i + history.count),
                message: tools[i]
            )))
        }
    }

    // 当前流式输出
    if let stream = stream, !stream.trimmingCharacters(in: .whitespaces).isEmpty {
        let key = "stream:\(sessionKey):\(streamStartedAt.map { String($0) } ?? "live")"
        items.append(.stream(ChatStreamItem(
            key: key,
            text: stream,
            startedAt: streamStartedAt ?? Date.now.timeIntervalSince1970
        )))
    } else if stream != nil {
        let key = "stream:\(sessionKey):\(streamStartedAt.map { String($0) } ?? "live")"
        items.append(.readingIndicator(ChatReadingIndicator(key: key)))
    }

    // 连续相同角色的消息之间添加视觉分隔（用于分组效果）
    return addGroupDividers(items: items)
}

/// 在连续相同角色的消息组之间添加分隔线
@MainActor
private func addGroupDividers(items: [ChatItem]) -> [ChatItem] {
    var result: [ChatItem] = []
    var lastRole: String?

    for item in items {
        switch item {
        case .message(let msgItem):
            let role = msgItem.message.role.lowercased()
            if let last = lastRole, last != role, last != "system", role != "system" {
                // 角色变化，添加 divider
                result.append(.divider(ChatDivider(
                    key: "divider:\(UUID().uuidString)",
                    label: "",
                    timestamp: Date.now.timeIntervalSince1970
                )))
            }
            lastRole = role
            result.append(item)

        case .divider, .stream, .readingIndicator:
            result.append(item)
        }
    }

    return result
}

// MARK: - 工具函数

private func messageKey(_ message: ChatMessage, index: Int) -> String {
    if let toolCallId = message.toolCallId, !toolCallId.isEmpty {
        let role = message.role
        if let id = message.id, !id.isEmpty {
            return "tool:\(role):\(toolCallId):\(id)"
        }
        if let ts = message.timestamp {
            return "tool:\(role):\(toolCallId):\(Int(ts)):\(index)"
        }
        return "tool:\(role):\(toolCallId):\(index)"
    }
    if let id = message.id, !id.isEmpty {
        return "msg:\(id)"
    }
    if let ts = message.timestamp {
        return "msg:\(message.role):\(Int(ts)):\(index)"
    }
    return "msg:\(message.role):\(index)"
}

private func messageMatchesSearch(_ message: ChatMessage, query: String) -> Bool {
    let lowerQuery = query.lowercased()
    if message.content.lowercased().contains(lowerQuery) {
        return true
    }
    if let toolCalls = message.toolCalls {
        for tc in toolCalls {
            if tc.name.lowercased().contains(lowerQuery) || tc.input.lowercased().contains(lowerQuery) {
                return true
            }
        }
    }
    return false
}
