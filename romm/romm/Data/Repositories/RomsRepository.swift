//
//  RomsRepository.swift
//  romm
//
//  Created by Ilyas Hallak on 06.08.25.
//

import Foundation

class RomsRepository: RomsRepositoryProtocol {
    private let apiClient: RommAPIClientProtocol
    private let logger = Logger.data
    
    init(apiClient: RommAPIClientProtocol = RommAPIClient.shared) {
        self.apiClient = apiClient
    }
    
    func getRoms(platformId: Int?, searchTerm: String?, limit: Int, offset: Int = 0, char: String? = nil, orderBy: String? = nil, orderDir: String? = nil, collectionId: Int? = nil) async throws -> PaginatedRomsResponse {
        logger.info("🕹️ Getting ROMs - Platform: \(platformId?.description ?? "all"), Collection: \(collectionId?.description ?? "none"), Search: \(searchTerm ?? "none"), Limit: \(limit), Offset: \(offset), Char: \(char ?? "none")")
        
        var path = "api/roms?limit=\(limit)&offset=\(offset)"
        
        // Add sorting parameters
        let finalOrderBy = orderBy ?? "name"
        let finalOrderDir = orderDir ?? "asc"
        path += "&order_by=\(finalOrderBy)&order_dir=\(finalOrderDir)&group_by_meta_id=true"
        
        if let platformId = platformId {
            path += "&platform_id=\(platformId)"
        }
        
        if let collectionId = collectionId {
            path += "&collection_id=\(collectionId)"
        }
        
        if let searchTerm = searchTerm, !searchTerm.isEmpty {
            let encodedTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            path += "&search=\(encodedTerm)"
        }
        
        if let char = char, !char.isEmpty {
            let encodedChar = char.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            path += "&char=\(encodedChar)"
        }
        
        do {
            let romsPage = try await apiClient.get(path, responseType: CustomLimitOffsetPageSimpleRomSchema.self)
            let domainRoms = romsPage.items.mapToDomain()
            
            let paginatedResponse = PaginatedRomsResponse(
                roms: domainRoms,
                total: romsPage.total ?? 0,
                limit: romsPage.limit ?? limit,
                offset: romsPage.offset ?? offset,
                charIndex: romsPage.charIndex
            )
            
            logger.info("✅ Retrieved \(domainRoms.count) ROMs (Total: \(paginatedResponse.total), HasMore: \(paginatedResponse.hasMore))")
            return paginatedResponse
        } catch {
            logger.error("❌ Error getting ROMs: \(error)")
            throw RomError.networkError
        }
    }
    
    func getRomDetails(id: Int) async throws -> RomDetails {
        logger.info("📄 Getting ROM details for ID: \(id)")
        
        do {
            let apiRom = try await apiClient.get("api/roms/\(id)", responseType: DetailedRomSchema.self)
            let domainRom = RomMapper.mapDetailsFromAPI(apiRom)
            
            logger.info("✅ Retrieved ROM details: \(domainRom.name)")
            return domainRom
        } catch {
            logger.error("❌ Error getting ROM details: \(error)")
            throw RomError.networkError
        }
    }
    
    func toggleRomFavorite(romId: Int, isFavorite: Bool) async throws {
        logger.info("❤️ Toggling favorite for ROM \(romId): \(isFavorite)")
        
        do {
            // ROM favorites are managed through the Favourites collection (usually ID 2)
            // First, get the current Favourites collection to get existing ROM IDs
            let favouritesCollection = try await apiClient.get("api/collections/2", responseType: CollectionSchema.self)
            var currentRomIds = Array(favouritesCollection.romIds)
            
            // Add or remove the ROM from the favorites collection
            if isFavorite {
                if !currentRomIds.contains(romId) {
                    currentRomIds.append(romId)
                }
            } else {
                currentRomIds.removeAll { $0 == romId }
            }
            
            // Create multipart form data manually
            let boundary = "----RommAppBoundary\(UUID().uuidString)"
            var formData = Data()
            
            // Helper function to add form field
            func addFormField(_ name: String, _ value: String) {
                formData.append("--\(boundary)\r\n".data(using: .utf8)!)
                formData.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
                formData.append("\(value)\r\n".data(using: .utf8)!)
            }
            
            // Add form fields
            addFormField("name", favouritesCollection.name)
            addFormField("description", favouritesCollection.description ?? "")
            addFormField("url_cover", favouritesCollection.urlCover ?? "")
            addFormField("rom_ids", "[\(currentRomIds.map(String.init).joined(separator: ","))]")
            
            // Close boundary
            formData.append("--\(boundary)--\r\n".data(using: .utf8)!)
            
            // Make request via the API client with custom multipart data
            let path = "api/collections/2?is_public=\(favouritesCollection.isPublic)&remove_cover=false"
            _ = try await makeMultipartRequest(path: path, boundary: boundary, formData: formData)
            
            logger.info("✅ ROM favorite toggled: \(romId)")
        } catch {
            logger.error("❌ Error toggling ROM favorite: \(error)")
            throw RomError.networkError
        }
    }
    
    private func makeMultipartRequest(path: String, boundary: String, formData: Data) async throws -> Data {
        // This is a custom multipart request since the standard apiClient doesn't support it
        // We'll use the existing APIClient pattern but with custom headers
        
        guard let serverURL = TokenProvider().getServerURL(),
              let username = TokenProvider().getUsername(),
              let password = TokenProvider().getPassword() else {
            throw RomError.networkError
        }
        
        let fullURL = "\(serverURL)/\(path)"
        guard let url = URL(string: fullURL) else {
            throw RomError.networkError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Add Basic Auth
        let loginString = "\(username):\(password)"
        guard let loginData = loginString.data(using: .utf8) else {
            throw RomError.networkError
        }
        let base64LoginString = loginData.base64EncodedString()
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = formData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw RomError.networkError
        }
        
        return data
    }
    
    func isRomFavorite(romId: Int) async throws -> Bool {
        logger.info("🔍 Checking favorite status for ROM \(romId)")
        
        do {
            // Get the Favourites collection to check if ROM is included
            let favouritesCollection = try await apiClient.get("api/collections/2", responseType: CollectionSchema.self)
            let isFavorite = favouritesCollection.romIds.contains(romId)
            
            logger.info("✅ ROM \(romId) favorite status: \(isFavorite)")
            return isFavorite
        } catch {
            logger.error("❌ Error checking ROM favorite status: \(error)")
            // If we can't check favorites, assume false rather than throwing
            return false
        }
    }
    
    func searchRoms(query: String) async throws -> [Rom] {
        // Search ROMs using the normal getRoms API with search term
        let response = try await getRoms(platformId: nil, searchTerm: query, limit: 50, offset: 0, collectionId: nil)
        return response.roms
    }
}