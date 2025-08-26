//
//  RomListView.swift
//  romm
//
//  Created by Ilyas Hallak on 06.08.25.
//

import SwiftUI

struct RomListView: View {
    @StateObject private var romsViewModel = RomsViewModel()
    @StateObject private var platformsViewModel = PlatformsViewModel()
    @State private var selectedPlatform: Platform?
    
    var body: some View {
        VStack(spacing: 0) {
            // Search and Filter Section
            VStack(spacing: 12) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search ROMs...", text: $romsViewModel.searchText)
                    
                    if !romsViewModel.searchText.isEmpty {
                        Button("Clear") {
                            romsViewModel.searchText = ""
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Platform Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        // All Platforms Button
                        Button("All") {
                            selectedPlatform = nil
                            romsViewModel.loadRoms(for: nil)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(selectedPlatform == nil ? Color.blue : Color(.systemGray5))
                        .foregroundColor(selectedPlatform == nil ? .secondary : .primary)
                        .cornerRadius(16)
                        
                        // Platform Buttons
                        ForEach(platformsViewModel.platforms) { platform in
                            Button(platform.name) {
                                selectedPlatform = platform
                                romsViewModel.loadRoms(for: platform.id)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedPlatform?.id == platform.id ? Color.blue : Color(.systemGray5))
                            .foregroundColor(selectedPlatform?.id == platform.id ? .secondary : .primary)
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            
            // ROM List
            if romsViewModel.isLoading && romsViewModel.roms.isEmpty {
                Spacer()
                ProgressView("Loading ROMs...")
                Spacer()
            } else if romsViewModel.roms.isEmpty && !romsViewModel.searchText.isEmpty {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No ROMs found")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text("Try adjusting your search or filters")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                Spacer()
            } else {
                List {
                    ForEach(romsViewModel.roms) { rom in
                        NavigationLink {
                            RomDetailView2(rom: rom)
                        } label: {
                            RomRowView(rom: rom) {
                                romsViewModel.toggleFavorite(for: rom)
                            }
                        }
                    }
                }
                .refreshable {
                    Task {
                        await romsViewModel.refresh()
                    }
                }
            }
        }
        .navigationTitle("ROM Library")
        .onAppear {
            Task {
                await platformsViewModel.refreshPlatforms()
                await romsViewModel.loadRoms()
            }
        }
        .alert("Error", isPresented: .constant(romsViewModel.errorMessage != nil || platformsViewModel.errorMessage != nil)) {
            Button("OK") {
                romsViewModel.clearError()
                platformsViewModel.clearError()
            }
        } message: {
            Text(romsViewModel.errorMessage ?? platformsViewModel.errorMessage ?? "")
        }
    }
}

struct RomRowView: View {
    let rom: Rom
    let onFavoriteToggle: () -> Void
    @StateObject private var platformsViewModel = PlatformsViewModel()
    
    var body: some View {
        HStack {
            // Cover Image
            CachedAsyncImage(urlString: rom.urlCover) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .overlay(
                        Image(systemName: "gamecontroller")
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 60, height: 80)
            .cornerRadius(8)
            .clipped()
            
            // ROM Info
            VStack(alignment: .leading, spacing: 4) {
                Text(rom.name)
                    .font(.headline)
                    .lineLimit(2)
                
                if let platform = platformsViewModel.platforms.first(where: { $0.id == rom.platformId }) {
                    Text(platform.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    if rom.hasRetroAchievements {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                    
                    if rom.isFavourite {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            
            Spacer()
            
            // Favorite Button
            Button(action: onFavoriteToggle) {
                Image(systemName: rom.isFavourite ? "heart.fill" : "heart")
                    .foregroundColor(rom.isFavourite ? .red : .gray)
            }
            .buttonStyle(.plain)
        }
        .onAppear {
            Task {
                if platformsViewModel.platforms.isEmpty {
                    await platformsViewModel.refreshPlatforms()
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        RomListView()
    }
}
