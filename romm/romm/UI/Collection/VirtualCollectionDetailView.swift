//
//  VirtualCollectionDetailView.swift
//  romm
//
//  Created by Ilyas Hallak on 23.08.25.
//

import SwiftUI

struct VirtualCollectionDetailView: View {
    let virtualCollection: VirtualCollection
    @State private var viewModel: VirtualCollectionDetailViewModel
    
    init(virtualCollection: VirtualCollection) {
        self.virtualCollection = virtualCollection
        self._viewModel = State(wrappedValue: VirtualCollectionDetailViewModel(virtualCollectionId: virtualCollection.id))
    }
    
    var body: some View {
        VStack {
            switch viewModel.viewState {
            case .loading:
                ProgressView("Loading virtual collection...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            case .loaded:
                VStack {
                    Text("Virtual Collection Detail")
                        .font(.title)
                    Text(virtualCollection.name)
                        .font(.headline)
                    Text("Virtual collections coming soon...")
                        .foregroundColor(.secondary)
                    Text("Collection ID: \(virtualCollection.id)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
            case .error(let errorMessage):
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("Error")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(errorMessage)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Button("Retry") {
                        Task {
                            await viewModel.loadVirtualCollection()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle(virtualCollection.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadVirtualCollection()
        }
    }
}