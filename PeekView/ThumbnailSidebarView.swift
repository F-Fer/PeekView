import SwiftUI
import PDFKit

struct ThumbnailSidebarView: NSViewRepresentable {
    let pdfView: PDFView

    func makeNSView(context: Context) -> PDFThumbnailView {
        let thumbnailView = PDFThumbnailView()
        thumbnailView.pdfView = pdfView
        thumbnailView.thumbnailSize = CGSize(width: 100, height: 140)
        return thumbnailView
    }

    func updateNSView(_ thumbnailView: PDFThumbnailView, context: Context) {
        thumbnailView.pdfView = pdfView
    }
}
