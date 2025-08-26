//
//  PlatformMapper.swift
//  romm
//
//  Created by Ilyas Hallak on 06.08.25.
//

import Foundation

struct PlatformMapper {
    static func mapFromAPI(_ apiPlatform: PlatformSchema) -> Platform {
        Platform(
            id: apiPlatform.id,
            name: apiPlatform.name,
            slug: apiPlatform.slug,
            igdbId: apiPlatform.igdbId,
            logoPath: apiPlatform.urlLogo,
            romCount: apiPlatform.romCount
        )
    }
}

extension Array where Element == PlatformSchema {
    func mapToDomain() -> [Platform] {
        return self.map { PlatformMapper.mapFromAPI($0) }
    }
}
