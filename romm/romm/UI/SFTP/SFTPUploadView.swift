import SwiftUI

struct SFTPUploadView: View {
    @State private var viewModel: SFTPUploadViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeviceManagement = false
    
    private let dependencyFactory: DependencyFactoryProtocol
    
    init(rom: Rom, dependencyFactory: DependencyFactoryProtocol = DefaultDependencyFactory.shared) {
        self.dependencyFactory = dependencyFactory
        self._viewModel = State(initialValue: SFTPUploadViewModel(rom: rom))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if viewModel.isCompleted {
                    completedView
                } else if viewModel.isUploading || viewModel.isPreparing {
                    uploadingView
                } else {
                    configurationView
                }
            }
            .padding()
            .navigationTitle("Send to Device")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(viewModel.isUploading || viewModel.isPreparing)
                }
                
                if !viewModel.isUploading && !viewModel.isPreparing && !viewModel.isCompleted {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Upload") {
                            Task {
                                await viewModel.startUpload()
                            }
                        }
                        .disabled(!viewModel.canUpload)
                    }
                }
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("Try Again") {
                    viewModel.resetUpload()
                }
                Button("Cancel", role: .cancel) {
                    viewModel.error = nil
                }
            } message: {
                Text(viewModel.error ?? "")
            }
            .sheet(isPresented: $viewModel.showingDirectoryBrowser) {
                if let connection = viewModel.selectedConnection {
                    SFTPDirectoryBrowserView(connection: connection, romName: viewModel.rom.name, dependencyFactory: dependencyFactory) { path in
                        viewModel.selectTargetPath(path)
                    }
                }
            }
            .sheet(isPresented: $showingDeviceManagement) {
                SFTPDevicesView(dependencyFactory: dependencyFactory)
            }
        }
    }
    
    private var configurationView: some View {
        VStack(spacing: 24) {
            // ROM Info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("ROM File")
                        .font(.headline)
                    Text(viewModel.rom.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            Divider()
            
            // Device Selection
            VStack(alignment: .leading, spacing: 12) {
                Text("Select Device")
                    .font(.headline)
                
                if viewModel.connections.isEmpty {
                    VStack(spacing: 12) {
                        Text("No SFTP devices configured")
                            .foregroundColor(.secondary)
                        
                        Button("Add Device") {
                            showingDeviceManagement = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                } else {
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 8) {
                        ForEach(viewModel.connections) { connection in
                            DeviceSelectionRow(
                                connection: connection,
                                isSelected: viewModel.selectedConnection?.id == connection.id,
                                onSelect: { viewModel.selectConnection(connection) }
                            )
                        }
                    }
                }
            }
            
            if viewModel.selectedConnection != nil {
                Divider()
                
                // Target Path Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Target Directory")
                        .font(.headline)
                    
                    Button(action: viewModel.browseDirectories) {
                        HStack {
                            Image(systemName: "folder")
                            Text(viewModel.targetPath ?? "Choose directory...")
                                .foregroundColor(viewModel.targetPath != nil ? .primary : .secondary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Storage Warning
            if let storageWarning = viewModel.storageWarning {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text(storageWarning)
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
    }
    
    private var uploadingView: some View {
        VStack(spacing: 24) {
            // Progress Indicator
            VStack(spacing: 16) {
                Image(systemName: viewModel.isPreparing ? "arrow.down.circle" : "icloud.and.arrow.up")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
                
                Text(viewModel.isPreparing ? "Preparing ROM..." : "Uploading ROM...")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(viewModel.rom.name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Progress Bar
            VStack(spacing: 8) {
                let progress = viewModel.isPreparing ? viewModel.prepareProgress : viewModel.uploadProgress
                
                ProgressView(value: progress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                
                Text(viewModel.isPreparing ? viewModel.prepareMessage : viewModel.uploadProgressText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(Int(progress * 100))%")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
    
    private var completedView: some View {
        VStack(spacing: 24) {
            // Success Indicator
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("Upload Complete!")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Your ROM has been successfully transferred to the device.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Details
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("ROM:")
                        .fontWeight(.medium)
                    Spacer()
                    Text(viewModel.rom.name)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Device:")
                        .fontWeight(.medium)
                    Spacer()
                    Text(viewModel.selectedConnection?.name ?? "Unknown")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Location:")
                        .fontWeight(.medium)
                    Spacer()
                    Text(viewModel.targetPath ?? "Unknown")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            HStack(spacing: 16) {
                Button("Send Another") {
                    viewModel.resetUpload()
                }
                .buttonStyle(.bordered)
                
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.top)
            
            Spacer()
        }
        .padding()
    }
}

struct DeviceSelectionRow: View {
    let connection: SFTPConnection
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(connection.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(connection.connectionString)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentColor)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SFTPUploadView(
        rom: Rom(
            id: 1,
            name: "Super Mario Bros.",
            platformId: 1,
            urlCover: nil,
            isFavourite: false,
            hasRetroAchievements: true,
            isPlayable: true
        ),
        dependencyFactory: MockDependencyFactory()
    )
}