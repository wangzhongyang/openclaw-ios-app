import SwiftUI

struct ChannelsView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        List {
            if let snapshot = appState.channelsSnapshot {
                ForEach(snapshot.channelOrder, id: \.self) { channelId in
                    NavigationLink(destination: ChannelDetailView(channelId: channelId, snapshot: snapshot)) {
                        VStack(alignment: .leading) {
                            Text(snapshot.channelLabels[channelId] ?? channelId)
                                .font(.headline)
                            if let accounts = snapshot.channelAccounts[channelId] {
                                Text("\(accounts.count) account(s)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            } else {
                Text("No channels data")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Channels")
    }
}

struct ChannelDetailView: View {
    let channelId: String
    let snapshot: ChannelsStatusSnapshot

    var body: some View {
        List {
            if let accounts = snapshot.channelAccounts[channelId] {
                ForEach(accounts) { account in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(account.name ?? account.accountId)
                            .font(.headline)
                        HStack(spacing: 8) {
                            StatusIndicator(text: "Enabled", active: account.enabled ?? false)
                            StatusIndicator(text: "Running", active: account.running ?? false)
                            StatusIndicator(text: "Connected", active: account.connected ?? false)
                        }
                    }
                }
            }
        }
        .navigationTitle(snapshot.channelLabels[channelId] ?? channelId)
    }
}

struct WhatsAppView: View {
    var body: some View {
        Text("WhatsApp Configuration")
            .navigationTitle("WhatsApp")
    }
}

struct NostrProfileForm: View {
    @State private var name = ""
    @State private var about = ""
    @State private var picture = ""

    var body: some View {
        Form {
            Section("Profile") {
                TextField("Name", text: $name)
                TextField("About", text: $about)
                TextField("Picture URL", text: $picture)
            }
        }
        .navigationTitle("Nostr Profile")
    }
}

// StatusIndicator is defined in Shared/SharedComponents.swift
