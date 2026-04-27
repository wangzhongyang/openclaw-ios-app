import Foundation

// MARK: - Channel Models

struct ChannelsStatusSnapshot: Codable {
    let ts: TimeInterval
    let channelOrder: [String]
    let channelLabels: [String: String]
    let channelDetailLabels: [String: String]?
    let channelSystemImages: [String: String]?
    let channelMeta: [ChannelUiMetaEntry]?
    let channels: [String: AnyCodable]
    let channelAccounts: [String: [ChannelAccountSnapshot]]
    let channelDefaultAccountId: [String: String]
}

struct ChannelUiMetaEntry: Codable {
    let channelId: String
    let label: String
    let detailLabel: String
    let systemImage: String?
}

struct ChannelAccountSnapshot: Codable, Identifiable {
    let accountId: String
    let name: String?
    let enabled: Bool?
    let configured: Bool?
    let linked: Bool?
    let running: Bool?
    let connected: Bool?
    let reconnectAttempts: Int?
    let lastConnectedAt: TimeInterval?
    let lastError: String?
    let lastStartAt: TimeInterval?
    let lastStopAt: TimeInterval?
    let lastInboundAt: TimeInterval?
    let lastOutboundAt: TimeInterval?
    let lastProbeAt: TimeInterval?
    let mode: String?
    let dmPolicy: String?
    let allowFrom: [String]?
    let tokenSource: String?
    let botTokenSource: String?
    let appTokenSource: String?
    let credentialSource: String?
    let audienceType: String?
    let audience: String?
    let webhookPath: String?
    let webhookUrl: String?
    let baseUrl: String?
    let allowUnmentionedGroups: Bool?
    let cliPath: String?
    let dbPath: String?
    let port: Int?

    var id: String { accountId }
}

// MARK: - Channel-specific statuses

struct WhatsAppStatus: Codable {
    let configured: Bool
    let linked: Bool
    let authAgeMs: TimeInterval?
    let selfInfo: WhatsAppSelf?
    let running: Bool
    let connected: Bool
    let lastConnectedAt: TimeInterval?
    let lastDisconnect: WhatsAppDisconnect?
    let reconnectAttempts: Int
    let lastMessageAt: TimeInterval?
    let lastEventAt: TimeInterval?
    let lastError: String?

    enum CodingKeys: String, CodingKey {
        case configured, linked, authAgeMs
        case selfInfo = "self"
        case running, connected, lastConnectedAt
        case lastDisconnect, reconnectAttempts
        case lastMessageAt, lastEventAt, lastError
    }
}

struct WhatsAppSelf: Codable {
    let e164: String?
    let jid: String?
}

struct WhatsAppDisconnect: Codable {
    let at: TimeInterval
    let status: Int?
    let error: String?
    let loggedOut: Bool?
}

struct TelegramStatus: Codable {
    let configured: Bool
    let tokenSource: String?
    let running: Bool
    let mode: String?
    let lastStartAt: TimeInterval?
    let lastStopAt: TimeInterval?
    let lastError: String?
    let probe: TelegramProbe?
    let lastProbeAt: TimeInterval?
}

struct TelegramProbe: Codable {
    let ok: Bool
    let status: Int?
    let error: String?
    let elapsedMs: TimeInterval?
    let bot: TelegramBot?
    let webhook: TelegramWebhook?
}

struct TelegramBot: Codable {
    let id: Int?
    let username: String?
}

struct TelegramWebhook: Codable {
    let url: String?
    let hasCustomCert: Bool?
}

struct DiscordStatus: Codable {
    let configured: Bool
    let tokenSource: String?
    let running: Bool
    let lastStartAt: TimeInterval?
    let lastStopAt: TimeInterval?
    let lastError: String?
    let probe: DiscordProbe?
    let lastProbeAt: TimeInterval?
}

struct DiscordProbe: Codable {
    let ok: Bool
    let status: Int?
    let error: String?
    let elapsedMs: TimeInterval?
    let bot: DiscordBot?
}

struct DiscordBot: Codable {
    let id: String?
    let username: String?
}

struct SlackStatus: Codable {
    let configured: Bool
    let botTokenSource: String?
    let appTokenSource: String?
    let running: Bool
    let lastStartAt: TimeInterval?
    let lastStopAt: TimeInterval?
    let lastError: String?
    let probe: SlackProbe?
    let lastProbeAt: TimeInterval?
}

struct SlackProbe: Codable {
    let ok: Bool
    let status: Int?
    let error: String?
    let elapsedMs: TimeInterval?
    let bot: SlackBot?
    let team: SlackTeam?
}

struct SlackBot: Codable {
    let id: String?
    let name: String?
}

struct SlackTeam: Codable {
    let id: String?
    let name: String?
}

struct SignalStatus: Codable {
    let configured: Bool
    let baseUrl: String
    let running: Bool
    let lastStartAt: TimeInterval?
    let lastStopAt: TimeInterval?
    let lastError: String?
    let probe: SignalProbe?
    let lastProbeAt: TimeInterval?
}

struct SignalProbe: Codable {
    let ok: Bool
    let status: Int?
    let error: String?
    let elapsedMs: TimeInterval?
    let version: String?
}

struct NostrStatus: Codable {
    let configured: Bool
    let publicKey: String?
    let running: Bool
    let lastStartAt: TimeInterval?
    let lastStopAt: TimeInterval?
    let lastError: String?
    let profile: NostrProfile?
}

struct NostrProfile: Codable {
    let name: String?
    let displayName: String?
    let about: String?
    let picture: String?
    let banner: String?
    let website: String?
    let nip05: String?
    let lud16: String?
}

struct GoogleChatStatus: Codable {
    let configured: Bool
    let credentialSource: String?
    let audienceType: String?
    let audience: String?
    let webhookPath: String?
    let webhookUrl: String?
    let running: Bool
    let lastStartAt: TimeInterval?
    let lastStopAt: TimeInterval?
    let lastError: String?
    let probe: GoogleChatProbe?
    let lastProbeAt: TimeInterval?
}

struct GoogleChatProbe: Codable {
    let ok: Bool
    let status: Int?
    let error: String?
    let elapsedMs: TimeInterval?
}

struct IMessageStatus: Codable {
    let configured: Bool
    let running: Bool
    let lastStartAt: TimeInterval?
    let lastStopAt: TimeInterval?
    let lastError: String?
    let cliPath: String?
    let dbPath: String?
    let probe: IMessageProbe?
    let lastProbeAt: TimeInterval?
}

struct IMessageProbe: Codable {
    let ok: Bool
    let error: String?
}
