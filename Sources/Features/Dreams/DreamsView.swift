import SwiftUI

struct DreamsView: View {
    @Environment(AppState.self) var appState
    
    var body: some View {
        List {
            // Dreaming Status
            if let status = appState.dreamingStatus {
                Section("Dreaming Status") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Plugin:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(status.pluginId)
                                .font(.caption)
                        }
                        HStack {
                            Text("Diary Path:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(status.diaryPath)
                                .font(.caption)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
            
            // Dream Diary
            Section("Dream Diary") {
                if let content = appState.dreamDiaryContent, !content.isEmpty {
                    Text(content)
                        .font(.system(size: 14))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text("No dream diary content")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Dreams")
        .task {
            await appState.loadDreamingStatus()
            await appState.loadDreamDiary()
        }
    }
}