import Foundation

/// Represents the type of transfer operation
enum TransferType: String, Codable {
    case upload = "upload"      // SFTP upload to remote device
    case download = "download"  // Download to local device
}

/// Domain model for transfer history (SFTP uploads and local downloads)
struct TransferHistory: Identifiable, Equatable {
    let id: UUID
    let deviceId: UUID
    let deviceName: String
    let deviceType: DeviceType
    let transferType: TransferType
    let romId: Int
    let romName: String
    let platformName: String
    let platformSlug: String?
    let fileSizeBytes: Int64
    let transferDate: Date
    let success: Bool

    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: fileSizeBytes, countStyle: .file)
    }

    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: transferDate, relativeTo: Date())
    }

    var fullDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: transferDate)
    }

    init(
        id: UUID = UUID(),
        deviceId: UUID,
        deviceName: String,
        deviceType: DeviceType,
        transferType: TransferType,
        romId: Int,
        romName: String,
        platformName: String,
        platformSlug: String? = nil,
        fileSizeBytes: Int64,
        transferDate: Date = Date(),
        success: Bool = true
    ) {
        self.id = id
        self.deviceId = deviceId
        self.deviceName = deviceName
        self.deviceType = deviceType
        self.transferType = transferType
        self.romId = romId
        self.romName = romName
        self.platformName = platformName
        self.platformSlug = platformSlug
        self.fileSizeBytes = fileSizeBytes
        self.transferDate = transferDate
        self.success = success
    }

    static func == (lhs: TransferHistory, rhs: TransferHistory) -> Bool {
        return lhs.id == rhs.id
    }
}

/// Grouped transfer history by platform
struct TransferHistoryByPlatform: Identifiable {
    let id: String  // platformName
    let platformName: String
    let platformSlug: String?
    var transfers: [TransferHistory]

    var totalSize: Int64 {
        transfers.reduce(0) { $0 + $1.fileSizeBytes }
    }

    var formattedTotalSize: String {
        ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
    }

    var transferCount: Int {
        transfers.count
    }
}
