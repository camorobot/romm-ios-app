import Foundation

enum FileType: String, CaseIterable {
    case directory = "directory"
    case rom = "rom"
    case archive = "archive"
    case image = "image"
    case document = "document"
    case unknown = "unknown"
    
    var iconName: String {
        switch self {
        case .directory:
            return "folder.fill"
        case .rom:
            return "gamecontroller.fill"
        case .archive:
            return "archivebox.fill"
        case .image:
            return "photo.fill"
        case .document:
            return "doc.fill"
        case .unknown:
            return "questionmark.circle.fill"
        }
    }
    
    static func fromFileExtension(_ extension: String) -> FileType {
        let lowercased = `extension`.lowercased()
        
        // ROM file extensions
        let romExtensions = [
            "nes", "snes", "smc", "sfc", "gb", "gbc", "gba", "nds", "3ds",
            "n64", "z64", "v64", "gcm", "iso", "wbfs", "rvz", "nkit",
            "md", "smd", "gen", "32x", "sms", "gg", "sg", "sc",
            "pce", "sgx", "tg16", "ws", "wsc", "ngp", "ngc",
            "lynx", "jag", "7z", "zip", "rar", "tar", "gz"
        ]
        
        // Archive extensions
        let archiveExtensions = ["zip", "7z", "rar", "tar", "gz", "bz2", "xz"]
        
        // Image extensions
        let imageExtensions = ["jpg", "jpeg", "png", "gif", "bmp", "tiff", "webp"]
        
        // Document extensions
        let documentExtensions = ["txt", "pdf", "doc", "docx", "rtf", "md"]
        
        if romExtensions.contains(lowercased) {
            return .rom
        } else if archiveExtensions.contains(lowercased) {
            return .archive
        } else if imageExtensions.contains(lowercased) {
            return .image
        } else if documentExtensions.contains(lowercased) {
            return .document
        } else {
            return .unknown
        }
    }
}

struct FilePermissions: Codable, Equatable {
    let owner: String
    let group: String
    let other: String
    let octal: String
    
    init(octalString: String) {
        self.octal = octalString
        
        // Parse octal permissions (e.g., "755" -> "rwxr-xr-x")
        let octalValue = Int(octalString.suffix(3), radix: 8) ?? 0
        
        func parsePermissionSet(_ value: Int) -> String {
            var result = ""
            result += (value & 4) != 0 ? "r" : "-"
            result += (value & 2) != 0 ? "w" : "-"
            result += (value & 1) != 0 ? "x" : "-"
            return result
        }
        
        self.owner = parsePermissionSet((octalValue >> 6) & 7)
        self.group = parsePermissionSet((octalValue >> 3) & 7)
        self.other = parsePermissionSet(octalValue & 7)
    }
    
    var displayString: String {
        return "\(owner)\(group)\(other)"
    }
    
    var isReadable: Bool {
        return owner.contains("r")
    }
    
    var isWritable: Bool {
        return owner.contains("w")
    }
    
    var isExecutable: Bool {
        return owner.contains("x")
    }
}

struct RemoteFile: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let name: String
    let path: String
    let fullPath: String
    let size: Int64
    let modifiedDate: Date
    let isDirectory: Bool
    let permissions: FilePermissions?
    let owner: String?
    let group: String?
    
    // Computed properties
    var fileExtension: String {
        guard !isDirectory else { return "" }
        return (name as NSString).pathExtension
    }
    
    var fileType: FileType {
        guard !isDirectory else { return .directory }
        return FileType.fromFileExtension(fileExtension)
    }
    
    var formattedSize: String {
        guard !isDirectory else { return "--" }
        return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
    
    var parentPath: String {
        return (fullPath as NSString).deletingLastPathComponent
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        path: String,
        size: Int64 = 0,
        modifiedDate: Date = Date(),
        isDirectory: Bool = false,
        permissions: FilePermissions? = nil,
        owner: String? = nil,
        group: String? = nil
    ) {
        self.id = id
        self.name = name
        self.path = path
        self.fullPath = (path as NSString).appendingPathComponent(name)
        self.size = size
        self.modifiedDate = modifiedDate
        self.isDirectory = isDirectory
        self.permissions = permissions
        self.owner = owner
        self.group = group
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: RemoteFile, rhs: RemoteFile) -> Bool {
        return lhs.id == rhs.id
    }
}

extension RemoteFile {
    static let mockDirectory = RemoteFile(
        name: "Nintendo",
        path: "/roms",
        isDirectory: true,
        permissions: FilePermissions(octalString: "755"),
        owner: "romm",
        group: "romm"
    )
    
    static let mockRomFile = RemoteFile(
        name: "Super Mario Bros.nes",
        path: "/roms/Nintendo/NES",
        size: 40960,
        modifiedDate: Date().addingTimeInterval(-86400),
        isDirectory: false,
        permissions: FilePermissions(octalString: "644"),
        owner: "romm",
        group: "romm"
    )
    
    static let mockFiles: [RemoteFile] = [
        mockDirectory,
        RemoteFile(
            name: "Sega",
            path: "/roms",
            isDirectory: true,
            permissions: FilePermissions(octalString: "755"),
            owner: "romm",
            group: "romm"
        ),
        mockRomFile,
        RemoteFile(
            name: "Sonic the Hedgehog.md",
            path: "/roms/Sega/Genesis",
            size: 524288,
            modifiedDate: Date().addingTimeInterval(-172800),
            isDirectory: false,
            permissions: FilePermissions(octalString: "644"),
            owner: "romm",
            group: "romm"
        )
    ]
}