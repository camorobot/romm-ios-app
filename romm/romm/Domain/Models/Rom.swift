//
//  Rom.swift
//  romm
//
//  Created by Ilyas Hallak on 06.08.25.
//

import Foundation

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
        fileName: String? = nil
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
    }
}

struct RomDetails: Identifiable, Equatable {
    let id: Int
    let name: String
    let fileName: String?
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
    
    init(
        id: Int,
        name: String,
        fileName: String? = nil,
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
        crcHash: String? = nil
    ) {
        self.id = id
        self.name = name
        self.fileName = fileName
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
    }
}