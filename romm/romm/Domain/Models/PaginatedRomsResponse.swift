//
//  PaginatedRomsResponse.swift
//  romm
//
//  Created by Claude on 08.08.25.
//

import Foundation

struct PaginatedRomsResponse {
    let roms: [Rom]
    let total: Int
    let limit: Int
    let offset: Int
    let hasMore: Bool
    let charIndex: [String: Int] // A-Z index with counts from API
    
    init(roms: [Rom], total: Int, limit: Int, offset: Int, charIndex: [String: Int] = [:]) {
        self.roms = roms
        self.total = total
        self.limit = limit
        self.offset = offset
        self.hasMore = (offset + limit) < total
        self.charIndex = charIndex
    }
}