//
//  User.swift
//  romm
//
//  Created by Ilyas Hallak on 06.08.25.
//

import Foundation

struct User: Identifiable, Equatable {
    let id: Int
    let username: String
    let email: String?
    let role: UserRole
    let avatarPath: String?
    let enabled: Bool
    
    init(
        id: Int,
        username: String,
        email: String? = nil,
        role: UserRole,
        avatarPath: String? = nil,
        enabled: Bool = true
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.role = role
        self.avatarPath = avatarPath
        self.enabled = enabled
    }
}

enum UserRole: String, CaseIterable {
    case admin = "admin"
    case editor = "editor"
    case viewer = "viewer"
    
    var displayName: String {
        switch self {
        case .admin:
            return "Administrator"
        case .editor:
            return "Editor"
        case .viewer:
            return "Viewer"
        }
    }
}