import Foundation
import CryptoKit

/// Device identity for Gateway authentication using Ed25519 key pairs.
struct DeviceIdentity: Codable {
    let deviceId: String   // SHA256 of raw public key bytes, as hex
    let privateKeyData: Data  // Ed25519 private key raw bytes (32 bytes)
    let publicKeyData: Data   // Ed25519 public key raw bytes (32 bytes)
    let createdAt: TimeInterval
}

enum DeviceIdentityStore {
    private static let deviceIdKey = "device_identity_v2"

    static func loadOrCreate() -> DeviceIdentity {
        if let existing = load() {
            return existing
        }
        // Fixed device identity for testing — stable across reinstall
        let identity = hardcodedIdentity()
        save(identity)
        return identity
    }

    /// Hardcoded Ed25519 key pair for development/testing.
    /// Device ID is derived from public key: SHA256(publicKey raw bytes)
    private static func hardcodedIdentity() -> DeviceIdentity {
        let privateKeyRaw = Data([
            0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
            0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F,
            0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17,
            0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F,
        ])
        let privateKey = try! Curve25519.Signing.PrivateKey(rawRepresentation: privateKeyRaw)
        let publicKeyData = privateKey.publicKey.rawRepresentation
        let deviceId = SHA256.hash(data: publicKeyData).compactMap { String(format: "%02x", $0) }.joined()
        return DeviceIdentity(
            deviceId: deviceId,
            privateKeyData: privateKeyRaw,
            publicKeyData: publicKeyData,
            createdAt: 0
        )
    }

    static func load() -> DeviceIdentity? {
        guard let data = UserDefaults.standard.data(forKey: deviceIdKey) else { return nil }
        return try? JSONDecoder().decode(DeviceIdentity.self, from: data)
    }

    static func save(_ identity: DeviceIdentity) {
        if let data = try? JSONEncoder().encode(identity) {
            UserDefaults.standard.set(data, forKey: deviceIdKey)
        }
    }

    private static func create() -> DeviceIdentity {
        let privateKey = Curve25519.Signing.PrivateKey()
        let publicKeyData = privateKey.publicKey.rawRepresentation

        // Device ID = SHA256(raw public key bytes) as hex (matching server's deriveDeviceIdFromPublicKey)
        let deviceId = SHA256.hash(data: publicKeyData).compactMap { String(format: "%02x", $0) }.joined()

        return DeviceIdentity(
            deviceId: deviceId,
            privateKeyData: privateKey.rawRepresentation,
            publicKeyData: publicKeyData,
            createdAt: Date().timeIntervalSince1970
        )
    }

    /// Sign data using Ed25519 for device auth.
    static func sign(_ data: Data) throws -> Data {
        guard let identity = load() else {
            throw DeviceIdentityError.notFound
        }
        let privateKey = try Curve25519.Signing.PrivateKey(rawRepresentation: identity.privateKeyData)
        return try privateKey.signature(for: data)
    }
}

enum DeviceIdentityError: Error, LocalizedError {
    case notFound
    var errorDescription: String? { "Device identity not found" }
}

extension Data {
    /// Base64URL encoding (no padding, URL-safe characters)
    func base64URLEncodedString() -> String {
        let result = base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        return result
    }
}
