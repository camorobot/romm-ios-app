//
//  AuthError.swift
//  romm
//
//  Created by Ilyas Hallak on 08.08.25.
//

import Foundation

enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case networkError
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid username or password"
        case .networkError:
            return "Network connection error"
        case .unauthorized:
            return "Unauthorized access"
        }
    }
}
