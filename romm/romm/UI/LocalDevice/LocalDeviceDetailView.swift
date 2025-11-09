import SwiftUI

struct LocalDeviceDetailView: View {
    @State private var viewModel = LocalDeviceDetailViewModel()
    @Environment(\.dismiss) private var dismiss

    private var device: LocalDevice {
        LocalDeviceManager.shared.currentDevice
    }

    var body: some View {
        Group {
            if viewModel.hasDownloadedROMs {
                downloadedROMsList
            } else {
                emptyStateView
            }
        }
        .navigationTitle(device.name)
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            viewModel.loadDownloadedROMs()
            viewModel.refreshStorageInfo()
        }
        .alert("Delete ROM?", isPresented: $viewModel.showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                viewModel.romToDelete = nil
            }
            Button("Delete", role: .destructive) {
                viewModel.deleteROM()
            }
        } message: {
            if let rom = viewModel.romToDelete {
                Text("Are you sure you want to delete \(rom.name)? This will remove all files (\(rom.formattedSize)).")
            }
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") {
                viewModel.error = nil
            }
        } message: {
            Text(viewModel.error ?? "")
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "iphone")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            Text("No Downloaded ROMs")
                .font(.title2)
                .fontWeight(.semibold)

            Text("ROMs downloaded to this device will appear here")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            storageInfoCard
                .padding(.top, 20)
        }
        .padding()
    }

    private var downloadedROMsList: some View {
        List {
            Section {
                storageInfoCard
            }

            ForEach(viewModel.platformNames, id: \.self) { platformName in
                if let roms = viewModel.romsByPlatform[platformName] {
                    Section(platformName) {
                        ForEach(roms) { rom in
                            DownloadedROMRow(
                                rom: rom,
                                onDelete: { viewModel.confirmDelete(rom) }
                            )
                        }
                    }
                }
            }
        }
    }

    private var storageInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Storage")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(device.availableStorageFormatted)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(device.hasLowStorage ? .orange : .primary)

                    Text("available")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Downloaded")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(viewModel.totalDownloadedSizeFormatted)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("\(viewModel.downloadedROMs.count) ROMs")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Storage usage bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    // Usage
                    RoundedRectangle(cornerRadius: 4)
                        .fill(device.hasLowStorage ? Color.orange : Color.blue)
                        .frame(
                            width: geometry.size.width * CGFloat(device.storageUsagePercentage / 100),
                            height: 8
                        )
                }
            }
            .frame(height: 8)

            HStack {
                Text("\(Int(device.storageUsagePercentage))% used")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text(device.totalStorageFormatted + " total")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct DownloadedROMRow: View {
    let rom: DownloadedROM
    let onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(rom.name)
                    .font(.headline)

                HStack(spacing: 8) {
                    Text(rom.formattedSize)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(rom.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if rom.files.count > 1 {
                    Text("\(rom.files.count) files")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Menu {
                Button("Show in Files") {
                    // TODO: Implement show in files
                }

                Button("Share") {
                    // TODO: Implement share
                }

                Divider()

                Button("Delete", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        LocalDeviceDetailView()
    }
}
