//
//  RomMapper.swift
//  romm
//
//  Created by Ilyas Hallak on 06.08.25.
//

import Foundation

struct RomMapper {
    static func mapFromAPI(_ apiRom: SimpleRomSchema) -> Rom {
        // Extract release year from metadata if available
        let releaseYear: Int? = {
            if let timestamp = apiRom.igdbMetadata?.firstReleaseDate {
                let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
                let calendar = Calendar.current
                return calendar.component(.year, from: date)
            }
            return nil
        }()
        
        return Rom(
            id: apiRom.id,
            name: apiRom.name ?? "Unknown ROM",
            slug: apiRom.slug ?? "",
            summary: apiRom.summary,
            platformId: apiRom.platformId,
            urlCover: apiRom.urlCover,
            releaseYear: releaseYear,
            isFavourite: apiRom.romUser.rating > 0 || apiRom.romUser.nowPlaying,
            hasRetroAchievements: apiRom.raId != nil,
            isPlayable: !apiRom.missingFromFs,
            sizeBytes: apiRom.fsSizeBytes,
            createdAt: DateFormatter.iso8601Full.string(from: apiRom.createdAt),
            rating: apiRom.metadatum.averageRating,
            languages: apiRom.languages,
            regions: apiRom.regions,
            fileName: apiRom.files.first?.fileName ?? ""
        )
    }
    
    static func mapDetailsFromAPI(_ apiRom: DetailedRomSchema) -> RomDetails {
        let releaseDate: Date? = {
            if let timestamp = apiRom.igdbMetadata?.firstReleaseDate {
                return Date(timeIntervalSince1970: TimeInterval(timestamp))
            }
            return nil
        }()
        
        return RomDetails(
            id: apiRom.id,
            name: apiRom.name ?? "Unknown ROM",
            fileName: apiRom.fsName,
            summary: apiRom.summary,
            urlCover: apiRom.urlCover,
            platformId: apiRom.platformId,
            isFavourite: false, // Will be loaded separately via user properties
            hasRetroAchievements: apiRom.raId != nil,
            genre: apiRom.igdbMetadata?.genres ?? [],
            developer: apiRom.igdbMetadata?.companies?.first,
            publisher: apiRom.igdbMetadata?.companies?.first,
            releaseDate: releaseDate,
            pathManual: apiRom.pathManual,
            sizeBytes: apiRom.fsSizeBytes,
            sha1Hash: apiRom.sha1Hash,
            md5Hash: apiRom.md5Hash,
            crcHash: apiRom.crcHash
        )
    }
}

extension Array where Element == SimpleRomSchema {
    func mapToDomain() -> [Rom] {
        return self.map { RomMapper.mapFromAPI($0) }
    }
}
