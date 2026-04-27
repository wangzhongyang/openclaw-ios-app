import SwiftUI

struct SessionsView: View {
    @Environment(AppState.self) var appState
    @State private var searchText = ""

    var body: some View {
        List {
            if let result = appState.sessionsResult {
                ForEach(result.sessions) { session in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Button(action: {
                                appState.setSessionKey(session.key)
                            }) {
                                Text(session.key)
                                    .font(.headline)
                                    .lineLimit(1)
                                    .contentTransition(.identity)
                            }
                            Spacer()
                            NavigationLink(destination: SessionDetailView(session: session)) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.secondary)
                            }
                            if let status = session.status {
                                SessionStatusBadge(status: status)
                            }
                        }
                        HStack(spacing: 12) {
                            Label(session.kind.capitalized, systemImage: kindIcon(session.kind))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if let tokens = session.totalTokens {
                                Text("\(tokens) tokens")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            if let updatedAt = session.updatedAt {
                                Text(formatTime(updatedAt))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            } else {
                ProgressView("Loading sessions...")
            }
        }
        .searchable(text: $searchText)
        .navigationTitle("Sessions")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    Task { @MainActor in
                        do {
                            let params: [String: Any] = ["includeGlobal": true, "includeUnknown": false, "limit": 120]
                            let result = try await GatewayClient.shared.request(type: SessionsListResult.self, method: "sessions.list", params: params)
                            appState.sessionsResult = result
                        } catch {
                            print("Failed to load sessions: \(error)")
                        }
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
    }

    private func kindIcon(_ kind: String) -> String {
        switch kind {
        case "direct": return "person.fill"
        case "group": return "person.2.fill"
        case "global": return "globe"
        default: return "questionmark.circle.fill"
        }
    }

    private func formatTime(_ ts: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: ts / 1000)
        let formatter = RelativeDateTimeFormatter()
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct SessionDetailView: View {
    let session: GatewaySessionRow

    var body: some View {
        Form {
            Section("Info") {
                DetailRow(label: "Key", value: session.key)
                DetailRow(label: "Kind", value: session.kind)
                if let model = session.model {
                    DetailRow(label: "Model", value: model)
                }
                if let thinkingLevel = session.thinkingLevel {
                    DetailRow(label: "Thinking", value: thinkingLevel)
                }
            }

            Section("Tokens") {
                if let input = session.inputTokens {
                    DetailRow(label: "Input", value: "\(input)")
                }
                if let output = session.outputTokens {
                    DetailRow(label: "Output", value: "\(output)")
                }
                if let total = session.totalTokens {
                    DetailRow(label: "Total", value: "\(total)")
                }
            }

            Section("Actions") {
                Button("Reset Session", role: .destructive) {
                    Task {
                        do {
                            let params = ["key": session.key]
                            _ = try await GatewayClient.shared.request(type: SessionsPatchResult.self, method: "sessions.reset", params: params)
                        } catch {
                            print("Failed to reset session: \(error)")
                        }
                    }
                }
            }
        }
        .navigationTitle(session.key)
    }
}

struct SessionStatusBadge: View {
    let status: String

    var body: some View {
        Text(status.capitalized)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(statusColor)
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }

    private var statusColor: Color {
        switch status {
        case "running": return .blue
        case "done": return .green
        case "failed": return .red
        case "killed": return .gray
        case "timeout": return .orange
        default: return .gray
        }
    }
}

// DetailRow is defined in Shared/SharedComponents.swift
