//
//  PlatformsRepository.swift
//  romm
//
//  Created by Ilyas Hallak on 06.08.25.
//

import Foundation

class PlatformsRepository: PlatformsRepositoryProtocol {
    private let logger = Logger.data
    private let apiClient: RommAPIClientProtocol
    
    init(apiClient: RommAPIClientProtocol = RommAPIClient.shared) {
        self.apiClient = apiClient
    }
    
    func getPlatforms() async throws -> [Platform] {
        logger.info("Getting platforms with authenticated request...")
        
        do {
            let apiPlatforms = try await apiClient.get("api/platforms", responseType: [PlatformSchema].self)
            let domainPlatforms = apiPlatforms.mapToDomain()
            
            logger.info("Retrieved \(domainPlatforms.count) platforms")
            return domainPlatforms
        } catch {
            logger.error("Error getting platforms: \(error)")
            throw PlatformError.networkError
        }
    }
    
    func addPlatform(name: String, slug: String) async throws -> Platform {
        logger.info("Adding platform: \(name)")
        
        struct AddPlatformRequest: Codable {
            let name: String
            let slug: String
        }
        
        do {
            let request = AddPlatformRequest(name: name, slug: slug)
            let apiPlatform = try await apiClient.post(
                "api/platforms", 
                body: request, 
                responseType: PlatformSchema.self
            )
            let domainPlatform = PlatformMapper.mapFromAPI(apiPlatform)
            
            logger.info("Platform added: \(domainPlatform.name)")
            return domainPlatform
        } catch {
            logger.error("Error adding platform: \(error)")
            throw PlatformError.networkError
        }
    }
    
    func deletePlatform(id: Int) async throws {
        logger.info("Deleting platform ID: \(id)")
        
        do {
            _ = try await apiClient.delete("api/platforms/\(id)")
            logger.info("Platform deleted: \(id)")
        } catch {
            logger.error("Error deleting platform: \(error)")
            throw PlatformError.networkError
        }
    }
}