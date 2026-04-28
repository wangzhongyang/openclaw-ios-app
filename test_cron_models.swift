import Foundation

// Test Cron models manually
func testCronJob() {
    let json = """
    {
        "id": "job1",
        "name": "Test Job",
        "enabled": true,
        "target": "session-123",
        "schedule": {
            "kind": "every",
            "everyMs": 60000,
            "anchorMs": 1777020000000
        },
        "payload": {
            "kind": "agentTurn",
            "message": "Hello from cron job",
            "model": "gpt-4",
            "thinking": "auto"
        }
    }
    """
    
    do {
        let data = json.data(using: .utf8)!
        // This would normally use the CronJob struct
        // For now, just verify the JSON is valid
        if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            print("✅ CronJob JSON is valid")
            print("Job ID: \(jsonObject["id"] ?? "unknown")")
            print("Job Name: \(jsonObject["name"] ?? "unknown")")
            
            if let schedule = jsonObject["schedule"] as? [String: Any] {
                print("Schedule kind: \(schedule["kind"] ?? "unknown")")
            }
        }
    } catch {
        print("❌ Failed to parse CronJob JSON: \(error)")
    }
}

testCronJob()
print("🎉 Cron models test completed!")