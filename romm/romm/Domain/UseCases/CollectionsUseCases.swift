//
//  CollectionsUseCases.swift
//  romm
//
//  Created by Ilyas Hallak on 10.08.25.
//

import Foundation

class GetCollectionsUseCase {
    private let collectionsRepository: CollectionsRepositoryProtocol
    
    init(collectionsRepository: CollectionsRepositoryProtocol) {
        self.collectionsRepository = collectionsRepository
    }
    
    func execute() async throws -> [Collection] {
        return try await collectionsRepository.getCollections()
    }
}

class GetVirtualCollectionsUseCase {
    private let collectionsRepository: CollectionsRepositoryProtocol
    
    init(collectionsRepository: CollectionsRepositoryProtocol) {
        self.collectionsRepository = collectionsRepository
    }
    
    func execute(type: String, limit: Int? = nil) async throws -> [VirtualCollection] {
        return try await collectionsRepository.getVirtualCollections(type: type, limit: limit)
    }
}