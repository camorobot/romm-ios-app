//
//  SearchView.swift
//  romm
//
//  Created by Ilyas Hallak on 07.08.25.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var searchViewModel = SearchViewModel()
    @StateObject private var userViewModel = UserViewModel()
    @EnvironmentObject var appData: AppData
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                SearchBar(text: $searchText, onSearchButtonClicked: {
                    Task {
                        await searchViewModel.search(query: searchText)
                    }
                })
                
                // Search Results
                if searchViewModel.isLoading {
                    ProgressView("Searching...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if searchText.isEmpty && searchViewModel.searchResults.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("Search ROMs")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("Enter a ROM name to start searching")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if searchViewModel.searchResults.isEmpty && !searchText.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No results found")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("Try searching with different keywords")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(searchViewModel.searchResults) { result in
                        SearchResultRowView(searchResult: result)
                            .onTapGesture {
                                // Navigate to ROM details or download
                            }
                    }
                }
            }
            .navigationTitle("Suche")
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
            .alert("Error", isPresented: .constant(searchViewModel.errorMessage != nil)) {
                Button("OK") {
                    searchViewModel.clearError()
                }
            } message: {
                Text(searchViewModel.errorMessage ?? "")
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    let onSearchButtonClicked: () -> Void
    
    var body: some View {
        HStack {
            TextField("Search ROMs...", text: $text)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    onSearchButtonClicked()
                }
            
            Button(action: onSearchButtonClicked) {
                Image(systemName: "magnifyingglass")
            }
            .buttonStyle(.borderedProminent)
            .disabled(text.isEmpty)
        }
        .padding()
    }
}

struct SearchResultRowView: View {
    let searchResult: SearchRom
    
    var body: some View {
        HStack {
            // Search result cover placeholder
            CachedAsyncImage(urlString: searchResult.coverUrl) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(searchResult.name)
                    .font(.headline)
                    .lineLimit(1)
                
                if let platform = searchResult.platform {
                    Text(platform)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let year = searchResult.releaseYear {
                    Text("\(year)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "arrow.down.circle")
                .foregroundColor(.blue)
        }
        .padding(.vertical, 4)
    }
}

// Placeholder models for search functionality
struct SearchRom: Identifiable {
    let id = UUID()
    let name: String
    let platform: String?
    let releaseYear: Int?
    let coverUrl: String?
}

class SearchViewModel: ObservableObject {
    @Published var searchResults: [SearchRom] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func search(query: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Placeholder search implementation
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        await MainActor.run {
            isLoading = false
            searchResults = []
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}

#Preview {
    SearchView()
        .environmentObject(AppData())
}