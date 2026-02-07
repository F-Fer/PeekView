import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var document: PDFDocument?
    @State private var showFileImporter = false
    @State private var pdfView = PDFView()
    @State private var showSidebar = true
    @State private var sidebarWidth: CGFloat = 140

    var body: some View {
        HStack(spacing: 0) {
            if showSidebar && document != nil {
                ThumbnailSidebarView(pdfView: pdfView)
                    .frame(width: sidebarWidth)
                Divider()
                    .frame(width: 4)
                    .contentShape(Rectangle())
                    .onHover { hovering in
                        if hovering {
                            NSCursor.resizeLeftRight.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
                    .gesture(
                        DragGesture(coordinateSpace: .global)
                            .onChanged { value in
                                sidebarWidth = min(max(value.location.x, 100), 260)
                            }
                    )
            }
            if let document {
                PDFKitView(pdfView: pdfView, document: document)
            } else {
                ContentUnavailableView(
                    "No PDF Open",
                    systemImage: "doc.text",
                    description: Text("Open a PDF file to get started")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showSidebar)
        .frame(minWidth: 500, minHeight: 400)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    showSidebar.toggle()
                } label: {
                    Image(systemName: "sidebar.leading")
                }
            }
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
