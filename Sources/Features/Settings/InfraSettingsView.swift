import SwiftUI

struct InfraSettingsView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        Form {
            Section("Infrastructure") {
                Text("Infrastructure settings coming soon")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Infrastructure")
    }
}
