//
//  ProfileViewModel.swift
//  romm
//
//  Created by Claude on 08.08.25.
//

import Foundation
import os

@MainActor
class ProfileViewModel: ObservableObject {
    private let logger = Logger.viewModel
    private let logoutUseCase: LogoutUseCase
    private let clearSetupConfigurationUseCase: ClearSetupConfigurationUseCaseProtocol
    
    init(factory: DependencyFactoryProtocol = DefaultDependencyFactory.shared) {
        self.logoutUseCase = factory.makeLogoutUseCase()
        self.clearSetupConfigurationUseCase = factory.makeClearSetupConfigurationUseCase()
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
    
    func restartSetup() {
        logger.info("Restarting setup...")
        
        do {
            try clearSetupConfigurationUseCase.execute()
            logger.info("Setup restart complete")
        } catch {
            logger.error("Failed to restart setup: \(error)")
        }
    }
}