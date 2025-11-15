import Foundation
import Kingfisher

class ImageCacheSettings: ObservableObject {
    static let shared = ImageCacheSettings()
    
    private let userDefaults = UserDefaults.standard
    
    private init() {
        // Initialize @Published properties from UserDefaults        
        let diskValue = userDefaults.integer(forKey: Keys.diskCacheLimit)
        self.diskCacheLimitMB = diskValue > 0 ? diskValue : Defaults.diskCacheLimitMB
        
        self.cacheEnabled = userDefaults.object(forKey: Keys.cacheEnabled) as? Bool ?? Defaults.cacheEnabled
        self.preloadEnabled = userDefaults.object(forKey: Keys.preloadEnabled) as? Bool ?? Defaults.preloadEnabled
        
        let expiryValue = userDefaults.integer(forKey: Keys.diskCacheExpiry)
        self.diskCacheExpiryDays = expiryValue > 0 ? expiryValue : Defaults.diskCacheExpiryDays
    }
    
    // MARK: - Settings Keys
    private enum Keys {
        static let diskCacheLimit = "image_disk_cache_limit_mb"
        static let cacheEnabled = "image_cache_enabled"
        static let preloadEnabled = "image_preload_enabled"
        static let diskCacheExpiry = "image_disk_cache_expiry_days"
    }
    
    // MARK: - Default Values
    private enum Defaults {
        static let diskCacheLimitMB = 250   // 250MB (user-requested default)
        static let cacheEnabled = true      // Always enabled (simplified)
        static let preloadEnabled = true    // Always enabled (simplified)
        static let diskCacheExpiryDays = 30 // 30 days (fixed, not user-configurable)
    }
    
    // MARK: - Properties
    
    @Published var diskCacheLimitMB: Int {
        didSet {
            userDefaults.set(diskCacheLimitMB, forKey: Keys.diskCacheLimit)
            applySettings()
        }
    }
    
    @Published var cacheEnabled: Bool {
        didSet {
            userDefaults.set(cacheEnabled, forKey: Keys.cacheEnabled)
            // Don't clear caches aggressively - let user do it manually if needed
            applySettings()
        }
    }
    
    @Published var preloadEnabled: Bool {
        didSet {
            userDefaults.set(preloadEnabled, forKey: Keys.preloadEnabled)
        }
    }
    
    @Published var diskCacheExpiryDays: Int {
        didSet {
            userDefaults.set(diskCacheExpiryDays, forKey: Keys.diskCacheExpiry)
            applySettings()
        }
    }
    
    // MARK: - Computed Properties
    
    var diskCacheLimitBytes: Int {
        diskCacheLimitMB * 1024 * 1024
    }
    
    var diskCacheExpirySeconds: TimeInterval {
        TimeInterval(diskCacheExpiryDays * 24 * 60 * 60)
    }
    
    // MARK: - Methods
    
    func applySettings() {
        KingfisherCacheManager.shared.updateSettings()
    }
    
    func resetToDefaults() {
        userDefaults.removeObject(forKey: Keys.diskCacheLimit)
        userDefaults.removeObject(forKey: Keys.cacheEnabled)
        userDefaults.removeObject(forKey: Keys.preloadEnabled)
        userDefaults.removeObject(forKey: Keys.diskCacheExpiry)
        
        // Update @Published properties to trigger UI updates
        diskCacheLimitMB = Defaults.diskCacheLimitMB
        cacheEnabled = Defaults.cacheEnabled
        preloadEnabled = Defaults.preloadEnabled
        diskCacheExpiryDays = Defaults.diskCacheExpiryDays
    }
    
    func getCacheStatistics() -> CacheStatistics {
        let (memoryUsed, diskUsed) = KingfisherCacheManager.shared.getCacheUsage()
        
        return CacheStatistics(
            memoryCacheUsedMB: 0, // Memory cache not user-visible
            memoryCacheLimitMB: 100, // Fixed 100MB limit
            diskCacheUsedMB: diskUsed / (1024 * 1024),
            diskCacheLimitMB: diskCacheLimitMB,
            memoryUtilization: 0, // Not measurable
            diskUtilization: Double(diskUsed) / Double(diskCacheLimitBytes)
        )
    }
}

struct CacheStatistics {
    let memoryCacheUsedMB: Int
    let memoryCacheLimitMB: Int
    let diskCacheUsedMB: Int
    let diskCacheLimitMB: Int
    let memoryUtilization: Double
    let diskUtilization: Double
    
    var formattedMemoryUsage: String {
        "\(memoryCacheUsedMB) MB / \(memoryCacheLimitMB) MB"
    }
    
    var formattedDiskUsage: String {
        "\(diskCacheUsedMB) MB / \(diskCacheLimitMB) MB"
    }
    
    var memoryPercentage: Int {
        Int(memoryUtilization * 100)
    }
    
    var diskPercentage: Int {
        Int(diskUtilization * 100)
    }
}