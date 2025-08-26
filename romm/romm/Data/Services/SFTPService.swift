import Foundation
import mft

struct SFTPServiceItem {
    let filename: String
    let size: UInt64
    let uid: UInt32
    let createTime: Date
    let isDirectory: Bool
    let isSymlink: Bool
}

class MFTSftpConnectionFacade {
    let hostname: String
    let port: Int32
    let username: String
    let password: String
    
    private let mft: MFTSftpConnection
    
    
    init(hostname: String, port: Int32, username: String, password: String) {
        self.hostname = hostname
        self.port = port
        self.username = username
        self.password = password
        
        self.mft = .init(hostname: hostname, port: Int(port), username: username, password: password)
    }
    
    func connect() throws {
        do {
            try mft.connect()
        } catch {
            throw SFTPError.connectionFailed
        }
    }
    
    func authenticate() throws {
        do {
            try mft.authenticate()
        } catch {
            throw SFTPError.authenticationFailed
        }
    }
    
    func disconnect() {
        mft.disconnect()
    }
    
    func contentsOfDirectory(atPath path: String, maxItems: Int) throws -> [SFTPDirectoryItem] {
        do {
            return try mft.contentsOfDirectory(atPath: path, maxItems: Int64(maxItems)).map { item in
                SFTPDirectoryItem(name: item.filename, path: item.filename, isDirectory: item.isDirectory, size: Int64(item.size), modificationDate: item.atime)
            }
        } catch {
            throw SFTPError.pathNotFound
        }
    }
    
    func write(stream: InputStream, toFileAtPath path: String, append: Bool, progress: @escaping (UInt64) -> Bool) throws {
        do {
            try mft.write(stream: stream, toFileAtPath: path, append: append, progress: progress)
        } catch {
            throw SFTPError.uploadFailed
        }
    }
    
    func read(fromFileAtPath path: String, toStream: OutputStream, progress: @escaping (Int) -> Bool) throws {
        throw SFTPError.downloadFailed
    }
    
    func createDirectory(atPath path: String) throws {
        do {
            try mft.createDirectory(atPath: path)
        } catch {
            throw SFTPError.pathNotFound
        }
    }
    
    func removeFile(atPath path: String) throws {
        do {
            try mft.createDirectory(atPath: path)
        } catch {
            throw SFTPError.pathNotFound
        }
    }
}

enum SFTPError: LocalizedError {
    case connectionFailed
    case authenticationFailed
    case pathNotFound
    case uploadFailed
    case downloadFailed
    case connectionTimeout
    case invalidCredentials
    case networkError(String)
    case insufficientStorage(required: Int64, available: Int64)
    case serviceNotConfigured
    
    var errorDescription: String? {
        switch self {
        case .connectionFailed:
            return "Failed to connect to SFTP server"
        case .authenticationFailed:
            return "Authentication failed"
        case .pathNotFound:
            return "Path not found on server"
        case .uploadFailed:
            return "Failed to upload file"
        case .downloadFailed:
            return "Failed to download file"
        case .connectionTimeout:
            return "Connection timeout"
        case .invalidCredentials:
            return "Invalid credentials"
        case .networkError(let message):
            return "Network error: \(message)"
        case .insufficientStorage(let required, let available):
            let requiredStr = ByteCountFormatter.string(fromByteCount: required, countStyle: .file)
            let availableStr = ByteCountFormatter.string(fromByteCount: available, countStyle: .file)
            return "Not enough storage space. Required: \(requiredStr), Available: \(availableStr)"
        case .serviceNotConfigured:
            return "SFTP service not configured"
        }
    }
}

struct SFTPDirectoryItem: Identifiable {
    let id: UUID = UUID()
    let name: String
    let path: String
    let isDirectory: Bool
    let size: Int64?
    let modificationDate: Date?
}

protocol SFTPServiceProtocol {
    func testConnection(_ connection: SFTPConnection) async throws -> Bool
    func testConnectionWithCredentials(_ connection: SFTPConnection, credentials: SFTPCredentials) async throws -> Bool
    func listDirectory(at path: String, connection: SFTPConnection) async throws -> [SFTPDirectoryItem]
    func uploadFile(from localPath: String, to remotePath: String, connection: SFTPConnection, progressHandler: @escaping (Int64, Int64) -> Void) async throws
    func downloadFile(from remotePath: String, to localPath: String, connection: SFTPConnection, progressHandler: @escaping (Int64, Int64) -> Void) async throws
    func createDirectory(at path: String, connection: SFTPConnection) async throws
    func deleteFile(at path: String, connection: SFTPConnection) async throws
}

class SFTPService: SFTPServiceProtocol {
    private let repository: SFTPRepositoryProtocol
    
    init(repository: SFTPRepositoryProtocol = SFTPRepository()) {
        self.repository = repository
    }
    
    private func createConnection(_ connection: SFTPConnection, with credentials: SFTPCredentials? = nil) -> MFTSftpConnectionFacade {
        let creds = credentials ?? repository.getCredentials(for: connection.id)
        
        return MFTSftpConnectionFacade(
            hostname: connection.host,
            port: Int32(connection.port),
            username: connection.username,
            password: creds?.password ?? ""
        )
    }
    
    private func authenticateConnection(_ sftp: MFTSftpConnectionFacade, connection: SFTPConnection, credentials: SFTPCredentials? = nil) throws {
        let creds = credentials ?? repository.getCredentials(for: connection.id)
        
        switch connection.authenticationType {
        case .password:
            guard let creds = creds, let password = creds.password, !password.isEmpty else {
                throw SFTPError.invalidCredentials
            }
            try sftp.authenticate()
            
        case .sshKey:
            guard let creds = creds, let privateKey = creds.privateKey, !privateKey.isEmpty else {
                throw SFTPError.invalidCredentials
            }
            // For SSH key authentication, we would need to implement key-based auth
            // This is a placeholder for the actual implementation
            throw SFTPError.authenticationFailed
            
        case .passwordWithKey:
            guard let creds = creds, 
                  let password = creds.password, !password.isEmpty,
                  let privateKey = creds.privateKey, !privateKey.isEmpty else {
                throw SFTPError.invalidCredentials
            }
            // For combined auth, we would need to implement both
            // This is a placeholder for the actual implementation
            throw SFTPError.authenticationFailed
        }
    }
    
    func testConnection(_ connection: SFTPConnection) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            Task {
                do {
                    let sftp = createConnection(connection)
                    
                    try sftp.connect()
                    defer { sftp.disconnect() }
                    
                    try authenticateConnection(sftp, connection: connection)
                    
                    continuation.resume(returning: true)
                } catch {
                    continuation.resume(throwing: mapMFTError(error))
                }
            }
        }
    }
    
    func testConnectionWithCredentials(_ connection: SFTPConnection, credentials: SFTPCredentials) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            Task {
                do {
                    let sftp = createConnection(connection, with: credentials)
                    
                    try sftp.connect()
                    defer { sftp.disconnect() }
                    
                    try authenticateConnection(sftp, connection: connection, credentials: credentials)
                    
                    continuation.resume(returning: true)
                } catch {
                    continuation.resume(throwing: mapMFTError(error))
                }
            }
        }
    }
    
    func listDirectory(at path: String, connection: SFTPConnection) async throws -> [SFTPDirectoryItem] {
        return try await withCheckedThrowingContinuation { continuation in
            Task {
                do {
                    let sftp = createConnection(connection)
                    
                    try sftp.connect()
                    defer { sftp.disconnect() }
                    
                    try sftp.authenticate()
                    
                    let contents = try sftp.contentsOfDirectory(atPath: path, maxItems: 1000)
                    
                    let items = contents.compactMap { item -> SFTPDirectoryItem? in
                        let fullPath = path.hasSuffix("/") ? "\(path)\(item.name)" : "\(path)/\(item.name)"
                        
                        return SFTPDirectoryItem(
                            name: item.name,
                            path: fullPath,
                            isDirectory: item.isDirectory,
                            size: item.size,
                            modificationDate: item.modificationDate
                        )
                    }
                    
                    continuation.resume(returning: items)
                } catch {
                    continuation.resume(throwing: mapMFTError(error))
                }
            }
        }
    }
    
    func uploadFile(from localPath: String, to remotePath: String, connection: SFTPConnection, progressHandler: @escaping (Int64, Int64) -> Void) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            Task {
                do {
                    let sftp = createConnection(connection)
                    
                    try sftp.connect()
                    defer { sftp.disconnect() }
                    
                    try sftp.authenticate()
                    
                    guard let inputStream = InputStream(fileAtPath: localPath) else {
                        throw SFTPError.uploadFailed
                    }
                    
                    let fileManager = FileManager.default
                    let fileAttributes = try fileManager.attributesOfItem(atPath: localPath)
                    let fileSize = fileAttributes[.size] as? Int64 ?? 0
                    
                    var uploadedBytes: Int64 = 0
                    var uploadCompleted = false
                    
                    print("🔍 SFTP Upload: Starting upload of file size: \(fileSize) bytes")
                    
                    try sftp.write(stream: inputStream, toFileAtPath: remotePath, append: false) { bytesWritten in
                        // Stop processing if upload is already marked as completed
                        guard !uploadCompleted else {
                            print("🔍 SFTP Upload: Ignoring progress update - upload completed")
                            return false // Signal to stop progress callbacks
                        }
                        
                        // bytesWritten is UInt64 from mft library
                        let currentBytes = Int64(bytesWritten)
                        uploadedBytes += currentBytes
                        
                        // Debug the raw values from mft library
                        print("🔍 SFTP Upload: mft reported bytesWritten=\(bytesWritten) (UInt64), converted=\(currentBytes), cumulative=\(uploadedBytes), fileSize=\(fileSize)")
                        
                        // Ensure uploaded bytes don't exceed file size
                        let clampedUploaded = min(uploadedBytes, fileSize)
                        
                        // Check if upload is complete
                        if clampedUploaded >= fileSize {
                            uploadCompleted = true
                            print("🔍 SFTP Upload: Upload completed, stopping progress updates")
                        }
                        
                        DispatchQueue.main.async {
                            progressHandler(clampedUploaded, fileSize)
                        }
                        
                        // Return false to stop progress callbacks if completed
                        return !uploadCompleted
                    }
                    
                    print("🔍 SFTP Upload: Upload completed")
                    
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: mapMFTError(error))
                }
            }
        }
    }
    
    func downloadFile(from remotePath: String, to localPath: String, connection: SFTPConnection, progressHandler: @escaping (Int64, Int64) -> Void) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            Task {
                do {
                    let sftp = createConnection(connection)
                    
                    try sftp.connect()
                    defer { sftp.disconnect() }
                    
                    try sftp.authenticate()
                    
                    guard let outputStream = OutputStream(toFileAtPath: localPath, append: false) else {
                        throw SFTPError.downloadFailed
                    }
                    
                    var downloadedBytes: Int64 = 0
                    let fileSize: Int64 = 0
                    
                    try sftp.read(fromFileAtPath: remotePath, toStream: outputStream) { bytesRead in
                        downloadedBytes += Int64(bytesRead)
                        DispatchQueue.main.async {
                            progressHandler(downloadedBytes, fileSize)
                        }
                        return true
                    }
                    
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: mapMFTError(error))
                }
            }
        }
    }
    
    func createDirectory(at path: String, connection: SFTPConnection) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            Task {
                do {
                    let sftp = createConnection(connection)
                    
                    try sftp.connect()
                    defer { sftp.disconnect() }
                    
                    try sftp.authenticate()
                    
                    try sftp.createDirectory(atPath: path)
                    
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: mapMFTError(error))
                }
            }
        }
    }
    
    func deleteFile(at path: String, connection: SFTPConnection) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            Task {
                do {
                    let sftp = createConnection(connection)
                    
                    try sftp.connect()
                    defer { sftp.disconnect() }
                    
                    try sftp.authenticate()
                    
                    try sftp.removeFile(atPath: path)
                    
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: mapMFTError(error))
                }
            }
        }
    }
    
    private func mapMFTError(_ error: Error) -> SFTPError {
        let errorString = error.localizedDescription.lowercased()
        
        if errorString.contains("connect") || errorString.contains("connection") {
            return .connectionFailed
        } else if errorString.contains("auth") {
            return .authenticationFailed
        } else if errorString.contains("timeout") {
            return .connectionTimeout
        } else if errorString.contains("path") || errorString.contains("directory") {
            return .pathNotFound
        } else {
            return .networkError(error.localizedDescription)
        }
    }
}
