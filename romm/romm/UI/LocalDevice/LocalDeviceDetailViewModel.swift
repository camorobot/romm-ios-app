import Foundation
import Observation

@MainActor
@Observable
class LocalDeviceDetailViewModel {
    var downloadedROMs: [DownloadedROM] = []
    var romsByPlatform: [String: [DownloadedROM]] = [:]
    var isLoading = false
    var error: String?
    var totalDownloadedSize: Int64 = 0
    var showingDeleteConfirmation = false
    var romToDelete: DownloadedROM?

    private let repository: LocalROMRepositoryProtocol

    init(repository: LocalROMRepositoryProtocol = LocalROMRepository()) {
        self.repository = repository
        loadDownloadedROMs()
    }

    // MARK: - Public Methods

    func loadDownloadedROMs() {
        isLoading = true
        error = nil

        do {
            downloadedROMs = try repository.getAllDownloadedROMs()
            romsByPlatform = try repository.getDownloadedROMsByPlatform()
            totalDownloadedSize = try repository.getTotalDownloadedSize()
        } catch {
            self.error = "Failed to load downloaded ROMs: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func confirmDelete(_ rom: DownloadedROM) {
        romToDelete = rom
        showingDeleteConfirmation = true
    }

    func deleteROM() {
        guard let rom = romToDelete else { return }

        do {
            try repository.deleteDownloadedROM(rom)
            romToDelete = nil
            showingDeleteConfirmation = false
            loadDownloadedROMs()
        } catch {
            self.error = "Failed to delete ROM: \(error.localizedDescription)"
        }
    }

    func refreshStorageInfo() {
        LocalDeviceManager.shared.updateStorageInfo()
    }

    var totalDownloadedSizeFormatted: String {
        ByteCountFormatter.string(fromByteCount: totalDownloadedSize, countStyle: .file)
    }

    var platformNames: [String] {
        Array(romsByPlatform.keys).sorted()
    }

    var hasDownloadedROMs: Bool {
        !downloadedROMs.isEmpty
    }
}
