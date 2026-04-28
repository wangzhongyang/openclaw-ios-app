import XCTest

@testable import OpenClaw

final class CronTests: XCTestCase {
    
    // MARK: - CronJob Decoding
    
    func testDecodeCronJob() throws {
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
            },
            "delivery": {
                "mode": "reply",
                "channel": "slack",
                "to": "user123"
            },
            "failureAlert": {
                "after": 3,
                "channel": "email",
                "cooldownMs": 3600000
            },
            "createdAt": 1777020000000,
            "updatedAt": 1777020000000,
            "state": {
                "nextRunAtMs": 1777020060000,
                "lastRunAtMs": 1777019940000,
                "lastRunStatus": "ok",
                "consecutiveErrors": 0
            }
        }
        """
        
        let data = json.data(using: .utf8)!
        let job = try JSONDecoder.default.decode(CronJob.self, from: data)
        
        XCTAssertEqual(job.id, "job1")
        XCTAssertEqual(job.name, "Test Job")
        XCTAssertTrue(job.enabled)
        XCTAssertEqual(job.sessionTarget, "session-123")
        
        switch job.schedule {
        case .every(let everyMs, let anchorMs):
            XCTAssertEqual(everyMs, 60000)
            XCTAssertEqual(anchorMs, 1777020000000)
        default:
            XCTFail("Expected every schedule")
        }
        
        if case .agentTurn(let message, let model, _, let thinking, _, _, _, _, _, _, _) = job.payload {
            XCTAssertEqual(message, "Hello from cron job")
            XCTAssertEqual(model, "gpt-4")
            XCTAssertEqual(thinking, "auto")
        } else {
            XCTFail("Expected agentTurn payload")
        }
        
        if let delivery = job.delivery {
            XCTAssertEqual(delivery.mode, "reply")
            XCTAssertEqual(delivery.channel, "slack")
            XCTAssertEqual(delivery.to, "user123")
        } else {
            XCTFail("Expected delivery")
        }
        
        if let failureAlert = job.failureAlert {
            XCTAssertEqual(failureAlert.after, 3)
            XCTAssertEqual(failureAlert.channel, "email")
            XCTAssertEqual(failureAlert.cooldownMs, 3600000)
        } else {
            XCTFail("Expected failureAlert")
        }
        
        if let state = job.state {
            XCTAssertEqual(state.nextRunAtMs, 1777020060000)
            XCTAssertEqual(state.lastRunAtMs, 1777019940000)
            XCTAssertEqual(state.lastRunStatus, "ok")
            XCTAssertEqual(state.consecutiveErrors, 0)
        } else {
            XCTFail("Expected state")
        }
    }
    
    // MARK: - CronStatus Decoding
    
    func testDecodeCronStatus() throws {
        let json = """
        {
            "enabled": true,
            "jobs": 5,
            "nextWakeAtMs": 1777020060000
        }
        """
        
        let data = json.data(using: .utf8)!
        let status = try JSONDecoder.default.decode(CronStatus.self, from: data)
        
        XCTAssertTrue(status.enabled)
        XCTAssertEqual(status.jobs, 5)
        XCTAssertEqual(status.nextWakeAtMs, 1777020060000)
    }
    
    // MARK: - CronRunLogEntry Decoding
    
    func testDecodeCronRunLogEntry() throws {
        let json = """
        {
            "ts": 1777020000000,
            "jobId": "job1",
            "action": "run",
            "status": "ok",
            "durationMs": 1234,
            "summary": "Job completed successfully",
            "delivered": true,
            "deliveryStatus": "sent",
            "sessionId": "sess-123",
            "sessionKey": "session-123",
            "jobName": "Test Job"
        }
        """
        
        let data = json.data(using: .utf8)!
        let entry = try JSONDecoder.default.decode(CronRunLogEntry.self, from: data)
        
        XCTAssertEqual(entry.ts, 1777020000000)
        XCTAssertEqual(entry.jobId, "job1")
        XCTAssertEqual(entry.action, "run")
        XCTAssertEqual(entry.status, "ok")
        XCTAssertEqual(entry.durationMs, 1234)
        XCTAssertEqual(entry.summary, "Job completed successfully")
        XCTAssertEqual(entry.delivered, true)
        XCTAssertEqual(entry.deliveryStatus, "sent")
        XCTAssertEqual(entry.sessionId, "sess-123")
        XCTAssertEqual(entry.sessionKey, "session-123")
        XCTAssertEqual(entry.jobName, "Test Job")
    }
    
    // MARK: - CronJobsListResult Decoding
    
    func testDecodeCronJobsListResult() throws {
        let json = """
        {
            "jobs": [
                {
                    "id": "job1",
                    "name": "Test Job 1",
                    "enabled": true,
                    "target": "session-123",
                    "schedule": {
                        "kind": "at",
                        "at": "2026-04-28T10:00:00Z"
                    },
                    "payload": {
                        "kind": "systemEvent",
                        "text": "System event"
                    }
                }
            ],
            "total": 1,
            "limit": 10,
            "offset": 0,
            "hasMore": false
        }
        """
        
        let data = json.data(using: .utf8)!
        let result = try JSONDecoder.default.decode(CronJobsListResult.self, from: data)
        
        XCTAssertEqual(result.jobs.count, 1)
        XCTAssertEqual(result.total, 1)
        XCTAssertEqual(result.limit, 10)
        XCTAssertEqual(result.offset, 0)
        XCTAssertFalse(result.hasMore!)
        
        let job = result.jobs[0]
        XCTAssertEqual(job.id, "job1")
        XCTAssertEqual(job.name, "Test Job 1")
        XCTAssertTrue(job.enabled)
        
        switch job.schedule {
        case .at(let at):
            XCTAssertEqual(at, "2026-04-28T10:00:00Z")
        default:
            XCTFail("Expected at schedule")
        }
        
        if case .systemEvent(let text) = job.payload {
            XCTAssertEqual(text, "System event")
        } else {
            XCTFail("Expected systemEvent payload")
        }
    }
}