import Foundation
import Combine

/// Manages the local device (this iPhone/iPad) as a download target
@MainActor
class LocalDeviceManager: ObservableObject {

    static let shared = LocalDeviceManager()

    @Published private(set) var currentDevice: LocalDevice

    private let userDefaults = UserDefaults.standard
    private let storageKey = "local_device_data"

    private init() {
        // Try to load saved device, or create a new one
        if let savedDevice = LocalDeviceManager.loadSavedDevice() {
            self.currentDevice = savedDevice
        } else {
            self.currentDevice = LocalDevice.current()
            saveDevice()
        }

        // Update storage info on init
        updateStorageInfo()
    }

    // MARK: - Public Methods

    /// Updates the storage information for the current device
    /// - Note: This is synchronous and should only be used when blocking is acceptable
    func updateStorageInfo() {
        currentDevice.updateStorageInfo()
        saveDevice()
    }

    /// Updates the storage information asynchronously to avoid blocking main thread
    /// - Note: Preferred method for better performance
    func updateStorageInfoAsync() async {
        // Perform storage check in background
        let storage = await Task.detached(priority: .utility) {
            let fileManager = FileManager.default
            guard let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return (available: Int64(0), total: Int64(0))
            }

            do {
                let values = try documentURL.resourceValues(forKeys: [
                    .volumeAvailableCapacityForImportantUsageKey,
                    .volumeTotalCapacityKey
                ])

                let available = Int64(values.volumeAvailableCapacityForImportantUsage ?? 0)
                let total = Int64(values.volumeTotalCapacity ?? 0)

                return (available: available, total: total)
            } catch {
                print("Error retrieving storage info: \(error)")
                return (available: Int64(0), total: Int64(0))
            }
        }.value

        // Update on main thread
        currentDevice.availableStorageBytes = storage.available
        currentDevice.totalStorageBytes = storage.total
        currentDevice.updatedAt = Date()
        saveDevice()
    }

    /// Updates the device name
    func updateName(_ newName: String) {
        currentDevice.name = newName
        currentDevice.updatedAt = Date()
        saveDevice()
    }

    /// Sets whether this device is the default
    func setAsDefault(_ isDefault: Bool) {
        currentDevice.isDefault = isDefault
        currentDevice.updatedAt = Date()
        saveDevice()
    }

    /// Updates the last connected timestamp
    func markAsConnected() {
        currentDevice.lastConnectedAt = Date()
        currentDevice.updatedAt = Date()
        saveDevice()
    }

    /// Checks if there's enough storage for a download
    func hasEnoughStorage(for sizeInBytes: Int64) -> Bool {
        updateStorageInfo()
        return currentDevice.hasEnoughStorage(for: sizeInBytes)
    }

    /// Gets the available storage in bytes
    var availableStorageBytes: Int64 {
        currentDevice.availableStorageBytes
    }

    /// Gets formatted available storage string
    var availableStorageFormatted: String {
        currentDevice.availableStorageFormatted
    }

    /// Checks if storage is low
    var hasLowStorage: Bool {
        currentDevice.hasLowStorage
    }

    // MARK: - Persistence

    private func saveDevice() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(currentDevice)
            userDefaults.set(data, forKey: storageKey)
        } catch {
            print("Error saving local device: \(error)")
        }
    }

    private static func loadSavedDevice() -> LocalDevice? {
        guard let data = UserDefaults.standard.data(forKey: "local_device_data") else {
            return nil
        }

        do {
            let decoder = JSONDecoder()
            var device = try decoder.decode(LocalDevice.self, from: data)

            // Always update storage info when loading
            device.updateStorageInfo()

            return device
        } catch {
            print("Error loading local device: \(error)")
            return nil
        }
    }

    /// Resets the local device to current device state
    func reset() {
        currentDevice = LocalDevice.current()
        saveDevice()
    }
}
