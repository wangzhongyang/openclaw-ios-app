import SwiftUI

struct AIAgentsSettingsView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        Form {
            Section("AI Agents") {
                Text("AI Agents settings coming soon")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("AI Agents")
    }
}
