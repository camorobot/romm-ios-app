import Foundation
import Combine

struct TimeoutError: Error {
    let timeout: TimeInterval
}

func withTimeout<T>(_ timeout: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
    return try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask {
            return try await operation()
        }
        
        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
            throw TimeoutError(timeout: timeout)
        }
        
        guard let result = try await group.next() else {
            throw TimeoutError(timeout: timeout)
        }
        
        group.cancelAll()
        return result
    }
}

class SFTPConnectionManager: ObservableObject {
    static let shared = SFTPConnectionManager()
    
    private var sftpService: SFTPServiceProtocol?
    private var connectionStatusCache = [UUID: (status: ConnectionStatus, lastChecked: Date)]()
    private let cacheValidityDuration: TimeInterval = 30
    private let connectionTimeout: TimeInterval = 10
    
    @Published var connectionStatuses = [UUID: ConnectionStatus]()
    
    private init() {
        // Service will be injected later to avoid circular dependency
    }
    
    func configure(with sftpService: SFTPServiceProtocol) {
        self.sftpService = sftpService
    }
    
    func checkConnectionStatus(for connection: SFTPConnection, forceRefresh: Bool = false) async -> ConnectionStatus {
        let cacheKey: UUID = connection.id
        
        if !forceRefresh, 
           let cached = connectionStatusCache[cacheKey],
           Date().timeIntervalSince(cached.lastChecked) < cacheValidityDuration {
            await MainActor.run {
                self.connectionStatuses[cacheKey] = cached.status
            }
            return cached.status
        }
        
        await MainActor.run {
            self.connectionStatuses[cacheKey] = .connecting
        }
        
        let status: ConnectionStatus
        do {
            let isConnected = try await withTimeout(connectionTimeout) {
                guard let sftpService = self.sftpService else {
                    throw SFTPError.serviceNotConfigured
                }
                return try await sftpService.testConnection(connection)
            }
            status = isConnected ? .connected : .error
        } catch is TimeoutError {
            status = .error
        } catch {
            status = .error
        }
        
        // Explicitly ensure types are correct
        let statusEntry: (status: ConnectionStatus, lastChecked: Date) = (status: status, lastChecked: Date())
        connectionStatusCache.updateValue(statusEntry, forKey: cacheKey)        
        
        await MainActor.run {
            self.connectionStatuses[cacheKey] = status
        }
        
        return status
    }
    
    func checkAllConnectionStatuses(for connections: [SFTPConnection], forceRefresh: Bool = false) async {
        await withTaskGroup(of: Void.self) { group in
            for connection in connections {
                group.addTask {
                    await self.checkConnectionStatus(for: connection, forceRefresh: forceRefresh)
                }
            }
        }
    }
    
    func listDirectory(at path: String, connection: SFTPConnection) async throws -> [SFTPDirectoryItem] {
        guard let sftpService = sftpService else {
            throw SFTPError.serviceNotConfigured
        }
        return try await sftpService.listDirectory(at: path, connection: connection)
    }
    
    func uploadFile(
        from localPath: String,
        to remotePath: String,
        connection: SFTPConnection,
        progressHandler: @escaping (Int64, Int64) -> Void
    ) async throws {
        guard let sftpService = sftpService else {
            throw SFTPError.serviceNotConfigured
        }
        try await sftpService.uploadFile(
            from: localPath,
            to: remotePath,
            connection: connection,
            progressHandler: progressHandler
        )
    }
    
    func downloadFile(
        from remotePath: String,
        to localPath: String,
        connection: SFTPConnection,
        progressHandler: @escaping (Int64, Int64) -> Void
    ) async throws {
        guard let sftpService = sftpService else {
            throw SFTPError.serviceNotConfigured
        }
        try await sftpService.downloadFile(
            from: remotePath,
            to: localPath,
            connection: connection,
            progressHandler: progressHandler
        )
    }
    
    func createDirectory(at path: String, connection: SFTPConnection) async throws {
        guard let sftpService = sftpService else {
            throw SFTPError.serviceNotConfigured
        }
        try await sftpService.createDirectory(at: path, connection: connection)
    }
    
    func clearCache() {
        connectionStatusCache.removeAll()
        Task { @MainActor in
            self.connectionStatuses.removeAll()
        }
    }
    
    func clearCache(for connection: SFTPConnection) {
        let cacheKey: UUID = connection.id
        connectionStatusCache.removeValue(forKey: cacheKey)
        Task { @MainActor in
            self.connectionStatuses.removeValue(forKey: cacheKey)
        }
    }
}
