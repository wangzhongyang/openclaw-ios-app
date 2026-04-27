import SwiftUI

struct AutomationSettingsView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        Form {
            Section("Automation") {
                Text("Automation settings coming soon")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Automation")
    }
}
