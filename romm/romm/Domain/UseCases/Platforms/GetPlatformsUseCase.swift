//
//  GetPlatformsUseCase.swift
//  romm
//
//  Created by Ilyas Hallak on 27.08.25.
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