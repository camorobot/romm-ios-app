//
//  CollectionsRepository.swift
//  romm
//
//  Created by Ilyas Hallak on 10.08.25.
//

import Foundation

class CollectionsRepository: CollectionsRepositoryProtocol {
    private let apiClient: RommAPIClientProtocol
    private let logger = Logger.data
    
    init(apiClient: RommAPIClientProtocol = RommAPIClient.shared) {
        self.apiClient = apiClient
    }
    
    func getCollections() async throws -> [Collection] {
        logger.info("Getting collections")
        
        do {
            let apiCollections = try await apiClient.get("api/collections", responseType: [CollectionSchema].self)
            let domainCollections = apiCollections.mapToDomain()
            
            logger.info("Retrieved \(domainCollections.count) collections")
            return domainCollections
        } catch {
            logger.error("Error getting collections: \(error)")
            throw CollectionError.networkError
        }
    }
    
    func getVirtualCollections(type: String, limit: Int? = nil) async throws -> [VirtualCollection] {
        logger.info("Getting virtual collections of type: \(type)")
        
        var path = "api/collections/virtual?type=\(type)"
        if let limit = limit {
            path += "&limit=\(limit)"
        }
        
        do {
            let apiCollections = try await apiClient.get(path, responseType: [VirtualCollectionSchema].self)
            let domainCollections = apiCollections.mapVirtualToDomain()
            
            logger.info("Retrieved \(domainCollections.count) virtual collections")
            return domainCollections
        } catch {
            logger.error("Error getting virtual collections: \(error)")
            throw CollectionError.networkError
        }
    }
    
    func getCollection(id: Int) async throws -> Collection {
        logger.info("Getting collection details for ID: \(id)")
        
        do {
            let apiCollection = try await apiClient.get("api/collections/\(id)", responseType: CollectionSchema.self)
            let domainCollection = CollectionMapper.mapFromAPI(apiCollection)
            
            logger.info("Retrieved collection: \(domainCollection.name)")
            return domainCollection
        } catch {
            logger.error("Error getting collection details: \(error)")
            throw CollectionError.networkError
        }
    }
    
    func getVirtualCollection(id: String) async throws -> VirtualCollection {
        logger.info("Getting virtual collection details for ID: \(id)")
        
        do {
            let apiCollection = try await apiClient.get("api/collections/virtual/\(id)", responseType: VirtualCollectionSchema.self)
            let domainCollection = CollectionMapper.mapVirtualFromAPI(apiCollection)
            
            logger.info("Retrieved virtual collection: \(domainCollection.name)")
            return domainCollection
        } catch {
            logger.error("Error getting virtual collection details: \(error)")
            throw CollectionError.networkError
        }
    }
}

enum CollectionError: Error, LocalizedError {
    case networkError
    case collectionNotFound
    case invalidCollectionId
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network connection error"
        case .collectionNotFound:
            return "Collection not found"
        case .invalidCollectionId:
            return "Invalid collection ID"
        }
    }
}