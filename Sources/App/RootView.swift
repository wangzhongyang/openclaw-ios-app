import SwiftUI

struct RootView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        Group {
            if !appState.isConnected {
                LoginView()
            } else {
                MainTabView()
            }
        }
    }
}

struct MainTabView: View {
    @Environment(AppState.self) var appState
    @State private var selectedTab: AppTab = .chat

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                ForEach(AppTab.allCases) { tab in
                    tabView(for: tab)
                        .tabItem {
                            Label(tab.title, systemImage: tab.icon)
                        }
                        .tag(tab)
                }
            }
            .onChange(of: selectedTab) { _, newTab in
                appState.selectedTab = newTab
                loadData(for: newTab)
            }
        }
    }

    @ViewBuilder
    private func tabView(for tab: AppTab) -> some View {
        switch tab {
        case .chat: ChatView()
        case .overview: DashboardView()
        case .channels: ChannelsView()
        case .instances: InstancesView()
        case .sessions: SessionsView()
        case .usage: UsageView()
        case .cron: CronView()
        case .agents: AgentsView()
        case .skills: SkillsView()
        case .config: ConfigView()
        case .communications: CommsSettingsView()
        case .appearance: AppearanceSettingsView()
        case .automation: AutomationSettingsView()
        case .infrastructure: InfraSettingsView()
        case .aiAgents: AIAgentsSettingsView()
        case .debug: DebugView()
        case .logs: LogsView()
        case .dreams: DreamsView()
        }
    }

    private func loadData(for tab: AppTab) {
        Task { @MainActor in
            switch tab {
            case .chat:
                appState.loadChatHistory()
            case .overview:
                appState.loadHealth()
            case .sessions:
                await loadSessions()
            case .usage:
                await loadUsage()
            case .cron:
                await loadCron()
            case .agents:
                await loadAgents()
            case .skills:
                await loadSkills()
            case .config:
                await loadConfig()
            case .channels:
                await loadChannels()
            default:
                break
            }
        }
    }

    private func loadSessions() async {
        do {
            let params: [String: Any] = ["includeGlobal": true, "includeUnknown": false, "limit": 120]
            let result = try await GatewayClient.shared.request(type: SessionsListResult.self, method: "sessions.list", params: params)
            appState.sessionsResult = result
        } catch {
            print("[RootView] sessions load failed: \(error)")
        }
    }

    private func loadUsage() async {
        do {
            let result = try await GatewayClient.shared.request(type: SessionsUsageResult.self, method: "sessions.usage")
            appState.usageResult = result
        } catch {
            print("[RootView] usage load failed: \(error)")
        }
    }

    private func loadCron() async {
        do {
            let jobs = try await GatewayClient.shared.request(type: CronJobsListResult.self, method: "cron.list")
            let status = try await GatewayClient.shared.request(type: CronStatus.self, method: "cron.status")
            appState.cronJobs = jobs.jobs
            appState.cronStatus = status
        } catch {
            print("[RootView] cron load failed: \(error)")
        }
    }

    private func loadAgents() async {
        do {
            let agents = try await GatewayClient.shared.request(type: AgentsListResult.self, method: "agents.list")
            let tools = try await GatewayClient.shared.request(type: ToolsCatalogResult.self, method: "tools.catalog")
            appState.agentsList = agents
            appState.toolsCatalogResult = tools
        } catch {
            print("[RootView] agents load failed: \(error)")
        }
    }

    private func loadSkills() async {
        do {
            let report = try await GatewayClient.shared.request(type: SkillStatusReport.self, method: "skills.status")
            appState.skillsReport = report
        } catch {
            print("[RootView] skills load failed: \(error)")
        }
    }

    private func loadConfig() async {
        do {
            let snapshot = try await GatewayClient.shared.request(type: ConfigSnapshot.self, method: "config.snapshot")
            appState.configSnapshot = snapshot
            appState.configRaw = snapshot.raw ?? "{\n}\n"
        } catch {
            print("[RootView] config load failed: \(error)")
        }
    }

    private func loadChannels() async {
        do {
            let snapshot = try await GatewayClient.shared.request(type: ChannelsStatusSnapshot.self, method: "channels.status")
            appState.channelsSnapshot = snapshot
        } catch {
            print("[RootView] channels load failed: \(error)")
        }
    }
}
