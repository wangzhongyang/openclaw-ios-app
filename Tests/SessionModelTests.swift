import XCTest

@testable import OpenClaw

final class SessionModelTests: XCTestCase {

    // MARK: - SessionsListResult Decoding

    func testDecodeServerResponse() throws {
        // This is the exact format the server returns:
        // SessionsListResultBase<GatewaySessionsDefaults, GatewaySessionRow>
        let json = """
        {
            "ts": 1777020000000,
            "path": "/Users/node/.openclaw/sessions",
            "count": 2,
            "defaults": {
                "modelProvider": "openai",
                "model": "gpt-4",
                "contextTokens": 128000
            },
            "sessions": [
                {
                    "key": "agent:default:direct:telegram:5692159644",
                    "kind": "direct",
                    "label": "telegram",
                    "sessionId": "session-abc-123",
                    "updatedAt": 1777019000000,
                    "model": "gpt-4",
                    "modelProvider": "openai",
                    "status": "done",
                    "inputTokens": 5000,
                    "outputTokens": 3000,
                    "totalTokens": 8000
                },
                {
                    "key": "agent:default:global",
                    "kind": "global",
                    "updatedAt": 1777018000000,
                    "status": "running"
                }
            ]
        }
        """.data(using: .utf8)!

        let result = try JSONDecoder.default.decode(SessionsListResult.self, from: json)

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.sessions.count, 2)
        XCTAssertEqual(result.sessions[0].key, "agent:default:direct:telegram:5692159644")
        XCTAssertEqual(result.sessions[0].kind, "direct")
        XCTAssertEqual(result.sessions[0].status, "done")
        XCTAssertEqual(result.sessions[1].kind, "global")
        XCTAssertEqual(result.defaults?.model, "gpt-4")
    }

    func testDecodeEmptySessionsList() throws {
        let json = """
        {
            "ts": 1777020000000,
            "path": "/Users/node/.openclaw/sessions",
            "count": 0,
            "defaults": null,
            "sessions": []
        }
        """.data(using: .utf8)!

        let result = try JSONDecoder.default.decode(SessionsListResult.self, from: json)

        XCTAssertEqual(result.count, 0)
        XCTAssertTrue(result.sessions.isEmpty)
        XCTAssertNil(result.defaults)
    }

    func testDecodeMinimalSessionRow() throws {
        let json = """
        {
            "ts": 1777020000000,
            "path": "/test",
            "count": 1,
            "sessions": [
                {
                    "key": "test-session-key",
                    "kind": "direct"
                }
            ]
        }
        """.data(using: .utf8)!

        let result = try JSONDecoder.default.decode(SessionsListResult.self, from: json)

        XCTAssertEqual(result.sessions.count, 1)
        XCTAssertEqual(result.sessions[0].key, "test-session-key")
        XCTAssertEqual(result.sessions[0].kind, "direct")
        XCTAssertNil(result.sessions[0].model)
        XCTAssertNil(result.sessions[0].status)
    }

    // MARK: - GatewaySessionRow Fields

    func testDecodeSessionRowWithAllFields() throws {
        let json = """
        {
            "key": "full-session-key",
            "kind": "direct",
            "label": "telegram",
            "displayName": "My Session",
            "subject": "Test Subject",
            "space": "main",
            "sessionId": "sess-123",
            "updatedAt": 1777019000000,
            "thinkingLevel": "high",
            "fastMode": false,
            "inputTokens": 100,
            "outputTokens": 200,
            "totalTokens": 300,
            "status": "done",
            "startedAt": 1777018000000,
            "endedAt": 1777019000000,
            "runtimeMs": 5000,
            "childSessions": ["child-1", "child-2"],
            "model": "gpt-4",
            "modelProvider": "openai",
            "contextTokens": 128000
        }
        """.data(using: .utf8)!

        let row = try JSONDecoder.default.decode(GatewaySessionRow.self, from: json)

        XCTAssertEqual(row.key, "full-session-key")
        XCTAssertEqual(row.kind, "direct")
        XCTAssertEqual(row.label, "telegram")
        XCTAssertEqual(row.displayName, "My Session")
        XCTAssertEqual(row.model, "gpt-4")
        XCTAssertEqual(row.modelProvider, "openai")
        XCTAssertEqual(row.contextTokens, 128000)
        XCTAssertEqual(row.status, "done")
        XCTAssertEqual(row.totalTokens, 300)
        XCTAssertEqual(row.childSessions?.count, 2)
    }

    // MARK: - GatewayHelloResponse with Snapshot

    func testDecodeHelloWithSnapshot() throws {
        let json = """
        {
            "type": "res",
            "protocol": 3,
            "server": {
                "version": "2026.4.24",
                "connId": "conn-123"
            },
            "features": {
                "methods": ["chat.send", "sessions.list"],
                "events": ["chat", "session.tool"]
            },
            "auth": {
                "deviceToken": "tok-abc",
                "role": "operator",
                "scopes": ["operator.admin", "operator.read"]
            },
            "snapshot": {
                "presence": [],
                "stateVersion": { "presence": 1, "health": 1 },
                "uptimeMs": 12345,
                "sessionDefaults": {
                    "defaultAgentId": "default",
                    "mainKey": "main",
                    "mainSessionKey": "agent:default:main",
                    "scope": "per-sender"
                },
                "authMode": "token"
            }
        }
        """.data(using: .utf8)!

        let hello = try JSONDecoder.default.decode(GatewayHelloResponse.self, from: json)

        XCTAssertEqual(hello.type, "res")
        XCTAssertEqual(hello.protocol, 3)
        XCTAssertEqual(hello.server?.version, "2026.4.24")
        XCTAssertEqual(hello.server?.connId, "conn-123")
        XCTAssertEqual(hello.auth?.role, "operator")
        XCTAssertNotNil(hello.snapshot)
        XCTAssertEqual(hello.snapshot?.uptimeMs, 12345)
        XCTAssertEqual(hello.snapshot?.sessionDefaults?.defaultAgentId, "default")
        XCTAssertEqual(hello.snapshot?.sessionDefaults?.mainKey, "main")
        XCTAssertEqual(hello.snapshot?.sessionDefaults?.mainSessionKey, "agent:default:main")
        XCTAssertEqual(hello.snapshot?.sessionDefaults?.scope, "per-sender")
        XCTAssertEqual(hello.snapshot?.authMode, "token")
    }

    func testDecodeHelloWithoutSnapshot() throws {
        let json = """
        {
            "type": "res",
            "protocol": 3,
            "server": { "version": "1.0.0" }
        }
        """.data(using: .utf8)!

        let hello = try JSONDecoder.default.decode(GatewayHelloResponse.self, from: json)

        XCTAssertEqual(hello.type, "res")
        XCTAssertNil(hello.snapshot)
    }

    func testDecodeSnapshotWithUpdateAvailable() throws {
        let json = """
        {
            "type": "res",
            "protocol": 3,
            "server": { "version": "2026.4.20" },
            "snapshot": {
                "presence": [],
                "stateVersion": { "presence": 2, "health": 3 },
                "uptimeMs": 99999,
                "updateAvailable": {
                    "currentVersion": "2026.4.20",
                    "latestVersion": "2026.4.24",
                    "channel": "stable"
                }
            }
        }
        """.data(using: .utf8)!

        let hello = try JSONDecoder.default.decode(GatewayHelloResponse.self, from: json)

        XCTAssertEqual(hello.snapshot?.updateAvailable?.currentVersion, "2026.4.20")
        XCTAssertEqual(hello.snapshot?.updateAvailable?.latestVersion, "2026.4.24")
        XCTAssertEqual(hello.snapshot?.updateAvailable?.channel, "stable")
    }
}
