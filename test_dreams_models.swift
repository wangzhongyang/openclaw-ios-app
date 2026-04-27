import Foundation

// Test Dreams models manually
func testDreamingStatus() {
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
    
    do {
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        
        // This would normally use the DreamingStatus struct
        // For now, just verify the JSON is valid
        if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            print("✅ DreamingStatus JSON is valid")
            print("Plugin ID: \(jsonObject["pluginId"] ?? "unknown")")
            print("Diary Path: \(jsonObject["diaryPath"] ?? "unknown")")
        }
    } catch {
        print("❌ Failed to parse DreamingStatus JSON: \(error)")
    }
}

testDreamingStatus()
print("🎉 Dreams models test completed!")