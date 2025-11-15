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
    @State private var hasDecompressionError = false

    var body: some View {
        Group {
            if let loadedImage = loadedImage {
                content(Image(uiImage: loadedImage))
            } else {
                placeholder()
            }
        }
        .animation(.none, value: loadedImage)
        .onAppear {
            loadImage()
        }
        .onChange(of: url) { _, newURL in
            loadedImage = nil
            hasDecompressionError = false
            loadImage()
        }
    }

    private func loadImage(forceRefresh: Bool = false) {
        guard let url = url, !isLoading else { return }

        isLoading = true

        // Optimized Kingfisher options for better performance and stability
        var options: KingfisherOptionsInfo = [
            .diskCacheExpiration(.days(30)),
            .backgroundDecode, // Decode images in background thread
            .scaleFactor(UIScreen.main.scale),
            .processor(DownsamplingImageProcessor(size: CGSize(width: 300, height: 300))),
            .retryStrategy(DelayRetryStrategy(maxRetryCount: 2, retryInterval: .seconds(0.5))),
            .cacheSerializer(FormatIndicatedCacheSerializer.png) // Use PNG serializer to avoid decompression errors
        ]

        // Force refresh from network if we had a decompression error
        if forceRefresh || hasDecompressionError {
            options.append(.forceRefresh)
        }

        // Use async callback to avoid DispatchQueue.main.async overhead
        KingfisherManager.shared.retrieveImage(with: url, options: options) { result in
            Task { @MainActor [isLoading, loadedImage] in
                // Struct doesn't need weak self - no retain cycles
                self.isLoading = false

                switch result {
                case .success(let value):
                    self.loadedImage = value.image
                    self.hasDecompressionError = false

                case .failure(let error):
                    // Handle decompression errors by clearing cache and retrying
                    if error.errorDescription?.contains("decompressing") == true ||
                       error.errorDescription?.contains("-17102") == true ||
                       error.isTaskCancelled == false {

                        if !self.hasDecompressionError {
                            Logger.general.warning("🔄 Image decompression failed, clearing cache and retrying: \(url)")

                            // Clear corrupt cache
                            KingfisherManager.shared.cache.removeImage(forKey: url.cacheKey)

                            // Mark that we had an error and retry once
                            self.hasDecompressionError = true
                            self.loadImage(forceRefresh: true)
                        } else {
                            Logger.general.error("❌ Image decompression failed after retry: \(url)")
                            self.loadedImage = nil
                        }
                    } else {
                        Logger.general.error("❌ Failed to load image from \(url): \(error)")
                        self.loadedImage = nil
                    }
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
