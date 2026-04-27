import SwiftUI

struct CommsSettingsView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        Form {
            Section("Communications") {
                Text("Configure communication channels here")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Communications")
    }
}
