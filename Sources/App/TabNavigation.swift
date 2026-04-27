import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case chat
    case overview
    case channels
    case instances
    case sessions
    case usage
    case cron
    case agents
    case skills
    case config
    case communications
    case appearance
    case automation
    case infrastructure
    case aiAgents
    case debug
    case logs
    case dreams

    var id: String { rawValue }

    var title: String {
        switch self {
        case .chat: "Chat"
        case .overview: "Overview"
        case .channels: "Channels"
        case .instances: "Instances"
        case .sessions: "Sessions"
        case .usage: "Usage"
        case .cron: "Cron"
        case .agents: "Agents"
        case .skills: "Skills"
        case .config: "Config"
        case .communications: "Communications"
        case .appearance: "Appearance"
        case .automation: "Automation"
        case .infrastructure: "Infrastructure"
        case .aiAgents: "AI Agents"
        case .debug: "Debug"
        case .logs: "Logs"
        case .dreams: "Dreams"
        }
    }

    var icon: String {
        switch self {
        case .chat: "message.fill"
        case .overview: "chart.bar.fill"
        case .channels: "link"
        case .instances: "antenna.radiowaves.left.and.right"
        case .sessions: "doc.text.fill"
        case .usage: "chart.pie.fill"
        case .cron: "clock.fill"
        case .agents: "folder.fill"
        case .skills: "bolt.fill"
        case .config: "gearshape.fill"
        case .communications: "paperplane.fill"
        case .appearance: "sparkles"
        case .automation: "terminal.fill"
        case .infrastructure: "globe"
        case .aiAgents: "brain.fill"
        case .debug: "ladybug.fill"
        case .logs: "doc.text.fill"
        case .dreams: "moon.fill"
        }
    }

    var group: TabGroup {
        switch self {
        case .chat: .chat
        case .overview, .channels, .instances, .sessions, .usage, .cron: .control
        case .agents, .skills, .dreams: .agent
        case .config, .communications, .appearance, .automation, .infrastructure, .aiAgents, .debug, .logs: .settings
        }
    }
}

enum TabGroup: String {
    case chat = "Chat"
    case control = "Control"
    case agent = "Agent"
    case settings = "Settings"
}
