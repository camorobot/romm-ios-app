import SwiftUI

struct SFTPDevicesView: View {
    @State private var viewModel = SFTPDevicesViewModel()
    
    init(dependencyFactory: DependencyFactoryProtocol = DefaultDependencyFactory.shared) {
        // With @Observable, we use simple initialization
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.connections.isEmpty && !viewModel.isLoading {
                    emptyStateView
                } else {
                    devicesList
                }
            }
            .navigationTitle("SFTP Devices")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Device") {
                        viewModel.addDevice()
                    }
                }
            }
            .refreshable {
                await viewModel.refreshConnectionStatuses()
            }
            .sheet(isPresented: $viewModel.showingAddDevice) {
                AddEditSFTPDeviceView(
                    connection: viewModel.editingConnection,
                    onSave: viewModel.saveConnection
                )
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.error = nil
                }
            } message: {
                Text(viewModel.error ?? "")
            }
        }
        .task {
            await viewModel.refreshConnectionStatuses()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "server.rack")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("No SFTP Devices")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add your first SFTP device to start transferring ROM files")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Add Device") {
                viewModel.addDevice()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private var devicesList: some View {
        List {
            ForEach(viewModel.connections) { connection in
                DeviceRow(
                    connection: connection,
                    onEdit: { viewModel.editDevice(connection) },
                    onDelete: { viewModel.deleteConnection(connection) },
                    onSetDefault: { viewModel.setDefaultConnection(connection) },
                    onTest: { await viewModel.testConnection(connection) }
                )
            }
        }
    }
}

struct DeviceRow: View {
    let connection: SFTPConnection
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onSetDefault: () -> Void
    let onTest: () async -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(connection.name)
                        .font(.headline)
                    
                    if connection.isDefault {
                        Text("DEFAULT")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }
                
                Text(connection.connectionString)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(connection.rootPath)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                connectionStatusIndicator
                
                Menu {
                    Button("Edit", action: onEdit)
                    
                    if !connection.isDefault {
                        Button("Set as Default", action: onSetDefault)
                    }
                    
                    Button("Test Connection") {
                        Task { await onTest() }
                    }
                    
                    Divider()
                    
                    Button("Delete", role: .destructive, action: onDelete)
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var connectionStatusIndicator: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            Text(connection.status.displayName)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var statusColor: Color {
        switch connection.status {
        case .connected:
            return .green
        case .connecting, .authenticating:
            return .orange
        case .error:
            return .red
        case .disconnected:
            return .gray
        }
    }
}

#Preview {
    SFTPDevicesView()
}