//
//  UserMapper.swift
//  romm
//
//  Created by Ilyas Hallak on 06.08.25.
//

import Foundation

struct UserMapper {
    static func mapFromAPI(_ apiUser: UserSchema) -> User {
        let role = UserRole(rawValue: apiUser.role.rawValue) ?? .viewer
        
        return User(
            id: apiUser.id,
            username: apiUser.username,
            email: apiUser.email,
            role: role,
            avatarPath: apiUser.avatarPath,
            enabled: apiUser.enabled
        )
    }
}
