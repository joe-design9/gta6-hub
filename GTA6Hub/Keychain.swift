import Foundation
import Security

/// Minimaler Keychain-Wrapper für den optionalen NVIDIA-API-Key.
enum Keychain {
    private static let service = "dev.joe.gta6hub"
    private static let account = "nvidia-api-key"

    static func saveNVIDIAKey(_ key: String) {
        let data = Data(key.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        SecItemDelete(query as CFDictionary)
        guard !key.isEmpty else { return }
        var attributes = query
        attributes[kSecValueData as String] = data
        SecItemAdd(attributes as CFDictionary, nil)
    }

    static func loadNVIDIAKey() -> String? {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8),
              !value.isEmpty
        else { return nil }
        return value
    }
}
