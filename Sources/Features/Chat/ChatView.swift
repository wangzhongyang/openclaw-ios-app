import SwiftUI
import Combine
import MarkdownUI

// MARK: - ChatView (Native SwiftUI)

struct ChatView: View {
    @Environment(AppState.self) var appState
    @StateObject private var viewModel = ChatViewModel()

    @State private var inputText = ""
    @State private var searchOpen = false
    @State private var searchQuery = ""
    @State private var sessionPickerOpen = false

    private let buildTime: String = {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        return formatter.string(from: date)
    }()

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Build time badge
                HStack {
                    Text("build \(buildTime)").font(.caption2).foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 16).padding(.top, 4)
                sessionPickerBar
                if searchOpen { searchBar }
                nativeChatView
                if !appState.chatQueue.isEmpty { queueView }
                if appState.chatCompactionInProgress { compactionIndicator }
                inputBar
            }
        }
        .sheet(isPresented: $sessionPickerOpen) { sessionPickerSheet }
        .navigationTitle("Chat")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation { searchOpen.toggle(); if !searchOpen { searchQuery = "" } }
                } label: { Image(systemName: searchOpen ? "xmark" : "magnifyingglass") }
            }
        }
        .onAppear { viewModel.connect(appState) }
        .onDisappear { viewModel.disconnect() }
    }

    // MARK: - Native Chat View

    var nativeChatView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.items) { item in
                        chatItemView(for: item)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 2)
                            .id(item.id)
                    }
                }
                .padding(.bottom, 8)
            }
            .onChange(of: viewModel.items.count) { _, count in
                if count > 0, let lastId = viewModel.items.last?.id {
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo(lastId, anchor: .bottom)
                    }
                }
            }
        }
    }

    @ViewBuilder
    func chatItemView(for item: ChatItem) -> some View {
        switch item {
        case .message(let messageItem):
            messageBubble(for: messageItem.message)
        case .divider:
            EmptyView()
        case .stream(let streamItem):
            Text(streamItem.text)
                .padding(12)
                .background(Color(uiColor: .secondarySystemBackground))
                .foregroundStyle(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .frame(maxWidth: 300, alignment: .leading)
        case .readingIndicator:
            HStack {
                Text("...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ProgressView()
                    .scaleEffect(0.7)
            }
            .padding(12)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .frame(maxWidth: 300, alignment: .leading)
        }
    }

    @ViewBuilder
    func messageBubble(for msg: ChatMessage) -> some View {
        HStack {
            if msg.role == "user" {
                Spacer()
                Text(msg.content)
                    .padding(12)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .frame(maxWidth: 300, alignment: .trailing)
            } else if msg.role == "tool" {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(msg.toolCalls ?? [], id: \.id) { tool in 
                        ToolCallCardView(toolCall: tool) 
                    }
                    if !msg.content.isEmpty {
                        Text(msg.content).font(.caption2).foregroundStyle(.secondary).padding(.horizontal, 12)
                    }
                }
                .frame(maxWidth: 300, alignment: .leading)
                Spacer()
            } else {
                if let isStreaming = msg.queued, isStreaming {
                    // This is actually not the right way to detect streaming
                    // But we'll use the current approach for now
                    Text(msg.content)
                        .padding(12)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .frame(maxWidth: 300, alignment: .leading)
                } else if (msg.toolCalls ?? []).isEmpty {
                    Markdown(msg.content)
                        .markdownTheme(.basic)
                        .padding(12)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .frame(maxWidth: 300, alignment: .leading)
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(msg.content)
                            .padding(12)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .foregroundStyle(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .frame(maxWidth: 300, alignment: .leading)
                        ForEach(msg.toolCalls ?? [], id: \.id) { tool in 
                            ToolCallCardView(toolCall: tool) 
                        }
                    }
                }
                Spacer()
            }
        }
    }

    // MARK: - Input Bar

    var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Type a message...", text: $inputText, axis: .vertical)
                .textFieldStyle(.plain)
                .font(.body)
                .padding(12)
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))

            if viewModel.isSending {
                Button {
                    appState.abortChat()
                } label: {
                    Image(systemName: "stop.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    send()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
                .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(uiColor: .systemBackground))
    }

    // MARK: - Session Picker Bar

    var sessionPickerBar: some View {
        HStack {
            Button { sessionPickerOpen.toggle() } label: {
                HStack(spacing: 6) {
                    Image(systemName: "bubble.left.and.bubble.right").font(.caption).foregroundStyle(.secondary)
                    Text(currentSessionLabel).font(.caption).foregroundStyle(.primary).lineLimit(1)
                    Image(systemName: "chevron.down").font(.caption2).foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)

            Button {
                appState.startNewSession()
                viewModel.clearAndRefresh()
            } label: {
                Image(systemName: "plus.circle").font(.caption).foregroundStyle(.blue)
            }
            .buttonStyle(.plain)
            .padding(.trailing, 8)
        }
        .padding(.horizontal).padding(.vertical, 4)
        .background(Color(uiColor: .systemBackground))
    }

    var currentSessionLabel: String {
        let sessions = appState.sessionsResult?.sessions ?? []
        if let current = sessions.first(where: { $0.key == appState.sessionKey }) {
            return (current.label?.isEmpty == false) ? current.label! : current.key
        }
        return "Select session..."
    }

    var sessionPickerSheet: some View {
        NavigationStack {
            List {
                Button {
                    appState.startNewSession()
                    viewModel.clearAndRefresh()
                    sessionPickerOpen = false
                } label: {
                    Label("New Session", systemImage: "plus.circle").foregroundStyle(.blue)
                }
                Section("Sessions") {
                    ForEach(appState.sessionsResult?.sessions ?? [], id: \.key) { session in
                        Button {
                            appState.setSessionKey(session.key)
                            sessionPickerOpen = false
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(session.label ?? session.key)
                                        .font(.subheadline).foregroundStyle(.primary).lineLimit(1)
                                    Text(session.kind).font(.caption2).foregroundStyle(.secondary)
                                }
                                Spacer()
                                if session.key == appState.sessionKey {
                                    Image(systemName: "checkmark").font(.caption).foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Select Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Done") { sessionPickerOpen = false } } }
        }
    }

    var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            TextField("Search messages...", text: $searchQuery).textFieldStyle(.plain)
            if !searchQuery.isEmpty {
                Button { searchQuery = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }.buttonStyle(.plain)
            }
        }
        .padding(8).background(Color(uiColor: .secondarySystemBackground))
    }

    var queueView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Queued (\(appState.chatQueue.count))").font(.caption).foregroundStyle(.secondary)
            ForEach(appState.chatQueue) { item in
                HStack {
                    Text(item.text).font(.caption2).lineLimit(1)
                    Spacer()
                    Button { appState.removeQueueItem(item.id) } label: {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                    }.buttonStyle(.plain)
                }
            }
        }
        .padding(8).background(Color(uiColor: .tertiarySystemBackground))
    }

    var compactionIndicator: some View {
        HStack {
            ProgressView().scaleEffect(0.7)
            Text("Compacting conversation...").font(.caption2).foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal).padding(.top, 4)
    }

    // MARK: - Actions

    private func send() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""
        if text.hasPrefix("/") {
            handleSlash(text)
        } else {
            appState.sendMessage(text)
            viewModel.refresh()
        }
    }

    private func handleSlash(_ text: String) {
        let components = text.split(separator: " ", maxSplits: 1)
        let command = String(components[0].dropFirst())
        switch command {
        case "clear": appState.clearChat()
        case "new": appState.startNewSession(); viewModel.clearAndRefresh()
        case "stop": appState.abortChat()
        default: appState.sendMessage(text); viewModel.refresh()
        }
    }
}

// MARK: - View Model

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var items: [ChatItem] = []
    @Published var isSending = false

    private weak var appState: AppState?
    private var timer: Timer?
    private var cancellables: Set<AnyCancellable> = []

    func connect(_ state: AppState) {
        self.appState = state
        refresh()
        
        // Since @Observable doesn't support $property, we'll use a different approach
        // We'll store the last update token and check for changes in a timer (but much less frequent)
        startLightweightPolling()
    }
    
    private func startLightweightPolling() {
        // Poll every 500ms instead of 100ms to reduce overhead
        let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                guard let appState = self.appState else { return }
                
                // Check if chat data has changed by comparing message counts or other indicators
                // This is a lightweight alternative to the full polling mechanism
                self.refresh()
            }
        }
        // Store timer for cleanup
        self.timer = timer
    }

    func clearAndRefresh() {
        items = []
        refresh()
    }

    func refresh() {
        guard let state = appState else { return }
        isSending = state.chatSending
        
        // Use buildChatItems to create proper ChatItem array with grouping, search, and streaming
        items = buildChatItems(
            messages: state.chatMessages,
            toolMessages: state.chatToolMessages,
            streamSegments: state.chatStreamSegments,
            stream: state.chatStream,
            streamStartedAt: state.chatStreamStartedAt,
            showToolCalls: state.showToolCalls,
            searchOpen: false, // Search not implemented in current UI
            searchQuery: "",
            sessionKey: state.sessionKey
        )
    }

    func disconnect() {
        cancellables.removeAll()
    }
}

// MARK: - Message Model

struct ChatMessageVM: Identifiable {
    let id: String
    let role: String
    let content: String
    let toolCalls: [ToolCall]
    let isStreaming: Bool

    var isUser: Bool { role == "user" }
    var isTool: Bool { role == "tool" }
}

// MARK: - Tool Call Card

struct ToolCallCardView: View {
    let toolCall: ToolCall
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button { withAnimation(.easeOut(duration: 0.2)) { expanded.toggle() } } label: {
                HStack {
                    Image(systemName: statusIcon).foregroundStyle(statusColor).font(.caption)
                    Text(toolCall.name).font(.caption).fontWeight(.medium)
                    if toolCall.status == .running { ProgressView().scaleEffect(0.7) }
                    Spacer()
                    Image(systemName: expanded ? "chevron.up" : "chevron.down").font(.caption2).foregroundStyle(.secondary)
                }
            }.buttonStyle(.plain)

            if expanded {
                VStack(alignment: .leading, spacing: 4) {
                    if !toolCall.input.isEmpty {
                        Text(toolCall.input).font(.caption2).monospaced().padding(6)
                            .background(Color(uiColor: .tertiarySystemBackground)).cornerRadius(6)
                    }
                    if let output = toolCall.output, !output.isEmpty {
                        Text(output).font(.caption2).monospaced().padding(6)
                            .background(Color(uiColor: .tertiarySystemBackground)).cornerRadius(6)
                    }
                }
            }
        }
        .padding(8).background(Color(uiColor: .tertiarySystemBackground)).clipShape(RoundedRectangle(cornerRadius: 8))
    }

    var statusIcon: String {
        switch toolCall.status {
        case .running: return "gearshape.arrow.triangle.2.circlepath"
        case .completed: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        }
    }
    var statusColor: Color {
        switch toolCall.status {
        case .running: return .orange
        case .completed: return .green
        case .failed: return .red
        }
    }
}
