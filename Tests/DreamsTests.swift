import XCTest

@testable import OpenClaw

final class DreamsTests: XCTestCase {
    
    // MARK: - DreamingStatus Decoding
    
    func testDecodeDreamingStatus() throws {
        let json = """
        {
            "pluginId": "memory-core",
            "light": {
                "enabled": true,
                "cron": "0 */6 * * *",
                "managedCronPresent": true,
                "nextRunAtMs": 1777020000000,
                "lookbackDays": 7,
                "limit": 10
            },
            "deep": {
                "enabled": true,
                "cron": "0 2 * * *",
                "managedCronPresent": true,
                "nextRunAtMs": 1777106400000,
                "limit": 5,
                "minScore": 0.8,
                "minRecallCount": 3,
                "minUniqueQueries": 2,
                "recencyHalfLifeDays": 30.0,
                "maxAgeDays": 365
            },
            "rem": {
                "enabled": true,
                "cron": "0 4 * * *",
                "managedCronPresent": true,
                "nextRunAtMs": 1777113600000,
                "lookbackDays": 30,
                "limit": 3,
                "minPatternStrength": 0.9
            },
            "diaryPath": "DREAMS.md",
            "memoryWikiPluginId": "memory-wiki"
        }
        """
        
        let data = json.data(using: .utf8)!
        let status = try JSONDecoder.default.decode(DreamingStatus.self, from: data)
        
        XCTAssertEqual(status.pluginId, "memory-core")
        XCTAssertEqual(status.diaryPath, "DREAMS.md")
        XCTAssertEqual(status.memoryWikiPluginId, "memory-wiki")
        
        XCTAssertTrue(status.light.enabled)
        XCTAssertEqual(status.light.cron, "0 */6 * * *")
        XCTAssertEqual(status.light.lookbackDays, 7)
        XCTAssertEqual(status.light.limit, 10)
        
        XCTAssertTrue(status.deep.enabled)
        XCTAssertEqual(status.deep.minScore, 0.8)
        XCTAssertEqual(status.deep.recencyHalfLifeDays, 30.0)
        
        XCTAssertTrue(status.rem.enabled)
        XCTAssertEqual(status.rem.minPatternStrength, 0.9)
    }
    
    // MARK: - DreamingDiaryResult Decoding
    
    func testDecodeDreamingDiaryResult() throws {
        let json = """
        {
            "content": "Hello World\\n---\\n*April 5, 2026, 3:00 AM*\\nThis is a dream entry."
        }
        """
        
        let data = json.data(using: .utf8)!
        let result = try JSONDecoder.default.decode(DreamingDiaryResult.self, from: data)
        
        XCTAssertEqual(result.content, "Hello World\n---\n*April 5, 2026, 3:00 AM*\nThis is a dream entry.")
    }
    
    // MARK: - WikiMemoryPalace Decoding
    
    func testDecodeWikiMemoryPalace() throws {
        let json = """
        {
            "palaces": [
                {
                    "name": "Main Palace",
                    "description": "Primary memory palace",
                    "entries": ["entry1", "entry2", "entry3"]
                }
            ]
        }
        """
        
        let data = json.data(using: .utf8)!
        let result = try JSONDecoder.default.decode(DreamingWikiListResult.self, from: data)
        
        XCTAssertEqual(result.palaces.count, 1)
        let palace = result.palaces[0]
        XCTAssertEqual(palace.name, "Main Palace")
        XCTAssertEqual(palace.description, "Primary memory palace")
        XCTAssertEqual(palace.entries, ["entry1", "entry2", "entry3"])
    }
}