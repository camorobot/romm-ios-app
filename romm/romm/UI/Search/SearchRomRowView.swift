//
//  SearchRomRowView.swift
//  romm
//
//  Created by Ilyas Hallak on 27.08.25.
//

import SwiftUI

struct SearchRomRowView: View {
    let rom: Rom
    
    private var platformName: String {
        // Use platform from ROM data if available, otherwise show platform ID
        if let platformSlug = rom.platformSlug {
            return platformSlug
        } else {
            return ""
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
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
                            .font(.caption)
                    )
            }
            .frame(width: 40, height: 40)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            
            VStack(alignment: .leading, spacing: 3) {
                Text(rom.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    // Plattform-Chip
                    Text(platformName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.8))
                        .clipShape(Capsule())
                    
                    // Jahr
                    if let year = rom.releaseYear?.description {
                        Text(year)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                // Zusätzliche Info-Zeile
                HStack(spacing: 8) {
                    // Regions
                    if !rom.regions.isEmpty {
                        ForEach(rom.regions.prefix(2), id: \.self) { region in
                            Text(flagEmoji(for: region))
                                .font(.caption)
                        }
                    }
                    
                    // Languages
                    if !rom.languages.isEmpty {
                        ForEach(rom.languages.prefix(1), id: \.self) { language in
                            Text(languageEmoji(for: language))
                                .font(.caption)
                        }
                    }
                    
                    Spacer()
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                RomStatusIcons(rom: rom)
                
                // Rating wenn vorhanden
                if let rating = rom.rating, rating > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption2)
                        Text(String(format: "%.1f", rating))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func flagEmoji(for regionCode: String) -> String {
        let regionMappings: [String: String] = [
            "USA": "🇺🇸", "US": "🇺🇸", "NTSC": "🇺🇸",
            "Europe": "🇪🇺", "EUR": "🇪🇺", "PAL": "🇪🇺",
            "Japan": "🇯🇵", "JPN": "🇯🇵", "JP": "🇯🇵",
            "Germany": "🇩🇪", "GER": "🇩🇪", "DE": "🇩🇪",
            "France": "🇫🇷", "FR": "🇫🇷", "FRA": "🇫🇷",
            "Spain": "🇪🇸", "ES": "🇪🇸", "ESP": "🇪🇸",
            "Italy": "🇮🇹", "IT": "🇮🇹", "ITA": "🇮🇹",
            "UK": "🇬🇧", "GB": "🇬🇧", "United Kingdom": "🇬🇧",
            "World": "🌍", "WW": "🌍", "WORLD": "🌍"
        ]
        
        return regionMappings[regionCode] ?? "🌍"
    }
    
    private func languageEmoji(for languageCode: String) -> String {
        let languageMappings: [String: String] = [
            "English": "🇬🇧", "EN": "🇬🇧", "en": "🇬🇧",
            "German": "🇩🇪", "DE": "🇩🇪", "de": "🇩🇪",
            "French": "🇫🇷", "FR": "🇫🇷", "fr": "🇫🇷",
            "Spanish": "🇪🇸", "ES": "🇪🇸", "es": "🇪🇸",
            "Italian": "🇮🇹", "IT": "🇮🇹", "it": "🇮🇹",
            "Japanese": "🇯🇵", "JP": "🇯🇵", "ja": "🇯🇵",
            "Korean": "🇰🇷", "KR": "🇰🇷", "ko": "🇰🇷",
            "Portuguese": "🇵🇹", "PT": "🇵🇹", "pt": "🇵🇹"
        ]
        
        return languageMappings[languageCode] ?? "🗣️"
    }
}

#Preview {
    SearchRomRowView(
        rom: Rom(
            id: 1,
            name: "Super Mario Bros. 3",
            platformId: 1,
            urlCover: nil,
            releaseYear: 1988,
            rating: 4.5,
            languages: ["English"],
            regions: ["USA"]
        )
    )
}
