import Foundation

class ImageCacheSettings: ObservableObject {
    static let shared = ImageCacheSettings()
    
    private let userDefaults = UserDefaults.standard
    
    private init() {
        // Initialize @Published properties from UserDefaults
        let memoryValue = userDefaults.integer(forKey: Keys.memoryCacheLimit)
        self.memoryCacheLimitMB = memoryValue > 0 ? memoryValue : Defaults.memoryCacheLimitMB
        
        let diskValue = userDefaults.integer(forKey: Keys.diskCacheLimit)
        self.diskCacheLimitMB = diskValue > 0 ? diskValue : Defaults.diskCacheLimitMB
        
        self.cacheEnabled = userDefaults.object(forKey: Keys.cacheEnabled) as? Bool ?? Defaults.cacheEnabled
        self.preloadEnabled = userDefaults.object(forKey: Keys.preloadEnabled) as? Bool ?? Defaults.preloadEnabled
        
        let expiryValue = userDefaults.integer(forKey: Keys.diskCacheExpiry)
        self.diskCacheExpiryDays = expiryValue > 0 ? expiryValue : Defaults.diskCacheExpiryDays
    }
    
    // MARK: - Settings Keys
    private enum Keys {
        static let memoryCacheLimit = "image_memory_cache_limit_mb"
        static let diskCacheLimit = "image_disk_cache_limit_mb"
        static let cacheEnabled = "image_cache_enabled"
        static let preloadEnabled = "image_preload_enabled"
        static let diskCacheExpiry = "image_disk_cache_expiry_days"
    }
    
    // MARK: - Default Values
    private enum Defaults {
        static let memoryCacheLimitMB = 100 // 100MB
        static let diskCacheLimitMB = 500   // 500MB
        static let cacheEnabled = true
        static let preloadEnabled = true
        static let diskCacheExpiryDays = 7  // 1 week
    }
    
    // MARK: - Properties
    
    @Published var memoryCacheLimitMB: Int {
        didSet {
            userDefaults.set(memoryCacheLimitMB, forKey: Keys.memoryCacheLimit)
            applySettings()
        }
    }
    
    @Published var diskCacheLimitMB: Int {
        didSet {
            userDefaults.set(diskCacheLimitMB, forKey: Keys.diskCacheLimit)
            applySettings()
        }
    }
    
    @Published var cacheEnabled: Bool {
        didSet {
            userDefaults.set(cacheEnabled, forKey: Keys.cacheEnabled)
            if !cacheEnabled {
                ImageCacheManager.shared.clearAllCaches()
            }
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
    
    var memoryCacheLimitBytes: Int {
        memoryCacheLimitMB * 1024 * 1024
    }
    
    var diskCacheLimitBytes: Int {
        diskCacheLimitMB * 1024 * 1024
    }
    
    var diskCacheExpirySeconds: TimeInterval {
        TimeInterval(diskCacheExpiryDays * 24 * 60 * 60)
    }
    
    // MARK: - Methods
    
    func applySettings() {
        ImageCacheManager.shared.updateSettings()
    }
    
    func resetToDefaults() {
        userDefaults.removeObject(forKey: Keys.memoryCacheLimit)
        userDefaults.removeObject(forKey: Keys.diskCacheLimit)
        userDefaults.removeObject(forKey: Keys.cacheEnabled)
        userDefaults.removeObject(forKey: Keys.preloadEnabled)
        userDefaults.removeObject(forKey: Keys.diskCacheExpiry)
        
        // Update @Published properties to trigger UI updates
        memoryCacheLimitMB = Defaults.memoryCacheLimitMB
        diskCacheLimitMB = Defaults.diskCacheLimitMB
        cacheEnabled = Defaults.cacheEnabled
        preloadEnabled = Defaults.preloadEnabled
        diskCacheExpiryDays = Defaults.diskCacheExpiryDays
    }
    
    func getCacheStatistics() -> CacheStatistics {
        let (memoryUsed, diskUsed) = ImageCacheManager.shared.getCacheUsage()
        
        return CacheStatistics(
            memoryCacheUsedMB: memoryUsed / (1024 * 1024),
            memoryCacheLimitMB: memoryCacheLimitMB,
            diskCacheUsedMB: diskUsed / (1024 * 1024),
            diskCacheLimitMB: diskCacheLimitMB,
            memoryUtilization: Double(memoryUsed) / Double(memoryCacheLimitBytes),
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