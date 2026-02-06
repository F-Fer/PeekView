import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var document: PDFDocument?
    @State private var showFileImporter = false

    var body: some View {
        Group {
            if let document {
                PDFKitView(document: document)
            } else {
                ContentUnavailableView(
                    "No PDF Open",
                    systemImage: "doc.text",
                    description: Text("Open a PDF file to get started")
                )
            }
        }
        .frame(minWidth: 600, minHeight: 400)
        .toolbar {
            ToolbarItem {
                Button("Open", systemImage: "folder") {
                    showFileImporter = true
                }
                .keyboardShortcut("o")
            }
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.pdf]
        ) { result in
            if case .success(let url) = result {
                loadPDF(from: url)
            }
        }
        .onOpenURL { url in
            loadPDF(from: url)
        }
    }

    private func loadPDF(from url: URL) {
        let didAccess = url.startAccessingSecurityScopedResource()
        defer {
            if didAccess { url.stopAccessingSecurityScopedResource() }
        }
        document = PDFDocument(url: url)
    }
}

#Preview {
    ContentView()
}
