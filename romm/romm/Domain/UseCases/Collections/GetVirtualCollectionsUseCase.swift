//
//  GetVirtualCollectionsUseCase.swift
//  romm
//
//  Created by Ilyas Hallak on 27.08.25.
//

import Foundation

class GetVirtualCollectionsUseCase {
    private let collectionsRepository: CollectionsRepositoryProtocol
    
    init(collectionsRepository: CollectionsRepositoryProtocol) {
        self.collectionsRepository = collectionsRepository
    }
    
    func execute(type: String, limit: Int? = nil) async throws -> [VirtualCollection] {
        return try await collectionsRepository.getVirtualCollections(type: type, limit: limit)
    }
}