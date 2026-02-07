import SwiftUI
import PDFKit

struct PDFKitView: NSViewRepresentable {
    let pdfView: PDFView
    let document: PDFDocument?

    func makeNSView(context: Context) -> PDFView {
        pdfView.autoScales = true
        return pdfView
    }

    func updateNSView(_ pdfView: PDFView, context: Context) {
        pdfView.document = document
    }
}
