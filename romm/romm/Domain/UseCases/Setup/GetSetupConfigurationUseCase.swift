//
//  GetSetupConfigurationUseCase.swift
//  romm
//
//  Created by Ilyas Hallak on 07.08.25.
//

import Foundation

protocol GetSetupConfigurationUseCaseProtocol {
    func execute() throws -> SetupConfiguration?
}

class GetSetupConfigurationUseCase: GetSetupConfigurationUseCaseProtocol {
    private let logger = Logger.general
    private let setupRepository: SetupRepositoryProtocol
    
    init(setupRepository: SetupRepositoryProtocol) {
        self.setupRepository = setupRepository
    }
    
    func execute() throws -> SetupConfiguration? {
        logger.info("Getting setup configuration...")
        
        let config = setupRepository.getSetupConfiguration()
        
        if let config = config {
            logger.info("Setup configuration found")
            logger.info("Setup date: \(config.setupDate)")
            logger.info("Version: \(config.version)")
        } else {
            logger.info("No setup configuration found")
        }
        
        return config
    }
}

protocol CheckSetupStatusUseCaseProtocol {
    func execute() -> Bool
}

class CheckSetupStatusUseCase: CheckSetupStatusUseCaseProtocol {
    private let logger = Logger.general
    private let setupRepository: SetupRepositoryProtocol
    
    init(setupRepository: SetupRepositoryProtocol) {
        self.setupRepository = setupRepository
    }
    
    func execute() -> Bool {
        let isSetup = setupRepository.isSetupComplete()
        logger.info("Setup status check: \(isSetup)")
        return isSetup
    }
}

protocol ClearSetupConfigurationUseCaseProtocol {
    func execute() throws
}

class ClearSetupConfigurationUseCase: ClearSetupConfigurationUseCaseProtocol {
    private let logger = Logger.general
    private let setupRepository: SetupRepositoryProtocol
    private let configurationService: ConfigurationService
    
    init(setupRepository: SetupRepositoryProtocol, configurationService: ConfigurationService) {
        self.setupRepository = setupRepository
        self.configurationService = configurationService
    }
    
    func execute() throws {
        logger.info("Clearing setup configuration...")
        
        try setupRepository.clearSetupConfiguration()
        try configurationService.clearConfiguration()
        
        logger.info("Setup configuration cleared")
    }
}