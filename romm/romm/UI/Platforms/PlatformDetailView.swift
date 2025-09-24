//
//  PlatformDetailView.swift
//  romm
//
//  Created by Ilyas Hallak on 07.08.25.
//

import SwiftUI


struct PlatformDetailView: View {
    
    let platform: Platform
    
    @State private var viewModel = PlatformDetailViewModel()
    
    @State private var searchText = ""
    @State private var showingSortSheet = false
    
    // Filter state
    @State private var selectedLanguages: Set<String> = []
    @State private var selectedRegions: Set<String> = []
    @State private var selectedStatus: Set<String> = []
    @State private var releaseYearRange: ClosedRange<Int>? = nil
    
    // Check if custom sorting is active (not default name/asc)
    private var isCustomSortingActive: Bool {
        viewModel.currentOrderBy != "name" || viewModel.currentOrderDir != "asc"
    }
    
    // Check if any filters are active
    private var isFilterActive: Bool {
        !selectedLanguages.isEmpty || !selectedRegions.isEmpty || !selectedStatus.isEmpty || releaseYearRange != nil
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Content
            switch viewModel.viewState {
            case .loading:
                // Only show full loading screen if we have no ROMs at all
                if viewModel.hasLoadedRoms {
                    // Show content while refreshing in background
                    RomListWithSectionIndex(
                        roms: filteredRoms(from: viewModel.lastLoadedRoms),
                        viewMode: viewModel.viewMode,
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
                } else {
                    LoadingView("Loading ROMs...")
                }
                
            case .loaded(let roms), .loadingMore(let roms):
                RomListWithSectionIndex(
                    roms: filteredRoms(from: roms),
                    viewMode: viewModel.viewMode,
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
                
            case .empty(let message):
                EmptyRomsView(message: message)
                
            case .error(let errorMessage):
                PlatformErrorView(message: errorMessage) {
                    Task {
                        await viewModel.loadRoms(for: platform.id)
                    }
                }
            }
        }
        .navigationTitle(platform.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // Sort/Filter Button
                Button(action: {
                    showingSortSheet = true
                }) {
                    ZStack {
                        Image(systemName: "line.3.horizontal.decrease")
                            .font(.system(size: 16, weight: .medium))
                        
                        // Active sorting/filtering indicator
                        if isCustomSortingActive || isFilterActive {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 6, height: 6)
                                .offset(x: 8, y: -8)
                        }
                    }
                }
                
                // View Mode Toggle Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        let newMode: ViewMode
                        switch viewModel.viewMode {
                        case .smallCard:
                            newMode = .bigCard
                        case .bigCard:
                            newMode = .table
                        case .table:
                            newMode = .smallCard
                        }
                        viewModel.updateViewMode(newMode)
                    }
                }) {
                    Image(systemName: viewModel.viewMode.icon)
                        .font(.system(size: 16, weight: .medium))
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $showingSortSheet) {
            let currentRoms = getCurrentRoms()
            let filterOptions = getAvailableFilterOptions(from: currentRoms)
            
            SortOptionsSheet(
                currentOrderBy: viewModel.currentOrderBy,
                currentOrderDir: viewModel.currentOrderDir,
                filterOptions: filterOptions,
                selectedLanguages: $selectedLanguages,
                selectedRegions: $selectedRegions,
                selectedStatus: $selectedStatus,
                releaseYearRange: $releaseYearRange,
                onSortSelected: { orderBy, orderDir in
                    
                    Task {
                        await viewModel.sortRoms(orderBy: orderBy, orderDir: orderDir)
                    }
                    showingSortSheet = false
                },
                onResetFilters: {
                    selectedLanguages.removeAll()
                    selectedRegions.removeAll()
                    selectedStatus.removeAll()
                    releaseYearRange = nil
                }
            )
        }
        .onAppear {
            // Only load if we don't have data for this platform yet
            if !viewModel.hasDataFor(platformId: platform.id) {
                Task {
                    await viewModel.loadRoms(for: platform.id)
                }
            }
        }
    }
    
    private func filteredRoms(from roms: [Rom]) -> [Rom] {
        var filtered = roms
        
        // Apply search text filter
        if !searchText.isEmpty {
            filtered = filtered.filter { rom in
                rom.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply language filter
        if !selectedLanguages.isEmpty {
            filtered = filtered.filter { rom in
                !rom.languages.isEmpty && Set(rom.languages).intersection(selectedLanguages).count > 0
            }
        }
        
        // Apply region filter
        if !selectedRegions.isEmpty {
            filtered = filtered.filter { rom in
                !rom.regions.isEmpty && Set(rom.regions).intersection(selectedRegions).count > 0
            }
        }
        
        // Apply status filter
        if !selectedStatus.isEmpty {
            filtered = filtered.filter { rom in
                let statusSet = getStatusSet(for: rom)
                return statusSet.intersection(selectedStatus).count > 0
            }
        }
        
        // Apply release year filter
        if let yearRange = releaseYearRange {
            filtered = filtered.filter { rom in
                guard let year = rom.releaseYear else { return false }
                return yearRange.contains(year)
            }
        }
        
        return filtered
    }
    
    private func getStatusSet(for rom: Rom) -> Set<String> {
        var statuses: Set<String> = []
        
        if rom.isFavourite {
            statuses.insert("Favourite")
        }
        if rom.hasRetroAchievements {
            statuses.insert("RetroAchievements")
        }
        if rom.isPlayable {
            statuses.insert("Playable")
        } else {
            statuses.insert("Not Playable")
        }
        
        return statuses
    }
    
    private func getAvailableFilterOptions(from roms: [Rom]) -> FilterOptions {
        var languages: Set<String> = []
        var regions: Set<String> = []
        var statuses: Set<String> = []
        var years: Set<Int> = []
        
        for rom in roms {
            languages.formUnion(rom.languages)
            regions.formUnion(rom.regions)
            statuses.formUnion(getStatusSet(for: rom))
            
            if let year = rom.releaseYear {
                years.insert(year)
            }
        }
        
        return FilterOptions(
            languages: Array(languages).sorted(),
            regions: Array(regions).sorted(),
            statuses: Array(statuses).sorted(),
            releaseYears: Array(years).sorted()
        )
    }
    
    private func getCurrentRoms() -> [Rom] {
        switch viewModel.viewState {
        case .loaded(let roms), .loadingMore(let roms):
            return roms
        case .loading:
            return viewModel.lastLoadedRoms
        default:
            return []
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
        HStack(spacing: 12) {
            // ROM Cover Image
            CachedAsyncImage(urlString: rom.urlCover) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(
                        colors: [Color.gray.opacity(0.15), Color.gray.opacity(0.25)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .overlay(
                        Image(systemName: "gamecontroller")
                            .foregroundColor(.gray)
                            .font(.title2)
                    )
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            // ROM Information
            VStack(alignment: .leading, spacing: 4) {
                Text(rom.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: 8) {
                    if let year = rom.releaseYear {
                        HStack(spacing: 3) {
                            Image(systemName: "calendar")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("\(year)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let rating = rom.rating {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", rating))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Status Icons
            VStack(spacing: 4) {
                RomStatusIcons(rom: rom)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator).opacity(0.2), lineWidth: 0.5)
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

// MARK: - Filter Options Data Structure
struct FilterOptions {
    let languages: [String]
    let regions: [String]
    let statuses: [String]
    let releaseYears: [Int]
}

// MARK: - Sort Options Sheet
struct SortOptionsSheet: View {
    let currentOrderBy: String
    let currentOrderDir: String
    let filterOptions: FilterOptions
    @Binding var selectedLanguages: Set<String>
    @Binding var selectedRegions: Set<String>
    @Binding var selectedStatus: Set<String>
    @Binding var releaseYearRange: ClosedRange<Int>?
    let onSortSelected: (String, String) -> Void
    let onResetFilters: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    private var isResetAvailable: Bool {
        currentOrderBy != "name" || currentOrderDir != "asc"
    }
    
    private var isFiltersActive: Bool {
        !selectedLanguages.isEmpty || !selectedRegions.isEmpty || !selectedStatus.isEmpty || releaseYearRange != nil
    }
    
    private let sortOptions: [(field: SortField, displayName: String)] = [
        (.name, "Title"),
        (.size, "Size"),
        (.added, "Added"),
        (.released, "Released"),
        (.rating, "Rating")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List {
                    Section("Sort Options") {
                        ForEach(sortOptions, id: \.field.rawValue) { option in
                            SortOptionRow(
                                title: option.displayName,
                                field: option.field,
                                currentOrderBy: currentOrderBy,
                                currentOrderDir: currentOrderDir,
                                onSelected: onSortSelected
                            )
                        }
                    }
                    
                    Section("Filter Options") {
                        // Language Filter
                        if !filterOptions.languages.isEmpty {
                            FilterRow(
                                title: "Language",
                                options: filterOptions.languages,
                                selectedOptions: $selectedLanguages,
                                icon: "globe"
                            )
                        }
                        
                        // Region Filter
                        if !filterOptions.regions.isEmpty {
                            FilterRow(
                                title: "Region",
                                options: filterOptions.regions,
                                selectedOptions: $selectedRegions,
                                icon: "flag"
                            )
                        }
                        
                        // Status Filter
                        if !filterOptions.statuses.isEmpty {
                            FilterRow(
                                title: "Status",
                                options: filterOptions.statuses,
                                selectedOptions: $selectedStatus,
                                icon: "star"
                            )
                        }
                        
                        // Release Year Filter
                        if !filterOptions.releaseYears.isEmpty {
                            ReleaseYearFilterRow(
                                availableYears: filterOptions.releaseYears,
                                selectedRange: $releaseYearRange
                            )
                        }
                    }
                }
                
                // Bottom button section
                VStack(spacing: 12) {
                    Divider()
                    
                    HStack(spacing: 16) {
                        // Reset button
                        Button("Reset to Default") {
                            onSortSelected("name", "asc")
                            onResetFilters()
                        }
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                        .disabled(!isResetAvailable && !isFiltersActive)
                        
                        // Done button
                        Button("Done") {
                            dismiss()
                        }
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .padding(.top, 8)
                .background(Color(.systemBackground))
            }
            .navigationTitle("Sort & Filter")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct SortOptionRow: View {
    let title: String
    let field: SortField
    let currentOrderBy: String
    let currentOrderDir: String
    let onSelected: (String, String) -> Void
    
    private var isSelected: Bool {
        field.rawValue == currentOrderBy
    }
    
    private var currentDirection: SortDirection {
        SortDirection(rawValue: currentOrderDir) ?? .asc
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(isSelected ? .semibold : .regular)
                
                if isSelected {
                    Text(currentDirection == .asc ? "Ascending" : "Descending")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                // Ascending button
                Button(action: {
                    onSelected(field.rawValue, SortDirection.asc.rawValue)
                }) {
                    Image(systemName: "chevron.up")
                        .foregroundColor(isSelected && currentDirection == .asc ? .blue : .secondary)
                        .font(.system(size: 14, weight: .medium))
                }
                .buttonStyle(.plain)
                
                // Descending button  
                Button(action: {
                    onSelected(field.rawValue, SortDirection.desc.rawValue)
                }) {
                    Image(systemName: "chevron.down")
                        .foregroundColor(isSelected && currentDirection == .desc ? .blue : .secondary)
                        .font(.system(size: 14, weight: .medium))
                }
                .buttonStyle(.plain)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            let newDirection = isSelected && currentDirection == .asc ? SortDirection.desc : SortDirection.asc
            onSelected(field.rawValue, newDirection.rawValue)
        }
    }
}

// MARK: - Filter Row Component
struct FilterRow: View {
    let title: String
    let options: [String]
    @Binding var selectedOptions: Set<String>
    let icon: String
    
    var body: some View {
        NavigationLink {
            FilterSelectionView(
                title: title,
                options: options,
                selectedOptions: $selectedOptions
            )
        } label: {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                    
                    if !selectedOptions.isEmpty {
                        Text("\(selectedOptions.count) selected")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("All")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if !selectedOptions.isEmpty {
                    Text("\(selectedOptions.count)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
            }
        }
    }
}

// MARK: - Release Year Filter Row
struct ReleaseYearFilterRow: View {
    let availableYears: [Int]
    @Binding var selectedRange: ClosedRange<Int>?
    
    private var minYear: Int {
        availableYears.min() ?? 1980
    }
    
    private var maxYear: Int {
        availableYears.max() ?? Calendar.current.component(.year, from: Date())
    }
    
    var body: some View {
        HStack {
            Image(systemName: "calendar")
                .foregroundColor(.blue)
                .font(.system(size: 16, weight: .medium))
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Release Year")
                    .font(.body)
                
                if let range = selectedRange {
                    Text("\(range.lowerBound) - \(range.upperBound)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("All years")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(selectedRange == nil ? "Set Range" : "Clear") {
                if selectedRange == nil {
                    selectedRange = minYear...maxYear
                } else {
                    selectedRange = nil
                }
            }
            .font(.caption)
            .foregroundColor(.blue)
        }
    }
}

// MARK: - Filter Selection View
struct FilterSelectionView: View {
    let title: String
    let options: [String]
    @Binding var selectedOptions: Set<String>
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(options, id: \.self) { option in
                    HStack {
                        Text(option)
                        Spacer()
                        if selectedOptions.contains(option) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if selectedOptions.contains(option) {
                            selectedOptions.remove(option)
                        } else {
                            selectedOptions.insert(option)
                        }
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear All") {
                        selectedOptions.removeAll()
                    }
                    .foregroundColor(.red)
                    .disabled(selectedOptions.isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PlatformDetailView(platform: Platform(
            id: 1,
            name: "Nintendo Switch",
            slug: "nintendo-switch",
            romCount: 42
        ))
    }
}
