//
//  RomsViewModel.swift
//  romm
//
//  Created by Ilyas Hallak on 06.08.25.
//

import Foundation
import Combine

@MainActor
class RomsViewModel: ObservableObject {
    @Published var roms: [Rom] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var searchText: String = ""
    @Published var selectedPlatformId: Int?
    
    private let getRomsUseCase: GetRomsUseCase
    private let searchRomsUseCase: SearchRomsUseCase
    private let toggleRomFavoriteUseCase: ToggleRomFavoriteUseCase
    
    private var cancellables = Set<AnyCancellable>()
    
    init(factory: DependencyFactoryProtocol = DefaultDependencyFactory.shared) {
        self.getRomsUseCase = factory.makeGetRomsUseCase()
        self.searchRomsUseCase = factory.makeSearchRomsUseCase()
        self.toggleRomFavoriteUseCase = factory.makeToggleRomFavoriteUseCase()
        
        setupSearchBinding()
    }
    
    private func setupSearchBinding() {
        // Automatically search when search text changes (with debounce)
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                Task {
                    if !searchText.isEmpty {
                        self?.performSearch()
                    } else {
                        await self?.loadRoms()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func loadRoms() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await getRomsUseCase.execute(
                platformId: selectedPlatformId,
                searchTerm: nil,
                limit: 50,
                offset: 0,
                char: nil,
                collectionId: nil
            )
            self.roms = response.roms
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    func loadRoms(for platformId: Int?) {
        selectedPlatformId = platformId
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response = try await getRomsUseCase.execute(
                    platformId: platformId,
                    searchTerm: nil,
                    limit: 50,
                    offset: 0,
                    char: nil,
                    collectionId: nil
                )
                self.roms = response.roms
                isLoading = false
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                if searchText.isEmpty {
                    let response = try await getRomsUseCase.execute(
                        platformId: selectedPlatformId,
                        searchTerm: nil,
                        limit: 50,
                        offset: 0,
                        char: nil,
                        collectionId: nil
                    )
                    self.roms = response.roms
                } else {
                    let response = try await getRomsUseCase.execute(
                        platformId: selectedPlatformId,
                        searchTerm: searchText,
                        limit: 50,
                        offset: 0,
                        char: nil,
                        collectionId: nil
                    )
                    self.roms = response.roms
                }
                isLoading = false
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func toggleFavorite(for rom: Rom) {
        Task {
            do {
                let newFavoriteState = !rom.isFavourite
                try await toggleRomFavoriteUseCase.execute(
                    romId: rom.id,
                    isFavorite: newFavoriteState
                )
                
                // Update local state
                if let index = roms.firstIndex(where: { $0.id == rom.id }) {
                    var updatedRom = roms[index]
                    updatedRom = Rom(
                        id: updatedRom.id,
                        name: updatedRom.name,
                        platformId: updatedRom.platformId,
                        urlCover: updatedRom.urlCover,
                        isFavourite: newFavoriteState,
                        hasRetroAchievements: updatedRom.hasRetroAchievements,
                        isPlayable: updatedRom.isPlayable
                    )
                    roms[index] = updatedRom
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func refresh() async {
        if searchText.isEmpty {
            await loadRoms()
        } else {
            performSearch()
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}
