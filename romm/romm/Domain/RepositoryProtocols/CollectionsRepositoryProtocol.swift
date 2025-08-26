//
//  CollectionsRepositoryProtocol.swift
//  romm
//
//  Created by Ilyas Hallak on 10.08.25.
//

import Foundation

protocol CollectionsRepositoryProtocol {
    func getCollections() async throws -> [Collection]
    func getVirtualCollections(type: String, limit: Int?) async throws -> [VirtualCollection]
    func getCollection(id: Int) async throws -> Collection
    func getVirtualCollection(id: String) async throws -> VirtualCollection
}