import SwiftUI

struct SkillsView: View {
    @Environment(AppState.self) var appState
    @State private var searchQuery = ""

    var body: some View {
        List {
            if let report = appState.skillsReport {
                Section("Skills (\(report.skills.count))") {
                    ForEach(report.skills) { skill in
                        NavigationLink(destination: SkillDetailView(skill: skill)) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    if let emoji = skill.emoji {
                                        Text(emoji)
                                    }
                                    Text(skill.name)
                                        .font(.headline)
                                    if skill.disabled {
                                        Text("Disabled")
                                            .font(.caption2)
                                            .foregroundStyle(.red)
                                    }
                                }
                                Text(skill.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                                if !skill.missing.bins.isEmpty {
                                    Text("Missing: \(skill.missing.bins.joined(separator: ", "))")
                                        .font(.caption2)
                                        .foregroundStyle(.orange)
                                }
                            }
                        }
                    }
                }
            } else {
                ProgressView("Loading skills...")
            }
        }
        .searchable(text: $searchQuery)
        .navigationTitle("Skills")
    }
}

struct SkillDetailView: View {
    let skill: SkillStatusEntry

    var body: some View {
        Form {
            Section("Info") {
                DetailRow(label: "Name", value: skill.name)
                DetailRow(label: "Source", value: skill.source)
                DetailRow(label: "Key", value: skill.skillKey)
            }

            if !skill.install.isEmpty {
                Section("Install") {
                    ForEach(skill.install, id: \.installId) { option in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(option.label)
                                .font(.headline)
                            Text("Bins: \(option.bins.joined(separator: ", "))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle(skill.name)
    }
}
