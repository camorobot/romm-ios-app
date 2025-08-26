//
//  CollectionsViewModel.swift
//  romm
//
//  Created by Ilyas Hallak on 10.08.25.
//

import Foundation
import os

@MainActor
class CollectionsViewModel: ObservableObject {
    private let logger = Logger.viewModel
    @Published var collections: [Collection] = []
    @Published var virtualCollections: [VirtualCollection] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let getCollectionsUseCase: GetCollectionsUseCase
    private let getVirtualCollectionsUseCase: GetVirtualCollectionsUseCase
    
    init(factory: DependencyFactoryProtocol = DefaultDependencyFactory.shared) {
        self.getCollectionsUseCase = factory.makeGetCollectionsUseCase()
        self.getVirtualCollectionsUseCase = factory.makeGetVirtualCollectionsUseCase()
        
        // Load collections automatically on init
        loadCollections()
    }
    
    private func loadCollections() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Load both regular collections and virtual collections in parallel
                async let collectionsTask = getCollectionsUseCase.execute()
                async let virtualCollectionsTask = getVirtualCollectionsUseCase.execute(type: "all", limit: 10)
                
                let (loadedCollections, loadedVirtualCollections) = try await (collectionsTask, virtualCollectionsTask)
                
                await MainActor.run {
                    self.collections = loadedCollections
                    self.virtualCollections = loadedVirtualCollections
                    self.isLoading = false
                }
                
                logger.info("Loaded \(loadedCollections.count) collections and \(loadedVirtualCollections.count) virtual collections")
                
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
                logger.error("Error loading collections: \(error)")
            }
        }
    }
    
    func refreshCollections() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Load both regular collections and virtual collections in parallel
            async let collectionsTask = getCollectionsUseCase.execute()
            async let virtualCollectionsTask = getVirtualCollectionsUseCase.execute(type: "all", limit: 10)
            
            let (loadedCollections, loadedVirtualCollections) = try await (collectionsTask, virtualCollectionsTask)
            
            collections = loadedCollections
            virtualCollections = loadedVirtualCollections
            isLoading = false
            
            logger.info("Refreshed \(collections.count) collections and \(virtualCollections.count) virtual collections")
            
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            logger.error("Error refreshing collections: \(error)")
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}