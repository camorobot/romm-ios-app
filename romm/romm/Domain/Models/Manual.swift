//
//  Manual.swift
//  romm
//
//  Created by Ilyas Hallak on 13.08.25.
//

import Foundation

struct Manual: Identifiable, Equatable {
    let id: Int
    let romId: Int
    let title: String?
    let url: String
    let fileName: String
    let sizeBytes: Int?
    let createdAt: String?
    
    init(
        id: Int,
        romId: Int,
        title: String? = nil,
        url: String,
        fileName: String,
        sizeBytes: Int? = nil,
        createdAt: String? = nil
    ) {
        self.id = id
        self.romId = romId
        self.title = title
        self.url = url
        self.fileName = fileName
        self.sizeBytes = sizeBytes
        self.createdAt = createdAt
    }
}