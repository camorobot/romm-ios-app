//
//  AppViewModel.swift
//  romm
//
//  Created by Ilyas Hallak on 08.08.25.
//

import Foundation
import Combine
import os
import Observation

enum AppState {
    case loading
    case setup
    case authenticated
    case authenticationFailed
}

@Observable
@MainActor
class AppViewModel {
    var appState: AppState = .loading
    
    private let logger = Logger.viewModel
    
    // Shared data for environment
    let appData = AppData()
    
    // Use Cases
    private let saveSetupConfigurationUseCase: SaveSetupConfigurationUseCaseProtocol
    private let getSetupConfigurationUseCase: GetSetupConfigurationUseCaseProtocol
    private let clearSetupConfigurationUseCase: ClearSetupConfigurationUseCaseProtocol
    
    private let factory: DependencyFactoryProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    init(factory: DependencyFactoryProtocol = DefaultDependencyFactory.shared) {
        self.factory = factory
        self.saveSetupConfigurationUseCase = factory.makeSaveSetupConfigurationUseCase()
        self.getSetupConfigurationUseCase = factory.makeGetSetupConfigurationUseCase()
        self.clearSetupConfigurationUseCase = factory.makeClearSetupConfigurationUseCase()

        // Listen for restart setup requests
        NotificationCenter.default.addObserver(
            forName: .restartSetupRequested,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handleRestartSetupRequest()
            }
        }
    }
    
    // MARK: - Public Methods
    
    func checkInitialState() async {
        logger.debug("Checking initial state...")
        
        let config = try? getSetupConfigurationUseCase.execute()
        
        if let config, config.token != nil {
            logger.info("Authentication state: \(appData.isAuthenticated)")
            updateAppConfig(config)
            appState = .authenticated
        } else {
            logger.info("Setup not complete, showing setup")
            appState = .setup
        }
        
    }
    
    // MARK: - Setup Methods
    
    func saveConfiguration(serverURL: String, username: String, password: String) async {
        logger.debug("Save configuration requested")
        appState = .loading
        guard !serverURL.isEmpty, !username.isEmpty, !password.isEmpty else {
            logger.warning("Missing required fields")
            appData.updateError("Please fill in all required fields")
            return
        }
        
        appData.updateLoading(true)
        appData.updateError(nil)
        
        do {
            logger.debug("Calling save setup configuration use case...")
            let setupConfig = try await saveSetupConfigurationUseCase.execute(
                serverURL: serverURL,
                username: username,
                password: password
            )
            
            updateAppConfig(setupConfig)
            logger.info("Setup configuration saved successfully")
            appData.updateLoading(false)
            appState = .authenticated
        } catch {
            logger.error("Setup configuration failed: \(error)")
            appData.updateLoading(false)
            appData.updateError(error.localizedDescription)
            appState = .authenticationFailed
        }
    }
    
    func restartSetup() {
        logger.debug("Restarting setup...")
        
        do {
            try clearSetupConfigurationUseCase.execute()
            resetAuthenticationState()
            appData.updateConfiguration(nil)
            appState = .loading
        } catch {
            logger.error("Failed to restart setup: \(error)")
            appData.updateError(error.localizedDescription)
        }
    }
    
    private func updateAppConfig(_ config: SetupConfiguration) {
        appData.updateConfiguration(.init(serverURL: config.serverURL, username: config.username, password: "", token: config.token, refreshToken: config.refreshToken))
    }
    
    private func resetAuthenticationState() {
        logger.debug("Resetting authentication state")
        appData.updateAuthState(false)
        appData.updateUser(nil)
        appData.updateError(nil)
    }
    
    func clearError() {
        appData.updateError(nil)
    }

    // MARK: - Private Methods

    private func handleRestartSetupRequest() {
        logger.info("Handling restart setup request from notification")
        resetAuthenticationState()
        appData.updateConfiguration(nil)
        appState = .setup
    }

}
