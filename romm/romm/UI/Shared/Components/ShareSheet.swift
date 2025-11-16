import SwiftUI
import UIKit
import UniformTypeIdentifiers

/// Shared component for presenting iOS share sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        print("🔧 Creating UIActivityViewController with \(activityItems.count) items")

        // Convert URLs to NSURL file URLs for better compatibility
        // Based on: https://stackoverflow.com/a/... (CC BY-SA 4.0)
        var filesToShare = [Any]()

        for item in activityItems {
            if let url = item as? URL {
                // Create NSURL with fileURLWithPath for proper file sharing
                let nsurl = NSURL(fileURLWithPath: url.path)
                print("   Adding: \(url.lastPathComponent)")
                print("     Path: \(url.path)")
                print("     isFileURL: \(url.isFileURL)")
                filesToShare.append(nsurl)
            } else {
                print("   ⚠️ Non-URL item: \(type(of: item))")
            }
        }

        print("   Total items to share: \(filesToShare.count)")

        let controller = UIActivityViewController(
            activityItems: filesToShare,
            applicationActivities: nil
        )

        // For iPad: configure popover presentation
        if let popover = controller.popoverPresentationController {
            popover.sourceView = UIView()
            popover.permittedArrowDirections = .any
        }

        // Be notified of the result when the share sheet is dismissed
        controller.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            if let error = error {
                print("❌ Share failed: \(error.localizedDescription)")
            } else if completed {
                print("✅ Share completed with: \(activityType?.rawValue ?? "unknown")")
            } else {
                print("⚠️ Share cancelled")
            }
        }

        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
