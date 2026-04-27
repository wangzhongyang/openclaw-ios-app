import SwiftUI

struct DashboardView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HealthCardsView(health: appState.healthResult)
                EventLogView()
                LogTailView()
            }
            .padding()
        }
        .navigationTitle("Overview")
        .refreshable {
            appState.loadHealth()
        }
    }
}

struct HealthCardsView: View {
    let health: HealthSummary?

    var body: some View {
        VStack(spacing: 12) {
            if let health {
                HealthStatusCard(title: "Status", value: health.ok ? "Healthy" : "Unhealthy", icon: health.ok ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                HealthStatusCard(title: "Heartbeat", value: "\(health.heartbeatSeconds)s", icon: "heart.fill")
                HealthStatusCard(title: "Sessions", value: "\(health.sessions.count)", icon: "bubble.left.fill")
                HealthStatusCard(title: "Agents", value: "\(health.agents.count)", icon: "brain.fill")

                if let defaultAgent = health.agents.first(where: { $0.id == health.defaultAgentId }) {
                    HealthStatusCard(title: "Default Agent", value: defaultAgent.name ?? defaultAgent.id, icon: "person.fill")
                }

                // Recent sessions
                if !health.sessions.recent.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Recent Sessions")
                            .font(.headline)
                        ForEach(health.sessions.recent.prefix(5), id: \.key) { session in
                            HStack {
                                Text(session.key)
                                    .font(.caption)
                                    .lineLimit(1)
                                Spacer()
                                if let age = session.age {
                                    Text(formatAge(age))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            } else {
                ProgressView("Loading health...")
            }
        }
    }

    private func formatAge(_ age: TimeInterval) -> String {
        if age < 60 {
            return "\(Int(age))s ago"
        } else if age < 3600 {
            return "\(Int(age / 60))m ago"
        } else {
            return "\(Int(age / 3600))h ago"
        }
    }
}

struct HealthStatusCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 30)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.headline)
            }
            Spacer()
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct EventLogView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Event Log")
                .font(.headline)
            Text("Events will appear here when connected")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct LogTailView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Log Tail")
                .font(.headline)
            Text("Recent logs will appear here")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
