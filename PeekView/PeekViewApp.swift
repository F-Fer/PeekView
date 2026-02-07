import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct PDFFileDocument: FileDocument {
    static var readableContentTypes: [UTType] = [.pdf]

    let pdfDocument: PDFDocument?

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        pdfDocument = PDFDocument(data: data)
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        throw CocoaError(.fileWriteNoPermission)
    }
}

@main
struct PeekViewApp: App {
    var body: some Scene {
        DocumentGroup(viewing: PDFFileDocument.self) { config in
            ContentView(document: config.document.pdfDocument)
        }
        .defaultSize(width: 1200, height: 1000)
    }
}
