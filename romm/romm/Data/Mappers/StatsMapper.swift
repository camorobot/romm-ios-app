//
//  StatsMapper.swift
//  romm
//
//  Created by Ilyas Hallak on 16.11.25.
//

import Foundation

struct StatsMapper {
    static func mapFromAPI(_ apiStats: StatsReturn) -> Stats {
        return Stats(
            platforms: apiStats.PLATFORMS,
            roms: apiStats.ROMS,
            saves: apiStats.SAVES,
            states: apiStats.STATES,
            screenshots: apiStats.SCREENSHOTS,
            totalFilesizeBytes: apiStats.TOTAL_FILESIZE_BYTES
        )
    }
}
