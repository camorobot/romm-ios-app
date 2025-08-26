//
//  RommAPIClient.swift
//  romm
//
//  Created by Ilyas Hallak on 06.08.25.
//

import Foundation
import os

protocol RommAPIClientProtocol {
    func makeRequest<T: Codable>(path: String, method: HTTPMethod, body: Data?, responseType: T.Type) async throws -> T
    func makeRequest(path: String, method: HTTPMethod, body: Data?) async throws -> Data
    func get<T: Codable>(_ path: String, responseType: T.Type) async throws -> T
    func get(_ path: String) async throws -> Data
    func post<RequestBody: Codable, ResponseType: Codable>(_ path: String, body: RequestBody, responseType: ResponseType.Type) async throws -> ResponseType
    func post(_ path: String, body: Data?) async throws -> Data
    func put<RequestBody: Codable, ResponseType: Codable>(_ path: String, body: RequestBody, responseType: ResponseType.Type) async throws -> ResponseType
    func put<RequestBody: Codable>(_ path: String, body: RequestBody) async throws -> Data
    func put(_ path: String, body: Data?) async throws -> Data
    func delete(_ path: String) async throws -> Data
    func getRomManual(romId: Int) async throws -> Manual?
    func getManualPDFData(manualURL: String) async throws -> Data
    func getRomDetails(id: Int) async throws -> DetailedRomSchema
}

enum APIClientError: LocalizedError {
    case noConfiguration
    case noCredentials
    case invalidURL(String)
    case authenticationRequired
    case networkError(Error)
    case invalidResponse(Int, String)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .noConfiguration:
            return "No configuration found - please complete setup"
        case .noCredentials:
            return "No authentication credentials found - please setup login"
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .authenticationRequired:
            return "Authentication required - please check credentials"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse(let code, let message):
            return "Server error (\(code)): \(message)"
        case .decodingError(let error):
            return "Data decoding error: \(error.localizedDescription)"
        }
    }
}

class RommAPIClient: RommAPIClientProtocol {
    static let shared = RommAPIClient()
    
    private let tokenProvider: TokenProviderProtocol
    private let urlSession: URLSession
    private let logger = Logger.network
    
    init(tokenProvider: TokenProviderProtocol = TokenProvider(),
         urlSession: URLSession = URLSession.shared) {
        self.tokenProvider = tokenProvider
        self.urlSession = urlSession
        setupAPIConfiguration()
    }
    
    private func setupAPIConfiguration() {
        // Update base URL from token provider when available
        if let baseURL = tokenProvider.getServerURL() {
            rommAPI.basePath = baseURL
        }
    }
    
    
    // MARK: - New Async/Await API Methods
    
    func makeRequest<T: Codable>(path: String, method: HTTPMethod, body: Data? = nil, responseType: T.Type) async throws -> T {
        let data = try await makeRequest(path: path, method: method, body: body)
        
        do {
            let decodedResponse = try JSONDecoder().decode(responseType, from: data)
            return decodedResponse
        } catch {
            // Log more details about the failed decoding
            let responsePreview = String(data: data.prefix(200), encoding: .utf8) ?? "Binary data"
            logger.error("Decoding error for \(responseType) at path \(path): \(error)")
            logger.error("Response data preview: \(responsePreview)")
            throw APIClientError.decodingError(error)
        }
    }
    
    func makeRequest(path: String, method: HTTPMethod, body: Data? = nil) async throws -> Data {
        let measurement = PerformanceMeasurement(operation: "\(method.rawValue) \(path)")
        logger.logNetworkRequest(method: method.rawValue, url: path)
        
        // Update configuration from token provider
        setupAPIConfiguration()
        
        // Build full URL
        let url = try buildURL(path: path)
        
        // Get credentials for Basic Auth
        guard let username = tokenProvider.getUsername(),
              let password = tokenProvider.getPassword() else {
            logger.error("No authentication credentials available")
            throw APIClientError.noCredentials
        }
        
        // Create Basic Auth header
        let loginString = "\(username):\(password)"
        guard let loginData = loginString.data(using: .utf8) else {
            logger.error("Failed to encode credentials")
            throw APIClientError.authenticationRequired
        }
        let base64LoginString = loginData.base64EncodedString()
        
        // Create authenticated request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30.0
        
        if let body = body {
            request.httpBody = body
            logger.debug("Request body size: \(body.count) bytes")
        }
        
        logger.debug("Request URL: \(url.absoluteString)")
        logger.debug("Using Basic Auth for user: \(username)")
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("Invalid response type")
                throw APIClientError.networkError(URLError(.badServerResponse))
            }
            
            logger.logNetworkRequest(method: method.rawValue, url: path, statusCode: httpResponse.statusCode)
            logger.debug("Response data size: \(data.count) bytes")
            
            // Handle HTTP status codes
            switch httpResponse.statusCode {
            case 200...299:
                measurement.end()
                return data
                
            case 401:
                logger.warning("Authentication failed - invalid credentials")
                throw APIClientError.authenticationRequired
                
            case 400...499:
                let errorMessage = String(data: data, encoding: .utf8) ?? "Client error"
                logger.error("Client error (\(httpResponse.statusCode)): \(errorMessage)")
                throw APIClientError.invalidResponse(httpResponse.statusCode, errorMessage)
                
            case 500...599:
                let errorMessage = String(data: data, encoding: .utf8) ?? "Server error"
                logger.error("Server error (\(httpResponse.statusCode)): \(errorMessage)")
                throw APIClientError.invalidResponse(httpResponse.statusCode, errorMessage)
                
            default:
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                logger.error("Unexpected status (\(httpResponse.statusCode)): \(errorMessage)")
                throw APIClientError.invalidResponse(httpResponse.statusCode, errorMessage)
            }
            
        } catch let error as URLError {
            logger.logNetworkError(method: method.rawValue, url: path, error: error)
            throw APIClientError.networkError(error)
        } catch let error as APIClientError {
            // Re-throw APIClientError as is
            throw error
        } catch {
            logger.logNetworkError(method: method.rawValue, url: path, error: error)
            throw APIClientError.networkError(error)
        }
    }
    
    private func buildURL(path: String) throws -> URL {
        guard let serverURL = tokenProvider.getServerURL() else {
            logger.error("No server URL configured")
            throw APIClientError.noConfiguration
        }
        
        // Clean up path and server URL
        let cleanServerURL = serverURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let cleanPath = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        
        let fullURLString = "\(cleanServerURL)/\(cleanPath)"
        
        guard let url = URL(string: fullURLString) else {
            logger.error("Invalid URL: \(fullURLString)")
            throw APIClientError.invalidURL(fullURLString)
        }
        
        return url
    }
    
    // MARK: - Convenience Extensions
    
    func get<T: Codable>(_ path: String, responseType: T.Type) async throws -> T {
        return try await makeRequest(path: path, method: .get, responseType: responseType)
    }
    
    func get(_ path: String) async throws -> Data {
        return try await makeRequest(path: path, method: .get)
    }
    
    func post<RequestBody: Codable, ResponseType: Codable>(
        _ path: String,
        body: RequestBody,
        responseType: ResponseType.Type
    ) async throws -> ResponseType {
        let jsonData = try JSONEncoder().encode(body)
        return try await makeRequest(path: path, method: .post, body: jsonData, responseType: responseType)
    }
    
    func post(_ path: String, body: Data? = nil) async throws -> Data {
        return try await makeRequest(path: path, method: .post, body: body)
    }
    
    func put<RequestBody: Codable, ResponseType: Codable>(_ path: String, body: RequestBody, responseType: ResponseType.Type) async throws -> ResponseType {
        let jsonData = try JSONEncoder().encode(body)
        return try await makeRequest(path: path, method: .put, body: jsonData, responseType: responseType)
    }
    
    func put<RequestBody: Codable>(_ path: String, body: RequestBody) async throws -> Data {
        let jsonData = try JSONEncoder().encode(body)
        return try await makeRequest(path: path, method: .put, body: jsonData)
    }
    
    func put(_ path: String, body: Data? = nil) async throws -> Data {
        return try await makeRequest(path: path, method: .put, body: body)
    }
    
    func delete(_ path: String) async throws -> Data {
        return try await makeRequest(path: path, method: .delete)
    }
}

// MARK: - Auth API Wrapper
extension RommAPIClient {
    func login() async throws -> String {
        return try await AuthAPI.loginApiLoginPost()
    }
    
    func logout() async throws -> String {
        return try await AuthAPI.logoutApiLogoutPost()
    }
}

// MARK: - Users API Wrapper
extension RommAPIClient {
    func getCurrentUser() async throws -> UserSchema {
        return try await UsersAPI.getCurrentUserApiUsersMeGet()
    }
    
    func getUsers() async throws -> [UserSchema] {
        return try await UsersAPI.getUsersApiUsersGet()
    }
}

// MARK: - ROMs API Wrapper
extension RommAPIClient {
    func getRoms(
        searchTerm: String? = nil,
        platformId: Int? = nil,
        limit: Int = 50
    ) async throws -> CustomLimitOffsetPageSimpleRomSchema {
        return try await RomsAPI.getRomsApiRomsGet(
            searchTerm: searchTerm,
            platformId: platformId,
            limit: limit
        )
    }
    
    func getRomDetails(id: Int) async throws -> DetailedRomSchema {
        return try await RomsAPI.getRomApiRomsIdGet(id: id)
    }
    
    func updateRomFavorite(
        id: Int,
        isFavorite: Bool
    ) async throws -> RomUserSchema {
        // NOTE: The API schema has changed, this method may need to be updated
        // For now, we'll update the last played date instead
        let updateBody = BodyUpdateRomUserApiRomsIdPropsPut(
            updateLastPlayed: true,
            removeLastPlayed: false
        )
        
        return try await RomsAPI.updateRomUserApiRomsIdPropsPut(
            id: id,
            bodyUpdateRomUserApiRomsIdPropsPut: updateBody
        )
    }
    
    func getRomManual(romId: Int) async throws -> Manual? {
        // First get the ROM details to check if manual path exists
        let romDetails = try await get("api/roms/\(romId)", responseType: DetailedRomSchema.self)
        
        // Check if manual path exists in ROM details
        guard let pathManual = romDetails.pathManual, !pathManual.isEmpty else {
            return nil
        }
        
        // Build full URL with server base URL + manual path
        guard let serverURL = tokenProvider.getServerURL() else {
            throw APIClientError.noConfiguration
        }
        
        // Add the missing assets/romm/resources prefix to pathManual
        let completePath = "assets/romm/resources/\(pathManual.trimmingCharacters(in: CharacterSet(charactersIn: "/")))"
        let fullManualURL = "\(serverURL.trimmingCharacters(in: CharacterSet(charactersIn: "/")))/\(completePath)"
        
        logger.debug("ROM Details pathManual: \(pathManual)")
        logger.debug("Full manual URL: \(fullManualURL)")
        
        let manual = Manual(
            id: 0,
            romId: romId,
            title: "Manual",
            url: fullManualURL,
            fileName: "manual.pdf",
            sizeBytes: nil
        )
        
        return manual
    }
    
    func getManualPDFData(manualURL: String) async throws -> Data {
        // Download PDF from the manual URL with authentication
        guard let url = URL(string: manualURL) else {
            throw APIClientError.invalidURL(manualURL)
        }
        
        // First, we need to authenticate and get session cookies
        // For now, we'll try the direct approach and log what we get
        
        // Create simple request without authentication (since PDF is publicly accessible)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 60.0
        
        logger.debug("Attempting PDF download from: \(manualURL)")
        logger.debug("PDF URL for testing: \(manualURL)")
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIClientError.networkError(URLError(.badServerResponse))
            }
            
            logger.debug("PDF Response status: \(httpResponse.statusCode)")
            logger.debug("PDF Response headers: \(httpResponse.allHeaderFields)")
            logger.debug("PDF Data size: \(data.count) bytes")
            
            // Log first few bytes to see what we actually got
            let preview = data.prefix(20)
            let previewString = String(data: preview, encoding: .utf8) ?? "Binary data"
            logger.debug("PDF Data preview: \(previewString)")
            
            switch httpResponse.statusCode {
            case 200...299:
                // Check if we got HTML instead of PDF
                if let contentType = httpResponse.allHeaderFields["Content-Type"] as? String {
                    logger.debug("Content-Type: \(contentType)")
                    if contentType.contains("text/html") {
                        let htmlContent = String(data: data, encoding: .utf8) ?? "HTML content"
                        logger.error("Received HTML instead of PDF: \(htmlContent.prefix(200))")
                        throw APIClientError.invalidResponse(200, "Received HTML instead of PDF - authentication may have failed")
                    }
                }
                return data
            case 401, 403:
                let errorMessage = String(data: data, encoding: .utf8) ?? "Authentication failed"
                logger.warning("Authentication failed: \(errorMessage)")
                throw APIClientError.authenticationRequired
            default:
                let errorMessage = String(data: data, encoding: .utf8) ?? "PDF download failed"
                logger.error("PDF download failed (\(httpResponse.statusCode)): \(errorMessage)")
                throw APIClientError.invalidResponse(httpResponse.statusCode, errorMessage)
            }
            
        } catch let error as URLError {
            logger.logNetworkError(method: "GET", url: manualURL, error: error)
            throw APIClientError.networkError(error)
        } catch let error as APIClientError {
            throw error
        } catch {
            logger.error("Unexpected error during PDF download: \(error)")
            throw APIClientError.networkError(error)
        }
    }
}

// MARK: - Platforms API Wrapper
extension RommAPIClient {
    func getPlatforms() async throws -> [PlatformSchema] {
        return try await PlatformsAPI.getPlatformsApiPlatformsGet()
    }
    
    func addPlatform(
        name: String,
        slug: String
    ) async throws -> PlatformSchema {
        let platformBody = BodyAddPlatformApiPlatformsPost(fsSlug: slug)
        return try await PlatformsAPI.addPlatformApiPlatformsPost(
            bodyAddPlatformApiPlatformsPost: platformBody
        )
    }
    
    func deletePlatform(id: Int) async throws -> String {
        return try await PlatformsAPI.deletePlatformApiPlatformsIdDelete(id: id)
    }
}

