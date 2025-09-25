import SwiftUI
import Kingfisher

// MARK: - Cached AsyncImage with Kingfisher (Disk-Only)

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    private let url: URL?
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder
    
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
        // Use manual approach with KingFisher for better compatibility
        AsyncImageLoader(url: url, content: content, placeholder: placeholder)
    }
}

// MARK: - AsyncImageLoader using KingFisher

private struct AsyncImageLoader<Content: View, Placeholder: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    @State private var loadedImage: UIImage?
    @State private var isLoading = false
    
    var body: some View {
        Group {
            if let loadedImage = loadedImage {
                content(Image(uiImage: loadedImage))
            } else {
                placeholder()
            }
        }
        .onAppear {
            loadImage()
        }
        .onChange(of: url) { _, newURL in
            loadedImage = nil
            loadImage()
        }
    }
    
    private func loadImage() {
        guard let url = url, !isLoading else { return }
        
        isLoading = true
        
        // Use KingFisher with our optimized cache settings
        let options: KingfisherOptionsInfo = [
            .diskCacheExpiration(.days(30)),
            .backgroundDecode,
            .scaleFactor(UIScreen.main.scale),
            .retryStrategy(DelayRetryStrategy(maxRetryCount: 1, retryInterval: .seconds(1)))
        ]
        
        KingfisherManager.shared.retrieveImage(with: url, options: options) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let value):
                    self.loadedImage = value.image                    
                case .failure(let error):
                    // Handle decompression errors by clearing cache and potentially retrying
                    if error.errorDescription?.contains("decompressing") == true || error.errorDescription?.contains("-17102") == true {
                        Logger.general.warning("🗑️ Image decompression failed, clearing cache for: \(url)")
                        KingfisherManager.shared.cache.removeImage(forKey: url.absoluteString)
                    } else {
                        Logger.general.error("❌ Failed to load image from \(url): \(error)")
                    }
                    self.loadedImage = nil
                }
            }
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
