//
//  AsyncUserDefaults.swift
//  romm
//
//  Performance optimization: Async wrapper for UserDefaults to avoid main thread blocking
//

import Foundation

/// Thread-safe async wrapper for UserDefaults to prevent main thread blocking
actor AsyncUserDefaults {
    private let userDefaults: UserDefaults
    private let backgroundQueue = DispatchQueue(label: "com.romm.userdefaults", qos: .utility)

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - Async Read Operations

    func string(forKey key: String) -> String? {
        return userDefaults.string(forKey: key)
    }

    func bool(forKey key: String) -> Bool {
        return userDefaults.bool(forKey: key)
    }

    func integer(forKey key: String) -> Int {
        return userDefaults.integer(forKey: key)
    }

    func object(forKey key: String) -> Any? {
        return userDefaults.object(forKey: key)
    }

    func data(forKey key: String) -> Data? {
        return userDefaults.data(forKey: key)
    }

    // MARK: - Async Write Operations

    func set(_ value: String?, forKey key: String) {
        userDefaults.set(value, forKey: key)
        // Fire and forget synchronization on background queue
        backgroundQueue.async { [userDefaults] in
            userDefaults.synchronize()
        }
    }

    func set(_ value: Bool, forKey key: String) {
        userDefaults.set(value, forKey: key)
        backgroundQueue.async { [userDefaults] in
            userDefaults.synchronize()
        }
    }

    func set(_ value: Int, forKey key: String) {
        userDefaults.set(value, forKey: key)
        backgroundQueue.async { [userDefaults] in
            userDefaults.synchronize()
        }
    }

    func set(_ value: Any?, forKey key: String) {
        userDefaults.set(value, forKey: key)
        backgroundQueue.async { [userDefaults] in
            userDefaults.synchronize()
        }
    }

    func removeObject(forKey key: String) {
        userDefaults.removeObject(forKey: key)
        backgroundQueue.async { [userDefaults] in
            userDefaults.synchronize()
        }
    }
}

/// Global shared instance for convenience
extension AsyncUserDefaults {
    static let shared = AsyncUserDefaults()
}
