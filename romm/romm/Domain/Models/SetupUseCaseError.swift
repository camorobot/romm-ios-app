//
//  SetupUseCaseError.swift
//  romm
//
//  Created by Ilyas Hallak on 27.08.25.
//

import Foundation

enum SetupUseCaseError: LocalizedError {
    case invalidInput
    case invalidURL
    case authenticationFailed
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidInput:
            return "Invalid input - please check server URL, username, and password"
        case .invalidURL:
            return "Invalid server URL - must start with http:// or https://"
        case .authenticationFailed:
            return "Authentication failed - please check your credentials"
        case .saveFailed:
            return "Failed to save setup configuration"
        }
    }
}