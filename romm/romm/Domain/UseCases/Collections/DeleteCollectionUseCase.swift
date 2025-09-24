//
//  DeleteCollectionUseCase.swift
//  romm
//
//  Created by Ilyas Hallak on 27.08.25.
//

import Foundation

class DeleteCollectionUseCase {
    private let collectionsRepository: CollectionsRepositoryProtocol
    
    init(collectionsRepository: CollectionsRepositoryProtocol) {
        self.collectionsRepository = collectionsRepository
    }
    
    func execute(collectionId: Int) async throws {
        guard collectionId > 0 else {
            throw CollectionError.invalidCollectionId
        }
        
        try await collectionsRepository.deleteCollection(id: collectionId)
    }
}