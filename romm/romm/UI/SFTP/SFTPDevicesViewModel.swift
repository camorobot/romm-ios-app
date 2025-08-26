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
    
    private let sftpUseCases: SFTPUseCases
    
    init(sftpUseCases: SFTPUseCases = SFTPUseCases()) {
        self.sftpUseCases = sftpUseCases
        
        loadConnections()
        Task {
            await refreshConnectionStatuses()
        }
    }
    
    func loadConnections() {
        connections = sftpUseCases.getAllConnections()
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
            try sftpUseCases.saveConnection(connection, credentials: credentials)
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
            try sftpUseCases.deleteConnection(connection)
            sftpUseCases.clearConnectionCache(for: connection)
            error = nil
            loadConnections() // Reload to get updated data
        } catch {
            self.error = "Failed to delete connection: \(error.localizedDescription)"
        }
    }
    
    func setDefaultConnection(_ connection: SFTPConnection) {
        do {
            try sftpUseCases.setDefaultConnection(connection)
            error = nil
            loadConnections() // Reload to get updated data
        } catch {
            self.error = "Failed to set default connection: \(error.localizedDescription)"
        }
    }
    
    func testConnection(_ connection: SFTPConnection) async {
        let status = await sftpUseCases.checkConnectionStatus(for: connection, forceRefresh: true)
        
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
        await sftpUseCases.checkAllConnectionStatuses(for: connections, forceRefresh: true)
        
        // Update all connection statuses
        for i in 0..<connections.count {
            let status = await sftpUseCases.checkConnectionStatus(for: connections[i])
            connections[i].status = status
        }
    }
}