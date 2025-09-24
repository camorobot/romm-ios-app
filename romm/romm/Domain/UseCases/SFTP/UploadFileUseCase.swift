//
//  UploadFileUseCase.swift
//  romm
//
//  Created by Ilyas Hallak on 27.08.25.
//

import Foundation

class UploadFileUseCase {
    private let connectionManager: SFTPConnectionManager
    
    init(connectionManager: SFTPConnectionManager = SFTPConnectionManager.shared) {
        self.connectionManager = connectionManager
    }
    
    func execute(from localPath: String, to remotePath: String, connection: SFTPConnection, progressHandler: @escaping (Int64, Int64) -> Void) async throws {
        try await connectionManager.uploadFile(from: localPath, to: remotePath, connection: connection, progressHandler: progressHandler)
    }
}