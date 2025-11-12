import Foundation

enum LocalROMDownloadError: LocalizedError {
    case insufficientStorage(required: Int64, available: Int64)
    case downloadFailed(String)
    case fileValidationFailed(String)
    case saveFailed(String)

    var errorDescription: String? {
        switch self {
        case .insufficientStorage(let required, let available):
            let requiredStr = ByteCountFormatter.string(fromByteCount: required, countStyle: .file)
            let availableStr = ByteCountFormatter.string(fromByteCount: available, countStyle: .file)
            return "Insufficient storage: \(requiredStr) required, \(availableStr) available"
        case .downloadFailed(let message):
            return "Download failed: \(message)"
        case .fileValidationFailed(let message):
            return "File validation failed: \(message)"
        case .saveFailed(let message):
            return "Save failed: \(message)"
        }
    }
}

protocol LocalROMDownloadServiceProtocol {
    /// Downloads ROM files to local device storage
    /// - Parameters:
    ///   - rom: The ROM to download
    ///   - files: The specific files to download
    ///   - progressHandler: Called with (downloaded bytes, total bytes) during download
    /// - Returns: The downloaded ROM metadata
    func downloadROM(
        rom: Rom,
        files: [RomFileInfo],
        progressHandler: @escaping (Int64, Int64) -> Void
    ) async throws -> DownloadedROM
}

@MainActor
class LocalROMDownloadService: LocalROMDownloadServiceProtocol {

    private let apiClient: RommAPIClientProtocol
    private let repository: LocalROMRepositoryProtocol
    private let tokenProvider: TokenProviderProtocol
    private let fileManager = FileManager.default

    init(
        apiClient: RommAPIClientProtocol,
        repository: LocalROMRepositoryProtocol = LocalROMRepository(),
        tokenProvider: TokenProviderProtocol = TokenProvider()
    ) {
        self.apiClient = apiClient
        self.tokenProvider = tokenProvider
        self.repository = repository
    }

    func downloadROM(
        rom: Rom,
        files: [RomFileInfo],
        progressHandler: @escaping (Int64, Int64) -> Void
    ) async throws -> DownloadedROM {

        // 1. Calculate total size
        let totalSize = files.reduce(0) { $0 + $1.fileSizeBytes }

        // 2. Check available storage
        let deviceManager = LocalDeviceManager.shared
        deviceManager.updateStorageInfo()

        guard deviceManager.hasEnoughStorage(for: totalSize) else {
            throw LocalROMDownloadError.insufficientStorage(
                required: totalSize,
                available: deviceManager.availableStorageBytes
            )
        }

        // 3. Create ROM directory
        let platformName = rom.platform?.name ?? "Unknown Platform"
        let romDirectoryPath = LocalROMRepository.createROMDirectoryPath(
            platformName: platformName,
            romName: rom.name
        )

        let romDirectoryURL = repository.romsBaseURL.appendingPathComponent(romDirectoryPath)

        try fileManager.createDirectory(
            at: romDirectoryURL,
            withIntermediateDirectories: true,
            attributes: nil
        )

        // 4. Download each file
        var downloadedFiles: [DownloadedROMFile] = []
        var totalDownloadedBytes: Int64 = 0

        for (index, fileInfo) in files.enumerated() {
            print("📥 Downloading file \(index + 1)/\(files.count): \(fileInfo.fileName)")

            // Download file from server
            let localFileURL = romDirectoryURL.appendingPathComponent(fileInfo.fileName)

            do {
                try await downloadFile(
                    fileName: fileInfo.fileName,
                    romId: rom.id,
                    to: localFileURL,
                    expectedSize: fileInfo.fileSizeBytes
                ) { downloadedBytes in
                    // Update progress for this file
                    let currentTotalBytes = totalDownloadedBytes + downloadedBytes
                    progressHandler(currentTotalBytes, totalSize)
                }

                // Verify file was downloaded
                guard fileManager.fileExists(atPath: localFileURL.path) else {
                    throw LocalROMDownloadError.fileValidationFailed("File not found after download: \(fileInfo.fileName)")
                }

                // Get actual file size
                let attributes = try fileManager.attributesOfItem(atPath: localFileURL.path)
                let actualSize = attributes[FileAttributeKey.size] as? Int64 ?? 0

                // Validate file size
                if actualSize != fileInfo.fileSizeBytes {
                    print("⚠️ Warning: Downloaded file size mismatch for \(fileInfo.fileName)")
                    print("   Expected: \(fileInfo.fileSizeBytes), Got: \(actualSize)")
                    // Don't throw - some files might have compression differences
                }

                downloadedFiles.append(DownloadedROMFile(
                    fileName: fileInfo.fileName,
                    fileSizeBytes: actualSize,
                    md5Hash: nil
                ))

                totalDownloadedBytes += actualSize

            } catch {
                // Clean up on error
                try? fileManager.removeItem(at: romDirectoryURL)
                throw LocalROMDownloadError.downloadFailed(error.localizedDescription)
            }
        }

        // 5. Create DownloadedROM metadata
        let downloadedROM = DownloadedROM(
            id: rom.id,
            name: rom.name,
            platformName: platformName,
            platformSlug: rom.platformSlug ?? "",
            downloadedAt: Date(),
            totalSizeBytes: totalDownloadedBytes,
            localDirectory: romDirectoryPath,
            files: downloadedFiles
        )

        // 6. Save metadata
        do {
            try repository.saveDownloadedROM(downloadedROM)
        } catch {
            // Clean up on error
            try? fileManager.removeItem(at: romDirectoryURL)
            throw LocalROMDownloadError.saveFailed(error.localizedDescription)
        }

        print("✅ Successfully downloaded ROM: \(rom.name)")
        print("   Files: \(downloadedFiles.count)")
        print("   Total size: \(ByteCountFormatter.string(fromByteCount: totalDownloadedBytes, countStyle: .file))")
        print("   Location: \(romDirectoryURL.path)")

        return downloadedROM
    }

    // MARK: - Private Helper Methods

    private func downloadFile(
        fileName: String,
        romId: Int,
        to destinationURL: URL,
        expectedSize: Int64,
        progressHandler: @escaping (Int64) -> Void
    ) async throws {
        // Get server URL from token provider
        guard let serverURL = tokenProvider.getServerURL() else {
            throw LocalROMDownloadError.downloadFailed("No server URL configured")
        }

        // Build download URL
        let cleanServerURL = serverURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let downloadURLString = "\(cleanServerURL)/api/roms/\(romId)/content/\(fileName)"

        guard let downloadURL = URL(string: downloadURLString) else {
            throw LocalROMDownloadError.downloadFailed("Invalid download URL")
        }

        print("📡 Downloading from: \(downloadURL.absoluteString)")

        // Create URL request
        var request = URLRequest(url: downloadURL)
        request.httpMethod = "GET"

        // Add authentication (Basic Auth)
        if let username = tokenProvider.getUsername(),
           let password = tokenProvider.getPassword() {
            let loginString = "\(username):\(password)"
            if let loginData = loginString.data(using: .utf8) {
                let base64LoginString = loginData.base64EncodedString()
                request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
            }
        }

        // Create download task
        let session = URLSession.shared
        let (tempFileURL, response) = try await session.download(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw LocalROMDownloadError.downloadFailed("Invalid response")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw LocalROMDownloadError.downloadFailed("HTTP \(httpResponse.statusCode)")
        }

        // Move file to destination
        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }

        try fileManager.moveItem(at: tempFileURL, to: destinationURL)

        // Report final progress
        let attributes = try fileManager.attributesOfItem(atPath: destinationURL.path)
        let actualSize = attributes[.size] as? Int64 ?? 0
        progressHandler(actualSize)
    }
}
