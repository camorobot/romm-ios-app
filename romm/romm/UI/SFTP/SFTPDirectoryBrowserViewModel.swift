import Foundation

@MainActor
@Observable
class SFTPDirectoryBrowserViewModel {
    var directoryItems: [SFTPDirectoryItem] = []
    var currentPath = "/"
    var isLoading = false
    var error: String?
    var selectedPath: String?
    var favoriteDirectories: [String] = []
    
    private let connection: SFTPConnection
    private let sftpUseCases: SFTPUseCases
    private var pathHistory: [String] = ["/"]
    
    init(connection: SFTPConnection, sftpUseCases: SFTPUseCases) {
        self.connection = connection
        self.sftpUseCases = sftpUseCases
        
        loadFavoriteDirectories()
    }
    
    var canGoBack: Bool {
        pathHistory.count > 1
    }
    
    var canGoUp: Bool {
        currentPath != "/"
    }
    
    var directories: [SFTPDirectoryItem] {
        directoryItems.filter { $0.isDirectory }.sorted { $0.name.lowercased() < $1.name.lowercased() }
    }
    
    var files: [SFTPDirectoryItem] {
        directoryItems.filter { !$0.isDirectory }.sorted { $0.name.lowercased() < $1.name.lowercased() }
    }
    
    func loadDirectory(path: String? = nil) async {
        let targetPath = path ?? currentPath
        
        isLoading = true
        error = nil
        
        do {
            let items = try await sftpUseCases.listDirectory(at: targetPath, connection: connection)
            
            directoryItems = items
            
            if path != nil {
                currentPath = targetPath
                pathHistory.append(targetPath)
            }
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func navigateToDirectory(_ item: SFTPDirectoryItem) async {
        guard item.isDirectory else { return }
        await loadDirectory(path: item.path)
    }
    
    func goBack() async {
        guard pathHistory.count > 1 else { return }
        
        pathHistory.removeLast()
        let previousPath = pathHistory.last ?? "/"
        currentPath = previousPath
        await loadDirectory()
    }
    
    func goUp() async {
        guard currentPath != "/" else { return }
        
        let parentPath = URL(fileURLWithPath: currentPath).deletingLastPathComponent().path
        let normalizedPath = parentPath.isEmpty || parentPath == "/" ? "/" : parentPath
        
        await loadDirectory(path: normalizedPath)
    }
    
    func goToRoot() async {
        await loadDirectory(path: "/")
    }
    
    func selectCurrentPath() {
        selectedPath = currentPath
    }
    
    func addToFavorites(_ path: String) {
        do {
            try sftpUseCases.addFavoriteDirectory(path, for: connection.id)
            loadFavoriteDirectories()
        } catch {
            self.error = "Failed to add favorite: \(error.localizedDescription)"
        }
    }
    
    func removeFromFavorites(_ path: String) {
        do {
            try sftpUseCases.removeFavoriteDirectory(path, for: connection.id)
            loadFavoriteDirectories()
        } catch {
            self.error = "Failed to remove favorite: \(error.localizedDescription)"
        }
    }
    
    func navigateToFavorite(_ path: String) async {
        await loadDirectory(path: path)
    }
    
    func createDirectory(name: String) async {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            error = "Directory name cannot be empty"
            return
        }
        
        let newDirPath = currentPath.hasSuffix("/") ? "\(currentPath)\(name)" : "\(currentPath)/\(name)"
        
        do {
            try await sftpUseCases.createDirectory(at: newDirPath, connection: connection)
            await loadDirectory()
        } catch {
            self.error = "Failed to create directory: \(error.localizedDescription)"
        }
    }
    
    private func loadFavoriteDirectories() {
        favoriteDirectories = sftpUseCases.getFavoriteDirectories(for: connection.id)
    }
    
    var currentPathComponents: [String] {
        guard currentPath != "/" else { return ["Root"] }
        
        let components = currentPath.split(separator: "/").map(String.init)
        return ["Root"] + components
    }
    
    func navigateToPathComponent(at index: Int) async {
        let components = currentPath.split(separator: "/").map(String.init)
        
        if index == 0 {
            await goToRoot()
            return
        }
        
        let targetComponents = Array(components.prefix(index))
        let targetPath = "/" + targetComponents.joined(separator: "/")
        
        await loadDirectory(path: targetPath)
    }
}