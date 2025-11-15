//
//  SearchView.swift
//  romm
//
//  Created by Ilyas Hallak on 07.08.25.
//

import SwiftUI

struct SearchView: View {
    @State private var searchViewModel = SearchViewModel()
    @EnvironmentObject var appData: AppData
    @State private var searchText = ""
    @State private var searchTask: Task<Void, Never>?
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        searchContentView
            .navigationTitle("Suche")
            .searchable(text: $searchText, prompt: "ROM-Namen eingeben...")
            .focused($isSearchFieldFocused)
            .onSubmit(of: .search) {
                performSearch()
            }
            .toolbar {
                cancelToolbarItem
            }
            .alert("Fehler", isPresented: .constant(searchViewModel.errorMessage != nil)) {
                Button("OK") {
                    searchViewModel.clearError()
                }
            } message: {
                Text(searchViewModel.errorMessage ?? "")
            }
            .onChange(of: searchText) { oldValue, newValue in
                handleSearchTextChange(newValue)
            }
            .onDisappear {
                searchTask?.cancel()
            }
    }
    
    @ViewBuilder
    private var searchContentView: some View {
        VStack(spacing: 0) {
            if searchViewModel.isLoading {
                loadingView
            } else if searchText.isEmpty && searchViewModel.searchResults.isEmpty {
                emptyStateView
            } else if searchViewModel.searchResults.isEmpty && !searchText.isEmpty && !searchViewModel.isLoading {
                noResultsView
            } else {
                searchResultsView
            }
        }
    }
    
    @ViewBuilder
    private var loadingView: some View {
        Spacer()
        LoadingView("Suche läuft...", fillScreen: false)
        Spacer()
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        Spacer()
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 80))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("ROM-Suche")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Verwende das Suchfeld oben, um ROMs zu finden")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        Spacer()
    }
    
    @ViewBuilder
    private var noResultsView: some View {
        Spacer()
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.magnifyingglass")
                .font(.system(size: 80))
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text("Keine Ergebnisse")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Keine ROMs für \"\(searchText)\" gefunden")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text("Versuche es mit anderen Suchbegriffen")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        Spacer()
    }
    
    @ViewBuilder
    private var searchResultsView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                resultCountHeader
                
                ForEach(searchViewModel.searchResults) { rom in
                    romResultRow(rom: rom)
                }
            }
        }
        .simultaneousGesture(
            DragGesture().onChanged { _ in
                isSearchFieldFocused = false
            }
        )
    }
    
    @ViewBuilder
    private var resultCountHeader: some View {
        if !searchViewModel.searchResults.isEmpty {
            HStack {
                Text("\(searchViewModel.searchResults.count) Ergebnis(se) gefunden")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 4)
        }
    }
    
    @ViewBuilder
    private func romResultRow(rom: Rom) -> some View {
        NavigationLink(destination: RomDetailView(rom: rom)) {
            SearchRomRowView(rom: rom)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
        
        if rom.id != searchViewModel.searchResults.last?.id {
            Divider()
                .padding(.leading, 72)
        }
    }
    
    @ToolbarContentBuilder
    private var cancelToolbarItem: some ToolbarContent {
        if !searchText.isEmpty {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Abbrechen") {
                    searchText = ""
                    searchViewModel.clearResults()
                    isSearchFieldFocused = false
                }
                .foregroundColor(.blue)
            }
        }
    }
    
    private func handleSearchTextChange(_ newValue: String) {
        // Cancel previous search task
        searchTask?.cancel()
        
        if newValue.isEmpty {
            searchViewModel.clearResults()
            return
        }
        
        // Start new search task with throttle
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            
            guard !Task.isCancelled else { return }
            
            await performSearch()
        }
    }
    
    private func performSearch() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }
        
        Task {
            await searchViewModel.search(query: query)
        }
    }
}



#Preview {
    SearchView()
        .environmentObject(AppData())
}
