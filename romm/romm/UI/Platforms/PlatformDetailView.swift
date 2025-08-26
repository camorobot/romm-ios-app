//
//  PlatformDetailView.swift
//  romm
//
//  Created by Ilyas Hallak on 07.08.25.
//

import SwiftUI


struct PlatformDetailView: View {
    
    let platform: Platform
    
    @StateObject private var viewModel = PlatformDetailViewModel()
    
    @State private var viewMode: ViewMode = ViewMode(rawValue: UserDefaults.standard.string(forKey: "selectedViewMode") ?? ViewMode.smallCard.rawValue) ?? .smallCard
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Content
            switch viewModel.viewState {
            case .loading:
                LoadingView(message: "Loading ROMs...")
                
            case .loaded(let roms), .loadingMore(let roms):
                ZStack {
                    RomListWithSectionIndex(
                        roms: filteredRoms(from: roms),
                        viewMode: viewMode,
                        onRefresh: {
                            await viewModel.refreshRoms()
                        },
                        onLoadMore: {
                            await viewModel.loadMoreRomsIfNeeded()
                        },
                        charIndex: viewModel.charIndex,
                        selectedChar: viewModel.selectedChar,
                        onCharTapped: { char in
                            await viewModel.filterByChar(char, platformId: platform.id)
                        },
                        onSort: { orderBy, orderDir in
                            await viewModel.sortRoms(orderBy: orderBy, orderDir: orderDir)
                        },
                        currentOrderBy: viewModel.currentOrderBy,
                        currentOrderDir: viewModel.currentOrderDir,
                        canLoadMore: viewModel.canLoadMore,
                        platform: platform
                    )
                    
                    // Show loading indicator at bottom when loading more
                    if case .loadingMore = viewModel.viewState {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .padding(12)
                                    .background(Color(.systemBackground).opacity(0.9))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .shadow(radius: 2)
                                Spacer()
                            }
                            .padding(.bottom, 50)
                        }
                    }
                }
                
            case .empty(let message):
                EmptyRomsView(message: message)
                
            case .error(let errorMessage):
                ErrorView(message: errorMessage) {
                    Task {
                        await viewModel.loadRoms(for: platform.id)
                    }
                }
            }
        }
        .navigationTitle(platform.name)
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Search ROMs...")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // Sort/Filter Button
                Button(action: {
                    // Placeholder für Sort/Filter action
                }) {
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.system(size: 16, weight: .medium))
                }
                
                // View Mode Toggle Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        switch viewMode {
                        case .smallCard:
                            viewMode = .bigCard
                        case .bigCard:
                            viewMode = .table
                        case .table:
                            viewMode = .smallCard
                        }
                        UserDefaults.standard.set(viewMode.rawValue, forKey: "selectedViewMode")
                    }
                }) {
                    Image(systemName: viewMode.icon)
                        .font(.system(size: 16, weight: .medium))
                }
            }
        }
        .task {
            await viewModel.loadRoms(for: platform.id)
        }
    }
    
    private func filteredRoms(from roms: [Rom]) -> [Rom] {
        if searchText.isEmpty {
            return roms
        } else {
            return roms.filter { rom in
                rom.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

struct PlatformHeaderView: View {
    let platform: Platform
    @Binding var viewMode: ViewMode
    
    var body: some View {
        HStack(spacing: 12) {

            Image(platform.slug)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .frame(width: 40, height: 40)

            Button(action: {
                // Placeholder action
            }) {
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(8)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }

            Spacer()

            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    switch viewMode {
                    case .smallCard:
                        viewMode = .bigCard
                    case .bigCard:
                        viewMode = .table
                    case .table:
                        viewMode = .smallCard
                    }
                    UserDefaults.standard.set(viewMode.rawValue, forKey: "selectedViewMode")
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: viewMode.icon)
                        .font(.system(size: 14, weight: .medium))
                    Text(viewMode.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
}


struct SmallRomCardView: View {
    let rom: Rom
    
    var body: some View {
        HStack {
            CachedAsyncImage(urlString: rom.urlCover) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        Image(systemName: "gamecontroller")
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(rom.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                if let year = rom.releaseYear {
                    Text("\(year)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            RomStatusIcons(rom: rom)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct BigRomCardView: View {
    let rom: Rom
    let platform: Platform?
    
    init(rom: Rom, platform: Platform? = nil) {
        self.rom = rom
        self.platform = platform
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                CachedAsyncImage(urlString: rom.urlCover) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.15))
                        .overlay(
                            Image(systemName: "gamecontroller")
                                .foregroundColor(.gray)
                                .font(.title2)
                        )
                }
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Favorite icon (readonly) - top right
                if rom.isFavourite {
                    Image(systemName: "heart.fill")
                        .font(.title3)
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Circle())
                        .offset(x: -8, y: 8)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(rom.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primary)
                
                HStack(alignment: .center, spacing: 8) {
                    if let year = rom.releaseYear {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(year)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    if let rating = rom.rating {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", rating))
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                HStack {
                    // Platform icon - bottom left
                    if let platform = platform {
                        Image(platform.slug)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    
                    Spacer()
                    RomStatusIcons(rom: rom)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator).opacity(0.3), lineWidth: 0.5)
        )
    }
}

struct TableRomRowView: View {
    let rom: Rom
    
    var body: some View {
        HStack {
            Text(rom.name)
                .font(.body)
                .lineLimit(1)
            
            Spacer()
            
            if let year = rom.releaseYear {
                Text("\(year)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            RomStatusIcons(rom: rom)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .fill(Color(.separator))
                .frame(height: 0.5),
            alignment: .bottom
        )
    }
}

struct RomStatusIcons: View {
    let rom: Rom
    
    var body: some View {
        HStack(spacing: 4) {
            if rom.isFavourite {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            if rom.hasRetroAchievements {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
            }                        
        }
    }
}

struct EmptyRomsView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "gamecontroller")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No ROMs Found")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct PlatformErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text("Error")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button("Retry") {
                onRetry()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NavigationView {
        PlatformDetailView(platform: Platform(
            id: 1,
            name: "Nintendo Switch",
            slug: "nintendo-switch",
            romCount: 42
        ))
    }
}
