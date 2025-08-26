import Foundation

class SFTPUseCases {
    private let repository: SFTPRepositoryProtocol
    private let connectionManager: SFTPConnectionManager
    private let fileSystemUseCases: FileSystemUseCases
    
    init(
        repository: SFTPRepositoryProtocol = SFTPRepository(), 
        connectionManager: SFTPConnectionManager = SFTPConnectionManager.shared,
        fileSystemUseCases: FileSystemUseCases = FileSystemUseCases()
    ) {
        self.repository = repository
        self.connectionManager = connectionManager
        self.fileSystemUseCases = fileSystemUseCases
    }
    
    func getAllConnections() -> [SFTPConnection] {
        return repository.getAllConnections()
    }
    
    func saveConnection(_ connection: SFTPConnection, credentials: SFTPCredentials) throws {
        try repository.saveConnection(connection, credentials: credentials)
    }
    
    func deleteConnection(_ connection: SFTPConnection) throws {
        try repository.deleteConnection(connection)
    }
    
    func testConnection(_ connection: SFTPConnection) async -> Bool {
        let status = await connectionManager.checkConnectionStatus(for: connection, forceRefresh: true)
        return status == .connected
    }
    
    func listDirectory(at path: String, connection: SFTPConnection) async throws -> [SFTPDirectoryItem] {
        return try await connectionManager.listDirectory(at: path, connection: connection)
    }
    
    func uploadFile(from localPath: String, to remotePath: String, connection: SFTPConnection, progressHandler: @escaping (Int64, Int64) -> Void) async throws {
        try await connectionManager.uploadFile(from: localPath, to: remotePath, connection: connection, progressHandler: progressHandler)
    }
    
    func getFavoriteDirectories(for connectionId: UUID) -> [String] {
        return repository.getFavoriteDirectories(for: connectionId)
    }
    
    func addFavoriteDirectory(_ path: String, for connectionId: UUID) throws {
        try repository.addFavoriteDirectory(path, for: connectionId)
    }
    
    func removeFavoriteDirectory(_ path: String, for connectionId: UUID) throws {
        try repository.removeFavoriteDirectory(path, for: connectionId)
    }
    
    // MARK: - Connection Status
    
    func checkConnectionStatus(for connection: SFTPConnection, forceRefresh: Bool = false) async -> ConnectionStatus {
        return await connectionManager.checkConnectionStatus(for: connection, forceRefresh: forceRefresh)
    }
    
    func checkAllConnectionStatuses(for connections: [SFTPConnection], forceRefresh: Bool = false) async {
        await connectionManager.checkAllConnectionStatuses(for: connections, forceRefresh: forceRefresh)
    }
    
    func clearConnectionCache() {
        connectionManager.clearCache()
    }
    
    func clearConnectionCache(for connection: SFTPConnection) {
        connectionManager.clearCache(for: connection)
    }
    
    // MARK: - File System Operations
    
    func getTemporaryFilePath(for fileName: String) -> String {
        return fileSystemUseCases.temporaryFilePath(for: fileName)
    }
    
    func checkAvailableStorage(requiredBytes: Int64) -> Bool {
        return fileSystemUseCases.hasEnoughStorage(requiredBytes: requiredBytes, safetyBufferPercent: 0.2)
    }
    
    func getAvailableStorageCapacity() -> Int64? {
        return fileSystemUseCases.availableStorageCapacity()
    }
    
    func getFormattedAvailableCapacity() -> String {
        return fileSystemUseCases.formattedAvailableCapacity()
    }
    
    func getFileSize(at path: String) throws -> Int64 {
        return try fileSystemUseCases.getFileSize(at: path)
    }
    
    func cleanupTemporaryFile(at path: String) {
        try? fileSystemUseCases.deleteFile(at: path)
    }
    
    // MARK: - Default Connection Management
    
    func getDefaultConnection() -> SFTPConnection? {
        return repository.getDefaultConnection()
    }
    
    func setDefaultConnection(_ connection: SFTPConnection) throws {
        try repository.setDefaultConnection(connection)
    }
    
    // MARK: - Connection Validation
    
    func testConnectionWithCredentials(_ connection: SFTPConnection, credentials: SFTPCredentials) async -> Bool {
        do {
            let service = SFTPService()
            return try await service.testConnectionWithCredentials(connection, credentials: credentials)
        } catch {
            return false
        }
    }
    
    func testConnection(_ connection: SFTPConnection, credentials: SFTPCredentials) async throws -> Bool {
        let service = SFTPService()
        return try await service.testConnectionWithCredentials(connection, credentials: credentials)
    }
    
    func createDirectory(at path: String, connection: SFTPConnection) async throws {
        try await connectionManager.createDirectory(at: path, connection: connection)
    }
    
    func getCredentials(for connectionId: UUID) -> SFTPCredentials? {
        return repository.getCredentials(for: connectionId)
    }
}