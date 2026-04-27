import Foundation

// MARK: - SlashCommands (对应 Web UI slash-commands.ts)

/// 内置本地命令（不发送给 Agent，客户端直接处理）
let LOCAL_SLASH_COMMANDS: Set<String> = [
    "help", "new", "reset", "stop", "compact", "focus",
    "model", "think", "fast", "verbose", "export-session",
    "usage", "agents", "kill", "steer", "redirect", "clear",
]

/// UI 专属命令（不在远程命令中）
let UI_ONLY_COMMANDS: [SlashCommandDef] = [
    SlashCommandDef(
        key: "clear",
        name: "clear",
        aliases: nil,
        description: "Clear chat history",
        args: nil,
        icon: "trash",
        category: .session,
        executeLocal: true,
        argOptions: nil,
        shortcut: nil,
        tier: .standard
    ),
    SlashCommandDef(
        key: "redirect",
        name: "redirect",
        aliases: nil,
        description: "Abort and restart with a new message",
        args: "[id] <message>",
        icon: "arrow.triangle.2.circlepath",
        category: .agents,
        executeLocal: true,
        argOptions: nil,
        shortcut: nil,
        tier: .power
    ),
]

/// 图标覆盖
let COMMAND_ICON_OVERRIDES: [String: String] = [
    "help": "book.fill",
    "status": "chart.bar.fill",
    "usage": "chart.bar.fill",
    "export": "square.and.arrow.down",
    "export_session": "square.and.arrow.down",
    "tools": "terminal",
    "skill": "bolt.fill",
    "commands": "book.fill",
    "new": "plus.circle.fill",
    "reset": "arrow.clockwise",
    "compact": "arrow.2.circlepath",
    "stop": "stop.fill",
    "clear": "trash",
    "focus": "eye.fill",
    "unfocus": "eye.slash",
    "model": "brain.fill",
    "models": "brain.fill",
    "think": "brain.fill",
    "verbose": "terminal",
    "fast": "bolt.fill",
    "agents": "display",
    "subagents": "folder.fill",
    "kill": "xmark.circle.fill",
    "steer": "paperplane.fill",
    "tts": "speaker.wave.3.fill",
]

/// 分类覆盖
let CATEGORY_OVERRIDES: [String: SlashCommandCategory] = [
    "help": .tools, "commands": .tools, "tools": .tools,
    "skill": .tools, "status": .tools, "export_session": .tools,
    "usage": .tools, "tts": .tools,
    "agents": .agents, "subagents": .agents, "kill": .agents, "steer": .agents, "redirect": .agents,
    "session": .session, "stop": .session, "reset": .session, "new": .session,
    "compact": .session, "focus": .session, "unfocus": .session,
    "model": .model, "models": .model, "think": .model,
    "verbose": .model, "fast": .model, "reasoning": .model,
    "elevated": .model, "queue": .model,
]

/// 描述覆盖
let COMMAND_DESCRIPTION_OVERRIDES: [String: String] = [
    "steer": "Inject a message into the active run",
]

/// 参数覆盖
let COMMAND_ARGS_OVERRIDES: [String: String] = [
    "steer": "[id] <message>",
]

// MARK: - 默认命令列表

nonisolated(unsafe) let ALL_SLASH_COMMANDS: [SlashCommandDef] = {
    let builtins = BUILTIN_COMMAND_ENTRIES.map { entry -> SlashCommandDef in
        toSlashCommand(entry, source: "local")
    }
    return builtins + UI_ONLY_COMMANDS
}()

/// 解析斜杠命令
func parseSlashCommand(_ text: String) -> ParsedSlashCommand? {
    let trimmed = text.trimmingCharacters(in: .whitespaces)
    guard trimmed.hasPrefix("/") else { return nil }

    let body = String(trimmed.dropFirst())
    // 找到第一个空格或冒号
    var sepIndex: String.Index?
    for (i, char) in body.enumerated() {
        if char == " " || char == ":" {
            sepIndex = body.index(body.startIndex, offsetBy: i)
            break
        }
    }
    if let sepRange = sepIndex {
        let name = String(body[..<sepRange])
        var remainder = String(body[body.index(after: sepRange)...]).trimmingCharacters(in: .whitespaces)
        if remainder.hasPrefix(":") {
            remainder = String(remainder.dropFirst()).trimmingCharacters(in: .whitespaces)
        }
        let args = remainder

        guard !name.isEmpty else { return nil }
        let normalizedName = name.lowercased()
        if let command = ALL_SLASH_COMMANDS.first(where: {
            $0.name == normalizedName || ($0.aliases?.contains(normalizedName) ?? false)
        }) {
            return ParsedSlashCommand(command: command, args: args)
        }
    } else {
        // 没有参数，只有命令名
        guard !body.isEmpty else { return nil }
        let normalizedName = body.lowercased()
        if let command = ALL_SLASH_COMMANDS.first(where: {
            $0.name == normalizedName || ($0.aliases?.contains(normalizedName) ?? false)
        }) {
            return ParsedSlashCommand(command: command, args: "")
        }
    }

    return nil
}

/// 获取补全列表
func getSlashCommandCompletions(filter: String, showAll: Bool = false) -> [SlashCommandDef] {
    let lower = filter.lowercased()
    var commands: [SlashCommandDef]

    if lower.isEmpty {
        commands = ALL_SLASH_COMMANDS
    } else {
        commands = ALL_SLASH_COMMANDS.filter { cmd in
            cmd.name.hasPrefix(lower) ||
            (cmd.aliases?.contains { $0.lowercased().hasPrefix(lower) } ?? false) ||
            cmd.description.lowercased().contains(lower)
        }
    }

    // 隐藏 power tier（除非 showAll）
    if lower.isEmpty && !showAll {
        commands = commands.filter { $0.tier != .power }
    }

    // 排序：tier → category → 精确匹配优先
    let tierOrder: [SlashCommandTier: Int] = [.essential: 0, .standard: 1, .power: 2]
    let categoryOrder: [SlashCommandCategory: Int] = [.session: 0, .model: 1, .tools: 2, .agents: 3]

    return commands.sorted { a, b in
        let aTier = tierOrder[a.tier] ?? 1
        let bTier = tierOrder[b.tier] ?? 1
        if aTier != bTier { return aTier < bTier }

        let aCat = categoryOrder[a.category] ?? 0
        let bCat = categoryOrder[b.category] ?? 0
        if aCat != bCat { return aCat < bCat }

        if !lower.isEmpty {
            let aExact = a.name.hasPrefix(lower) ? 0 : 1
            let bExact = b.name.hasPrefix(lower) ? 0 : 1
            if aExact != bExact { return aExact < bExact }
        }

        return false
    }
}

/// 隐藏的 power 命令数量
func getHiddenCommandCount() -> Int {
    ALL_SLASH_COMMANDS.filter { $0.tier == .power }.count
}

// MARK: - 内部转换

private func toSlashCommand(_ entry: CommandEntry, source: String) -> SlashCommandDef {
    let normalizedName = entry.name.lowercased()
    let category = CATEGORY_OVERRIDES[normalizedName] ?? entry.category ?? .tools
    let icon = COMMAND_ICON_OVERRIDES[normalizedName]
    let description = COMMAND_DESCRIPTION_OVERRIDES[normalizedName] ?? entry.description
    let args = COMMAND_ARGS_OVERRIDES[normalizedName] ?? formatArgs(entry)
    let executeLocal = source == "local" && LOCAL_SLASH_COMMANDS.contains(entry.key)
    let argOptions = entry.args?.first?.choices?.compactMap { $0 as? String }

    return SlashCommandDef(
        key: entry.key,
        name: entry.name,
        aliases: entry.aliases,
        description: description,
        args: args,
        icon: icon,
        category: category,
        executeLocal: executeLocal,
        argOptions: argOptions,
        shortcut: nil,
        tier: source == "local" ? (entry.tier ?? .standard) : .standard
    )
}

private func formatArgs(_ entry: CommandEntry) -> String? {
    guard let args = entry.args, !args.isEmpty else { return nil }
    return args.map { arg in
        arg.required ? "<\(arg.name)>" : "[\(arg.name)]"
    }.joined(separator: " ")
}

// MARK: - CommandEntry 结构（对应远程命令）

struct CommandArg: Sendable {
    let name: String
    let required: Bool
    let choices: [Any]?
}

struct CommandEntry: Sendable {
    let key: String
    let name: String
    let aliases: [String]?
    let description: String
    let args: [CommandArg]?
    let category: SlashCommandCategory?
    let tier: SlashCommandTier?
}

// 内置命令定义
nonisolated(unsafe) let BUILTIN_COMMAND_ENTRIES: [CommandEntry] = [
    CommandEntry(key: "help", name: "help", aliases: nil, description: "Show available commands", args: nil, category: .tools, tier: .essential),
    CommandEntry(key: "new", name: "new", aliases: nil, description: "Start a new session", args: nil, category: .session, tier: .essential),
    CommandEntry(key: "reset", name: "reset", aliases: nil, description: "Reset the current session", args: nil, category: .session, tier: .standard),
    CommandEntry(key: "stop", name: "stop", aliases: nil, description: "Stop the current run", args: nil, category: .session, tier: .essential),
    CommandEntry(key: "compact", name: "compact", aliases: nil, description: "Compact the conversation context", args: nil, category: .session, tier: .standard),
    CommandEntry(key: "focus", name: "focus", aliases: nil, description: "Enter focus mode", args: nil, category: .session, tier: .standard),
    CommandEntry(key: "model", name: "model", aliases: nil, description: "Change the model", args: [CommandArg(name: "model", required: true, choices: nil)], category: .model, tier: .essential),
    CommandEntry(key: "think", name: "think", aliases: nil, description: "Set reasoning level", args: [CommandArg(name: "level", required: false, choices: ["off", "low", "medium", "high"])], category: .model, tier: .standard),
    CommandEntry(key: "fast", name: "fast", aliases: nil, description: "Use fast model mode", args: nil, category: .model, tier: .standard),
    CommandEntry(key: "verbose", name: "verbose", aliases: nil, description: "Enable verbose output", args: nil, category: .model, tier: .standard),
    CommandEntry(key: "export-session", name: "export-session", aliases: ["export"], description: "Export session as markdown", args: nil, category: .tools, tier: .standard),
    CommandEntry(key: "usage", name: "usage", aliases: nil, description: "Show session usage stats", args: nil, category: .tools, tier: .standard),
    CommandEntry(key: "agents", name: "agents", aliases: nil, description: "List available agents", args: nil, category: .agents, tier: .standard),
    CommandEntry(key: "kill", name: "kill", aliases: nil, description: "Kill a subagent", args: [CommandArg(name: "id", required: true, choices: nil)], category: .agents, tier: .power),
    CommandEntry(key: "steer", name: "steer", aliases: nil, description: "Inject a message into the active run", args: nil, category: .agents, tier: .power),
    CommandEntry(key: "status", name: "status", aliases: nil, description: "Show system status", args: nil, category: .tools, tier: .essential),
    CommandEntry(key: "tools", name: "tools", aliases: nil, description: "List available tools", args: nil, category: .tools, tier: .standard),
    CommandEntry(key: "tts", name: "tts", aliases: nil, description: "Toggle text-to-speech", args: nil, category: .tools, tier: .standard),
]
