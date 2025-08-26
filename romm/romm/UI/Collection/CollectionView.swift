//
//  CollectionView.swift
//  romm
//
//  Created by Ilyas Hallak on 07.08.25.
//

import SwiftUI

struct CollectionView: View {
    @StateObject private var collectionsViewModel = CollectionsViewModel()
    @StateObject private var userViewModel = UserViewModel()
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        NavigationView {
            VStack {
                if collectionsViewModel.isLoading {
                    ProgressView("Loading collections...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if collectionsViewModel.collections.isEmpty && collectionsViewModel.virtualCollections.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "books.vertical")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No Collections found")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("Your collections will appear here")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        // Virtual Collections Section
                        if !collectionsViewModel.virtualCollections.isEmpty {
                            Section("Virtual Collections") {
                                ForEach(collectionsViewModel.virtualCollections, id: \.id) { virtualCollection in
                                    NavigationLink {
                                        VirtualCollectionDetailView(virtualCollection: virtualCollection)
                                    } label: {
                                        VirtualCollectionRowView(virtualCollection: virtualCollection)
                                    }
                                }
                            }
                        }
                        
                        // Custom Collections Section
                        if !collectionsViewModel.collections.isEmpty {
                            Section("Custom Collections") {
                                ForEach(collectionsViewModel.collections, id: \.id) { collection in
                                    NavigationLink {
                                        CollectionDetailView(collection: collection)
                                    } label: {
                                        CollectionRowView(collection: collection)
                                    }
                                }
                            }
                        }
                    }
                    .refreshable {
                        await collectionsViewModel.refreshCollections()
                    }
                }
            }
            .navigationTitle("Collections")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { userViewModel.logout() }) {
                            Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                        
                        if let user = appData.currentUser {
                            Section {
                                Text("Logged in as \(user.username)")
                                    .foregroundColor(.secondary)
                            }
                        }
                    } label: {
                        Image(systemName: "person.circle")
                    }
                }
            }
            .alert("Error", isPresented: .constant(collectionsViewModel.errorMessage != nil)) {
                Button("OK") {
                    collectionsViewModel.clearError()
                }
            } message: {
                Text(collectionsViewModel.errorMessage ?? "")
            }
        }
    }
}

struct CollectionRowView: View {
    let collection: Collection
    
    var body: some View {
        HStack(spacing: 12) {
            // Collection cover
            CachedAsyncImage(urlString: collection.urlCover) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.2))
                    .overlay(
                        Image(systemName: "folder.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                    )
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(collection.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text("\(collection.romCount) ROM\(collection.romCount == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !collection.description.isEmpty {
                    Text(collection.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                if collection.isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                if !collection.isPublic {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct VirtualCollectionRowView: View {
    let virtualCollection: VirtualCollection
    
    var body: some View {
        HStack(spacing: 12) {
            // Virtual collection icon
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.purple.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: collectionTypeIcon(virtualCollection.type))
                        .foregroundColor(.purple)
                        .font(.title2)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(virtualCollection.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text("\(virtualCollection.romCount) ROM\(virtualCollection.romCount == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !virtualCollection.description.isEmpty {
                    Text(virtualCollection.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
                    .font(.caption)
                
                if virtualCollection.isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func collectionTypeIcon(_ type: String) -> String {
        switch type.lowercased() {
        case "favorites", "favourite":
            return "heart.fill"
        case "recent":
            return "clock.fill"
        case "most_played", "mostplayed":
            return "chart.bar.fill"
        default:
            return "folder.fill"
        }
    }
}


#Preview {
    CollectionView()
        .environmentObject(AppData())
}