import SwiftUI

struct DebugView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        Form {
            if let connId = GatewayClient.shared.connId {
                DetailRow(label: "Connection ID", value: connId)
            }
            if let version = GatewayClient.shared.serverVersion {
                DetailRow(label: "Server Version", value: version)
            }
            Button("Disconnect") {
                GatewayClient.shared.disconnect()
            }
            .foregroundColor(.red)
        }
        .navigationTitle("Debug")
    }
}
