import SwiftUI

struct LogsView: View {
    @Environment(AppState.self) var appState
    @State private var logEntries: [LogEntry] = []

    var body: some View {
        List {
            if !logEntries.isEmpty {
                ForEach(logEntries.prefix(50)) { entry in
                    VStack(alignment: .leading, spacing: 2) {
                        if let msg = entry.message {
                            Text(msg)
                                .font(.caption)
                                .lineLimit(2)
                        } else {
                            Text(entry.raw)
                                .font(.caption)
                                .lineLimit(2)
                        }
                        if let time = entry.time {
                            Text(time)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        if let level = entry.level {
                            Text(level.uppercased())
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } else {
                Text("No logs loaded")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Logs")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    Task { @MainActor in
                        do {
                            let result = try await GatewayClient.shared.request(
                                type: LogsResult.self,
                                method: "logs.tail",
                                params: ["limit": 100]
                            )
                            logEntries = result.entries
                        } catch {
                            print("Failed to load logs: \(error)")
                        }
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
    }
}
