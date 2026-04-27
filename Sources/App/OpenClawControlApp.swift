import SwiftUI

@main
struct OpenClawControlApp: App {
    // Use @StateObject for ObservableObject or direct reference for @Observable
    // @State is for value types, not appropriate for @Observable class instances
    private let appState = AppState.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .onAppear {
                    appState.start()
                }
        }
    }
}
