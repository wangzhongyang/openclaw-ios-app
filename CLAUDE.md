# CLAUDE.md

**核心规则**：除 iOS 页面布局外，所有模块逻辑必须与 `/Users/wangzhongyang/everyCode/service/openclaw/ui` 内一致，不允许擅自更改。如要修改，必须说明原因并获得用户明确同意。

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概览

**OpenClaw Control iOS** — 原生 SwiftUI iOS App（iOS 17+），100% 复刻 OpenClaw Web 控制面板的全部功能。通过 WebSocket 连接 OpenClaw Gateway（协议 v3，operator 角色），提供聊天、会话管理、Agent 配置等全部管理面板功能。

**技术栈**：SwiftUI + Observation (iOS 17+)、URLSessionWebSocketTask、CryptoKit (Ed25519)、Swift Charts、XcodeGen 构建。**允许使用外部 Swift 包依赖**以加快开发速度（如 MarkdownUI 用于 Markdown 渲染、Highlightr 用于代码高亮等）。
gateway token: b9902b482fb17c04ee03b9ca7479111780d993b0f7bdbc1793d6aa6cb65ac333

## 构建命令

本项目使用 **XcodeGen** 生成 Xcode 项目，无 `Package.swift`。

### 重要：构建前必须清理 DerivedData

Xcode 的 DerivedData 缓存可能导致旧代码被使用，修改代码后务必按以下步骤操作。

### 一键构建并运行（推荐）

```bash
# 自动清理 → 构建 → 安装到模拟器 → 启动
./build_run.sh
```

`build_run.sh` 会自动：
1. 执行 `xcodebuild clean` 清理 DerivedData
2. 编译最新代码
3. 安装到已启动的 iPhone 17 模拟器
4. 终止旧进程并重新启动 App

**必须在代码变更后使用此脚本，不要直接在 Xcode 中点击运行。**

### 手动构建

```bash
# 从 project.yml 生成 Xcode 项目（修改依赖或 target 后执行）
xcodegen generate

# 必须先清理！
xcodebuild clean -project OpenClawControliOS.xcodeproj -scheme OpenClawControliOS

# 编译
xcodebuild -project OpenClawControliOS.xcodeproj -scheme OpenClawControliOS -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17' build

# 安装到已启动的模拟器（Bundle ID: ai.openclaw.control）
# xcrun simctl install <SIMULATOR_ID> <APP_PATH>
# xcrun simctl launch <SIMULATOR_ID> ai.openclaw.control

# 运行全部单元测试
xcodebuild test -project OpenClawControliOS.xcodeproj -scheme OpenClawControliOS -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:OpenClawControliOSTests

# 运行单个测试类
xcodebuild test -project OpenClawControliOS.xcodeproj -scheme OpenClawControliOS -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:OpenClawControliOSTests/SessionModelTests
```

## Web UI 模块清单（19 个 Tab）

所有 Tab 按 4 个分组排列，对应 `navigation.ts` 中的 `TAB_GROUPS`。

### Chat 分组

| Tab | 路由 | Web UI 逻辑文件 | iOS 对应文件 | 核心 RPC |
|-----|------|----------------|-------------|---------|
| Chat | /chat | `views/chat.ts`, `controllers/chat.ts`, `chat/build-chat-items.ts`, `chat/tool-cards.ts`, `chat/slash-commands.ts`, `chat/export.ts`, `chat/side-result.ts`, `chat/session-cache.ts`, `chat/session-controls.ts`, `chat/message-normalizer.ts`, `chat/grouped-render.ts`, `chat/run-controls.ts`, `chat/status-indicators.ts` | `Sources/Features/Chat/ChatView.swift` | `chat.history`, `chat.send`, `chat.abort`, `models.catalog` |

### Control 分组

| Tab | 路由 | Web UI 逻辑文件 | iOS 对应文件 | 核心 RPC |
|-----|------|----------------|-------------|---------|
| Overview | /overview | `views/overview.ts`, `views/overview-cards.ts`, `views/overview-attention.ts`, `views/overview-event-log.ts`, `views/overview-log-tail.ts`, `views/overview-hints.ts`, `controllers/health.ts` | `Sources/Features/Dashboard/DashboardView.swift` | `health` |
| Channels | /channels | `views/channels.ts`, `views/channels.telegram.ts`, `views/channels.discord.ts`, `views/channels.whatsapp.ts`, `views/channels.signal.ts`, `views/channels.slack.ts`, `views/channels.nostr.ts`, `views/channels.nostr-profile-form.ts`, `views/channels.imessage.ts`, `views/channels.googlechat.ts`, `views/channels.config.ts`, `views/channels.shared.ts`, `views/channels.types.ts`, `controllers/channels.ts` | `Sources/Features/Channels/ChannelsView.swift` | `channels.status` |
| Instances | /instances | `views/instances.ts` | `Sources/Features/Instances/InstancesView.swift` | `health` (instances 字段) |
| Sessions | /sessions | `views/sessions.ts`, `controllers/sessions.ts` | `Sources/Features/Sessions/SessionsView.swift` | `sessions.list`, `sessions.patch` |
| Usage | /usage | `views/usage.ts`, `views/usage-metrics.ts`, `views/usage-render-overview.ts`, `views/usage-render-details.ts`, `views/usage-query.ts`, `views/usageTypes.ts`, `controllers/usage.ts` | `Sources/Features/Usage/UsageView.swift` | `sessions.usage` |
| Cron | /cron | `views/cron.ts`, `views/cron-quick-create.ts`, `controllers/cron.ts`, `controllers/cron-filters.test.ts` | `Sources/Features/Cron/CronView.swift` | `cron.list`, `cron.status`, `cron.create`, `cron.update`, `cron.delete`, `cron.run`, `cron.runs` |

### Agent 分组

| Tab | 路由 | Web UI 逻辑文件 | iOS 对应文件 | 核心 RPC |
|-----|------|----------------|-------------|---------|
| Agents | /agents | `views/agents.ts`, `views/agents-panels-overview.ts`, `views/agents-panels-tools-skills.ts`, `views/agents-panels-status-files.ts`, `views/agents-utils.ts`, `views/agents.types.ts`, `controllers/agents.ts`, `controllers/agent-files.ts`, `controllers/agent-identity.ts`, `controllers/agent-skills.ts`, `controllers/assistant-identity.ts` | `Sources/Features/Agents/AgentsView.swift` | `agents.list`, `agents.files`, `tools.catalog`, `tools.effective`, `agent.identity` |
| Skills | /skills | `views/skills.ts`, `views/skills-grouping.ts`, `views/skills-shared.ts`, `controllers/skills.ts` | `Sources/Features/Skills/SkillsView.swift` | `skills.status`, `clawhub.*` |
| **Nodes** | /nodes | `views/nodes.ts`, `views/nodes-exec-approvals.ts`, `views/nodes-shared.ts`, `views/nodes.types.ts`, `controllers/nodes.ts`, `controllers/devices.ts`, `controllers/exec-approval.ts`, `controllers/exec-approvals.ts` | **缺失（未实现）** | `nodes.list`, `devices.list`, `exec.approvals.*` |
| Dreams | /dreaming | `views/dreaming.ts`, `controllers/dreaming.ts` | `Sources/Features/Dreams/DreamsView.swift` | `dreaming.status`, `dreaming.diary`, `dreaming.wiki.*` |

### Settings 分组

| Tab | 路由 | Web UI 逻辑文件 | iOS 对应文件 | 核心 RPC |
|-----|------|----------------|-------------|---------|
| Config | /config | `views/config.ts`, `views/config-form.ts`, `views/config-form.render.ts`, `views/config-form.search.node.test.ts`, `views/config-form.shared.ts`, `views/config-form.analyze.ts`, `views/config-quick.ts`, `views/config-presets.ts`, `controllers/config.ts` | `Sources/Features/Config/ConfigView.swift` | `config.snapshot`, `config.save`, `config.apply` |
| Communications | /communications | `views/channels.config.ts`, `views/channels.*.ts` (各渠道子表单) | `Sources/Features/Settings/CommsSettingsView.swift` | `config.snapshot`, `config.save` |
| Appearance | /appearance | `views/config-presets.ts`, `views/config-form.*.ts` (表单渲染复用) | `Sources/Features/Settings/AppearanceSettingsView.swift` | `config.snapshot` |
| Automation | /automation | `views/exec-approval.ts`, `controllers/exec-approval.ts`, `controllers/exec-approvals.ts` | `Sources/Features/Settings/AutomationSettingsView.swift` | `exec.approvals.get`, `exec.approvals.save` |
| Infrastructure | /infrastructure | `controllers/devices.ts`, `controllers/presence.ts`, `views/nodes-shared.ts` | `Sources/Features/Settings/InfraSettingsView.swift` | `devices.list`, `devices.pair`, `devices.approve`, `devices.revoke`, `presence.list` |
| AI Agents | /ai-agents | `controllers/model-auth-status.ts` | `Sources/Features/Settings/AIAgentsSettingsView.swift` | `models.auth.status`, `models.auth.configure` |
| Debug | /debug | `views/debug.ts`, `controllers/debug.ts` | `Sources/Features/Settings/DebugView.swift` | `debug.*` (RPC 测试调用任意方法) |
| Logs | /logs | `views/logs.ts`, `controllers/logs.ts` | `Sources/Features/Settings/LogsView.swift` | `logs.tail` |

## Gateway 协议

### 帧类型

| 类型 | Web UI 类型 | iOS 类型 | 说明 |
|------|------------|---------|------|
| req | `GatewayRequestFrame` | `GatewayRequestFrame` | 客户端请求，含 `id`, `method`, `params` |
| res | `GatewayResponseFrame` | 隐式处理 | 服务端响应，含 `id`, `ok`, `payload`/`error` |
| event | `GatewayEventFrame` | `GatewayEventFrame` | 服务端事件推送，含 `event`, `payload`, `seq` |

### 握手流程

1. **connect.challenge** — 服务端推送包含 `nonce` 的挑战事件
2. **connect** — 客户端发送连接请求，含 token + Ed25519 设备签名（V3 payload）
3. **hello** — 服务端返回 `GatewayHelloOk`，含版本号、connId、sessionDefaults

### 核心 RPC 方法列表

```
connect              — 握手连接（不通过 request<T>）
health               — 健康检查
sessions.list        — 会话列表
sessions.patch       — 会话操作（批量删除/压缩等）
sessions.usage       — 用量统计
chat.history         — 聊天历史
chat.send            — 发送消息
chat.abort           — 中断当前运行
models.catalog       — 模型目录
models.auth.status   — 模型认证状态
models.auth.configure— 配置模型认证
config.snapshot      — 配置快照
config.save          — 保存配置
config.apply         — 应用配置
cron.list            — 定时任务列表
cron.status          — 定时任务状态
cron.create          — 创建任务
cron.update          — 更新任务
cron.delete          — 删除任务
cron.run             — 手动执行
cron.runs            — 执行日志
agents.list          — Agent 列表
agents.files         — Agent 文件列表
tools.catalog        — 工具目录
tools.effective      — 有效工具列表
agent.identity       — Agent 身份
skills.status        — 技能状态
clawhub.search       — 技能市场搜索
clawhub.detail       — 技能详情
clawhub.install      — 安装技能
channels.status      — 渠道状态
devices.list         — 设备列表
devices.pair         — 设备配对
devices.approve      — 批准设备
devices.revoke       — 撤销设备
presence.list        — 在线列表
exec.approvals.get   — 执行审批获取
exec.approvals.save  — 执行审批保存
exec.approval.resolve— 执行审批决策
dreaming.status      — 梦境状态
dreaming.diary       — 梦境日记
dreaming.wiki.*      — Wiki 相关
logs.tail            — 日志尾随
nodes.list           — 节点列表
```

### 聊天事件流

事件通过 `event` 帧到达，AppState 按 `frame.event` 分发：

| event | 处理函数 | 说明 |
|-------|---------|------|
| chat | `handleChatEvent()` | delta/final/aborted/error 状态机 |
| session.tool | `handleToolEvent()` | 工具执行状态更新 |
| chat.run | `handleChatRunEvent()` | 运行状态事件 |

## 类型系统映射

Web UI 的 `ui/src/ui/types.ts` 定义了所有 DTO 类型，iOS 的 `Core/Models/*.swift` 必须与之对齐：

| Web 类型 (types.ts) | iOS 文件 | 用途 |
|---------------------|---------|------|
| `ChannelsStatusSnapshot` | `ChannelModels.swift` | 渠道状态快照 |
| `CronJob`, `CronStatus`, `CronRunLogEntry` | `CronModels.swift` | 定时任务 |
| `HealthSummary`, `StatusSummary` | `HealthModels.swift` | 健康检查 |
| `LogEntry`, `LogLevel` | `LogModels.swift` | 日志 |
| `SessionsListResult`, `SessionEntry` | `SessionModels.swift` | 会话 |
| `SkillStatusReport` | `SkillModels.swift` | 技能 |
| `SessionsUsageResult`, `SessionUsageTimeSeries` | `UsageModels.swift` | 用量 |
| `ChatMessage`, `ChatHistoryResult`, `ChatSendResult` | `ChatModels.swift` | 聊天 |
| `ConfigSnapshot`, `ConfigUiHints` | `ConfigModels.swift` | 配置 |
| `AgentsListResult`, `ToolsCatalogResult`, `AgentIdentityResult` | `AgentModels.swift` | Agent |
| `DreamingStatus`, `WikiMemoryPalace`, `WikiImportInsights` | `DreamModels.swift` | 梦境 |
| `AnyCodable` | `AnyCodable.swift` | 异构 JSON 值（如聊天消息 content 数组） |

**规则**：所有 Codable 字段名必须使用 `.useDefaultKeys`（与 Web UI camelCase 对齐）。

## 存储层映射

| Web UI (storage.ts) | iOS 文件 | 说明 |
|---------------------|---------|------|
| `UiSettings` 结构 | `AppSettings.swift` | UserDefaults 持久化 |
| token 存储 | `KeychainStore.swift` | Keychain 安全存储 |
| device identity | `DeviceIdentity.swift` | Ed25519 密钥对（设备认证） |

**AppSettings 键值**：
- `gateway.url` / `gateway.token` — 连接凭据
- `session.lastKey` — 上次会话 key
- `theme.name` / `theme.mode` — 主题
- `ui.borderRadius` / `ui.splitRatio` / `ui.chatFocusMode` — UI 设置

## 架构模式

- **状态管理**：单例 `@Observable @MainActor AppState`，通过 `.environment()` 注入。所有 Feature View 通过 `@Environment(AppState.self)` 读取状态。
- **网络**：`GatewayClient.shared` 是唯一 WebSocket 客户端。`request<T: Decodable>(method:params:)` 发送 `req` 帧并按 `id` 等待 `res` 帧。事件通过 `onEvent { }` 监听器分发。
- **导航**：`RootView` 在 `LoginView`（未连接）和 `MainTabView`（已连接）间切换。`MainTabView` 使用 `TabView` 展示全部 18 个 `AppTab`，分 4 组（Chat / Control / Agent / Settings）。
- **数据加载**：Tab 切换触发 `RootView` 的 `loadData(for:)`，执行 Gateway RPC 并将结果存入 `AppState`。
- **登录**：`connect()` 时自动使用 `server sessionDefaults.mainSessionKey`，与 Web UI 行为对齐。

## 目录结构

```
Sources/
├── App/                          # 入口 + 导航
│   ├── OpenClawControlApp.swift  # @main
│   ├── AppState.swift            # 全局状态（@Observable 单例）
│   ├── RootView.swift            # 根视图 + TabView 路由
│   ├── LoginView.swift           # 登录/连接页
│   └── TabNavigation.swift       # AppTab 枚举 + TabGroup
├── Core/
│   ├── Gateway/
│   │   └── GatewayClient.swift   # WebSocket 客户端（握手、请求、事件）
│   ├── Models/                   # 所有 DTO 类型（对应 types.ts）
│   │   ├── AgentModels.swift
│   │   ├── AnyCodable.swift
│   │   ├── ChannelModels.swift
│   │   ├── ChatModels.swift
│   │   ├── ConfigModels.swift
│   │   ├── CronModels.swift
│   │   ├── DreamModels.swift
│   │   ├── HealthModels.swift
│   │   ├── LogModels.swift
│   │   ├── SessionModels.swift
│   │   ├── SkillModels.swift
│   │   └── UsageModels.swift
│   └── Storage/
│       ├── AppSettings.swift      # UserDefaults
│       ├── KeychainStore.swift    # Keychain
│       └── DeviceIdentity.swift   # Ed25519 设备身份
├── Features/                     # 各功能页面视图
│   ├── Chat/ChatView.swift
│   ├── Dashboard/DashboardView.swift
│   ├── Channels/ChannelsView.swift
│   ├── Instances/InstancesView.swift
│   ├── Sessions/SessionsView.swift
│   ├── Usage/UsageView.swift
│   ├── Cron/CronView.swift
│   ├── Agents/AgentsView.swift
│   ├── Skills/SkillsView.swift
│   ├── Config/ConfigView.swift
│   ├── Settings/
│   │   ├── CommsSettingsView.swift
│   │   ├── AppearanceSettingsView.swift
│   │   ├── AutomationSettingsView.swift
│   │   ├── InfraSettingsView.swift
│   │   ├── AIAgentsSettingsView.swift
│   │   ├── DebugView.swift
│   │   └── LogsView.swift
│   └── Dreams/DreamsView.swift
└── Shared/
    └── SharedComponents.swift     # 可复用 UI 组件
Tests/
    └── SessionModelTests.swift
```

## 当前进度

- **Phase 1（基础设施）完成**：模型类型、Gateway 客户端、存储层、登录页、Tab 导航、基础聊天
- **Phase 2-4 大部分为 stub**：多数 Feature View 仅展示框架，具体业务逻辑待实现
- **缺失模块**：`Nodes`（节点管理）在 Web UI 中存在，iOS 尚未添加
- 详见 `PLAN.md` 的 4 阶段路线图

## 重要说明

- **零外部依赖** — 仅使用 Apple 系统框架
- **协议 v3** — 设备签名使用 V3 payload 格式 + Ed25519
- **Role: operator** — 以 operator 身份连接，含 admin/read/write/approvals/pairing scopes
- **调试日志** — 写入设备 `Documents/openclaw_debug.log`
- **project.yml** 定义构建配置 — 修改此文件后需执行 `xcodegen generate`
- **ExyteChat + polling 模式** — ChatView 使用 `@StateObject ChatViewModel` + 200ms 定时器轮询 `AppState`，这是确保 UI 及时更新数据的可靠方案
- **调试关键经验** — Xcode 的 DerivedData 缓存会导致旧代码不被替换，修改代码后**必须 clean**再 build，否则可能出现"代码没生效"的假象
