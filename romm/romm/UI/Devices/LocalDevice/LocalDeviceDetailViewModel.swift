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
        // Don't load automatically - prevents UI blocking during navigation
        // View will trigger loading via .task modifier
    }

    // MARK: - Public Methods

    /// Loads downloaded ROMs asynchronously to avoid blocking main thread
    func loadDownloadedROMsAsync() async {
        isLoading = true
        error = nil

        // Perform FileManager operations in background
        let result = await Task.detached(priority: .userInitiated) { [repository = self.repository] () -> Result<(roms: [DownloadedROM], byPlatform: [String: [DownloadedROM]], totalSize: Int64), Error> in
            do {
                let downloadedROMs = try repository.getAllDownloadedROMs()
                let romsByPlatform = try repository.getDownloadedROMsByPlatform()
                let totalDownloadedSize = try repository.getTotalDownloadedSize()
                return .success((downloadedROMs, romsByPlatform, totalDownloadedSize))
            } catch {
                return .failure(error)
            }
        }.value

        // Update UI on main thread
        switch result {
        case .success(let data):
            self.downloadedROMs = data.roms
            self.romsByPlatform = data.byPlatform
            self.totalDownloadedSize = data.totalSize
        case .failure(let error):
            self.error = "Failed to load downloaded ROMs: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// Legacy synchronous method - prefer loadDownloadedROMsAsync() for better performance
    @available(*, deprecated, message: "Use loadDownloadedROMsAsync() instead")
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

    func refreshStorageInfo() async {
        await LocalDeviceManager.shared.updateStorageInfoAsync()
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
