import AppKit
import PDFKit

class PeekablePDFView: PDFView {
    private var activePopover: NSPopover?

    override func mouseDown(with event: NSEvent) {
        let locationInView = convert(event.locationInWindow, from: nil)
        let areaType: PDFAreaOfInterest = areaOfInterest(for: locationInView)

        guard areaType.contains(.linkArea),
              let page = page(for: locationInView, nearest: false) else {
            super.mouseDown(with: event)
            return
        }

        let pointOnPage = convert(locationInView, to: page)
        guard let annotation = page.annotation(at: pointOnPage) else {
            super.mouseDown(with: event)
            return
        }

        // Resolve internal destination: PDFActionGoTo first, then direct destination
        let destination: PDFDestination?
        if let goTo = annotation.action as? PDFActionGoTo {
            destination = goTo.destination
        } else {
            destination = annotation.destination
        }

        guard let destination, destination.page != nil else {
            // External URL or unresolvable — let PDFView handle it
            super.mouseDown(with: event)
            return
        }

        if event.modifierFlags.contains(.command) {
            go(to: destination)
        } else {
            showPeekPopover(for: destination, at: annotation.bounds, on: page)
        }
    }

    private func showPeekPopover(for destination: PDFDestination, at annotationBounds: CGRect, on page: PDFPage) {
        activePopover?.close()

        let peekPDFView = PDFView()
        peekPDFView.document = document
        peekPDFView.autoScales = false
        peekPDFView.scaleFactor = scaleFactor
        peekPDFView.go(to: destination)

        let popover = NSPopover()
        popover.contentSize = NSSize(width: 500, height: 350)
        popover.behavior = .transient
        popover.contentViewController = NSViewController()
        popover.contentViewController?.view = peekPDFView

        // Convert annotation bounds from page space to view space for positioning
        let viewRect = convert(annotationBounds, from: page)
        popover.show(relativeTo: viewRect, of: self, preferredEdge: .minY)

        activePopover = popover
    }
}
