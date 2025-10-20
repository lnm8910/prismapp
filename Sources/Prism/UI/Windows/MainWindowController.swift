import Cocoa

class MainWindowController: NSWindowController, NSWindowDelegate {
    // UI Components
    private var scrollView: NSScrollView!
    private var textView: PrismTextView!
    private var statusBar: StatusBar!

    // State
    private var currentDocument: PrismDocument?
    private var documents: [PrismDocument] = []

    init() {
        // Create window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1000, height: 700),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        window.title = "Prism"
        window.center()
        window.setFrameAutosaveName("MainWindow")
        window.minSize = NSSize(width: 400, height: 300)

        super.init(window: window)

        window.delegate = self

        setupUI()

        // Create initial document
        newDocument()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        guard let window = window else { return }

        // Create container view
        let containerView = NSView(frame: window.contentView!.bounds)
        containerView.autoresizingMask = [.width, .height]
        window.contentView = containerView

        // Setup status bar first (so we know its height)
        setupStatusBar(in: containerView)

        // Setup text editor
        setupTextEditor(in: containerView)
    }

    private func setupTextEditor(in containerView: NSView) {
        // Create text container
        let textContainer = NSTextContainer()
        textContainer.containerSize = NSSize(width: CGFloat.greatestFiniteMagnitude,
                                             height: CGFloat.greatestFiniteMagnitude)
        textContainer.widthTracksTextView = false

        // Create layout manager
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)

        // Create text storage
        let textStorage = NSTextStorage()
        textStorage.addLayoutManager(layoutManager)

        // Create text view
        textView = PrismTextView(frame: .zero, textContainer: textContainer)
        textView.autoresizingMask = [.width, .height]
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = true

        // Set callback for text changes
        textView.onTextChange = { [weak self] in
            self?.updateStatusBar()
            self?.updateWindowTitle()
        }

        // Create scroll view
        scrollView = NSScrollView(frame: containerView.bounds)
        scrollView.autoresizingMask = [.width, .height]
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.autohidesScrollers = true

        // Add to container (leave space for status bar)
        var scrollFrame = containerView.bounds
        scrollFrame.size.height -= 24 // Status bar height
        scrollFrame.origin.y = 24
        scrollView.frame = scrollFrame

        containerView.addSubview(scrollView)
    }

    private func setupStatusBar(in containerView: NSView) {
        let statusBarFrame = NSRect(
            x: 0,
            y: 0,
            width: containerView.bounds.width,
            height: 24
        )

        statusBar = StatusBar(frame: statusBarFrame)
        statusBar.autoresizingMask = [.width, .maxYMargin]
        containerView.addSubview(statusBar)
    }

    // MARK: - Document operations

    func newDocument() {
        let document = PrismDocument()
        currentDocument = document
        documents.append(document)

        textView.setDocument(document)
        updateWindowTitle()
        updateStatusBar()
    }

    func openDocument() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.message = "Choose a file to open"

        panel.begin { [weak self] response in
            if response == .OK, let url = panel.url {
                self?.openFile(url: url)
            }
        }
    }

    private func openFile(url: URL) {
        let document = PrismDocument(fileURL: url)
        currentDocument = document
        documents.append(document)

        textView.setDocument(document)
        updateWindowTitle()
        updateStatusBar()
    }

    func saveDocument() {
        guard let document = currentDocument else { return }

        if let url = document.fileURL {
            do {
                try document.saveToFile(url: url)
                updateWindowTitle()
                showSaveSuccess()
            } catch {
                showError(message: "Failed to save file: \(error.localizedDescription)")
            }
        } else {
            saveDocumentAs()
        }
    }

    func saveDocumentAs() {
        guard let document = currentDocument else { return }

        let panel = NSSavePanel()
        panel.canCreateDirectories = true
        panel.message = "Choose where to save the file"

        // Suggest filename if we have one
        if let url = document.fileURL {
            panel.nameFieldStringValue = url.lastPathComponent
        } else {
            panel.nameFieldStringValue = "Untitled.txt"
        }

        panel.begin { [weak self] response in
            if response == .OK, let url = panel.url {
                do {
                    try document.saveToFile(url: url)
                    self?.updateWindowTitle()
                    self?.updateStatusBar()
                    self?.showSaveSuccess()
                } catch {
                    self?.showError(message: "Failed to save file: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - UI Updates

    private func updateWindowTitle() {
        guard let document = currentDocument else {
            window?.title = "Prism"
            return
        }

        let fileName = document.fileURL?.lastPathComponent ?? "Untitled"
        let modified = document.isModified ? "• " : ""
        window?.title = "\(modified)\(fileName)"
        window?.representedURL = document.fileURL
    }

    private func updateStatusBar() {
        guard let document = currentDocument else { return }

        // Calculate cursor position
        let selectedRange = textView.selectedRange()
        let textUpToCursor = (textView.string as NSString).substring(to: selectedRange.location)
        let lines = textUpToCursor.components(separatedBy: .newlines)
        let cursorLine = lines.count
        let cursorColumn = (lines.last?.count ?? 0) + 1

        statusBar.update(
            document: document,
            cursorLine: cursorLine,
            cursorColumn: cursorColumn
        )
    }

    // MARK: - View actions

    func showFind() {
        // TODO: Implement find panel in Phase 3
        let alert = NSAlert()
        alert.messageText = "Find & Replace"
        alert.informativeText = "Find & Replace functionality will be available in Phase 3."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    func toggleLineNumbers() {
        // TODO: Implement line numbers in Phase 3
        let alert = NSAlert()
        alert.messageText = "Line Numbers"
        alert.informativeText = "Line numbers will be available in Phase 3."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    func toggleWordWrap() {
        textView.toggleWordWrap()
    }

    // MARK: - Helper methods

    private func showSaveSuccess() {
        // Visual feedback that save succeeded (brief)
        if let window = window {
            window.standardWindowButton(.documentIconButton)?.flash()
        }
    }

    private func showError(message: String) {
        let alert = NSAlert()
        alert.messageText = "Error"
        alert.informativeText = message
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    // MARK: - NSWindowDelegate

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        guard let document = currentDocument, document.isModified else {
            return true
        }

        let alert = NSAlert()
        alert.messageText = "Do you want to save the changes?"
        alert.informativeText = "Your changes will be lost if you don't save them."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Don't Save")
        alert.addButton(withTitle: "Cancel")

        let response = alert.runModal()

        switch response {
        case .alertFirstButtonReturn: // Save
            saveDocument()
            return !document.isModified // Close only if save succeeded
        case .alertSecondButtonReturn: // Don't Save
            return true
        default: // Cancel
            return false
        }
    }

    func windowDidBecomeKey(_ notification: Notification) {
        // Update status bar when window becomes active
        updateStatusBar()
    }
}

// MARK: - NSView Extension for flash effect

private extension NSView {
    func flash() {
        let originalAlpha = alphaValue
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.15
            animator().alphaValue = 0.3
        }, completionHandler: {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.15
                self.animator().alphaValue = originalAlpha
            })
        })
    }
}
