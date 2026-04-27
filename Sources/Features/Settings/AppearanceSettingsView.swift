import SwiftUI

struct AppearanceSettingsView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Theme", selection: .constant("auto")) {
                    Text("Auto").tag("auto")
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
            }
        }
        .navigationTitle("Appearance")
    }
}
