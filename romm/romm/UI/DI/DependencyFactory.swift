//
//  DependencyFactory.swift
//  romm
//
//  Created by Ilyas Hallak on 06.08.25.
//

import Foundation

protocol DependencyFactoryProtocol {
    // Repositories
    var authRepository: AuthRepositoryProtocol { get }
    var romsRepository: RomsRepositoryProtocol { get }
    var platformsRepository: PlatformsRepositoryProtocol { get }
    var collectionsRepository: CollectionsRepositoryProtocol { get }
    var setupRepository: SetupRepositoryProtocol { get }
    var sftpRepository: SFTPRepositoryProtocol { get }
    
    // Services
    var sftpKeychainService: SFTPKeychainServiceProtocol { get }
    var sftpService: SFTPServiceProtocol { get }
    var sftpConnectionManager: SFTPConnectionManager { get }
    var apiClient: RommAPIClientProtocol { get }
    
    // Use Cases
    func makeLogoutUseCase() -> LogoutUseCase
    func makeGetCurrentUserUseCase() -> GetCurrentUserUseCase
    func makeGetRomsUseCase() -> GetRomsUseCase
    func makeGetRomDetailsUseCase() -> GetRomDetailsUseCase
    func makeToggleRomFavoriteUseCase() -> ToggleRomFavoriteUseCase
    func makeCheckRomFavoriteStatusUseCase() -> CheckRomFavoriteStatusUseCase
    func makeSearchRomsUseCase() -> SearchRomsUseCase
    func makeGetPlatformsUseCase() -> GetPlatformsUseCase
    func makeAddPlatformUseCase() -> AddPlatformUseCase
    func makeGetCollectionsUseCase() -> GetCollectionsUseCase
    func makeGetVirtualCollectionsUseCase() -> GetVirtualCollectionsUseCase
    
    // Setup Use Cases
    func makeSaveSetupConfigurationUseCase() -> SaveSetupConfigurationUseCaseProtocol
    func makeGetSetupConfigurationUseCase() -> GetSetupConfigurationUseCaseProtocol
    func makeCheckSetupStatusUseCase() -> CheckSetupStatusUseCaseProtocol
    func makeClearSetupConfigurationUseCase() -> ClearSetupConfigurationUseCaseProtocol
    
    // SFTP Use Cases
    func makeSFTPUseCases() -> SFTPUseCases
    
    // SFTP ViewModels
    @MainActor func makeSFTPDevicesViewModel() -> SFTPDevicesViewModel
    @MainActor func makeSFTPDirectoryBrowserViewModel(connection: SFTPConnection) -> SFTPDirectoryBrowserViewModel
    @MainActor func makeSFTPUploadViewModel(rom: Rom) -> SFTPUploadViewModel
    @MainActor func makeAddEditSFTPDeviceViewModel(connection: SFTPConnection?) -> AddEditSFTPDeviceViewModel
}

class DefaultDependencyFactory: DependencyFactoryProtocol {
    static let shared = DefaultDependencyFactory()
    
    // MARK: - Repositories (Singletons)
    
    lazy var authRepository: AuthRepositoryProtocol = AuthRepository()
    lazy var romsRepository: RomsRepositoryProtocol = RomsRepository()
    lazy var platformsRepository: PlatformsRepositoryProtocol = PlatformsRepository()
    lazy var collectionsRepository: CollectionsRepositoryProtocol = CollectionsRepository()
    lazy var setupRepository: SetupRepositoryProtocol = SetupRepository()
    
    // MARK: - SFTP Services (Singletons)
    
    lazy var sftpKeychainService: SFTPKeychainServiceProtocol = SFTPKeychainService()
    lazy var sftpRepository: SFTPRepositoryProtocol = SFTPRepository(keychainService: sftpKeychainService)
    lazy var sftpService: SFTPServiceProtocol = SFTPService(repository: sftpRepository)
    lazy var sftpConnectionManager: SFTPConnectionManager = {
        let manager = SFTPConnectionManager.shared
        manager.configure(with: sftpService)
        return manager
    }()
    lazy var apiClient: RommAPIClientProtocol = RommAPIClient.shared
    
    private init() {}
    
    // MARK: - Auth Use Cases
    
    func makeLogoutUseCase() -> LogoutUseCase {
        LogoutUseCase(authRepository: authRepository)
    }
    
    func makeGetCurrentUserUseCase() -> GetCurrentUserUseCase {
        GetCurrentUserUseCase(authRepository: authRepository)
    }
    
    // MARK: - ROM Use Cases
    
    func makeGetRomsUseCase() -> GetRomsUseCase {
        GetRomsUseCase(romsRepository: romsRepository)
    }
    
    func makeGetRomDetailsUseCase() -> GetRomDetailsUseCase {
        GetRomDetailsUseCase(romsRepository: romsRepository)
    }
    
    func makeToggleRomFavoriteUseCase() -> ToggleRomFavoriteUseCase {
        ToggleRomFavoriteUseCase(romsRepository: romsRepository)
    }
    
    func makeCheckRomFavoriteStatusUseCase() -> CheckRomFavoriteStatusUseCase {
        CheckRomFavoriteStatusUseCase(romsRepository: romsRepository)
    }
    
    func makeSearchRomsUseCase() -> SearchRomsUseCase {
        SearchRomsUseCase(romsRepository: romsRepository)
    }
    
    // MARK: - Platform Use Cases
    
    func makeGetPlatformsUseCase() -> GetPlatformsUseCase {
        GetPlatformsUseCase(platformsRepository: platformsRepository)
    }
    
    func makeAddPlatformUseCase() -> AddPlatformUseCase {
        AddPlatformUseCase(platformsRepository: platformsRepository)
    }
    
    // MARK: - Collection Use Cases
    
    func makeGetCollectionsUseCase() -> GetCollectionsUseCase {
        GetCollectionsUseCase(collectionsRepository: collectionsRepository)
    }
    
    func makeGetVirtualCollectionsUseCase() -> GetVirtualCollectionsUseCase {
        GetVirtualCollectionsUseCase(collectionsRepository: collectionsRepository)
    }
    
    // MARK: - Setup Use Cases
    
    func makeSaveSetupConfigurationUseCase() -> SaveSetupConfigurationUseCaseProtocol {
        SaveSetupConfigurationUseCase(
            setupRepository: setupRepository
        )
    }
    
    func makeGetSetupConfigurationUseCase() -> GetSetupConfigurationUseCaseProtocol {
        GetSetupConfigurationUseCase(setupRepository: setupRepository)
    }
    
    func makeCheckSetupStatusUseCase() -> CheckSetupStatusUseCaseProtocol {
        CheckSetupStatusUseCase(setupRepository: setupRepository)
    }
    
    func makeClearSetupConfigurationUseCase() -> ClearSetupConfigurationUseCaseProtocol {
        ClearSetupConfigurationUseCase(
            setupRepository: setupRepository,
            configurationService: DefaultConfigurationService.shared
        )
    }
    
    // MARK: - SFTP Use Cases
    
    func makeSFTPUseCases() -> SFTPUseCases {
        SFTPUseCases(repository: sftpRepository, connectionManager: sftpConnectionManager)
    }
    
    // MARK: - SFTP ViewModels
    
    @MainActor func makeSFTPDevicesViewModel() -> SFTPDevicesViewModel {
        SFTPDevicesViewModel(sftpUseCases: makeSFTPUseCases())
    }
    
    @MainActor func makeSFTPDirectoryBrowserViewModel(connection: SFTPConnection) -> SFTPDirectoryBrowserViewModel {
        SFTPDirectoryBrowserViewModel(connection: connection, sftpUseCases: makeSFTPUseCases())
    }
    
    @MainActor func makeSFTPUploadViewModel(rom: Rom) -> SFTPUploadViewModel {
        SFTPUploadViewModel(rom: rom, sftpUseCases: makeSFTPUseCases(), apiClient: apiClient)
    }
    
    @MainActor func makeAddEditSFTPDeviceViewModel(connection: SFTPConnection?) -> AddEditSFTPDeviceViewModel {
        AddEditSFTPDeviceViewModel(connection: connection, sftpUseCases: makeSFTPUseCases())
    }
}

// MARK: - Mock Factory for Testing

class MockDependencyFactory: DependencyFactoryProtocol {
    
    // Mock repositories can be injected for testing
    var authRepository: AuthRepositoryProtocol
    var romsRepository: RomsRepositoryProtocol
    var platformsRepository: PlatformsRepositoryProtocol
    var collectionsRepository: CollectionsRepositoryProtocol
    var setupRepository: SetupRepositoryProtocol
    var sftpRepository: SFTPRepositoryProtocol
    
    // Mock services
    var sftpKeychainService: SFTPKeychainServiceProtocol
    var sftpService: SFTPServiceProtocol
    var sftpConnectionManager: SFTPConnectionManager
    var apiClient: RommAPIClientProtocol
    
    init(
        authRepository: AuthRepositoryProtocol? = nil,
        romsRepository: RomsRepositoryProtocol? = nil,
        platformsRepository: PlatformsRepositoryProtocol? = nil,
        collectionsRepository: CollectionsRepositoryProtocol? = nil,
        setupRepository: SetupRepositoryProtocol? = nil,
        sftpRepository: SFTPRepositoryProtocol? = nil,
        sftpKeychainService: SFTPKeychainServiceProtocol? = nil,
        sftpService: SFTPServiceProtocol? = nil,
        sftpConnectionManager: SFTPConnectionManager? = nil,
        apiClient: RommAPIClientProtocol? = nil
    ) {
        // Use provided mocks or default to real implementations
        self.authRepository = authRepository ?? AuthRepository()
        self.romsRepository = romsRepository ?? RomsRepository()
        self.platformsRepository = platformsRepository ?? PlatformsRepository()
        self.collectionsRepository = collectionsRepository ?? CollectionsRepository()
        self.setupRepository = setupRepository ?? SetupRepository()
        
        let keychainService = sftpKeychainService ?? SFTPKeychainService()
        self.sftpKeychainService = keychainService
        self.sftpRepository = sftpRepository ?? SFTPRepository(keychainService: keychainService)
        self.sftpService = sftpService ?? SFTPService(repository: self.sftpRepository)
        
        if let providedManager = sftpConnectionManager {
            self.sftpConnectionManager = providedManager
        } else {
            let manager = SFTPConnectionManager.shared
            manager.configure(with: self.sftpService)
            self.sftpConnectionManager = manager
        }
        
        self.apiClient = apiClient ?? RommAPIClient.shared
    }
    
    func makeLogoutUseCase() -> LogoutUseCase {
        LogoutUseCase(authRepository: authRepository)
    }
    
    func makeGetCurrentUserUseCase() -> GetCurrentUserUseCase {
        GetCurrentUserUseCase(authRepository: authRepository)
    }
    
    func makeGetRomsUseCase() -> GetRomsUseCase {
        GetRomsUseCase(romsRepository: romsRepository)
    }
    
    func makeGetRomDetailsUseCase() -> GetRomDetailsUseCase {
        GetRomDetailsUseCase(romsRepository: romsRepository)
    }
    
    func makeToggleRomFavoriteUseCase() -> ToggleRomFavoriteUseCase {
        ToggleRomFavoriteUseCase(romsRepository: romsRepository)
    }
    
    func makeCheckRomFavoriteStatusUseCase() -> CheckRomFavoriteStatusUseCase {
        CheckRomFavoriteStatusUseCase(romsRepository: romsRepository)
    }
    
    func makeSearchRomsUseCase() -> SearchRomsUseCase {
        SearchRomsUseCase(romsRepository: romsRepository)
    }
    
    func makeGetPlatformsUseCase() -> GetPlatformsUseCase {
        GetPlatformsUseCase(platformsRepository: platformsRepository)
    }
    
    func makeAddPlatformUseCase() -> AddPlatformUseCase {
        AddPlatformUseCase(platformsRepository: platformsRepository)
    }
    
    func makeGetCollectionsUseCase() -> GetCollectionsUseCase {
        GetCollectionsUseCase(collectionsRepository: collectionsRepository)
    }
    
    func makeGetVirtualCollectionsUseCase() -> GetVirtualCollectionsUseCase {
        GetVirtualCollectionsUseCase(collectionsRepository: collectionsRepository)
    }
    
    func makeSaveSetupConfigurationUseCase() -> SaveSetupConfigurationUseCaseProtocol {
        SaveSetupConfigurationUseCase(
            setupRepository: setupRepository
        )
    }
    
    func makeGetSetupConfigurationUseCase() -> GetSetupConfigurationUseCaseProtocol {
        GetSetupConfigurationUseCase(setupRepository: setupRepository)
    }
    
    func makeCheckSetupStatusUseCase() -> CheckSetupStatusUseCaseProtocol {
        CheckSetupStatusUseCase(setupRepository: setupRepository)
    }
    
    func makeClearSetupConfigurationUseCase() -> ClearSetupConfigurationUseCaseProtocol {
        ClearSetupConfigurationUseCase(
            setupRepository: setupRepository,
            configurationService: DefaultConfigurationService.shared
        )
    }
    
    // MARK: - SFTP Use Cases
    
    func makeSFTPUseCases() -> SFTPUseCases {
        SFTPUseCases(repository: sftpRepository, connectionManager: sftpConnectionManager)
    }
    
    // MARK: - SFTP ViewModels
    
    @MainActor func makeSFTPDevicesViewModel() -> SFTPDevicesViewModel {
        SFTPDevicesViewModel(sftpUseCases: makeSFTPUseCases())
    }
    
    @MainActor func makeSFTPDirectoryBrowserViewModel(connection: SFTPConnection) -> SFTPDirectoryBrowserViewModel {
        SFTPDirectoryBrowserViewModel(connection: connection, sftpUseCases: makeSFTPUseCases())
    }
    
    @MainActor func makeSFTPUploadViewModel(rom: Rom) -> SFTPUploadViewModel {
        SFTPUploadViewModel(rom: rom, sftpUseCases: makeSFTPUseCases(), apiClient: apiClient)
    }
    
    @MainActor func makeAddEditSFTPDeviceViewModel(connection: SFTPConnection?) -> AddEditSFTPDeviceViewModel {
        AddEditSFTPDeviceViewModel(connection: connection, sftpUseCases: makeSFTPUseCases())
    }
}
