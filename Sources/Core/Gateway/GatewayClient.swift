import Foundation
import OSLog

// MARK: - Gateway Frames

struct GatewayRequestFrame: Encodable {
    let type = "req"
    let id: String
    let method: String
    let params: AnyCodable?
}

struct GatewayEventFrame {
    let event: String
    let payload: Data?
    let seq: Int?
}

struct GatewayErrorInfo {
    let code: String
    let message: String
    let details: AnyCodable?
    let retryable: Bool?
    let retryAfterMs: TimeInterval?
}

// MARK: - Gateway Client Error

enum GatewayError: Error, LocalizedError {
    case notConnected
    case connectionFailed(String)
    case authFailed(String)
    case requestFailed(String, code: String, retryable: Bool)
    case closed

    var errorDescription: String? {
        switch self {
        case .notConnected:
            return "Gateway is not connected"
        case .connectionFailed(let msg):
            return "Connection failed: \(msg)"
        case .authFailed(let msg):
            return "Authentication failed: \(msg)"
        case .requestFailed(let msg, let code, let retryable):
            return "Request failed [\(code), retryable: \(retryable)]: \(msg)"
        case .closed:
            return "Gateway connection closed"
        }
    }
}

// MARK: - Pending Request

private struct PendingRequest {
    let continuation: CheckedContinuation<Data, Error>
    let timeoutTask: Task<Void, Never>
}

// MARK: - Gateway Client

/// WebSocket client for the OpenClaw Gateway protocol.
/// Mirrors the web UI's GatewayBrowserClient (ui/src/ui/gateway.ts).
@MainActor
final class GatewayClient {
    static let shared = GatewayClient()

    private static let logger = Logger(subsystem: "ai.openclaw.control", category: "gateway")

    private var ws: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    private var pending = [String: PendingRequest]()
    private var pendingMethods = [String: String]()
    private(set) var isConnected = false
    private var isClosed = false
    private var backoffMs: TimeInterval = 0.8
    private var eventListeners = [UUID: (GatewayEventFrame) -> Void]()

    private(set) var serverVersion: String?
    private(set) var connId: String?
    private(set) var helloSnapshot: GatewaySnapshot?

    private init() {}

    // MARK: - Connection

    private var challengeContinuation: CheckedContinuation<String, Error>?

    func connect(url: String, token: String) async throws {
        guard let gatewayURL = URL(string: url) else {
            Self.log("[Gateway] Invalid URL: \(url)")
            throw GatewayError.connectionFailed("Invalid URL: \(url)")
        }

        Self.log("[Gateway] Connecting to \(url)")
        isClosed = false
        connectNonce = nil  // Clear stale nonce from previous connection
        challengeContinuation = nil
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        let session = URLSession(configuration: config)
        urlSession = session

        let task = session.webSocketTask(with: gatewayURL)
        ws = task
        task.resume()

        // Start receive loop first
        Task { await receiveLoop() }

        // Step 1: Wait for connect.challenge event to get nonce
        Self.log("[Gateway] Waiting for challenge")
        let nonce = try await waitForChallenge()
        Self.log("[Gateway] Challenge received, nonce=\(String(nonce.prefix(8)))...")

        // Step 2: Send ONE connect request with device included (matching UI behavior)
        let requestId = UUID().uuidString
        Self.log("[Gateway] Sending connect with device, id=\(String(requestId.prefix(8)))")
        let helloData = try await sendAndWaitForResponse(requestId: requestId, token: token, withDevice: true)
        do {
            let hello = try JSONDecoder.default.decode(GatewayHelloResponse.self, from: helloData)

            // Connected!
            isConnected = true
            serverVersion = hello.server?.version
            connId = hello.server?.connId
            helloSnapshot = hello.snapshot
            backoffMs = 0.8
            Self.log("[Gateway] Connected! version=\(hello.server?.version ?? "unknown"), mainSessionKey=\(hello.snapshot?.sessionDefaults?.mainSessionKey ?? "nil")")
        } catch {
            Self.log("[Gateway] hello decode failed: \(error)")
            throw GatewayError.connectionFailed("Failed to decode hello response: \(error.localizedDescription)")
        }
    }

    /// Send a connect frame and wait for the response
    private func sendAndWaitForResponse(requestId: String, token: String, withDevice: Bool, timeout: TimeInterval = 15) async throws -> Data {
        // Build params
        var params: [String: Any] = [
            "minProtocol": 3,
            "maxProtocol": 3,
            "client": [
                "id": "openclaw-ios",
                "version": "1.0.0",
                "platform": "iOS",
                "mode": "ui",
            ],
            "role": "operator",
            "scopes": ["operator.admin", "operator.read", "operator.write", "operator.approvals", "operator.pairing"],
            "caps": ["tool-events"],
            "auth": ["token": token],
            "userAgent": userAgentString(),
            "locale": Locale.current.identifier,
        ]

        if withDevice, let device = try? buildDeviceParams(token: token) {
            params["device"] = device
        }

        let frame = GatewayRequestFrame(id: requestId, method: "connect", params: AnyCodable(value: params))
        let data = try JSONEncoder.default.encode(frame)
        let message = URLSessionWebSocketTask.Message.string(String(data: data, encoding: .utf8)!)

        // Register in pending BEFORE sending to avoid any race
        let responseData: Data = try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else { return }
            let timeoutTask = Task {
                do {
                    try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                    if let pr = self.pending.removeValue(forKey: requestId) {
                        pr.timeoutTask.cancel()
                        pr.continuation.resume(
                            throwing: GatewayError.requestFailed("Connect timed out", code: "TIMEOUT", retryable: false))
                    }
                } catch {}
            }
            self.pending[requestId] = PendingRequest(continuation: continuation, timeoutTask: timeoutTask)
            self.pendingMethods[requestId] = "connect"

            // Send inside the continuation - the send completion is independent
            // The response will arrive on receiveLoop and resume via handleResponse
            Task {
                do {
                    try await self.ws?.send(message)
                } catch {
                    // Send failed - remove from pending and resume with error
                    if let pr = self.pending.removeValue(forKey: requestId) {
                        pr.timeoutTask.cancel()
                        pr.continuation.resume(throwing: error)
                    }
                }
            }
        }

        return responseData
    }

    static func log(_ message: String) {
        NSLog(message)
        print(message)
        // Also write to a file we can read
        if let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = docs.appendingPathComponent("openclaw_debug.log")
            if let handle = try? FileHandle(forWritingTo: fileURL) {
                handle.seekToEndOfFile()
                if let data = "\(message)\n".data(using: .utf8) {
                    try? handle.write(contentsOf: data)
                }
                try? handle.close()
            } else {
                try? "\(message)\n".write(to: fileURL, atomically: true, encoding: .utf8)
            }
        }
    }

    private func buildDeviceParams(token: String) throws -> [String: Any] {
        let deviceIdentity = DeviceIdentityStore.loadOrCreate()
        let signedAt = Date().timeIntervalSince1970 * 1000
        let nonce = connectNonce ?? ""

        // Build V3 payload matching server format:
        // v3|deviceId|clientId|clientMode|role|scopes|signedAtMs|token|nonce|platform|deviceFamily
        let scopes = "operator.admin,operator.read,operator.write,operator.approvals,operator.pairing"
        let payload = "v3|\(deviceIdentity.deviceId)|openclaw-ios|ui|operator|\(scopes)|\(Int(signedAt))|\(token)|\(nonce)|ios|"
        Self.log("[Gateway] signing payload: \(payload)")
        let signature = try DeviceIdentityStore.sign(Data(payload.utf8))
        Self.log("[Gateway] deviceId=\(deviceIdentity.deviceId) pubKey=\(String(deviceIdentity.publicKeyData.base64URLEncodedString().prefix(16)))...")

        return [
            "id": deviceIdentity.deviceId,
            "publicKey": deviceIdentity.publicKeyData.base64URLEncodedString(),
            "signature": signature.base64URLEncodedString(),
            "signedAt": Int(signedAt),
            "nonce": nonce,
        ]
    }

    /// Wait for connect.challenge event
    private func waitForChallenge() async throws -> String {
        // If nonce already arrived, return immediately
        if let nonce = connectNonce {
            return nonce
        }
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            challengeContinuation = continuation
            // Double-check after setting continuation in case of race
            if let nonce = connectNonce {
                challengeContinuation = nil
                continuation.resume(returning: nonce)
            }
        }
    }

    func disconnect() {
        isClosed = true
        isConnected = false
        ws?.cancel(with: .goingAway, reason: nil)
        ws = nil
        urlSession?.invalidateAndCancel()
        urlSession = nil

        let pendingCopy = pending
        pending.removeAll()
        for (_, pr) in pendingCopy {
            pr.timeoutTask.cancel()
            pr.continuation.resume(throwing: GatewayError.closed)
        }
    }

    // MARK: - Request

    func request<T: Decodable>(type: T.Type, method: String, params: [String: Any]? = nil, timeout: TimeInterval = 15) async throws -> T {
        guard isConnected else {
            throw GatewayError.notConnected
        }

        let id = UUID().uuidString
        var anyParams: AnyCodable?
        if let params {
            anyParams = AnyCodable(value: params)
        }
        let frame = GatewayRequestFrame(id: id, method: method, params: anyParams)
        let data = try JSONEncoder.default.encode(frame)
        let message = URLSessionWebSocketTask.Message.string(String(data: data, encoding: .utf8)!)

        Self.log("[Gateway] send: method=\(method) id=\(String(id.prefix(8)))")

        // Send frame
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            ws?.send(message) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }

        // Wait for response payload data
        let responseData: Data = try await withCheckedThrowingContinuation { continuation in
            let timeoutTask = Task {
                do {
                    try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                    if let pr = pending.removeValue(forKey: id) {
                        pr.continuation.resume(
                            throwing: GatewayError.requestFailed("Request timed out", code: "TIMEOUT", retryable: false))
                    }
                } catch {
                    // Task cancelled
                }
            }
            pending[id] = PendingRequest(continuation: continuation, timeoutTask: timeoutTask)
            pendingMethods[id] = method
        }

        return try JSONDecoder.default.decode(T.self, from: responseData)
    }

    // MARK: - Events

    func onEvent(_ handler: @escaping (GatewayEventFrame) -> Void) -> UUID {
        let id = UUID()
        eventListeners[id] = handler
        return id
    }

    func removeEventListener(_ id: UUID) {
        eventListeners.removeValue(forKey: id)
    }

    // MARK: - Private

    private var connectNonce: String?

    private func receiveLoop() async {
        guard let ws else { return }

        while !isClosed {
            do {
                let message = try await ws.receive()
                handleMessage(message)
            } catch {
                if !isClosed {
                    Self.logger.error("WebSocket receive error: \(error.localizedDescription)")
                    handleDisconnect()
                }
                break
            }
        }
    }

    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        guard case .string(let text) = message,
              let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = json["type"] as? String
        else {
            Self.log("[Gateway] handleMessage: non-string or parse failure")
            return
        }

        let event = json["event"] as? String ?? ""
        let id = json["id"] as? String ?? ""
        Self.log("[Gateway] recv: type=\(type) event=\(event) id=\(id)")

        // Intercept connect.challenge events even before receiveLoop is fully running
        if type == "event", let event = json["event"] as? String, event == "connect.challenge",
           let payload = json["payload"] as? [String: Any], let nonce = payload["nonce"] as? String {
            connectNonce = nonce
            challengeContinuation?.resume(returning: nonce)
            challengeContinuation = nil
            return
        }

        switch type {
        case "res":
            handleResponse(data, json: json)
        case "event":
            handleEvent(data, json: json)
        default:
            break
        }
    }

    private func handleResponse(_ data: Data, json: [String: Any]) {
        guard let id = json["id"] as? String else {
            Self.log("[Gateway] handleResponse: no id")
            return
        }
        guard let ok = json["ok"] as? Bool else {
            Self.log("[Gateway] handleResponse: no ok for id=\(id)")
            return
        }

        guard let pr = pending.removeValue(forKey: id) else {
            Self.log("[Gateway] handleResponse: no pending entry for id=\(id)")
            return
        }
        let method = pendingMethods.removeValue(forKey: id) ?? "?"
        Self.log("[Gateway] handleResponse: method=\(method) ok=\(ok)")
        pr.timeoutTask.cancel()

        if ok {
            // Extract payload from the raw JSON
            if let payload = json["payload"],
               let payloadData = try? JSONSerialization.data(withJSONObject: payload) {
                pr.continuation.resume(returning: payloadData)
            } else {
                // Null payload -> empty object
                pr.continuation.resume(returning: "{}".data(using: .utf8)!)
            }
        } else {
            let errorDict = json["error"] as? [String: Any]
            let code = errorDict?["code"] as? String ?? "UNKNOWN"
            let message = errorDict?["message"] as? String ?? "Request failed"
            let retryable = errorDict?["retryable"] as? Bool ?? false
            Self.log("[Gateway] handleResponse error: id=\(id) code=\(code) msg=\(message)")
            pr.continuation.resume(
                throwing: GatewayError.requestFailed(message, code: code, retryable: retryable))
        }
    }

    private func handleEvent(_ data: Data, json: [String: Any]) {
        guard let event = json["event"] as? String else { return }

        let payloadData: Data? = {
            if let payload = json["payload"],
               let d = try? JSONSerialization.data(withJSONObject: payload) {
                return d
            }
            return nil
        }()

        let frame = GatewayEventFrame(
            event: event,
            payload: payloadData,
            seq: json["seq"] as? Int
        )

        for (_, handler) in eventListeners {
            handler(frame)
        }
    }

    private func handleDisconnect() {
        isConnected = false

        let pendingCopy = pending
        pending.removeAll()
        for (_, pr) in pendingCopy {
            pr.timeoutTask.cancel()
            pr.continuation.resume(throwing: GatewayError.closed)
        }
    }

    private func userAgentString() -> String {
        let version = ProcessInfo.processInfo.operatingSystemVersionString
        return "OpenClaw-iOS-Control/1.0 (\(version))"
    }
}

// MARK: - JSON Encoder/Decoder

extension JSONEncoder {
    static let `default`: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .useDefaultKeys
        return encoder
    }()
}

extension JSONDecoder {
    static let `default`: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        return decoder
    }()
}
