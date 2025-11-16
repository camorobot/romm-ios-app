//
//  PlatformStatsRowView.swift
//  romm
//
//  Created by Ilyas Hallak on 16.11.25.
//

import SwiftUI

struct PlatformStatsRowView: View {
    let platformStats: PlatformStats

    private var platformColor: Color {
        // Generate a consistent color based on the platform slug
        let hash = abs(platformStats.slug.hashValue)
        let hue = Double(hash % 360) / 360.0
        return Color(hue: hue, saturation: 0.6, brightness: 0.8)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // Platform icon/logo
                if let logoPath = platformStats.logoPath, !logoPath.isEmpty {
                    AsyncImage(url: URL(string: logoPath)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        platformFallbackIcon
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    platformFallbackIcon
                }

                // Platform info
                VStack(alignment: .leading, spacing: 4) {
                    Text(platformStats.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    HStack(spacing: 8) {
                        Text(platformStats.slug)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        if !platformStats.manufacturer.isEmpty && platformStats.manufacturer != "Unknown" {
                            Text("•")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text(platformStats.manufacturer)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer()

                // Size and ROM count
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(ByteFormatter.format(platformStats.sizeBytes))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        Text("(\(String(format: "%.1f", platformStats.percentage))%)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text("\(platformStats.romCount) roms")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)

                    // Progress
                    RoundedRectangle(cornerRadius: 4)
                        .fill(platformColor)
                        .frame(
                            width: geometry.size.width * CGFloat(min(platformStats.percentage / 100.0, 1.0)),
                            height: 8
                        )
                }
            }
            .frame(height: 8)
        }
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var platformFallbackIcon: some View {
        Image(systemName: "gamecontroller.fill")
            .font(.system(size: 30))
            .foregroundColor(.blue)
            .frame(width: 50, height: 50)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    List {
        PlatformStatsRowView(
            platformStats: PlatformStats(
                id: 1,
                name: "Game Boy Advance",
                slug: "gba",
                manufacturer: "Nintendo",
                romCount: 695,
                sizeBytes: 11_430_000_000,
                percentage: 3.7,
                logoPath: nil
            )
        )

        PlatformStatsRowView(
            platformStats: PlatformStats(
                id: 2,
                name: "Dreamcast",
                slug: "dc",
                manufacturer: "Sega",
                romCount: 6,
                sizeBytes: 2_930_000_000,
                percentage: 1.0,
                logoPath: nil
            )
        )
    }
}
