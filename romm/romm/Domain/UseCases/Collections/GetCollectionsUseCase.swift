//
//  GetCollectionsUseCase.swift
//  romm
//
//  Created by Ilyas Hallak on 27.08.25.
//

import Foundation

class GetCollectionsUseCase {
    private let collectionsRepository: CollectionsRepositoryProtocol
    
    init(collectionsRepository: CollectionsRepositoryProtocol) {
        self.collectionsRepository = collectionsRepository
    }
    
    func execute(limit: Int? = nil, offset: Int? = nil) async throws -> [Collection] {
        return try await collectionsRepository.getCollections(limit: limit, offset: offset)
    }
}