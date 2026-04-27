import Foundation

// MARK: - Skill Models

struct SkillStatusReport: Codable {
    let workspaceDir: String
    let managedSkillsDir: String
    let skills: [SkillStatusEntry]
}

struct SkillStatusEntry: Codable, Identifiable {
    let name: String
    let description: String
    let source: String
    let filePath: String
    let baseDir: String
    let skillKey: String
    let bundled: Bool?
    let primaryEnv: String?
    let emoji: String?
    let homepage: String?
    let always: Bool
    let disabled: Bool
    let blockedByAllowlist: Bool
    let eligible: Bool
    let requirements: SkillRequirements
    let missing: SkillMissing
    let configChecks: [SkillsStatusConfigCheck]
    let install: [SkillInstallOption]

    var id: String { skillKey }
}

struct SkillRequirements: Codable {
    let bins: [String]
    let env: [String]
    let config: [String]
    let os: [String]
}

struct SkillMissing: Codable {
    let bins: [String]
    let env: [String]
    let config: [String]
    let os: [String]
}

struct SkillsStatusConfigCheck: Codable {
    let path: String
    let satisfied: Bool
}

struct SkillInstallOption: Codable {
    let installId: String
    let kind: String      // "brew" | "node" | "go" | "uv"
    let label: String
    let bins: [String]
}

struct SkillMessage: Codable {
    let kind: String      // "success" | "error"
    let text: String
}

// MARK: - ClawHub (Skill Marketplace)

struct ClawHubSearchResult: Codable, Identifiable {
    let slug: String
    let name: String
    let description: String
    let author: String?
    let downloads: Int?
    let tags: [String]?

    var id: String { slug }
}

struct ClawHubSkillDetail: Codable {
    let slug: String
    let name: String
    let description: String
    let author: String?
    let version: String?
    let readme: String?
    let downloads: Int?
    let tags: [String]?
    let installCommand: String?
}
