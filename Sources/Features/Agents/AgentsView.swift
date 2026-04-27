import SwiftUI

struct AgentsView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        List {
            if let agents = appState.agentsList {
                Section("Agents") {
                    ForEach(agents.agents) { agent in
                        NavigationLink(destination: AgentDetailView(agent: agent)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(agent.name)
                                    .font(.headline)
                                if let model = agent.model {
                                    Text(model)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            } else {
                ProgressView("Loading agents...")
            }
        }
        .navigationTitle("Agents")
    }
}

struct AgentDetailView: View {
    let agent: GatewayAgentRow

    var body: some View {
        Form {
            Section("Info") {
                DetailRow(label: "ID", value: agent.id)
                DetailRow(label: "Name", value: agent.name)
                if let model = agent.model {
                    DetailRow(label: "Model", value: model)
                }
                if let workspace = agent.workspace {
                    DetailRow(label: "Workspace", value: workspace)
                }
            }
        }
        .navigationTitle(agent.name)
    }
}
