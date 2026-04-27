# OpenClaw Control iOS - 完整实施方案

## 项目概述

用纯 SwiftUI 原生开发一个 iOS App，**100% 复刻** OpenClaw Web 控制面板（`ui/` 目录）的全部功能。
App 通过 WebSocket 连接到 OpenClaw Gateway，提供所有管理面板功能。

## 功能对照表（Web UI → iOS）

| # | Web Tab | iOS 页面 | 核心功能 | 复用现有 iOS 代码 |
|---|---------|---------|---------|-----------------|
| 1 | Chat | 聊天页 | 消息列表、流式输出、工具调用展示、消息队列、附件、模型选择 | 复用 IOSGatewayChatTransport |
| 2 | Overview | 仪表盘 | 健康卡片、状态监控、事件日志、日志尾随 | 复用 GatewayStatusBuilder |
| 3 | Channels | 渠道管理 | Telegram/Discord/WhatsApp/Signal/Slack/Nostr/iMessage/GoogleChat 配置 | 部分复用 |
| 4 | Instances | 实例列表 | 运行实例监控 | 新建 |
| 5 | Sessions | 会话管理 | 列表/搜索/分页/批量操作/压缩 | 复用部分 transport |
| 6 | Usage | 用量分析 | Token 统计、费用分析、时间序列图表（Swift Charts） | 新建 |
| 7 | Cron | 定时任务 | 任务列表、快速创建、运行日志 | 新建 |
| 8 | Agents | Agent 管理 | 文件编辑器、工具列表、技能管理、身份配置 | 新建 |
| 9 | Skills | 技能市场 | ClawHub 搜索、安装、状态 | 新建 |
| 10 | Config | 配置编辑 | 快速/高级模式、表单/RAW JSON 编辑器 | 新建 |
| 11 | Communications | 通信设置 | 各渠道配置表单 | 部分复用 |
| 12 | Appearance | 外观设置 | 主题切换、圆角、字体 | 新建 |
| 13 | Automation | 自动化设置 | 执行审批、定时任务配置 | 复用 ExecApproval |
| 14 | Infrastructure | 基础设施 | 节点、设备配对、Gateway 设置 | 复用 Gateway 连接 |
| 15 | AI Agents | AI Agent | Agent 身份、模型认证、认证配置 | 新建 |
| 16 | Debug | 调试页 | 状态、健康、心跳、RPC 测试器 | 新建 |
| 17 | Logs | 日志页 | 日志查看、过滤、自动跟随、导出 | 新建 |
| 18 | Dreams | 梦境 | 梦境日记、Wiki 记忆宫殿 | 新建 |

## 技术架构

### 技术栈

| 层级 | 技术 | 说明 |
|------|------|------|
| UI 框架 | SwiftUI + Observation | iOS 17+，@Observable/@Bindable |
| 导航 | TabView + NavigationStack | 对应 Web Tab 路由 |
| 网络 | URLSessionWebSocketTask | Gateway WebSocket 协议 |
| 状态管理 | @Observable | 替代 Web 的 @state |
| 存储 | UserDefaults + Keychain | Token 存 Keychain，设置存 UserDefaults |
| 图表 | Swift Charts | 用量图表 |
| Markdown | AttributedString + 自定义解析 | 消息渲染 |
| 国际化 | .xcstrings | 对应 Web i18n |
| 加密 | CryptoKit (Ed25519) | 设备身份认证 |
| 构建 | XcodeGen | 与现有 iOS 项目一致 |

### 目录结构

```
openclaw-control-ios/
├── project.yml                         # XcodeGen 配置
├── PLAN.md                             # 本方案
├── Resources/
│   ├── Info.plist
│   └── Localizable.xcstrings
├── Sources/
│   ├── App/                            # 入口 + 导航
│   │   ├── OpenClawControlApp.swift    # @main 入口
│   │   ├── AppState.swift              # 全局状态
│   │   ├── RootView.swift              # 根视图 + Tab 导航
│   │   ├── LoginView.swift             # 登录/连接页
│   │   └── TabNavigation.swift         # Tab 定义 + 分组
│   ├── Core/
│   │   ├── Gateway/                    # Gateway 协议层
│   │   │   ├── GatewayClient.swift     # WebSocket 客户端
│   │   │   ├── GatewayProtocol.swift   # 帧类型 + 连接参数
│   │   │   ├── GatewayEvents.swift     # 事件流处理
│   │   │   └── GatewayErrorHandling.swift # 错误码 + 重试
│   │   ├── Storage/
│   │   │   ├── AppSettings.swift       # UserDefaults 设置
│   │   │   ├── KeychainStore.swift     # Keychain Token 存储
│   │   │   └── DeviceIdentity.swift    # Ed25519 设备身份
│   │   ├── Models/                     # 所有数据类型（对应 types.ts）
│   │   │   ├── ChatModels.swift        # 聊天相关
│   │   │   ├── SessionModels.swift     # 会话相关
│   │   │   ├── AgentModels.swift       # Agent 相关
│   │   │   ├── ChannelModels.swift     # 渠道相关
│   │   │   ├── CronModels.swift        # 定时任务相关
│   │   │   ├── UsageModels.swift       # 用量相关
│   │   │   ├── ConfigModels.swift      # 配置相关
│   │   │   ├── SkillModels.swift       # 技能相关
│   │   │   ├── HealthModels.swift      # 健康相关
│   │   │   ├── LogModels.swift         # 日志相关
│   │   │   └── DreamModels.swift       # 梦境相关
│   │   ├── Theme/                      # 主题系统
│   │   │   ├── Theme.swift             # 主题定义
│   │   │   └── ThemeColors.swift       # 主题色
│   │   └── I18n/
│   │       └── Localizable.swift       # 国际化
│   ├── Features/                       # 各功能页面
│   │   ├── Chat/                       # 聊天模块
│   │   │   ├── ChatView.swift          # 主聊天页
│   │   │   ├── ChatMessageView.swift   # 消息气泡
│   │   │   ├── ChatInputView.swift     # 输入框
│   │   │   ├── ChatToolCallView.swift  # 工具调用卡片
│   │   │   ├── ChatQueueView.swift     # 消息队列
│   │   │   ├── ChatStreaming.swift     # 流式输出处理
│   │   │   ├── ChatModelSelect.swift   # 模型选择器
│   │   │   └── ChatSideResult.swift    # 侧边结果
│   │   ├── Dashboard/                  # 概览
│   │   │   ├── DashboardView.swift
│   │   │   ├── HealthCards.swift
│   │   │   ├── EventLogView.swift
│   │   │   └── LogTailView.swift
│   │   ├── Channels/                   # 渠道管理
│   │   │   ├── ChannelsView.swift
│   │   │   ├── ChannelConfigViews.swift
│   │   │   ├── WhatsAppView.swift
│   │   │   └── NostrProfileForm.swift
│   │   ├── Instances/                  # 实例
│   │   │   └── InstancesView.swift
│   │   ├── Sessions/                   # 会话管理
│   │   │   ├── SessionsView.swift
│   │   │   ├── SessionRow.swift
│   │   │   ├── SessionFilter.swift
│   │   │   └── CompactionView.swift
│   │   ├── Usage/                      # 用量
│   │   │   ├── UsageView.swift
│   │   │   ├── UsageCharts.swift
│   │   │   └── UsageSessionTable.swift
│   │   ├── Cron/                       # 定时任务
│   │   │   ├── CronView.swift
│   │   │   ├── CronQuickCreate.swift
│   │   │   └── CronRunLogs.swift
│   │   ├── Agents/                     # Agent 管理
│   │   │   ├── AgentsView.swift
│   │   │   ├── AgentFileEditor.swift
│   │   │   ├── AgentToolsView.swift
│   │   │   └── AgentSkillsView.swift
│   │   ├── Skills/                     # 技能市场
│   │   │   ├── SkillsView.swift
│   │   │   └── ClawHubSearch.swift
│   │   ├── Config/                     # 配置
│   │   │   ├── ConfigView.swift
│   │   │   ├── ConfigFormRenderer.swift
│   │   │   └── ConfigRawEditor.swift
│   │   ├── Settings/                   # 设置页
│   │   │   ├── CommsSettingsView.swift
│   │   │   ├── AppearanceSettingsView.swift
│   │   │   ├── AutomationSettingsView.swift
│   │   │   ├── InfraSettingsView.swift
│   │   │   ├── AIAgentsSettingsView.swift
│   │   │   ├── DebugView.swift
│   │   │   └── LogsView.swift
│   │   └── Dreams/                     # 梦境
│   │       ├── DreamsView.swift
│   │       └── DreamDiaryView.swift
│   └── Shared/                         # 共享组件
│       ├── Components/
│       │   ├── MarkdownView.swift
│       │   ├── SearchBar.swift
│       │   ├── StatusBadge.swift
│       │   ├── ErrorBanner.swift
│       │   └── LoadingView.swift
│       └── Extensions/
│           ├── Date+Extensions.swift
│           └── String+Extensions.swift
└── Tests/
    ├── GatewayClientTests.swift        # Gateway 客户端测试
    ├── GatewayProtocolTests.swift      # 协议帧测试
    ├── ModelDecodingTests.swift        # 模型解码测试
    ├── StorageTests.swift              # 存储测试
    └── NavigationTests.swift           # 导航测试
```

## Gateway 协议映射

| Web (TypeScript) | iOS (Swift) | 作用 |
|------------------|-------------|------|
| GatewayBrowserClient | GatewayClient | WebSocket 连接管理 |
| GatewayEventFrame | GatewayEventFrame | 服务端事件 |
| GatewayResponseFrame | GatewayResponseFrame | RPC 响应 |
| GatewayConnectParams | GatewayConnectParams | 连接握手参数 |
| GatewayHelloOk | GatewayHelloResponse | 连接成功响应 |
| GatewayRequestError | GatewayClientError | 错误处理 |
| request<T>() | request<T>() | RPC 请求 |
| connect() | connect() | 建立连接 |
| onEvent | events() AsyncStream | 事件流订阅 |

## 与现有 iOS 项目的关系

**本项目是独立的 Xcode 项目**，复用现有 iOS 项目中已验证的组件：

| 复用项 | 来源 | 用途 |
|--------|------|------|
| GatewayConnectionController | apps/ios/Sources/Gateway/ | WebSocket 连接 + 发现 |
| GatewaySettingsStore | apps/ios/Sources/Gateway/ | Gateway 设置持久化 |
| KeychainStore | apps/ios/Sources/Gateway/ | Token 安全存储 |
| IOSGatewayChatTransport | apps/ios/Sources/Chat/ | 聊天 transport 层 |
| ExecApproval 相关 | apps/ios/Sources/ | 执行审批 |
| GatewayProtocol 帧 | apps/ios/Sources/Shared/ | 协议帧定义 |

**不复用**：NodeAppModel、VoiceWake、Watch、Push、Camera、Location 等移动设备特有功能。

## 测试策略

### 1. 单元测试（可自动运行）
- **GatewayClient 测试**：连接、断开、重连、请求-响应、事件流
- **协议帧测试**：JSON 编码/解码、帧类型校验
- **Model 解码测试**：所有 DTO 类型的 JSON 解码正确性
- **存储测试**：UserDefaults、Keychain 读写
- **导航测试**：Tab 路由映射

### 2. 功能测试（需模拟器/真机）
- 聊天功能：发送消息、流式输出、工具调用、中断
- 会话管理：列表加载、过滤、分页
- 配置编辑：保存/应用
- 渠道状态：各渠道连接状态
- 定时任务：创建/删除/启停

### 3. 自测方案
- 编写完整的单元测试覆盖核心逻辑
- 使用 Mock Gateway 模拟服务端响应
- 所有 Model 类型编写 JSON 解码测试（使用真实 Web UI 数据样例）

## 实施阶段

### Phase 1: 基础设施（核心必须）
- [ ] XcodeGen project.yml 配置
- [ ] 所有 Model 类型（对应 types.ts 全部类型）
- [ ] GatewayClient（WebSocket 连接、认证、请求、事件流）
- [ ] 存储层（AppSettings、KeychainStore）
- [ | 登录/连接页面
- [ ] Tab 导航框架
- [ ] 基础聊天页面

### Phase 2: 管理面板（核心功能）
- [ ] 概览仪表盘
- [ ] 会话管理
- [ ] 配置编辑器（表单 + RAW）
- [ ] 渠道管理
- [ ] 实例列表

### Phase 3: 高级功能
- [ ] 用量分析（图表）
- [ ] 定时任务
- [ ] Agent 管理
- [ ] 技能市场
- [ ] 所有设置子页
- [ ] 调试 + 日志

### Phase 4: 完善
- [ ] 梦境日记
- [ ] 国际化
- [ ] 执行审批侧边栏
- [ ] 主题切换
- [ ] 性能优化

## 关键设计决策

1. **独立项目** — 不依赖现有 iOS App 的 NodeAppModel，专注于 Web Control UI 的复刻
2. **iOS 17+** — 使用 @Observable 宏、Swift Charts、现代 SwiftUI
3. **WebSocket 优先** — 与 Web UI 使用相同的 Gateway 协议（operator 客户端）
4. **零外部依赖** — 仅使用系统框架（CryptoKit、Swift Charts 等）
5. **状态管理对齐 Web** — 每个 View 的 @Observable ViewModel 对应 Web 的 @state
6. **Gateway 连接方式** — 手动输入 URL + Token（与 Web UI 一致），不复用 Bonjour 发现

## 风险与应对

| 风险 | 应对方案 |
|------|---------|
| Gateway 协议变化 | 所有 Model 类型编写解码测试，协议变化时测试会捕获 |
| 移动端屏幕空间有限 | 数据密集页面（如 Usage 表格）采用可滚动/可筛选设计 |
| 无法在 CI 运行 UI 测试 | 核心逻辑全部单元测试化，UI 部分仅做编译验证 |
| Web UI 持续更新 | 所有 Model 类型直接对应 types.ts，Web 更新时同步更新 Swift 模型 |
