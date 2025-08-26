//
//  PlatformsUseCases.swift
//  romm
//
//  Created by Ilyas Hallak on 06.08.25.
//

import Foundation

class GetPlatformsUseCase {
    private let platformsRepository: PlatformsRepositoryProtocol
    
    init(platformsRepository: PlatformsRepositoryProtocol) {
        self.platformsRepository = platformsRepository
    }
    
    func execute() async throws -> [Platform] {
        return try await platformsRepository.getPlatforms()
    }
}

class AddPlatformUseCase {
    private let platformsRepository: PlatformsRepositoryProtocol
    
    init(platformsRepository: PlatformsRepositoryProtocol) {
        self.platformsRepository = platformsRepository
    }
    
    func execute(name: String, slug: String) async throws -> Platform {
        guard !name.isEmpty, !slug.isEmpty else {
            throw PlatformError.invalidInput
        }
        
        return try await platformsRepository.addPlatform(name: name, slug: slug)
    }
}

enum PlatformError: Error, LocalizedError {
    case invalidInput
    case platformExists
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidInput:
            return "Platform name and slug cannot be empty"
        case .platformExists:
            return "Platform already exists"
        case .networkError:
            return "Network connection error"
        }
    }
}