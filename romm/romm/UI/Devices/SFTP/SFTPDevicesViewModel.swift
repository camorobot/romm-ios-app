import Foundation
import Observation

@Observable
class SFTPDevicesViewModel {
    var connections: [SFTPConnection] = []
    var isLoading = false
    var error: String?
    var showingAddDevice = false
    var editingConnection: SFTPConnection?
    var showingLocalDeviceDetail = false
    
    // Track running connection tests to allow cancellation
    private var runningTasks: [UUID: Task<Void, Never>] = [:]
    
    private let getAllConnectionsUseCase: GetAllConnectionsUseCase
    private let saveConnectionUseCase: SaveConnectionUseCase
    private let deleteConnectionUseCase: DeleteConnectionUseCase
    private let manageDefaultConnectionUseCase: ManageDefaultConnectionUseCase
    private let testConnectionUseCase: TestConnectionUseCase
    private let checkConnectionStatusUseCase: CheckConnectionStatusUseCase
    private let clearConnectionCacheUseCase: ClearConnectionCacheUseCase
    
    init(_ factory: DependencyFactoryProtocol = DefaultDependencyFactory.shared) {
        self.getAllConnectionsUseCase = factory.makeGetAllConnectionsUseCase()
        self.saveConnectionUseCase = factory.makeSaveConnectionUseCase()
        self.deleteConnectionUseCase = factory.makeDeleteConnectionUseCase()
        self.manageDefaultConnectionUseCase = factory.makeManageDefaultConnectionUseCase()
        self.testConnectionUseCase = factory.makeTestConnectionUseCase()
        self.checkConnectionStatusUseCase = factory.makeCheckConnectionStatusUseCase()
        self.clearConnectionCacheUseCase = factory.makeClearConnectionCacheUseCase()
    }
    
    func loadConnections() {
        connections = getAllConnectionsUseCase.execute()
    }

    func loadConnectionsAsync() async {
        loadConnections()
        
        // Only check status if we don't have cached status or if it's been a while
        // This prevents unnecessary network calls every time view appears
        let needsRefresh = connections.allSatisfy { $0.status == .disconnected }
        
        if needsRefresh {
            await refreshConnectionStatuses()
        }
    }
    
    func forceRefreshConnections() async {
        loadConnections()
        await refreshConnectionStatuses()
    }
    
    func addDevice() {
        editingConnection = nil
        showingAddDevice = true
    }
    
    func editDevice(_ connection: SFTPConnection) {
        editingConnection = connection
        showingAddDevice = true
    }
    
    func saveConnection(_ connection: SFTPConnection, credentials: SFTPCredentials) {
        do {
            try saveConnectionUseCase.execute(connection, credentials: credentials)
            showingAddDevice = false
            editingConnection = nil
            error = nil
            loadConnections() // Reload to get updated data
        } catch {
            self.error = "Failed to save connection: \(error.localizedDescription)"
        }
    }
    
    func deleteConnection(_ connection: SFTPConnection) async {
        do {
            try deleteConnectionUseCase.execute(connection)
            await clearConnectionCacheUseCase.execute(for: connection)
            error = nil
            loadConnections() // Reload to get updated data
        } catch {
            self.error = "Failed to delete connection: \(error.localizedDescription)"
        }
    }
    
    func setDefaultConnection(_ connection: SFTPConnection) {
        do {
            try manageDefaultConnectionUseCase.setDefaultConnection(connection)
            error = nil
            loadConnections() // Reload to get updated data
        } catch {
            self.error = "Failed to set default connection: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    func testConnection(_ connection: SFTPConnection) {
        // Cancel any existing test for this connection
        runningTasks[connection.id]?.cancel()
        
        // Immediately update UI to show testing state (non-blocking)
        connections = connections.map { conn in
            var updatedConnection = conn
            if updatedConnection.id == connection.id {
                updatedConnection.status = .connecting
            }
            return updatedConnection
        }
        
        // Perform actual test in background with proper cancellation support
        let task = Task.detached(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            
            do {
                let status = await self.checkConnectionStatusUseCase.execute(for: connection, forceRefresh: true)
                
                // Only update UI if task wasn't cancelled and self still exists
                guard !Task.isCancelled else { return }
                
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.connections = self.connections.map { conn in
                        var updatedConnection = conn
                        if updatedConnection.id == connection.id {
                            updatedConnection.status = status
                        }
                        return updatedConnection
                    }
                    // Remove completed task
                    self.runningTasks.removeValue(forKey: connection.id)
                }
            } catch {
                // Handle cancellation gracefully
                await MainActor.run { [weak self] in
                    guard let self = self, !Task.isCancelled else { return }
                    self.connections = self.connections.map { conn in
                        var updatedConnection = conn
                        if updatedConnection.id == connection.id {
                            updatedConnection.status = .error
                        }
                        return updatedConnection
                    }
                    self.runningTasks.removeValue(forKey: connection.id)
                }
            }
        }
        
        // Store task for potential cancellation
        runningTasks[connection.id] = task
    }
    
    func refreshConnectionStatuses() async {
        // Set all connections to connecting state immediately for UI feedback
        await MainActor.run {
            self.connections = self.connections.map { conn in
                var updatedConnection = conn
                updatedConnection.status = .connecting
                return updatedConnection
            }
        }
        
        // Check all connections in parallel (fast!)
        await checkConnectionStatusUseCase.executeForAllConnections(for: connections, forceRefresh: true)

        // Update local array with cached statuses (instant - no network calls)
        // Note: executeForAllConnections already updated the cache, so forceRefresh: false
        for i in 0..<connections.count {
            let status = await checkConnectionStatusUseCase.execute(for: connections[i], forceRefresh: false)
            await MainActor.run {
                self.connections[i].status = status
            }
        }
    }

    func showLocalDeviceDetail() {
        showingLocalDeviceDetail = true
    }
    
    // Cancel all running connection tests (call when view disappears)
    func cancelAllConnectionTests() {
        for task in runningTasks.values {
            task.cancel()
        }
        runningTasks.removeAll()
    }
    
    deinit {
        cancelAllConnectionTests()
    }
}
