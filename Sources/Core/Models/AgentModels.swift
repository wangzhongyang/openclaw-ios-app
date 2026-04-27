import Foundation

// MARK: - Agent Models

struct AgentsListResult: Codable {
    let defaultId: String
    let mainKey: String
    let scope: String
    let agents: [GatewayAgentRow]
}

struct AgentIdentityResult: Codable {
    let agentId: String
    let name: String
    let avatar: String
    let emoji: String?
}

struct AgentFileEntry: Codable, Identifiable {
    let name: String
    let path: String
    let missing: Bool
    let size: Int?
    let updatedAtMs: TimeInterval?
    let content: String?

    var id: String { path }
}

struct AgentsFilesListResult: Codable {
    let agentId: String
    let workspace: String
    let files: [AgentFileEntry]
}

struct AgentsFilesSetResult: Codable {
    let ok: Bool
    let agentId: String
    let workspace: String
    let file: AgentFileEntry
}

// MARK: - Model Catalog

struct ModelCatalogEntry: Codable {
    let modelId: String
    let name: String
    let provider: String
    let alias: String?
    let contextWindow: Int?
    let reasoning: Bool?
    let input: [String]?
}

struct ModelCatalogResult: Codable {
    let models: [ModelCatalogEntry]
}

struct ChatModelOverride: Codable {
    let model: String?
    let provider: String?
    let contextTokens: Int?
}

// MARK: - Tools

struct ToolCatalogEntry: Codable {
    let toolId: String
    let name: String
    let description: String
    let group: String?
    let profile: String?
}

struct ToolsCatalogResult: Codable {
    let tools: [ToolCatalogEntry]
    let groups: [ToolCatalogGroup]
}

struct ToolCatalogGroup: Codable {
    let groupId: String
    let name: String
    let toolIds: [String]
}

struct ToolsEffectiveResult: Codable {
    let agentId: String
    let sessionKey: String?
    let tools: [ToolsEffectiveEntry]
}

struct ToolsEffectiveEntry: Codable {
    let name: String
    let enabled: Bool
    let source: String?
}

// MARK: - Model Auth Status

struct ModelAuthStatusResult: Codable {
    let providers: [ModelAuthStatusProvider]
}

struct ModelAuthStatusProvider: Codable {
    let id: String
    let name: String
    let profiles: [ModelAuthStatusProfile]
}

struct ModelAuthStatusProfile: Codable {
    let id: String
    let name: String
    let configured: Bool
    let expiry: ModelAuthExpiry?
}

struct ModelAuthExpiry: Codable {
    let expiresAt: TimeInterval?
    let isExpired: Bool
}
