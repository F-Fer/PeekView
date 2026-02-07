import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var document: PDFDocument?
    @State private var showFileImporter = false
    @State private var pdfView = PeekablePDFView()
    @State private var showSidebar = true
    @State private var sidebarWidth: CGFloat = 140
    @State private var searchText = ""
    @State private var searchResults: [PDFSelection] = []
    @State private var currentResultIndex = 0
    @State private var isSearchFieldPresented = false
    @State private var searchTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
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
        .searchable(text: $searchText, isPresented: $isSearchFieldPresented)
        .onChange(of: searchText) {
            performSearch()
        }
        .onSubmit(of: .search) {
            navigateToNextResult()
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    showSidebar.toggle()
                } label: {
                    Image(systemName: "sidebar.leading")
                }
            }
            if !searchResults.isEmpty {
                ToolbarItem {
                    HStack(spacing: 4) {
                        Button {
                            navigateToPreviousResult()
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                        Text("\(currentResultIndex + 1) of \(searchResults.count)")
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                        Button {
                            navigateToNextResult()
                        } label: {
                            Image(systemName: "chevron.right")
                        }
                    }
                }
            }
            ToolbarItem {
                Button("Find", systemImage: "magnifyingglass") {
                    isSearchFieldPresented = true
                }
                .keyboardShortcut("f")
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
        } // NavigationStack
    }

    private func performSearch() {
        searchTask?.cancel()

        guard let document, !searchText.isEmpty else {
            searchResults = []
            currentResultIndex = 0
            pdfView.highlightedSelections = nil
            return
        }

        let query = searchText
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }

            let results = await Task.detached {
                document.findString(query, withOptions: [.caseInsensitive])
            }.value
            guard !Task.isCancelled else { return }

            searchResults = results
            pdfView.highlightedSelections = results
            currentResultIndex = 0
            if let first = results.first {
                pdfView.currentSelection = first
                pdfView.go(to: first)
            }
        }
    }

    private func navigateToNextResult() {
        guard !searchResults.isEmpty else { return }
        currentResultIndex = (currentResultIndex + 1) % searchResults.count
        let selection = searchResults[currentResultIndex]
        pdfView.currentSelection = selection
        pdfView.go(to: selection)
    }

    private func navigateToPreviousResult() {
        guard !searchResults.isEmpty else { return }
        currentResultIndex = (currentResultIndex - 1 + searchResults.count) % searchResults.count
        let selection = searchResults[currentResultIndex]
        pdfView.currentSelection = selection
        pdfView.go(to: selection)
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
