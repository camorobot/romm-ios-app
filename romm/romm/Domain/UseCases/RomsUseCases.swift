//
//  RomsUseCases.swift
//  romm
//
//  Created by Ilyas Hallak on 06.08.25.
//

import Foundation

class GetRomsUseCase {
    private let romsRepository: RomsRepositoryProtocol
    
    init(romsRepository: RomsRepositoryProtocol) {
        self.romsRepository = romsRepository
    }
    
    func execute(platformId: Int? = nil, searchTerm: String? = nil, limit: Int = 50, offset: Int = 0, char: String? = nil, orderBy: String? = nil, orderDir: String? = nil, collectionId: Int? = nil) async throws -> PaginatedRomsResponse {
        return try await romsRepository.getRoms(platformId: platformId, searchTerm: searchTerm, limit: limit, offset: offset, char: char, orderBy: orderBy, orderDir: orderDir, collectionId: collectionId)
    }
}

class GetRomDetailsUseCase {
    private let romsRepository: RomsRepositoryProtocol
    
    init(romsRepository: RomsRepositoryProtocol) {
        self.romsRepository = romsRepository
    }
    
    func execute(romId: Int) async throws -> RomDetails {
        guard romId > 0 else {
            throw RomError.invalidRomId
        }
        
        return try await romsRepository.getRomDetails(id: romId)
    }
}

class ToggleRomFavoriteUseCase {
    private let romsRepository: RomsRepositoryProtocol
    
    init(romsRepository: RomsRepositoryProtocol) {
        self.romsRepository = romsRepository
    }
    
    func execute(romId: Int, isFavorite: Bool) async throws {
        guard romId > 0 else {
            throw RomError.invalidRomId
        }
        
        try await romsRepository.toggleRomFavorite(romId: romId, isFavorite: isFavorite)
    }
}

class SearchRomsUseCase {
    private let romsRepository: RomsRepositoryProtocol
    
    init(romsRepository: RomsRepositoryProtocol) {
        self.romsRepository = romsRepository
    }
    
    func execute(query: String) async throws -> [Rom] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return []
        }
        
        return try await romsRepository.searchRoms(query: query)
    }
}

class CheckRomFavoriteStatusUseCase {
    private let romsRepository: RomsRepositoryProtocol
    
    init(romsRepository: RomsRepositoryProtocol) {
        self.romsRepository = romsRepository
    }
    
    func execute(romId: Int) async throws -> Bool {
        return try await romsRepository.isRomFavorite(romId: romId)
    }
}

enum RomError: Error, LocalizedError {
    case invalidRomId
    case romNotFound
    case networkError
    case favoritesNotImplemented
    
    var errorDescription: String? {
        switch self {
        case .invalidRomId:
            return "Invalid ROM ID"
        case .romNotFound:
            return "ROM not found"
        case .networkError:
            return "Network connection error"
        case .favoritesNotImplemented:
            return "Favorite toggling requires multipart/form-data support - coming in a future update!"
        }
    }
}
