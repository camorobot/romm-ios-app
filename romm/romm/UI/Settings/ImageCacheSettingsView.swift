import SwiftUI

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
                    cacheUsageRow(
                        title: "Memory Cache",
                        usage: cacheStatistics.formattedMemoryUsage,
                        percentage: cacheStatistics.memoryPercentage
                    )
                    
                    cacheUsageRow(
                        title: "Disk Cache",
                        usage: cacheStatistics.formattedDiskUsage,
                        percentage: cacheStatistics.diskPercentage
                    )
                }
                .padding(.vertical, 4)
                
                Button("Refresh Statistics") {
                    refreshStatistics()
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
                            Text("Memory Cache Limit")
                            Spacer()
                            Text("\(settings.memoryCacheLimitMB) MB")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(
                            value: Binding(
                                get: { Double(settings.memoryCacheLimitMB) },
                                set: { settings.memoryCacheLimitMB = Int($0) }
                            ),
                            in: 10...500,
                            step: 10
                        )
                        
                        Text("Recommended: 50-200 MB")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                    
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
                Button("Clear Memory Cache") {
                    clearCacheType = .memory
                    showingClearConfirmation = true
                }
                .foregroundColor(.orange)
                
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
                    refreshStatistics()
                }
                .foregroundColor(.blue)
            }
            
            // Information Section
            Section("Information") {
                CacheInfoRow(title: "Image caching improves performance by storing downloaded images locally.")
                CacheInfoRow(title: "Memory cache provides instant access but is cleared when the app is terminated.")
                CacheInfoRow(title: "Disk cache persists between app launches but uses storage space.")
                CacheInfoRow(title: "Preloading downloads images in advance for smoother scrolling.")
            }
        }
        .navigationTitle("Image Cache")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            refreshStatistics()
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
    
    private func performCacheClear() {
        let cacheManager = ImageCacheManager.shared
        
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
            refreshStatistics()
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