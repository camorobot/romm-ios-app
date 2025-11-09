//
//  UploadFileUseCase.swift
//  romm
//
//  Created by Ilyas Hallak on 27.08.25.
//

import Foundation

class UploadFileUseCase {
    private let connectionManager: SFTPConnectionManager
    
    init(connectionManager: SFTPConnectionManager) {
        self.connectionManager = connectionManager
    }
    
    func execute(from localPath: String, to remotePath: String, connection: SFTPConnection, progressHandler: @escaping @Sendable @MainActor (Int64, Int64) -> Void) async throws {
        try await connectionManager.uploadFile(from: localPath, to: remotePath, connection: connection, progressHandler: progressHandler)
    }
}