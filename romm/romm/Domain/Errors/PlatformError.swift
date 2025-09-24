//
//  PlatformError.swift
//  romm
//
//  Created by Ilyas Hallak on 26.08.25.
//

import Foundation

enum PlatformError: Error, LocalizedError {
    case invalidInput
    case platformExists
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidInput:
            return "Platform name and slug cannot be empty"
        case .platformExists:
            return "Platform already exists"
        case .networkError:
            return "Network connection error"
        }
    }
}
