import Foundation

// Test Skills models manually
func testSkillStatusReport() {
    let json = """
    {
        "workspaceDir": "/Users/node/.openclaw/skills",
        "managedSkillsDir": "/Users/node/.openclaw/skills/managed",
        "skills": [
            {
                "name": "Test Skill",
                "description": "A test skill for unit testing",
                "source": "local",
                "skillKey": "test-skill"
            }
        ]
    }
    """
    
    do {
        let data = json.data(using: .utf8)!
        // This would normally use the SkillStatusReport struct
        // For now, just verify the JSON is valid
        if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            print("✅ SkillStatusReport JSON is valid")
            print("Workspace Dir: \(jsonObject["workspaceDir"] ?? "unknown")")
            
            if let skills = jsonObject["skills"] as? [[String: Any]] {
                print("Skills count: \(skills.count)")
                if let firstSkill = skills.first {
                    print("First skill name: \(firstSkill["name"] ?? "unknown")")
                }
            }
        }
    } catch {
        print("❌ Failed to parse SkillStatusReport JSON: \(error)")
    }
}

testSkillStatusReport()
print("🎉 Skills models test completed!")