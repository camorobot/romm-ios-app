import Foundation
import Observation

struct RomFileInfo: Identifiable, Hashable {
    let id: String
    let fileName: String
    let fileSizeBytes: Int64
    let fileExtension: String
    
    init(from romFile: RomFileSchema) {
        self.id = romFile.fileName
        self.fileName = romFile.fileName
        self.fileSizeBytes = Int64(romFile.fileSizeBytes)
        self.fileExtension = ""  // RomFileSchema doesn't have fsExtension, get from fileName
    }
    
    init(id: String, fileName: String, fileSizeBytes: Int64, fileExtension: String) {
        self.id = id
        self.fileName = fileName
        self.fileSizeBytes = fileSizeBytes
        self.fileExtension = fileExtension
    }
    
    var displaySize: String {
        ByteCountFormatter.string(fromByteCount: fileSizeBytes, countStyle: .file)
    }
}

@MainActor
@Observable
class SFTPUploadViewModel {
    var connections: [SFTPConnection] = []
    var selectedConnection: SFTPConnection?
    var targetPath: String?
    var isUploading = false
    var uploadProgress: Double = 0.0
    var uploadedBytes: Int64 = 0
    var totalBytes: Int64 = 0
    var error: String?
    var isCompleted = false
    var showingDirectoryBrowser = false
    
    // Preparation progress
    var isPreparing = false
    var prepareProgress: Double = 0.0
    var preparedBytes: Int64 = 0
    var prepareMessage = "Preparing ROM file..."
    
    // Multi-file support
    var availableFiles: [RomFileInfo] = []
    var selectedFiles: Set<String> = []
    var isLoadingFiles = false
    var currentFileIndex = 0
    var totalFiles = 0
    
    let rom: Rom
    private let sftpUseCases: SFTPUseCases
    private let apiClient: RommAPIClientProtocol
    
    init(rom: Rom, sftpUseCases: SFTPUseCases = SFTPUseCases(), apiClient: RommAPIClientProtocol = RommAPIClient.shared) {
        self.rom = rom
        self.sftpUseCases = sftpUseCases
        self.apiClient = apiClient
        
        loadConnections()
        loadAvailableFiles()
    }
    
    private func loadConnections() {
        connections = sftpUseCases.getAllConnections()
        selectedConnection = sftpUseCases.getDefaultConnection() ?? connections.first
    }
    
    private func loadAvailableFiles() {
        Task {
            isLoadingFiles = true
            error = nil
            
            do {
                // Use getRomDetails to get all files for this ROM
                let romDetails = try await apiClient.getRomDetails(id: rom.id)
                
                let files = romDetails.files.map { RomFileInfo(from: $0) }
                
                await MainActor.run {
                    self.availableFiles = files
                    
                    // Auto-select the first file by default
                    if let firstFile = files.first {
                        self.selectedFiles = [firstFile.id]
                    }
                    
                    self.isLoadingFiles = false
                }
                
            } catch {
                await MainActor.run {
                    // Fallback to single file from ROM data
                    let fallbackFile = RomFileInfo(
                        id: rom.fileName ?? "\(rom.name).rom",
                        fileName: rom.fileName ?? "\(rom.name).rom",
                        fileSizeBytes: 0,
                        fileExtension: ""
                    )
                    
                    self.availableFiles = [fallbackFile]
                    self.selectedFiles = [fallbackFile.id]
                    self.isLoadingFiles = false
                    
                    print("⚠️ Could not load ROM files, using fallback: \(error)")
                }
            }
        }
    }
    
    func selectConnection(_ connection: SFTPConnection) {
        selectedConnection = connection
        targetPath = nil
    }
    
    func browseDirectories() {
        guard selectedConnection != nil else { return }
        showingDirectoryBrowser = true
    }
    
    func selectTargetPath(_ path: String) {
        targetPath = path
        showingDirectoryBrowser = false
    }
    
    // MARK: - Multi-File Selection
    
    func toggleFileSelection(_ fileId: String) {
        if selectedFiles.contains(fileId) {
            selectedFiles.remove(fileId)
        } else {
            selectedFiles.insert(fileId)
        }
    }
    
    func selectAllFiles() {
        selectedFiles = Set(availableFiles.map { $0.id })
    }
    
    func deselectAllFiles() {
        selectedFiles.removeAll()
    }
    
    var selectedFilesList: [RomFileInfo] {
        return availableFiles.filter { selectedFiles.contains($0.id) }
    }
    
    func startUpload() async {
        guard let connection = selectedConnection,
              let targetPath = targetPath,
              !isUploading else { return }
        
        isUploading = true
        uploadProgress = 0.0
        uploadedBytes = 0
        error = nil
        isCompleted = false
        
        var localPath: String?
        
        do {
            localPath = try await downloadRomFile()
            totalBytes = try sftpUseCases.getFileSize(at: localPath!)
            
            let fileName = rom.fileName ?? "\(rom.name).rom"
            let remotePath = targetPath.hasSuffix("/") ? "\(targetPath)\(fileName)" : "\(targetPath)/\(fileName)"
            
            try await sftpUseCases.uploadFile(
                from: localPath!,
                to: remotePath,
                connection: connection,
                progressHandler: { [weak self] uploaded, total in
                    DispatchQueue.main.async {
                        // Stop processing progress updates if upload is marked as completed
                        guard let strongSelf = self, !strongSelf.isCompleted else { 
                            print("🔍 Progress: Ignoring update after completion")
                            return 
                        }
                        
                        // Debug progress calculation
                        print("🔍 Progress: uploaded=\(uploaded), total=\(total)")
                        
                        strongSelf.uploadedBytes = uploaded
                        strongSelf.totalBytes = total
                        
                        // Safe progress calculation with bounds checking
                        if total > 0 {
                            let rawProgress = Double(uploaded) / Double(total)
                            let progress = min(max(rawProgress, 0.0), 1.0)
                            strongSelf.uploadProgress = progress
                            print("🔍 Progress: calculated progress=\(progress) (\(Int(progress * 100))%)")
                            
                            // Stop accepting updates once we reach 100%
                            if progress >= 1.0 {
                                print("🔍 Progress: Reached 100%, stopping progress updates")
                                strongSelf.uploadProgress = 1.0
                                // Don't set isCompleted here - let the upload function handle that
                            }
                        } else {
                            strongSelf.uploadProgress = 0.0
                        }
                    }
                }
            )
            
            isCompleted = true
            
        } catch {
            self.error = error.localizedDescription
        }
        
        // Always cleanup temporary file, even on error
        if let localPath = localPath {
            sftpUseCases.cleanupTemporaryFile(at: localPath)
        }
        
        isUploading = false
    }
    
    func resetUpload() {
        isUploading = false
        uploadProgress = 0.0
        uploadedBytes = 0
        totalBytes = 0
        error = nil
        isCompleted = false
        currentFileIndex = 0
        totalFiles = 0
        selectedFiles.removeAll()
        targetPath = nil
        showingDirectoryBrowser = false
        
        // Reset preparation state
        isPreparing = false
        prepareProgress = 0.0
        preparedBytes = 0
        prepareMessage = "Preparing ROM file..."
    }
    
    private func downloadRomFile() async throws -> String {
        let fileName = rom.fileName ?? "\(rom.name).rom"
        let localPath = sftpUseCases.getTemporaryFilePath(for: fileName)
        
        print("🔍 Debug: Starting ROM download...")
        
        isPreparing = true
        prepareProgress = 0.0
        preparedBytes = 0
        prepareMessage = "Downloading ROM file..."
        
        // Check available storage before download
        try checkStorageCapacity()
        
        let romDownloadURL = try await getRomDownloadURL()
        
        // Create authenticated download request
        var request = URLRequest(url: romDownloadURL)
        request.httpMethod = "GET"
        
        // Add authentication (same as API client)
        let tokenProvider = TokenProvider()
        guard let username = tokenProvider.getUsername(),
              let password = tokenProvider.getPassword() else {
            print("❌ Debug: No credentials found")
            isPreparing = false
            throw SFTPError.authenticationFailed
        }
        
        let loginString = "\(username):\(password)"
        guard let loginData = loginString.data(using: .utf8) else {
            isPreparing = false
            throw SFTPError.authenticationFailed
        }
        let base64LoginString = loginData.base64EncodedString()
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        print("🔍 Debug: Making download request with auth for user: \(username)")
        
        return try await withCheckedThrowingContinuation { continuation in
            let downloadTask = URLSession.shared.downloadTask(with: request) { [weak self] tempURL, response, error in
                DispatchQueue.main.async {
                    self?.isPreparing = false
                }
                
                if let error = error {
                    print("❌ Debug: Download error: \(error)")
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let tempURL = tempURL else {
                    print("❌ Debug: No temporary URL")
                    continuation.resume(throwing: SFTPError.downloadFailed)
                    return
                }
                
                do {
                    let data = try Data(contentsOf: tempURL)
                    print("🔍 Debug: Downloaded data size: \(data.count) bytes")
                    try data.write(to: URL(fileURLWithPath: localPath))
                    continuation.resume(returning: localPath)
                } catch {
                    print("❌ Debug: Error writing file: \(error)")
                    continuation.resume(throwing: error)
                }
            }
            
            // Set up progress observation
            let progressObserver = downloadTask.progress.observe(\.fractionCompleted) { [weak self] progress, _ in
                DispatchQueue.main.async {
                    guard let self = self, self.isPreparing else { return }
                    self.prepareProgress = progress.fractionCompleted
                    self.preparedBytes = progress.completedUnitCount
                    
                    if progress.fractionCompleted < 0.1 {
                        self.prepareMessage = "Connecting to server..."
                    } else if progress.fractionCompleted < 1.0 {
                        self.prepareMessage = "Downloading ROM file... \(Int(progress.fractionCompleted * 100))%"
                    } else {
                        self.prepareMessage = "Processing file..."
                    }
                }
            }
            
            downloadTask.resume()
        }
    }
    
    private func getRomDownloadURL() async throws -> URL {
        // Skip getRomDetails for now and use existing ROM data directly
        print("🔍 Debug: Building ROM download URL for ID \(rom.id)")
        
        // Use fileName from the ROM object, or fallback to name + extension
        let fileName = rom.fileName ?? "\(rom.name).rom"
        print("🔍 Debug: Using filename: \(fileName)")
        
        // Build the direct download URL (the API endpoint serves the file directly)
        guard let serverURL = TokenProvider().getServerURL() else {
            throw SFTPError.networkError("No server URL configured")
        }
        
        let downloadURLString = "\(serverURL.trimmingCharacters(in: CharacterSet(charactersIn: "/")))/api/roms/\(rom.id)/content/\(fileName)"
        print("🔍 Debug: Download URL: \(downloadURLString)")
        
        guard let url = URL(string: downloadURLString) else {
            throw SFTPError.downloadFailed
        }
        
        return url
    }
    
    private func checkStorageCapacity() throws {
        print("🔍 Debug: Checking storage capacity...")
        
        // Get ROM size from details or estimate
        let requiredBytes: Int64
        
        // Try to get accurate file size from selected files
        if !selectedFilesList.isEmpty {
            requiredBytes = selectedFilesList.reduce(0) { $0 + $1.fileSizeBytes }
        } else {
            // Use estimation for now - could be improved with async ROM details fetching
            requiredBytes = estimateRomSize()
            print("⚠️ Using ROM size estimate: \(ByteCountFormatter.string(fromByteCount: requiredBytes, countStyle: .file))")
        }
        
        // Check available storage using use cases
        if !sftpUseCases.checkAvailableStorage(requiredBytes: requiredBytes) {
            let availableBytes = sftpUseCases.getAvailableStorageCapacity() ?? 0
            let requiredBytesWithBuffer = Int64(Double(requiredBytes) * 1.2)
            throw SFTPError.insufficientStorage(required: requiredBytesWithBuffer, available: availableBytes)
        }
        
        print("✅ Debug: Sufficient storage available - \(sftpUseCases.getFormattedAvailableCapacity())")
    }
    
    private func estimateRomSize() -> Int64 {
        // ROM size estimation based on platform/name patterns
        let romName = rom.name.lowercased()
        
        // Large ROM patterns (CD-based systems)
        if romName.contains("cd") || romName.contains("iso") || romName.contains("chd") {
            return 700 * 1024 * 1024  // 700MB estimate for CD ROMs
        }
        
        // DVD-based systems
        if romName.contains("dvd") || romName.contains("wii") || romName.contains("ps2") {
            return 4 * 1024 * 1024 * 1024  // 4GB estimate for DVD ROMs
        }
        
        // Cartridge-based systems
        return 32 * 1024 * 1024  // 32MB estimate for cartridge ROMs
    }
    
    
    var canUpload: Bool {
        selectedConnection != nil && targetPath != nil && !isUploading && !selectedFiles.isEmpty
    }
    
    var storageWarning: String? {
        guard let availableBytes = sftpUseCases.getAvailableStorageCapacity() else {
            return nil
        }
        
        let requiredBytes: Int64
        if !selectedFilesList.isEmpty {
            requiredBytes = selectedFilesList.reduce(0) { $0 + $1.fileSizeBytes }
        } else {
            requiredBytes = estimateRomSize()
        }
        
        let requiredBytesWithBuffer = Int64(Double(requiredBytes) * 1.2)
        
        if availableBytes < requiredBytesWithBuffer {
            let availableStr = ByteCountFormatter.string(fromByteCount: availableBytes, countStyle: .file)
            let requiredStr = ByteCountFormatter.string(fromByteCount: requiredBytesWithBuffer, countStyle: .file)
            return "⚠️ Low storage: \(availableStr) available, \(requiredStr) needed"
        }
        
        return nil
    }
    
    var uploadProgressText: String {
        if totalBytes > 0 {
            let formatter = ByteCountFormatter()
            formatter.countStyle = .file
            let uploadedText = formatter.string(fromByteCount: uploadedBytes)
            let totalText = formatter.string(fromByteCount: totalBytes)
            return "\(uploadedText) / \(totalText)"
        }
        return "Preparing..."
    }
}
