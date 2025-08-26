//
//  Platform.swift
//  romm
//
//  Created by Ilyas Hallak on 06.08.25.
//

import Foundation

struct Platform: Identifiable, Equatable, Hashable {
    let id: Int
    let name: String
    let slug: String
    let igdbId: Int?
    let logoPath: String?
    let romCount: Int
    
    var logoUrl: String? {
        guard let logoPath = logoPath else { return nil }
        
        return logoPath
    }
    
    init(
        id: Int,
        name: String,
        slug: String,
        igdbId: Int? = nil,
        logoPath: String? = nil,
        romCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.slug = slug
        self.igdbId = igdbId
        self.logoPath = logoPath
        self.romCount = romCount
    }
}
