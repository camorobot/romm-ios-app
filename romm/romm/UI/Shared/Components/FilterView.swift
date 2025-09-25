//
//  FilterView.swift
//  romm
//
//  Created by Ilyas Hallak on 24.09.25.
//

import SwiftUI

// MARK: - Filter Options Data Structure
struct FilterOptions {
    let genres: [String]
    let franchises: [String]
    let collections: [String]
    let companies: [String]
    let ageRatings: [String]
    let regions: [String]
    let languages: [String]
    let statuses: [String]
}

// MARK: - Filter States
struct FilterStates {
    // Toggle states
    var showUnmatched: Bool = false
    var showMatched: Bool = false
    var showFavourites: Bool = false
    var showDuplicates: Bool = false
    var showMissing: Bool = false
    var showVerified: Bool = false
    var showRetroAchievements: Bool = false
    
    // Single selection filters
    var selectedGenre: String? = nil
    var selectedFranchise: String? = nil
    var selectedCollection: String? = nil
    var selectedCompany: String? = nil
    var selectedAgeRating: String? = nil
    var selectedRegion: String? = nil
    var selectedLanguage: String? = nil
    var selectedStatus: String? = nil
}

// MARK: - Filter View
struct FilterView: View {
    let filterOptions: FilterOptions
    @Binding var filterStates: FilterStates
    let onReset: () -> Void
    let onApply: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    private var hasActiveFilters: Bool {
        filterStates.showUnmatched ||
        filterStates.showMatched ||
        filterStates.showFavourites ||
        filterStates.showDuplicates ||
        filterStates.showMissing ||
        filterStates.showVerified ||
        filterStates.showRetroAchievements ||
        filterStates.selectedGenre != nil ||
        filterStates.selectedFranchise != nil ||
        filterStates.selectedCollection != nil ||
        filterStates.selectedCompany != nil ||
        filterStates.selectedAgeRating != nil ||
        filterStates.selectedRegion != nil ||
        filterStates.selectedLanguage != nil ||
        filterStates.selectedStatus != nil
    }
    
    private var hasAvailableFilters: Bool {
        !filterOptions.genres.isEmpty ||
        !filterOptions.franchises.isEmpty ||
        !filterOptions.collections.isEmpty ||
        !filterOptions.companies.isEmpty ||
        !filterOptions.ageRatings.isEmpty ||
        !filterOptions.regions.isEmpty ||
        !filterOptions.languages.isEmpty ||
        !filterOptions.statuses.isEmpty
    }
    
    var body: some View {
        NavigationView {
            List {
                // Toggle Filters Section
                Section("Quick Filters") {
                    FilterToggleRow(title: "Show Unmatched", icon: "magnifyingglass.circle", isOn: $filterStates.showUnmatched)
                    FilterToggleRow(title: "Show Matched", icon: "magnifyingglass.circle.fill", isOn: $filterStates.showMatched)
                    FilterToggleRow(title: "Show Favourites", icon: "star.fill", isOn: $filterStates.showFavourites)
                    FilterToggleRow(title: "Show Duplicates", icon: "rectangle.on.rectangle.fill", isOn: $filterStates.showDuplicates)
                    FilterToggleRow(title: "Show Missing", icon: "questionmark.circle.fill", isOn: $filterStates.showMissing)
                    FilterToggleRow(title: "Show Verified", icon: "checkmark.seal.fill", isOn: $filterStates.showVerified)
                    FilterToggleRow(title: "Show RetroAchievements", icon: "trophy.fill", isOn: $filterStates.showRetroAchievements)
                }
                
                // Picker Filters Section
                Section("Filters") {
                    PickerRow(title: "Genre", options: filterOptions.genres, selectedOption: $filterStates.selectedGenre)
                    PickerRow(title: "Franchise", options: filterOptions.franchises, selectedOption: $filterStates.selectedFranchise)
                    PickerRow(title: "Collection", options: filterOptions.collections, selectedOption: $filterStates.selectedCollection)
                    PickerRow(title: "Company", options: filterOptions.companies, selectedOption: $filterStates.selectedCompany)
                    PickerRow(title: "Age Rating", options: filterOptions.ageRatings, selectedOption: $filterStates.selectedAgeRating)
                    PickerRow(title: "Region", options: filterOptions.regions, selectedOption: $filterStates.selectedRegion)
                    PickerRow(title: "Language", options: filterOptions.languages, selectedOption: $filterStates.selectedLanguage)
                    PickerRow(title: "Status", options: filterOptions.statuses, selectedOption: $filterStates.selectedStatus)
                }
                
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
                
                ToolbarItemGroup(placement: .bottomBar) {
                    Button("Reset") {
                        onReset()
                    }
                    .foregroundColor(.red)
                    .disabled(!hasActiveFilters)
                    
                    Spacer()
                    
                    Button("Apply Filters") {
                        onApply()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}

// MARK: - Filter Toggle Row
struct FilterToggleRow: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
    }
}

// MARK: - Picker Row
struct PickerRow: View {
    let title: String
    let options: [String]
    @Binding var selectedOption: String?
    
    private var hasOptions: Bool {
        !options.isEmpty
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(hasOptions ? .primary : .secondary)
            
            Spacer()
            
            Picker("", selection: $selectedOption) {
                Text("All").tag(nil as String?)
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option as String?)
                }
            }
            .pickerStyle(.menu)
            .tint(hasOptions ? .blue : .secondary)
            .disabled(!hasOptions)
        }
    }
}

// MARK: - Previews
#Preview {
    FilterView(
        filterOptions: FilterOptions(
            genres: ["Action", "Adventure", "RPG", "Strategy"],
            franchises: ["Mario", "Zelda", "Pokémon"],
            collections: ["Nintendo Hits", "Greatest Games"],
            companies: ["Nintendo", "Sony", "Microsoft"],
            ageRatings: ["E", "T", "M"],
            regions: ["North America", "Europe", "Japan"],
            languages: ["English", "German", "French"],
            statuses: ["Complete", "Incomplete"]
        ),
        filterStates: .constant(FilterStates()),
        onReset: { },
        onApply: { }
    )
}