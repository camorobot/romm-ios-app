import SwiftUI

// MARK: - Image Cache Manager

class ImageCacheManager: ObservableObject {
    static let shared = ImageCacheManager()
    
    private let urlSession: URLSession
    private let memoryCache = NSCache<NSString, UIImage>()
    private let settings = ImageCacheSettings.shared
    
    private init() {
        // Configure URLCache with settings
        let diskCacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("ImageCache")
        
        let urlCache = URLCache(
            memoryCapacity: 20 * 1024 * 1024, // 20MB for URL cache memory
            diskCapacity: settings.diskCacheLimitBytes,
            directory: diskCacheURL
        )
        
        // Configure URLSession with caching
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = urlCache
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.timeoutIntervalForRequest = 30.0
        configuration.timeoutIntervalForResource = 60.0
        
        self.urlSession = URLSession(configuration: configuration)
        
        // Configure memory cache with settings
        updateSettings()
    }
    
    func updateSettings() {
        memoryCache.countLimit = 500 // Maximum 200 images in memory
        memoryCache.totalCostLimit = settings.memoryCacheLimitBytes
        
        // Update URLCache limits
        if let urlCache = urlSession.configuration.urlCache {
            urlCache.diskCapacity = settings.diskCacheLimitBytes
        }
    }
    
    func loadImage(from url: URL) async -> UIImage? {
        // Check if caching is enabled
        guard settings.cacheEnabled else {
            return await loadImageDirectly(from: url)
        }
        
        let cacheKey = url.absoluteString as NSString
        
        // Check memory cache first
        if let cachedImage = memoryCache.object(forKey: cacheKey) {
            return cachedImage
        }
        
        do {
            let (data, response) = try await urlSession.data(from: url)
            
            // Verify response
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return nil
            }
            
            // Create image from data
            guard let image = UIImage(data: data) else {
                return nil
            }
            
            // Cache in memory if enabled
            if settings.cacheEnabled {
                let cost = data.count
                memoryCache.setObject(image, forKey: cacheKey, cost: cost)
            }
            
            return image
            
        } catch {
            print("❌ Failed to load image from \(url): \(error)")
            return nil
        }
    }
    
    private func loadImageDirectly(from url: URL) async -> UIImage? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let image = UIImage(data: data) else {
                return nil
            }
            
            return image
        } catch {
            return nil
        }
    }
    
    func clearMemoryCache() {
        memoryCache.removeAllObjects()
    }
    
    func clearDiskCache() {
        urlSession.configuration.urlCache?.removeAllCachedResponses()
    }
    
    func clearAllCaches() {
        clearMemoryCache()
        clearDiskCache()
    }
    
    func getCacheUsage() -> (memory: Int, disk: Int) {
        let memoryUsed = memoryCache.totalCostLimit // This is an approximation
        let diskUsed = urlSession.configuration.urlCache?.currentDiskUsage ?? 0
        return (memory: memoryUsed, disk: diskUsed)
    }
    
    func preloadImages(urls: [URL]) {
        guard settings.preloadEnabled else { return }
        
        Task {
            for url in urls {
                _ = await loadImage(from: url)
            }
        }
    }
}

// MARK: - Cached AsyncImage

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    private let url: URL?
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder
    
    @StateObject private var imageManager = ImageCacheManager.shared
    @State private var loadedImage: UIImage?
    @State private var isLoading = false
    
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let loadedImage = loadedImage {
                content(Image(uiImage: loadedImage))
            } else {
                placeholder()
                    .onAppear {
                        Task {
                            await loadImage()
                        }
                    }
            }
        }
        .onChange(of: url) { _, newURL in
            loadedImage = nil
            Task {
                await loadImage()
            }
        }
    }
    
    private func loadImage() async {
        guard let url = url, !isLoading else { return }
        
        isLoading = true
        let image = await imageManager.loadImage(from: url)
        
        await MainActor.run {
            self.loadedImage = image
            self.isLoading = false
        }
    }
}

// MARK: - Convenience Initializers

extension CachedAsyncImage where Content == Image, Placeholder == Color {
    init(url: URL?) {
        self.init(
            url: url,
            content: { $0 },
            placeholder: { Color.gray.opacity(0.3) }
        )
    }
}

extension CachedAsyncImage where Placeholder == Color {
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content
    ) {
        self.init(
            url: url,
            content: content,
            placeholder: { Color.gray.opacity(0.3) }
        )
    }
}

// MARK: - String URL Convenience

extension CachedAsyncImage {
    init(
        urlString: String?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        let url = urlString.flatMap(URL.init)
        self.init(url: url, content: content, placeholder: placeholder)
    }
}

extension CachedAsyncImage where Content == Image, Placeholder == Color {
    init(urlString: String?) {
        let url = urlString.flatMap(URL.init)
        self.init(url: url)
    }
}
