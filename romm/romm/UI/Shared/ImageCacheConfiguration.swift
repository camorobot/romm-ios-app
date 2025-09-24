//
//  ImageCacheConfiguration.swift
//  romm
//
//  Created by Claude on 28.08.25.
//

import Foundation
import Kingfisher
import UIKit

/// Manages global image cache configuration for the app
class ImageCacheConfiguration {
    static let shared = ImageCacheConfiguration()
    
    private init() {
        configureKingfisher()
    }
    
    private func configureKingfisher() {
        // Configure the default cache
        let cache = ImageCache.default
        
        // DISK ONLY CACHING - No memory cache to save RAM
        cache.memoryStorage.config.totalCostLimit = 0 // Disable memory cache
        cache.memoryStorage.config.countLimit = 0 // No memory items
        
        // DISK CACHE CONFIGURATION
        cache.diskStorage.config.sizeLimit = 200 * 1024 * 1024 // 200MB as requested
        cache.diskStorage.config.expiration = .days(30) // Keep for 30 days
        cache.diskStorage.config.pathExtension = "romm_cache" // Custom folder name
        
        // DOWNLOAD OPTIONS
        KingfisherManager.shared.defaultOptions = [
            .diskCacheExpiration(.days(30)), // Disk expiration
            .backgroundDecode, // Decode images in background to avoid main thread blocking
            .scaleFactor(UIScreen.main.scale), // Use correct scale factor
            .cacheOriginalImage, // Cache the original image
        ]
        
        // PERFORMANCE OPTIMIZATIONS
        KingfisherManager.shared.downloader.downloadTimeout = 30.0 // 30s timeout
        KingfisherManager.shared.downloader.sessionConfiguration.httpMaximumConnectionsPerHost = 6 // Max concurrent downloads
        
        Logger.general.info("🖼️ KingFisher configured: Disk-only cache, 200MB limit, 30-day retention")
    }
    
    /// Clear all cached images
    func clearCache() {
        ImageCache.default.clearMemoryCache() // Clear any remaining memory cache
        ImageCache.default.clearDiskCache { 
            Logger.general.info("🗑️ Image cache cleared")
        }
    }
    
    /// Get current cache size information
    func getCacheSize(completion: @escaping (UInt) -> Void) {
        ImageCache.default.calculateDiskStorageSize { result in
            switch result {
            case .success(let size):
                completion(size)
            case .failure:
                completion(0)
            }
        }
    }
    
    /// Format cache size for display
    func formatCacheSize(_ bytes: UInt) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}
