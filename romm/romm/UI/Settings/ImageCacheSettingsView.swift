import SwiftUI
import Kingfisher

struct ImageCacheSettingsView: View {
    @StateObject private var settings = ImageCacheSettings.shared
    @State private var cacheStatistics = ImageCacheSettings.shared.getCacheStatistics()
    @State private var showingClearConfirmation = false

    var body: some View {
        Form {
            // Cache Status Section
            Section("Cache Status") {
                VStack(spacing: 12) {
                    // Disk cache usage
                    cacheUsageRow(
                        title: "Disk Cache",
                        usage: cacheStatistics.formattedDiskUsage,
                        percentage: cacheStatistics.diskPercentage
                    )
                }
                .padding(.vertical, 4)

                Button {
                    refreshStatisticsAsync()
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh Statistics")
                    }
                }
                .foregroundColor(.accentColor)
            }

            // Cache Settings Section
            Section("Settings") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Max Cache Size")
                        Spacer()
                        Text("\(settings.diskCacheLimitMB) MB")
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                    }

                    Slider(
                        value: Binding(
                            get: { Double(settings.diskCacheLimitMB) },
                            set: { settings.diskCacheLimitMB = Int($0) }
                        ),
                        in: 100...1000,
                        step: 50
                    )

                    Text("Range: 100 MB - 1000 MB (1 GB)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }

            // Cache Management Section
            Section("Management") {
                Button {
                    showingClearConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Clear Cache")
                    }
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Image Cache")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            refreshStatisticsAsync()
        }
        .alert("Clear Cache", isPresented: $showingClearConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                performCacheClear()
            }
        } message: {
            Text("This will clear all cached images. Images will need to be downloaded again.")
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
        // Clear all caches (both memory and disk)
        KingfisherCacheManager.shared.clearAllCaches()

        // Refresh statistics after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            refreshStatisticsAsync()
        }
    }
}

#Preview {
    NavigationView {
        ImageCacheSettingsView()
    }
}
