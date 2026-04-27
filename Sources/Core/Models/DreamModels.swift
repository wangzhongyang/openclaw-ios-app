import Foundation

// MARK: - Dream Models

struct DreamingStatus: Codable {
    let enabled: Bool
    let mode: String?
    let diaryPath: String?
    let lastRunAt: TimeInterval?
    let lastError: String?
}

struct WikiMemoryPalace: Codable {
    let entries: [WikiMemoryEntry]
    let totalCount: Int
}

struct WikiMemoryEntry: Codable, Identifiable {
    let id: String
    let title: String
    let content: String?
    let createdAt: TimeInterval
    let updatedAt: TimeInterval
    let tags: [String]?
}

struct DreamDiaryEntry: Codable, Identifiable {
    let id: String
    let title: String
    let content: String
    let createdAt: TimeInterval
    let tags: [String]?
}

struct WikiImportInsights: Codable {
    let totalEntries: Int
    let importedCount: Int
    let errorCount: Int
    let errors: [String]
}

struct DreamingModeResult: Codable {
    let ok: Bool
    let mode: String?
}

struct DreamAction: Codable {
    let ok: Bool
    let message: String?
    let path: String?
}
