//
//  AuthUseCases.swift
//  romm
//
//  Created by Ilyas Hallak on 06.08.25.
//

import Foundation

class LogoutUseCase {
    private let authRepository: AuthRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
    
    func execute() async throws {
        try await authRepository.logout()
    }
}

