//
//  RomsRepositoryProtocol.swift
//  romm
//
//  Created by Ilyas Hallak on 06.08.25.
//

import Foundation

protocol RomsRepositoryProtocol {
    func getRoms(platformId: Int?, searchTerm: String?, limit: Int, offset: Int, char: String?, orderBy: String?, orderDir: String?, collectionId: Int?) async throws -> PaginatedRomsResponse
    func getRomDetails(id: Int) async throws -> RomDetails
    func toggleRomFavorite(romId: Int, isFavorite: Bool) async throws
    func isRomFavorite(romId: Int) async throws -> Bool
    func searchRoms(query: String) async throws -> [Rom]
}