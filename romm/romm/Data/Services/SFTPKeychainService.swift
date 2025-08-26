import Foundation
import Security

protocol SFTPKeychainServiceProtocol {
    func savePassword(for connectionId: UUID, password: String) throws
    func getPassword(for connectionId: UUID) -> String?
    func saveSSHKey(for connectionId: UUID, privateKey: String, passphrase: String?) throws
    func getSSHKey(for connectionId: UUID) -> (privateKey: String, passphrase: String?)?
    func deleteCredentials(for connectionId: UUID) throws
}

class SFTPKeychainService: SFTPKeychainServiceProtocol {
    private let keychainService = "com.romm.sftp"
    private let logger = Logger.data
    
    enum KeychainError: LocalizedError {
        case saveFailed(OSStatus)
        case retrievalFailed(OSStatus)
        case deletionFailed(OSStatus)
        
        var errorDescription: String? {
            switch self {
            case .saveFailed(let status):
                return "Failed to save to keychain: \(status)"
            case .retrievalFailed(let status):
                return "Failed to retrieve from keychain: \(status)"
            case .deletionFailed(let status):
                return "Failed to delete from keychain: \(status)"
            }
        }
    }
    
    private enum CredentialType: String {
        case password = "password"
        case privateKey = "privateKey"
        case passphrase = "passphrase"
    }
    
    // MARK: - Password Management
    
    func savePassword(for connectionId: UUID, password: String) throws {
        let key = credentialKey(for: connectionId, type: .password)
        try saveToKeychain(key: key, value: password)
        logger.debug("Saved password for connection: \(connectionId)")
    }
    
    func getPassword(for connectionId: UUID) -> String? {
        let key = credentialKey(for: connectionId, type: .password)
        return getFromKeychain(key: key)
    }
    
    // MARK: - SSH Key Management
    
    func saveSSHKey(for connectionId: UUID, privateKey: String, passphrase: String?) throws {
        let privateKeyKey = credentialKey(for: connectionId, type: .privateKey)
        try saveToKeychain(key: privateKeyKey, value: privateKey)
        
        if let passphrase = passphrase, !passphrase.isEmpty {
            let passphraseKey = credentialKey(for: connectionId, type: .passphrase)
            try saveToKeychain(key: passphraseKey, value: passphrase)
        }
        
        logger.debug("Saved SSH key for connection: \(connectionId)")
    }
    
    func getSSHKey(for connectionId: UUID) -> (privateKey: String, passphrase: String?)? {
        let privateKeyKey = credentialKey(for: connectionId, type: .privateKey)
        guard let privateKey = getFromKeychain(key: privateKeyKey) else {
            return nil
        }
        
        let passphraseKey = credentialKey(for: connectionId, type: .passphrase)
        let passphrase = getFromKeychain(key: passphraseKey)
        
        return (privateKey: privateKey, passphrase: passphrase)
    }
    
    // MARK: - Cleanup
    
    func deleteCredentials(for connectionId: UUID) throws {
        let passwordKey = credentialKey(for: connectionId, type: .password)
        let privateKeyKey = credentialKey(for: connectionId, type: .privateKey)
        let passphraseKey = credentialKey(for: connectionId, type: .passphrase)
        
        // Delete all credentials - ignoring individual failures since some might not exist
        try? removeFromKeychain(key: passwordKey)
        try? removeFromKeychain(key: privateKeyKey)
        try? removeFromKeychain(key: passphraseKey)
        
        logger.debug("Deleted credentials for connection: \(connectionId)")
    }
    
    // MARK: - Private Keychain Methods
    
    private func credentialKey(for connectionId: UUID, type: CredentialType) -> String {
        return "\(connectionId.uuidString)_\(type.rawValue)"
    }
    
    private func saveToKeychain(key: String, value: String) throws {
        let data = value.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: keychainService,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            logger.error("Keychain save error: \(status)")
            throw KeychainError.saveFailed(status)
        }
    }
    
    private func getFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: keychainService,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess,
              let data = item as? Data,
              let value = String(data: data, encoding: .utf8) else {
            if status != errSecItemNotFound {
                logger.error("Keychain retrieval error: \(status)")
            }
            return nil
        }
        
        return value
    }
    
    private func removeFromKeychain(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: keychainService
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            logger.error("Keychain delete error: \(status)")
            throw KeychainError.deletionFailed(status)
        }
    }
}