//
//  CreateSFTPDirectoryUseCase.swift
//  romm
//
//  Created by Ilyas Hallak on 27.08.25.
//

import Foundation

class CreateSFTPDirectoryUseCase {
    private let connectionManager: SFTPConnectionManager
    
    init(connectionManager: SFTPConnectionManager = SFTPConnectionManager.shared) {
        self.connectionManager = connectionManager
    }
    
    func execute(at path: String, connection: SFTPConnection) async throws {
        try await connectionManager.createDirectory(at: path, connection: connection)
    }
}