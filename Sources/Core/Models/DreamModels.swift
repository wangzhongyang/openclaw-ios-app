import Foundation

// MARK: - Dream Models

struct DreamingStatus: Codable {
    let pluginId: String
    let light: DreamingPhaseStatus
    let deep: DreamingPhaseStatus  
    let rem: DreamingPhaseStatus
    let diaryPath: String
    let memoryWikiPluginId: String
}

struct DreamingPhaseStatus: Codable {
    let enabled: Bool
    let cron: String
    let managedCronPresent: Bool
    let nextRunAtMs: TimeInterval?
    let lookbackDays: Int?
    let limit: Int?
    let minScore: Double?
    let minRecallCount: Int?
    let minUniqueQueries: Int?
    let recencyHalfLifeDays: Double?
    let maxAgeDays: Int?
    let minPatternStrength: Double?
}

struct DreamingDiaryResult: Codable {
    let content: String
}

struct WikiMemoryPalace: Codable, Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let entries: [String]
}

struct DreamingWikiListResult: Codable {
    let palaces: [WikiMemoryPalace]
}