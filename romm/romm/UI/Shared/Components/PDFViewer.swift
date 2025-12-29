//
//  PDFViewer.swift
//  romm
//
//  Created by Ilyas Hallak on 13.08.25.
//

import SwiftUI
import PDFKit

struct PDFViewer: UIViewRepresentable {
    let data: Data
    private let logger = Logger.ui

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = UIColor.systemBackground

        // Try to create PDF document with error handling
        if let document = PDFDocument(data: data) {
            pdfView.document = document
            logger.info("PDF document created successfully - Pages: \(document.pageCount)")
        } else {
            logger.warning("Failed to create PDF document from data")
            // Set a placeholder or error state
            pdfView.backgroundColor = UIColor.systemGray6
        }

        // Setup notification observer for page changes
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.pageChanged(_:)),
            name: .PDFViewPageChanged,
            object: pdfView
        )

        return pdfView
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {
        if let document = PDFDocument(data: data) {
            pdfView.document = document
            logger.info("PDF document updated - Pages: \(document.pageCount)")
        } else {
            logger.warning("Failed to update PDF document")
            pdfView.document = nil
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject {
        @objc func pageChanged(_ notification: Notification) {
            guard let pdfView = notification.object as? PDFView else { return }
            // Reset zoom to fit page when user navigates to a different page
            pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit
        }
    }
}