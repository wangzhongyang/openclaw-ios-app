import Foundation

/// App settings persisted via UserDefaults
@MainActor
final class AppSettings {
    static let shared = AppSettings()

    private let defaults: UserDefaults

    var gatewayURL: String {
        get { defaults.string(forKey: Keys.gatewayURL) ?? "" }
        set { defaults.set(newValue, forKey: Keys.gatewayURL) }
    }

    var gatewayToken: String {
        get { defaults.string(forKey: Keys.gatewayToken) ?? "" }
        set { defaults.set(newValue, forKey: Keys.gatewayToken) }
    }

    var lastSessionKey: String {
        get { defaults.string(forKey: Keys.lastSessionKey) ?? "" }
        set { defaults.set(newValue, forKey: Keys.lastSessionKey) }
    }

    var themeName: String {
        get { defaults.string(forKey: Keys.themeName) ?? "claw" }
        set { defaults.set(newValue, forKey: Keys.themeName) }
    }

    var themeMode: String {
        get { defaults.string(forKey: Keys.themeMode) ?? "system" }
        set { defaults.set(newValue, forKey: Keys.themeMode) }
    }

    var locale: String {
        get { defaults.string(forKey: Keys.locale) ?? "en" }
        set { defaults.set(newValue, forKey: Keys.locale) }
    }

    var borderRadius: Double {
        get { defaults.double(forKey: Keys.borderRadius) }
        set { defaults.set(newValue, forKey: Keys.borderRadius) }
    }

    var chatFocusMode: Bool {
        get { defaults.bool(forKey: Keys.chatFocusMode) }
        set { defaults.set(newValue, forKey: Keys.chatFocusMode) }
    }

    var splitRatio: Double {
        get { defaults.double(forKey: Keys.splitRatio) == 0 ? 0.5 : defaults.double(forKey: Keys.splitRatio) }
        set { defaults.set(newValue, forKey: Keys.splitRatio) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    private enum Keys {
        static let gatewayURL = "gateway.url"
        static let gatewayToken = "gateway.token"
        static let lastSessionKey = "session.lastKey"
        static let themeName = "theme.name"
        static let themeMode = "theme.mode"
        static let locale = "ui.locale"
        static let borderRadius = "ui.borderRadius"
        static let chatFocusMode = "ui.chatFocusMode"
        static let splitRatio = "ui.splitRatio"
    }
}
