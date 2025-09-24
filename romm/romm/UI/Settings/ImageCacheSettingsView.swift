import SwiftUI
import Kingfisher

struct ImageCacheSettingsView: View {
    @StateObject private var settings = ImageCacheSettings.shared
    @State private var cacheStatistics = ImageCacheSettings.shared.getCacheStatistics()
    @State private var showingClearConfirmation = false
    @State private var clearCacheType: ClearCacheType = .all
    
    enum ClearCacheType {
        case memory, disk, all
        
        var title: String {
            switch self {
            case .memory: return "Clear Memory Cache"
            case .disk: return "Clear Disk Cache"
            case .all: return "Clear All Caches"
            }
        }
        
        var message: String {
            switch self {
            case .memory: return "This will clear images from memory. They will be reloaded from disk cache when needed."
            case .disk: return "This will clear all cached images from disk. Images will need to be downloaded again."
            case .all: return "This will clear both memory and disk caches. All images will need to be downloaded again."
            }
        }
    }
    
    var body: some View {
        Form {
            // Cache Status Section
            Section("Cache Status") {
                VStack(spacing: 12) {
                    // Only show disk cache since memory cache is not measurable
                    cacheUsageRow(
                        title: "Disk Cache",
                        usage: cacheStatistics.formattedDiskUsage,
                        percentage: cacheStatistics.diskPercentage
                    )
                    
                    // Info about memory cache
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Memory Cache")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                            Text("100 MB limit (fixed)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("Memory cache is automatically managed by the system")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
                
                Button("Refresh Statistics") {
                    refreshStatisticsAsync()
                }
                .foregroundColor(.accentColor)
            }
            
            // Cache Settings Section
            Section("Cache Settings") {
                Toggle("Enable Image Caching", isOn: $settings.cacheEnabled)
                
                if settings.cacheEnabled {
                    Toggle("Enable Image Preloading", isOn: $settings.preloadEnabled)
                    
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Disk Cache Limit")
                            Spacer()
                            Text("\(settings.diskCacheLimitMB) MB")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(
                            value: Binding(
                                get: { Double(settings.diskCacheLimitMB) },
                                set: { settings.diskCacheLimitMB = Int($0) }
                            ),
                            in: 100...2000,
                            step: 50
                        )
                        
                        Text("Recommended: 200-1000 MB")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Cache Expiry")
                            Spacer()
                            Text("\(settings.diskCacheExpiryDays) day\(settings.diskCacheExpiryDays == 1 ? "" : "s")")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(
                            value: Binding(
                                get: { Double(settings.diskCacheExpiryDays) },
                                set: { settings.diskCacheExpiryDays = Int($0) }
                            ),
                            in: 1...30,
                            step: 1
                        )
                        
                        Text("How long to keep cached images")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            
            // Cache Management Section
            Section("Cache Management") {
                Button("Force Cache Cleanup") {
                    KingfisherCacheManager.shared.forceCacheCleanup()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        refreshStatisticsAsync()
                    }
                }
                .foregroundColor(.blue)
                
                Button("Clear Disk Cache") {
                    clearCacheType = .disk
                    showingClearConfirmation = true
                }
                .foregroundColor(.orange)
                
                Button("Clear All Caches") {
                    clearCacheType = .all
                    showingClearConfirmation = true
                }
                .foregroundColor(.red)
                
                Button("Reset to Defaults") {
                    settings.resetToDefaults()
                    refreshStatisticsAsync()
                }
                .foregroundColor(.blue)
            }
            
            // Information Section
            Section("Information") {
                CacheInfoRow(title: "Image caching improves performance by storing downloaded images locally.")
                CacheInfoRow(title: "Memory cache is automatically managed by iOS and cleared when needed.")
                CacheInfoRow(title: "Disk cache persists between app launches and can be manually cleared.")
                CacheInfoRow(title: "Preloading downloads images in advance for smoother scrolling.")
            }
        }
        .navigationTitle("Image Cache")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            refreshStatisticsAsync()
        }
        .alert(clearCacheType.title, isPresented: $showingClearConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                performCacheClear()
            }
        } message: {
            Text(clearCacheType.message)
        }
    }
    
    private func cacheUsageRow(title: String, usage: String, percentage: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text(usage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: Double(percentage), total: 100.0)
                .progressViewStyle(LinearProgressViewStyle(tint: progressColor(for: percentage)))
                .scaleEffect(x: 1, y: 0.5)
            
            Text("\(percentage)% used")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private func progressColor(for percentage: Int) -> Color {
        switch percentage {
        case 0..<50: return .green
        case 50..<80: return .orange
        default: return .red
        }
    }
    
    private func refreshStatistics() {
        cacheStatistics = settings.getCacheStatistics()
    }
    
    private func refreshStatisticsAsync() {
        KingfisherCacheManager.shared.getCacheUsageAsync { memoryUsed, diskUsed in
            self.cacheStatistics = CacheStatistics(
                memoryCacheUsedMB: 0, // Memory not measurable
                memoryCacheLimitMB: 100, // Fixed 100MB
                diskCacheUsedMB: diskUsed / (1024 * 1024),
                diskCacheLimitMB: self.settings.diskCacheLimitMB,
                memoryUtilization: 0, // Memory not measurable
                diskUtilization: Double(diskUsed) / Double(self.settings.diskCacheLimitBytes)
            )
        }
    }
    
    private func performCacheClear() {
        let cacheManager = KingfisherCacheManager.shared
        
        switch clearCacheType {
        case .memory:
            cacheManager.clearMemoryCache()
        case .disk:
            cacheManager.clearDiskCache()
        case .all:
            cacheManager.clearAllCaches()
        }
        
        // Refresh statistics after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            refreshStatisticsAsync()
        }
    }
}

struct CacheInfoRow: View {
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: "info.circle")
                .foregroundColor(.blue)
                .font(.caption)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    NavigationView {
        ImageCacheSettingsView()
    }
}