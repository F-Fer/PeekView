# PeekView

A macOS PDF reader with split-pane view designed for academic papers. Click a reference in the main pane to open it in a side pane without losing your reading position.

## Requirements

- macOS 14.0+
- Xcode 15.4+

## Getting Started

```bash
open PeekView.xcodeproj
```

Set your development team in the PeekView target under Signing & Capabilities, then build and run with **Cmd+R**.

## PDF Handler

PeekView registers as an alternate PDF viewer on macOS. To set it as your default PDF app, right-click any PDF in Finder > Get Info > Open With > select PeekView > Change All.

## Tech Stack

- Swift + SwiftUI
- PDFKit
