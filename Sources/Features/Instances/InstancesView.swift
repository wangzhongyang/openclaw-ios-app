import SwiftUI

struct InstancesView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        List {
            if let connId = GatewayClient.shared.connId {
                HStack {
                    Text("Connection ID")
                    Spacer()
                    Text(connId)
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            }
            if let version = GatewayClient.shared.serverVersion {
                HStack {
                    Text("Server Version")
                    Spacer()
                    Text(version)
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            }
        }
        .navigationTitle("Instances")
    }
}
