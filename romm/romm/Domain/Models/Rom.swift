//
//  Rom.swift
//  romm
//
//  Created by Ilyas Hallak on 06.08.25.
//

import Foundation

struct SiblingRom: Identifiable, Equatable {
    let id: Int
    let name: String?
    let fsNameNoTags: String
    let fsNameNoExt: String
    let sortComparator: String
    
    var displayName: String {
        return name ?? fsNameNoExt
    }
    
    var displayNameWithExtension: String {
        // Use fsNameNoTags as it contains the most specific filename info including disc/cd info
        // If fsNameNoTags is empty, fallback to name or fsNameNoExt
        if !fsNameNoTags.isEmpty {
            return fsNameNoTags
        } else if let name = name, !name.isEmpty {
            return name
        } else {
            return fsNameNoExt
        }
    }
}

struct Rom: Identifiable, Equatable {
    let id: Int
    let name: String
    let slug: String
    let summary: String?
    let platformId: Int
    let urlCover: String?
    let releaseYear: Int?
    let isFavourite: Bool
    let hasRetroAchievements: Bool
    let isPlayable: Bool
    
    // Additional fields for table display
    let sizeBytes: Int?
    let createdAt: String?
    let rating: Double?
    let languages: [String]
    let regions: [String]
    let fileName: String?
    let platformSlug: String?
    
    var platform: Platform? = nil
    
    init(
        id: Int,
        name: String,
        slug: String = "",
        summary: String? = nil,
        platformId: Int,
        urlCover: String? = nil,
        releaseYear: Int? = nil,
        isFavourite: Bool = false,
        hasRetroAchievements: Bool = false,
        isPlayable: Bool = false,
        sizeBytes: Int? = nil,
        createdAt: String? = nil,
        rating: Double? = nil,
        languages: [String] = [],
        regions: [String] = [],
        fileName: String? = nil,
        platformSlug: String? = nil
    ) {
        self.id = id
        self.name = name
        self.slug = slug
        self.summary = summary
        self.platformId = platformId
        self.urlCover = urlCover
        self.releaseYear = releaseYear
        self.isFavourite = isFavourite
        self.hasRetroAchievements = hasRetroAchievements
        self.isPlayable = isPlayable
        self.sizeBytes = sizeBytes
        self.createdAt = createdAt
        self.rating = rating
        self.languages = languages
        self.regions = regions
        self.fileName = fileName
        self.platformSlug = platformSlug
    }
}

struct RomDetails: Identifiable, Equatable {
    let id: Int
    let name: String
    let fileName: String?
    let fsNameNoExt: String?
    let fsName: String?
    let summary: String?
    let urlCover: String?
    let platformId: Int
    let isFavourite: Bool
    let hasRetroAchievements: Bool
    let genre: [String]
    let developer: String?
    let publisher: String?
    let releaseDate: Date?
    let pathManual: String?
    let sizeBytes: Int?
    let sha1Hash: String?
    let md5Hash: String?
    let crcHash: String?
    let franchises: [String]
    
    // Extended metadata from metadatum object
    let companies: [String]
    let gameModes: [String]
    let ageRatings: [String]
    let averageRating: Double?
    let platformDisplayName: String
    let siblings: [SiblingRom]
    
    init(
        id: Int,
        name: String,
        fileName: String? = nil,
        fsNameNoExt: String? = nil,
        fsName: String? = nil,
        summary: String? = nil,
        urlCover: String? = nil,
        platformId: Int,
        isFavourite: Bool = false,
        hasRetroAchievements: Bool = false,
        genre: [String] = [],
        developer: String? = nil,
        publisher: String? = nil,
        releaseDate: Date? = nil,
        pathManual: String? = nil,
        sizeBytes: Int? = nil,
        sha1Hash: String? = nil,
        md5Hash: String? = nil,
        crcHash: String? = nil,
        franchises: [String] = [],
        companies: [String] = [],
        gameModes: [String] = [],
        ageRatings: [String] = [],
        averageRating: Double? = nil,
        platformDisplayName: String,
        siblings: [SiblingRom] = []
    ) {
        self.id = id
        self.name = name
        self.fileName = fileName
        self.fsNameNoExt = fsNameNoExt
        self.fsName = fsName
        self.summary = summary
        self.urlCover = urlCover
        self.platformId = platformId
        self.isFavourite = isFavourite
        self.hasRetroAchievements = hasRetroAchievements
        self.genre = genre
        self.developer = developer
        self.publisher = publisher
        self.releaseDate = releaseDate
        self.pathManual = pathManual
        self.sizeBytes = sizeBytes
        self.sha1Hash = sha1Hash
        self.md5Hash = md5Hash
        self.crcHash = crcHash
        self.franchises = franchises
        self.companies = companies
        self.gameModes = gameModes
        self.ageRatings = ageRatings
        self.averageRating = averageRating
        self.platformDisplayName = platformDisplayName
        self.siblings = siblings
    }
}
