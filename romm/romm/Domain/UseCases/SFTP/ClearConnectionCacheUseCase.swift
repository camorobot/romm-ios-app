//
//  ClearConnectionCacheUseCase.swift
//  romm
//
//  Created by Ilyas Hallak on 27.08.25.
//

import Foundation

class ClearConnectionCacheUseCase {
    private let connectionManager: SFTPConnectionManager
    
    init(connectionManager: SFTPConnectionManager) {
        self.connectionManager = connectionManager
    }
    
    @MainActor
    func execute() {
        connectionManager.clearCache()
    }

    @MainActor
    func execute(for connection: SFTPConnection) {
        connectionManager.clearCache(for: connection)
    }
}