import Foundation
import Observation

@MainActor
@Observable
class SFTPDevicesViewModel {
    var connections: [SFTPConnection] = []
    var isLoading = false
    var error: String?
    var showingAddDevice = false
    var editingConnection: SFTPConnection?
    var showingLocalDeviceDetail = false
    
    private let getAllConnectionsUseCase: GetAllConnectionsUseCase
    private let saveConnectionUseCase: SaveConnectionUseCase
    private let deleteConnectionUseCase: DeleteConnectionUseCase
    private let manageDefaultConnectionUseCase: ManageDefaultConnectionUseCase
    private let testConnectionUseCase: TestConnectionUseCase
    private let checkConnectionStatusUseCase: CheckConnectionStatusUseCase
    private let clearConnectionCacheUseCase: ClearConnectionCacheUseCase
    
    init(
        getAllConnectionsUseCase: GetAllConnectionsUseCase,
        saveConnectionUseCase: SaveConnectionUseCase,
        deleteConnectionUseCase: DeleteConnectionUseCase,
        manageDefaultConnectionUseCase: ManageDefaultConnectionUseCase,
        testConnectionUseCase: TestConnectionUseCase,
        checkConnectionStatusUseCase: CheckConnectionStatusUseCase,
        clearConnectionCacheUseCase: ClearConnectionCacheUseCase
    ) {
        self.getAllConnectionsUseCase = getAllConnectionsUseCase
        self.saveConnectionUseCase = saveConnectionUseCase
        self.deleteConnectionUseCase = deleteConnectionUseCase
        self.manageDefaultConnectionUseCase = manageDefaultConnectionUseCase
        self.testConnectionUseCase = testConnectionUseCase
        self.checkConnectionStatusUseCase = checkConnectionStatusUseCase
        self.clearConnectionCacheUseCase = clearConnectionCacheUseCase
        
        loadConnections()
        Task {
            await refreshConnectionStatuses()
        }
    }
    
    func loadConnections() {
        connections = getAllConnectionsUseCase.execute()
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
    
    func deleteConnection(_ connection: SFTPConnection) {
        do {
            try deleteConnectionUseCase.execute(connection)
            clearConnectionCacheUseCase.execute(for: connection)
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
    
    func testConnection(_ connection: SFTPConnection) async {
        let status = await checkConnectionStatusUseCase.execute(for: connection, forceRefresh: true)
        
        // Update the connection status in our local array
        connections = connections.map { conn in
            var updatedConnection = conn
            if updatedConnection.id == connection.id {
                updatedConnection.status = status
            }
            return updatedConnection
        }
    }
    
    func refreshConnectionStatuses() async {
        await checkConnectionStatusUseCase.executeForAllConnections(for: connections, forceRefresh: true)

        // Update all connection statuses
        for i in 0..<connections.count {
            let status = await checkConnectionStatusUseCase.execute(for: connections[i])
            connections[i].status = status
        }
    }

    func showLocalDeviceDetail() {
        showingLocalDeviceDetail = true
    }
}