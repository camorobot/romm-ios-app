//
//  UserViewModel.swift
//  romm
//
//  Created by Claude on 08.08.25.
//

import Foundation
import os

@MainActor
class UserViewModel: ObservableObject {
    private let logger = Logger.viewModel
    private let logoutUseCase: LogoutUseCase
    
    init(factory: DependencyFactoryProtocol = DefaultDependencyFactory.shared) {
        self.logoutUseCase = factory.makeLogoutUseCase()
    }
    
    func logout() {
        logger.info("Logging out...")
        
        Task {
            do {
                try await logoutUseCase.execute()
                logger.info("Logout complete")
            } catch {
                logger.error("Logout failed: \(error)")
            }
        }
    }
}