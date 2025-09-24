//
//  ClearConnectionCacheUseCase.swift
//  romm
//
//  Created by Ilyas Hallak on 27.08.25.
//

import Foundation

class ClearConnectionCacheUseCase {
    private let connectionManager: SFTPConnectionManager
    
    init(connectionManager: SFTPConnectionManager = SFTPConnectionManager.shared) {
        self.connectionManager = connectionManager
    }
    
    func execute() {
        connectionManager.clearCache()
    }
    
    func execute(for connection: SFTPConnection) {
        connectionManager.clearCache(for: connection)
    }
}