//
//  FullScreenPDFViewer.swift
//  romm
//
//  Created by Ilyas Hallak on 22.09.25.
//

import SwiftUI
import PDFKit

struct FullScreenPDFViewer: View {
    let pdfData: Data
    let title: String
    @Environment(\.dismiss) private var dismiss
    @State private var showToolbar = true
    @State private var currentPage = 1
    @State private var totalPages = 0
    @State private var zoomScale: CGFloat = 1.0
    
    private let logger = Logger.ui
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                PDFViewWithControls(
                    data: pdfData,
                    currentPage: $currentPage,
                    totalPages: $totalPages,
                    zoomScale: $zoomScale,
                    showToolbar: $showToolbar
                )
                
                // Overlay controls
                if showToolbar {
                    VStack {
                        Spacer()
                        
                        // Bottom toolbar
                        HStack {
                            // Page navigation
                            Button(action: previousPage) {
                                Image(systemName: "chevron.left")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                            .disabled(currentPage <= 1)
                            
                            Spacer()
                            
                            // Page indicator
                            Text("\(currentPage) / \(totalPages)")
                                .foregroundColor(.white)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.black.opacity(0.6))
                                .cornerRadius(8)
                            
                            Spacer()
                            
                            Button(action: nextPage) {
                                Image(systemName: "chevron.right")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                            .disabled(currentPage >= totalPages)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .black.opacity(0.6)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                    .transition(.opacity)
                }
            }
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showToolbar.toggle()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .foregroundColor(.white)
                        .font(.headline)
                        .lineLimit(1)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: zoomIn) {
                            Label("Zoom In", systemImage: "plus.magnifyingglass")
                        }
                        
                        Button(action: zoomOut) {
                            Label("Zoom Out", systemImage: "minus.magnifyingglass")
                        }
                        
                        Button(action: resetZoom) {
                            Label("Reset Zoom", systemImage: "magnifyingglass")
                        }
                        
                        Divider()
                        
                        Button(action: sharePDF) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.white)
                    }
                }
            }
            .toolbarBackground(.black.opacity(0.8), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func previousPage() {
        guard currentPage > 1 else { return }
        currentPage -= 1
    }
    
    private func nextPage() {
        guard currentPage < totalPages else { return }
        currentPage += 1
    }
    
    private func zoomIn() {
        zoomScale = min(zoomScale * 1.25, 5.0)
    }
    
    private func zoomOut() {
        zoomScale = max(zoomScale / 1.25, 0.25)
    }
    
    private func resetZoom() {
        zoomScale = 1.0
    }
    
    private func sharePDF() {
        let activityController = UIActivityViewController(
            activityItems: [pdfData],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityController, animated: true)
        }
    }
}

struct PDFViewWithControls: UIViewRepresentable {
    let data: Data
    @Binding var currentPage: Int
    @Binding var totalPages: Int
    @Binding var zoomScale: CGFloat
    @Binding var showToolbar: Bool
    
    private let logger = Logger.ui
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        
        // Configure PDF view
        pdfView.autoScales = true
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .horizontal
        pdfView.backgroundColor = UIColor.black
        pdfView.usePageViewController(true, withViewOptions: nil)
        
        // Enable zoom and scrolling
        pdfView.minScaleFactor = 0.25
        pdfView.maxScaleFactor = 5.0
        pdfView.scaleFactor = 1.0
        
        // Load PDF document
        if let document = PDFDocument(data: data) {
            pdfView.document = document
            DispatchQueue.main.async {
                totalPages = document.pageCount
                currentPage = 1
            }
            logger.info("PDF document loaded - Pages: \(document.pageCount)")
        } else {
            logger.warning("Failed to create PDF document from data")
        }
        
        // Set up delegate
        pdfView.delegate = context.coordinator
        
        // Add notification observer for page changes
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.pageChanged),
            name: .PDFViewPageChanged,
            object: pdfView
        )
        
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        // Update current page if needed
        if let document = pdfView.document,
           currentPage > 0 && currentPage <= document.pageCount {
            let page = document.page(at: currentPage - 1)
            if pdfView.currentPage != page {
                pdfView.go(to: page!)
            }
        }
        
        // Update zoom scale
        if abs(pdfView.scaleFactor - zoomScale) > 0.01 {
            pdfView.scaleFactor = zoomScale
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PDFViewDelegate {
        let parent: PDFViewWithControls
        
        init(_ parent: PDFViewWithControls) {
            self.parent = parent
        }
        
        @objc func pageChanged(_ notification: Notification) {
            guard let pdfView = notification.object as? PDFView,
                  let document = pdfView.document,
                  let currentPage = pdfView.currentPage else { return }
            
            let pageIndex = document.index(for: currentPage)
            DispatchQueue.main.async {
                self.parent.currentPage = pageIndex + 1
            }
        }
        
        func pdfViewWillClick(onLink sender: PDFView, with url: URL) {
            // Handle link clicks if needed
        }
    }
}

#Preview {
    // Create sample PDF data for preview
    let samplePDFData = Data()
    
    FullScreenPDFViewer(
        pdfData: samplePDFData,
        title: "Sample Manual"
    )
}