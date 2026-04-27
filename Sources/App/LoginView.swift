import SwiftUI

struct LoginView: View {
    @Environment(AppState.self) var appState
    @State private var urlInput = "http://localhost:18889"
    @State private var tokenInput = "b9902b482fb17c04ee03b9ca7479111780d993b0f7bdbc1793d6aa6cb65ac333"
    @State private var isConnecting = false

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 60))
                .foregroundStyle(.blue)

            Text("Connect to OpenClaw")
                .font(.title)
                .fontWeight(.bold)

            VStack(spacing: 16) {
                TextField("Gateway URL", text: $urlInput)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()

                SecureField("Auth Token", text: $tokenInput)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal)

            Button(action: connect) {
                if isConnecting {
                    ProgressView()
                } else {
                    Text("Connect")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(isConnecting)
            .padding(.horizontal)

            if let error = appState.lastError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding()
    }

    private func connect() {
        isConnecting = true
        appState.gatewayURL = urlInput
        appState.gatewayToken = tokenInput
        AppSettings.shared.gatewayURL = urlInput
        AppSettings.shared.gatewayToken = tokenInput
        KeychainStore.saveToken(instanceId: "default", token: tokenInput)
        appState.connect()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isConnecting = false
        }
    }
}
