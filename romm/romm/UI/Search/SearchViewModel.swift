//
//  SearchViewModel.swift
//  romm
//
//  Created by Ilyas Hallak on 27.08.25.
//

import Foundation

@MainActor
@Observable
class SearchViewModel {
    var searchResults: [Rom] = []
    var isLoading = false
    var errorMessage: String?
    
    private let searchRomsUseCase: SearchRomsUseCase
    
    init(dependencyFactory: DependencyFactoryProtocol = DefaultDependencyFactory.shared) {
        self.searchRomsUseCase = dependencyFactory.makeSearchRomsUseCase()
    }
    
    func search(query: String) async {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            print("🔍 Starting search for: '\(query)'")
            // Use the direct API approach
            let results = try await searchRomsUseCase.execute(query: query)
            print("🔍 Search results: \(results.count) ROMs found")
            searchResults = results
        } catch {
            print("❌ Search failed, trying legacy method: \(error)")
            // Fallback to legacy method if direct API fails
            do {
                let factory = DefaultDependencyFactory.shared
                let results = try await factory.romsRepository.searchRomsLegacy(query: query)
                print("🔍 Legacy Search results: \(results.count) ROMs found")
                searchResults = results
            } catch let legacyError {
                print("❌ Both search methods failed: \(legacyError)")
                errorMessage = "Suche fehlgeschlagen: \(legacyError.localizedDescription)"
                searchResults = []
            }
        }
        
        isLoading = false
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    func clearResults() {
        searchResults = []
        errorMessage = nil
    }
}
