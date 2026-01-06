//
//  EmulatorViewModel.swift
//  romm
//
//  Created by Ilyas Hallak on 11.12.25.
//

import Foundation
import Observation

@Observable
@MainActor
class EmulatorViewModel {
    // State
    var isLoading: Bool = true
    var showControls: Bool = false
    var errorMessage: String?
    var emulatorURL: URL?

    // Dependencies
    private let rom: Rom
    private let tokenProvider: TokenProviderProtocol
    private let logger = Logger.viewModel

    init(
        rom: Rom,
        tokenProvider: TokenProviderProtocol = TokenProvider()
    ) {
        self.rom = rom
        self.tokenProvider = tokenProvider
    }

    func startEmulator() {
        logger.info("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        logger.info("🎮 Starting emulator for ROM: \(rom.name) (ID: \(rom.id))")
        logger.info("Platform: \(rom.platformSlug ?? "unknown")")

        guard let serverURLString = tokenProvider.getServerURL() else {
            logger.error("❌ No server configured")
            errorMessage = "No server configured. Please set up your ROMM server in Settings."
            isLoading = false
            return
        }
        logger.info("✅ Server URL: \(serverURLString)")

        // Build ROMM's EmulatorJS player URL
        let cleanServerURL = serverURLString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let url = URL(string: "\(cleanServerURL)/rom/\(rom.id)/ejs") else {
            logger.error("❌ Failed to create emulator URL")
            errorMessage = "Failed to create emulator URL"
            isLoading = false
            return
        }

        emulatorURL = url
        logger.info("✅ Emulator URL: \(url.absoluteString)")
        logger.info("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }


    func cleanup() {
        logger.info("Cleaning up emulator session for ROM: \(rom.name)")
        // Optional: Send "exit" event to server to save state
        // Or rely on server's auto-save
        // Future: Could call /api/states to ensure state is saved
    }

    func clearError() {
        errorMessage = nil
    }
}
