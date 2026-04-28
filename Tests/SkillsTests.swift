import XCTest

@testable import OpenClaw

final class SkillsTests: XCTestCase {
    
    // MARK: - SkillStatusReport Decoding
    
    func testDecodeSkillStatusReport() throws {
        let json = """
        {
            "workspaceDir": "/Users/node/.openclaw/skills",
            "managedSkillsDir": "/Users/node/.openclaw/skills/managed",
            "skills": [
                {
                    "name": "Test Skill",
                    "description": "A test skill for unit testing",
                    "source": "local",
                    "filePath": "/Users/node/.openclaw/skills/test-skill",
                    "baseDir": "/Users/node/.openclaw/skills",
                    "skillKey": "test-skill",
                    "bundled": false,
                    "primaryEnv": "python",
                    "emoji": "🧪",
                    "homepage": "https://example.com",
                    "always": true,
                    "disabled": false,
                    "blockedByAllowlist": false,
                    "eligible": true,
                    "requirements": {
                        "bins": ["python3", "pip"],
                        "env": ["OPENAI_API_KEY"],
                        "config": ["model"],
                        "os": ["darwin", "linux"]
                    },
                    "missing": {
                        "bins": [],
                        "env": [],
                        "config": [],
                        "os": []
                    },
                    "configChecks": [
                        {
                            "path": "config.yaml",
                            "satisfied": true
                        }
                    ],
                    "install": [
                        {
                            "installId": "brew-python",
                            "kind": "brew",
                            "label": "Python via Homebrew",
                            "bins": ["python3", "pip3"]
                        }
                    ]
                }
            ]
        }
        """
        
        let data = json.data(using: .utf8)!
        let report = try JSONDecoder.default.decode(SkillStatusReport.self, from: data)
        
        XCTAssertEqual(report.workspaceDir, "/Users/node/.openclaw/skills")
        XCTAssertEqual(report.managedSkillsDir, "/Users/node/.openclaw/skills/managed")
        XCTAssertEqual(report.skills.count, 1)
        
        let skill = report.skills[0]
        XCTAssertEqual(skill.name, "Test Skill")
        XCTAssertEqual(skill.description, "A test skill for unit testing")
        XCTAssertEqual(skill.source, "local")
        XCTAssertEqual(skill.skillKey, "test-skill")
        XCTAssertFalse(skill.bundled!)
        XCTAssertEqual(skill.primaryEnv, "python")
        XCTAssertEqual(skill.emoji, "🧪")
        XCTAssertEqual(skill.homepage, "https://example.com")
        XCTAssertTrue(skill.always)
        XCTAssertFalse(skill.disabled)
        XCTAssertFalse(skill.blockedByAllowlist)
        XCTAssertTrue(skill.eligible)
        
        XCTAssertEqual(skill.requirements.bins, ["python3", "pip"])
        XCTAssertEqual(skill.requirements.env, ["OPENAI_API_KEY"])
        XCTAssertEqual(skill.requirements.config, ["model"])
        XCTAssertEqual(skill.requirements.os, ["darwin", "linux"])
        
        XCTAssertEqual(skill.missing.bins, [])
        XCTAssertEqual(skill.missing.env, [])
        XCTAssertEqual(skill.missing.config, [])
        XCTAssertEqual(skill.missing.os, [])
        
        XCTAssertEqual(skill.configChecks.count, 1)
        XCTAssertEqual(skill.configChecks[0].path, "config.yaml")
        XCTAssertTrue(skill.configChecks[0].satisfied)
        
        XCTAssertEqual(skill.install.count, 1)
        let install = skill.install[0]
        XCTAssertEqual(install.installId, "brew-python")
        XCTAssertEqual(install.kind, "brew")
        XCTAssertEqual(install.label, "Python via Homebrew")
        XCTAssertEqual(install.bins, ["python3", "pip3"])
    }
    
    // MARK: - ClawHubSearchResult Decoding
    
    func testDecodeClawHubSearchResult() throws {
        let json = """
        {
            "slug": "test-skill",
            "name": "Test Skill",
            "description": "A test skill from ClawHub",
            "author": "test-author",
            "downloads": 1000,
            "tags": ["test", "utility"]
        }
        """
        
        let data = json.data(using: .utf8)!
        let result = try JSONDecoder.default.decode(ClawHubSearchResult.self, from: data)
        
        XCTAssertEqual(result.slug, "test-skill")
        XCTAssertEqual(result.name, "Test Skill")
        XCTAssertEqual(result.description, "A test skill from ClawHub")
        XCTAssertEqual(result.author, "test-author")
        XCTAssertEqual(result.downloads, 1000)
        XCTAssertEqual(result.tags, ["test", "utility"])
    }
    
    // MARK: - ClawHubSkillDetail Decoding
    
    func testDecodeClawHubSkillDetail() throws {
        let json = """
        {
            "slug": "test-skill",
            "name": "Test Skill",
            "description": "A detailed test skill",
            "author": "test-author",
            "version": "1.0.0",
            "readme": "# Test Skill\\nThis is a test skill.",
            "downloads": 1500,
            "tags": ["test", "detailed"],
            "installCommand": "openclaw skills install test-skill"
        }
        """
        
        let data = json.data(using: .utf8)!
        let detail = try JSONDecoder.default.decode(ClawHubSkillDetail.self, from: data)
        
        XCTAssertEqual(detail.slug, "test-skill")
        XCTAssertEqual(detail.name, "Test Skill")
        XCTAssertEqual(detail.description, "A detailed test skill")
        XCTAssertEqual(detail.author, "test-author")
        XCTAssertEqual(detail.version, "1.0.0")
        XCTAssertEqual(detail.readme, "# Test Skill\nThis is a test skill.")
        XCTAssertEqual(detail.downloads, 1500)
        XCTAssertEqual(detail.tags, ["test", "detailed"])
        XCTAssertEqual(detail.installCommand, "openclaw skills install test-skill")
    }
}