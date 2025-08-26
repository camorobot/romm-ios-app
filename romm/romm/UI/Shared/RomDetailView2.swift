//
//  RomDetailView2.swift
//  romm
//
//  Created by Claude on 21.08.25.
//

import SwiftUI
import SafariServices

struct RomDetailView2: View {
    let rom: Rom
    @StateObject private var viewModel = RomDetailViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var scrollOffset: CGFloat = 0
    @State private var showTitle: Bool = false
    @State private var selectedTab: DetailTab = .details
    @State private var dominantColor: Color? = nil
    @State private var isHashesExpanded: Bool = false
    @State private var showingActionSheet = false
    @State private var showingShareSheet = false
    @State private var showingSFTPUpload = false
    
    enum DetailTab: String, CaseIterable {
        case details = "DETAILS"
        case manual = "MANUAL"
        case game = "GAME"
    }
    
    private enum CoordinateSpaces {
        case scrollView
    }
    
    init(rom: Rom) {
        self.rom = rom
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero Image with your ParallaxHeader
                    ParallaxHeader(
                        coordinateSpace: CoordinateSpaces.scrollView,
                        defaultHeight: 400
                    ) {
                        ZStack(alignment: .top) {
                            CachedAsyncImage(urlString: rom.urlCover) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .onAppear {
                                        extractDominantColor(from: image)
                                    }
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray)
                                    .overlay(
                                        Image(systemName: "gamecontroller")
                                            .font(.system(size: 80))
                                            .foregroundColor(.white)
                                    )
                            }
                            
                            // Semi-transparent overlay in navbar area for better button visibility
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: .black.opacity(0.3), location: 0.0),
                                    .init(color: .black.opacity(0.1), location: 0.3),
                                    .init(color: .clear, location: 0.5)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        }
                    }
                    
                    // Content section with blur effect
                    VStack(spacing: 0) {
                        titleBlock
                        metaSection
                        actionBar
                        stickyTabNavigation
                        tabContentSection
                        Spacer(minLength: 100)
                    }
                    .frame(maxWidth: 700)
                    .padding(.horizontal, 20)
                    .background(
                        Group {
                            if let dominantColor = dominantColor {
                                dominantColor
                                    .opacity(0.08)
                                    .blur(radius: 30)
                                    .background(.ultraThickMaterial)
                            } else {
                                Color(.systemBackground)
                                    .opacity(0.9)
                                    .background(.ultraThickMaterial)
                            }
                        }
                    )
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 20,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 20
                        )
                    )
                    .onChange(of: selectedTab) { _, newTab in
                        if newTab == .manual && viewModel.manual == nil && !viewModel.isLoadingManual {
                            Task {
                                await viewModel.loadManual(for: rom.id)
                            }
                        }
                    }
                    .confirmationDialog("Actions", isPresented: $showingActionSheet, titleVisibility: .visible) {
                        actionSheetButtons
                    }
                    .sheet(isPresented: $showingShareSheet) {
                        ShareSheet(activityItems: ["Check out this ROM: \(rom.name)"])
                    }
                    .sheet(isPresented: $showingSFTPUpload) {
                        SFTPUploadView(rom: rom)
                    }
                    .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                        Button("OK") {
                            viewModel.clearError()
                        }
                    } message: {
                        Text(viewModel.errorMessage ?? "")
                    }
                }
            }
            .overlay(alignment: .top) {
                // Small gradient overlay from top for better NavigationBar visibility
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .black.opacity(0.4), location: 0.0),
                        .init(color: .black.opacity(0.2), location: 0.5),
                        .init(color: .clear, location: 1.0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 120)
                .ignoresSafeArea(edges: .top)
            }
            .coordinateSpace(name: CoordinateSpaces.scrollView)
            .ignoresSafeArea(edges: .top)
            .navigationBarTitle(showTitle ? rom.name : "", displayMode: .inline)
            .navigationBarBackButtonHidden(false)
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
                // Show title when content view reaches navbar (around 300px up from original position)
                withAnimation(.easeInOut(duration: 0.2)) {
                    showTitle = scrollOffset < -300
                    print(scrollOffset)
                }
            }
            .onAppear {
                Task {
                    await viewModel.loadRomDetails(romId: rom.id)
                }
            }
        }
    }
    
    @ViewBuilder
    private var titleBlock: some View {
        VStack(spacing: 12) {
            // Platform (small, secondary)
            if let platform = rom.platform {
                Text(platform.name.uppercased())
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .tracking(1)
            }
            
            // ROM Name (large, bold)
            Text(rom.name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .accessibility(addTraits: .isHeader)
            
            // Publisher/Developer (small)
            if let details = viewModel.romDetails, let developer = details.developer {
                Text(developer)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 24)
    }
    
    @ViewBuilder
    private var metaSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let details = viewModel.romDetails, !details.genre.isEmpty {
                Text("GENRE")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .tracking(1)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 8) {
                    ForEach(details.genre, id: \.self) { genre in
                        GenreCapsule(text: genre)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 24)
    }
    
    @ViewBuilder
    private var actionBar: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Toggle Favorite Button
                Button(action: { viewModel.toggleFavorite(originalRom: rom) }) {
                    HStack {
                        Image(systemName: viewModel.actualFavoriteStatus ? "heart.fill" : "heart")
                            .foregroundColor(viewModel.actualFavoriteStatus ? .accentColor : .secondary)
                        Text("Favorite")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.systemGray6).opacity(0.3))
                    )
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                }
                .accessibility(hint: Text(viewModel.actualFavoriteStatus ? "Remove from favorites" : "Add to favorites"))
                
                // Add to Collection Button
                Button(action: {
                    // TODO: Implement add to collection
                }) {
                    Label("Collection", systemImage: "folder.badge.plus")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(.systemGray6).opacity(0.3))
                        )
                        .foregroundColor(.secondary)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                }
                .accessibility(hint: Text("Add this ROM to a collection"))
            }
            
            // Send to Device Button
            Button(action: {
                showingSFTPUpload = true
            }) {
                Label("Send to Device", systemImage: "paperplane")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.accentColor)
                    )
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            }
            .accessibility(hint: Text("Upload this ROM to an SFTP device"))
        }
        .padding(.bottom, 24)
    }
    
    @ViewBuilder
    private var stickyTabNavigation: some View {
        HStack(spacing: 0) {
            ForEach(DetailTab.allCases, id: \.self) { tab in
                Button(action: {
                    selectedTab = tab
                }) {
                    VStack(spacing: 8) {
                        Text(tab.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Rectangle()
                            .fill(selectedTab == tab ? Color.accentColor : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 16)
    }
    
    @ViewBuilder
    private var tabContentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            switch selectedTab {
            case .details:
                detailsContent
            case .manual:
                manualContent
            case .game:
                gameContent
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 100)
    }
    
    @ViewBuilder
    private var detailsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let details = viewModel.romDetails {
                DetailRow(label: "File", value: details.fileName ?? details.name)
                
                if let sizeBytes = details.sizeBytes {
                    DetailRow(label: "Size", value: formatFileSize(sizeBytes))
                }
                
                // Collapsible Hashes Section
                VStack(alignment: .leading, spacing: 0) {
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            isHashesExpanded.toggle()
                        }
                    }) {
                        HStack {
                            Text("Hashes")
                                .font(.headline)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .rotationEffect(.degrees(isHashesExpanded ? 90 : 0))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top)
                    
                    if isHashesExpanded {
                        VStack(alignment: .leading, spacing: 12) {
                            if let sha1 = details.sha1Hash {
                                InfoRow(label: "SHA-1", value: sha1)
                            }
                            if let md5 = details.md5Hash {
                                InfoRow(label: "MD5", value: md5)
                            }
                            if let crc = details.crcHash {
                                InfoRow(label: "CRC", value: crc)
                            }
                        }
                        .padding(.top, 8)
                    }
                }
            }
            
            if let details = viewModel.romDetails {
                if !details.genre.isEmpty {
                    DetailRow(label: "Genres", value: details.genre.joined(separator: ", "))
                        .padding(.top)
                }
                
                if let developer = details.developer {
                    DetailRow(label: "Companies", value: developer)
                }
                
                if let publisher = details.publisher, publisher != details.developer {
                    DetailRow(label: "Publisher", value: publisher)
                }
                
                if let summary = details.summary, !summary.isEmpty {
                    summarySection(summary)
                }
            }
        }
    }
    
    @ViewBuilder
    private var manualContent: some View {
        VStack {
            if viewModel.isLoadingManual {
                ProgressView("Loading manual...")
                    .padding(.top, 40)
            } else if let pdfData = viewModel.manualPDFData {
                PDFViewer(data: pdfData)
                    .frame(minHeight: 600)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    
                    Text("No manual available")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("This ROM doesn't have a manual or it hasn't been uploaded yet.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 60)
            }
        }
    }
    
    @ViewBuilder
    private var gameContent: some View {
        VStack {
            Text("Game data coming soon...")
                .foregroundColor(.secondary)
                .font(.subheadline)
                .padding(.top, 40)
        }
    }
    
    @ViewBuilder
    private func summarySection(_ summary: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Summary")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text(summary)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 8)
    }
    
    @ViewBuilder
    private var actionSheetButtons: some View {
        Button(viewModel.actualFavoriteStatus ? "Remove from Favorites" : "Add to Favorites") {
            viewModel.toggleFavorite(originalRom: rom)
        }
        
        Button("Add to Collection") {
            // TODO: Implement add to collection
        }
        
        Button("Set as Default") {
            // TODO: Implement set as default
        }
        
        Button("Cancel", role: .cancel) {}
    }
    
    private func extractDominantColor(from image: Image) {
        let renderer = ImageRenderer(content: image)
        renderer.scale = 1.0
        
        if let uiImage = renderer.uiImage,
           let dominantUIColor = uiImage.dominantColor() {
            DispatchQueue.main.async {
                self.dominantColor = Color(dominantUIColor)
            }
        }
    }
    
    private func formatFileSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

#Preview {
    NavigationView {
        RomDetailView2(rom: Rom(
            id: 1,
            name: "Super Mario Bros.",
            platformId: 1,
            urlCover: nil,
            isFavourite: false,
            hasRetroAchievements: true,
            isPlayable: true
        ))
    }
}

// MARK: - Supporting Components

struct GenreCapsule: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .foregroundColor(.primary)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.primary)
                .frame(width: 60, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .textSelection(.enabled)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            Spacer()
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
                .textSelection(.enabled)
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension UIImage {
    func dominantColor() -> UIColor? {
        guard let cgImage = self.cgImage else { return nil }
        
        let width = 50
        let height = 50
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        
        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        ) else { return nil }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var colorCount: [UIColor: Int] = [:]
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (y * width + x) * bytesPerPixel
                let r = CGFloat(pixelData[pixelIndex]) / 255.0
                let g = CGFloat(pixelData[pixelIndex + 1]) / 255.0
                let b = CGFloat(pixelData[pixelIndex + 2]) / 255.0
                
                let color = UIColor(red: r, green: g, blue: b, alpha: 1.0)
                colorCount[color, default: 0] += 1
            }
        }
        
        return colorCount.max(by: { $0.value < $1.value })?.key
    }
}

struct ParallaxHeader<Content: View, Space: Hashable>: View {
    let content: () -> Content
    let coordinateSpace: Space
    let defaultHeight: CGFloat
    
    init(
        coordinateSpace: Space,
        defaultHeight: CGFloat,
        @ViewBuilder _ content: @escaping () -> Content
    ) {
        self.content = content
        self.coordinateSpace = coordinateSpace
        self.defaultHeight = defaultHeight
    }
    
    var body: some View {
        GeometryReader { proxy in
            let offset = offset(for: proxy)
            let heightModifier = heightModifier(for: proxy)
            content()
                .edgesIgnoringSafeArea(.horizontal)
                .frame(
                    width: proxy.size.width,
                    height: proxy.size.height + heightModifier
                )
                .offset(y: offset)
                .onAppear {
                    // Extract dominant color from cover image
                    // This is handled in the main view where AsyncImage is defined
                }
        }.frame(height: defaultHeight)
    }
    
    
    private func offset(for proxy: GeometryProxy) -> CGFloat {
        let frame = proxy.frame(in: .named(coordinateSpace))
        if frame.minY < 0 {
            return -frame.minY * 0.8
        }
        return -frame.minY
    }
    
    private func heightModifier(for proxy: GeometryProxy) -> CGFloat {
        let frame = proxy.frame(in: .named(coordinateSpace))
        return max(0, frame.minY)
    }
}

struct ParallaxExample: View {
    private enum CoordinateSpaces {
        case scrollView
    }
    var body: some View {
        ScrollView {
            ParallaxHeader(
                coordinateSpace: CoordinateSpaces.scrollView,
                defaultHeight: 400
            ) {
                Image("flower")
                    .resizable()
                    .scaledToFill()
            }
            Rectangle()
                .fill(.blue)
                .frame(height: 1000)
                .shadow(color: .black.opacity(0.8), radius: 10, y: -10)
                .offset(y: -10)
        }
        .coordinateSpace(name: CoordinateSpaces.scrollView)
        .edgesIgnoringSafeArea(.top)
        
    }
}
