//
//  RomDetailViewModel.swift
//  romm
//
//  Created by Ilyas Hallak on 06.08.25.
//

import Foundation

@MainActor
class RomDetailViewModel: ObservableObject {
    @Published var romDetails: RomDetails?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var actualFavoriteStatus: Bool = false // True favorite status from Collections API
    @Published var manual: Manual?
    @Published var manualPDFData: Data?
    @Published var isLoadingManual: Bool = false
    
    private let logger = Logger.viewModel
    
    private let getRomDetailsUseCase: GetRomDetailsUseCase
    private let toggleRomFavoriteUseCase: ToggleRomFavoriteUseCase
    private let checkRomFavoriteStatusUseCase: CheckRomFavoriteStatusUseCase
    private let loadManualUseCase: LoadManualUseCase
    
    init(factory: DependencyFactoryProtocol = DefaultDependencyFactory.shared) {
        self.getRomDetailsUseCase = factory.makeGetRomDetailsUseCase()
        self.toggleRomFavoriteUseCase = factory.makeToggleRomFavoriteUseCase()
        self.checkRomFavoriteStatusUseCase = factory.makeCheckRomFavoriteStatusUseCase()
        self.loadManualUseCase = LoadManualUseCase()
    }
    
    func loadRomDetails(romId: Int) async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Load ROM details and favorite status in parallel
            async let detailsTask = getRomDetailsUseCase.execute(romId: romId)
            async let favoriteStatusTask = checkRomFavoriteStatusUseCase.execute(romId: romId)
            
            let (details, favoriteStatus) = try await (detailsTask, favoriteStatusTask)
            
            romDetails = details
            actualFavoriteStatus = favoriteStatus
            isLoading = false
            
            logger.info("Loaded ROM details for \(details.name) - Favorite: \(favoriteStatus)")
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            logger.error("Error loading ROM details: \(error)")
        }
    }
    
    func toggleFavorite(originalRom: Rom) {
        logger.debug("Toggling favorite for ROM \(originalRom.id): \(originalRom.name)")
        
        Task {
            do {
                // Use the actual favorite status from Collections API
                let currentFavoriteState = actualFavoriteStatus
                let romId = romDetails?.id ?? originalRom.id
                
                let newFavoriteState = !currentFavoriteState
                logger.debug("Current favorite state: \(currentFavoriteState) -> New state: \(newFavoriteState)")
                
                try await toggleRomFavoriteUseCase.execute(
                    romId: romId,
                    isFavorite: newFavoriteState
                )
                
                logger.info("Successfully toggled favorite state")
                
                // Update the actual favorite status
                actualFavoriteStatus = newFavoriteState
                
                // Also update the romDetails if available
                if let romDetails = romDetails {
                    self.romDetails = RomDetails(
                        id: romDetails.id,
                        name: romDetails.name,
                        fileName: romDetails.fileName,
                        summary: romDetails.summary,
                        urlCover: romDetails.urlCover,
                        platformId: romDetails.platformId,
                        isFavourite: newFavoriteState,
                        hasRetroAchievements: romDetails.hasRetroAchievements,
                        genre: romDetails.genre,
                        developer: romDetails.developer,
                        publisher: romDetails.publisher,
                        releaseDate: romDetails.releaseDate,
                        pathManual: romDetails.pathManual,
                        sizeBytes: romDetails.sizeBytes,
                        sha1Hash: romDetails.sha1Hash,
                        md5Hash: romDetails.md5Hash,
                        crcHash: romDetails.crcHash
                    )
                }
                
            } catch {
                logger.error("Error toggling favorite: \(error)")
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func loadManual(for romId: Int) async {
        guard !isLoadingManual else { return }
        
        isLoadingManual = true
        
        do {
            manual = try await loadManualUseCase.execute(for: romId)
            
            if manual != nil {
                // Load PDF data
                let pdfData = try await loadManualUseCase.getManualPDFData(for: romId)
                
                // Validate PDF data
                if let data = pdfData, !data.isEmpty {
                    // Check if data starts with PDF magic bytes
                    let pdfHeader = data.prefix(4)
                    if pdfHeader.starts(with: Data([0x25, 0x50, 0x44, 0x46])) { // "%PDF"
                        manualPDFData = data
                        logger.info("PDF data validated - Size: \(data.count) bytes")
                    } else {
                        logger.warning("Invalid PDF data - Header: \(pdfHeader.map { String(format: "%02x", $0) }.joined())")
                        manualPDFData = nil
                    }
                } else {
                    logger.warning("Empty or nil PDF data")
                    manualPDFData = nil
                }
            }
            
            isLoadingManual = false
            logger.info("Loaded manual for ROM \(romId) - Available: \(manual != nil)")
        } catch {
            isLoadingManual = false
            logger.error("Error loading manual: \(error)")
            manualPDFData = nil
            // Don't set error message for manual loading, just log it
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}
