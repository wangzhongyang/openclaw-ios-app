import SwiftUI

struct DreamsView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        List {
            if let status = appState.skillsReport {
                Section("Skills Workspace") {
                    DetailRow(label: "Workspace", value: status.workspaceDir)
                    DetailRow(label: "Skills", value: "\(status.skills.count)")
                }
            }

            Section("Dreams") {
                Text("Dream management coming soon")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Dreams")
    }
}
