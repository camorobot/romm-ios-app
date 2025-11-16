//
//  Stats.swift
//  romm
//
//  Created by Ilyas Hallak on 16.11.25.
//

import Foundation

struct Stats: Equatable, Hashable {
    let platforms: Int
    let roms: Int
    let saves: Int
    let states: Int
    let screenshots: Int
    let totalFilesizeBytes: Int

    init(
        platforms: Int,
        roms: Int,
        saves: Int,
        states: Int,
        screenshots: Int,
        totalFilesizeBytes: Int
    ) {
        self.platforms = platforms
        self.roms = roms
        self.saves = saves
        self.states = states
        self.screenshots = screenshots
        self.totalFilesizeBytes = totalFilesizeBytes
    }
}
