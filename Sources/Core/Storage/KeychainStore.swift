import Foundation
import Security

/// Secure Keychain storage for Gateway tokens
enum KeychainStore {
    private static let service = "ai.openclaw.control"
    private static let tokenKeyPrefix = "gateway_token_"

    static func saveToken(instanceId: String, token: String) {
        let key = "\(tokenKeyPrefix)\(instanceId)"
        let data = Data(token.utf8)

        // Delete existing entry
        deleteToken(instanceId: instanceId)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    static func loadToken(instanceId: String) -> String? {
        let key = "\(tokenKeyPrefix)\(instanceId)"
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true,
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func deleteToken(instanceId: String) {
        let key = "\(tokenKeyPrefix)\(instanceId)"
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]
        SecItemDelete(query as CFDictionary)
    }
}
