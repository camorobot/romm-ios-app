//
//  RomError.swift
//  romm
//
//  Created by Ilyas Hallak on 26.08.25.
//

import Foundation

enum RomError: Error, LocalizedError {
    case invalidRomId
    case romNotFound
    case networkError
    case favoritesNotImplemented
    
    var errorDescription: String? {
        switch self {
        case .invalidRomId:
            return "Invalid ROM ID"
        case .romNotFound:
            return "ROM not found"
        case .networkError:
            return "Network connection error"
        case .favoritesNotImplemented:
            return "Favorite toggling requires multipart/form-data support - coming in a future update!"
        }
    }
}
