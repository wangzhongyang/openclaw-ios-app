import SwiftUI

struct ConfigView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        List {
            if let config = appState.configSnapshot {
                Section("Status") {
                    DetailRow(label: "Exists", value: "\(config.exists ?? false)")
                    DetailRow(label: "Valid", value: "\(config.valid ?? false)")
                    if let path = config.path {
                        DetailRow(label: "Path", value: path)
                    }
                    if let hash = config.hash {
                        DetailRow(label: "Hash", value: hash)
                    }
                }

                if let issues = config.issues, !issues.isEmpty {
                    Section("Issues (\(issues.count))") {
                        ForEach(issues) { issue in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(issue.path)
                                    .font(.headline)
                                Text(issue.message)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                if let raw = config.raw {
                    Section("Raw Config") {
                        Text(raw)
                            .font(.caption)
                            .monospaced()
                    }
                }
            } else {
                ProgressView("Loading config...")
            }
        }
        .navigationTitle("Config")
    }
}
