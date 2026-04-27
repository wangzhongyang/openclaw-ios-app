import SwiftUI

struct UsageView: View {
    @Environment(AppState.self) var appState
    @State private var startDate = ""
    @State private var endDate = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Date range
                HStack {
                    TextField("Start date", text: $startDate)
                        .textFieldStyle(.roundedBorder)
                    TextField("End date", text: $endDate)
                        .textFieldStyle(.roundedBorder)
                }

                if let result = appState.usageResult {
                    // Totals
                    VStack(spacing: 8) {
                        Text("Total Tokens")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("\(result.totals.totalTokens)")
                            .font(.largeTitle)

                        if let cost = result.totals.cost {
                            Text("$\(String(format: "%.4f", cost))")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                    // Sessions
                    if !result.entries.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Sessions")
                                .font(.headline)
                                .padding(.horizontal)
                            ForEach(result.entries.prefix(20)) { entry in
                                SessionUsageRow(entry: entry)
                            }
                        }
                    }
                } else {
                    ProgressView("Loading usage...")
                }
            }
            .padding()
        }
        .navigationTitle("Usage")
    }
}

struct SessionUsageRow: View {
    let entry: SessionsUsageEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(entry.sessionKey)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                if let cost = entry.cost {
                    Text("$\(String(format: "%.4f", cost))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            HStack(spacing: 12) {
                if let model = entry.model {
                    Text(model)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text("\(entry.totalTokens) tokens")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        Divider()
    }
}
