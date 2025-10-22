import Cocoa

class MainWindowController: NSWindowController, NSWindowDelegate, TabBarDelegate {
    // UI Components
    private var tabBar: TabBarView!
    private var scrollView: NSScrollView!
    private var statusBar: StatusBar!

    // Tab Management
    private var tabs: [TabItem] = []
    private var currentTabIndex: Int = 0

    private var currentTab: TabItem? {
        guard currentTabIndex >= 0 && currentTabIndex < tabs.count else { return nil }
        return tabs[currentTabIndex]
    }

    private var currentTextView: PrismTextView? {
        return currentTab?.textView
    }

    init() {
        // Create window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1000, height: 700),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
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
        setupDragAndDrop()

        // Don't create initial document here - let AppDelegate handle it
        // This allows files passed on launch to open properly
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

        // Setup tab bar
        setupTabBar(in: containerView)

        // Setup status bar
        setupStatusBar(in: containerView)

        // Setup scroll view (text editor will be added per tab)
        setupScrollView(in: containerView)
    }

    private func setupTabBar(in containerView: NSView) {
        // Position at the top of the content area
        let tabBarFrame = NSRect(
            x: 0,
            y: containerView.bounds.height - 32,
            width: containerView.bounds.width,
            height: 32
        )

        tabBar = TabBarView(frame: tabBarFrame)
        tabBar.autoresizingMask = [.width, .minYMargin]
        tabBar.delegate = self
        containerView.addSubview(tabBar)
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

    private func setupScrollView(in containerView: NSView) {
        // Calculate scroll view frame (space for tab bar at top and status bar at bottom)
        let topSpace: CGFloat = 32 // tab bar
        let bottomSpace: CGFloat = 24 // status bar

        var scrollFrame = containerView.bounds
        scrollFrame.size.height -= (topSpace + bottomSpace)
        scrollFrame.origin.y = bottomSpace // Above status bar

        // Create scroll view
        scrollView = NSScrollView(frame: scrollFrame)
        scrollView.autoresizingMask = [.width, .height]
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder

        containerView.addSubview(scrollView)
    }

    private func createTextViewForTab(_ tab: TabItem) -> PrismTextView {
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
        let textView = PrismTextView(frame: scrollView.bounds, textContainer: textContainer)
        textView.autoresizingMask = [.width, .height]
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = true
        textView.minSize = NSSize(width: 0, height: scrollView.contentSize.height)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)

        // Set callback for text changes
        textView.onTextChange = { [weak self] in
            self?.updateStatusBar()
            self?.updateWindowTitle()
            self?.updateTabBar()
        }

        return textView
    }

    // MARK: - Tab Management

    func newDocument() {
        let document = PrismDocument()
        let tab = TabItem(document: document)
        let textView = createTextViewForTab(tab)
        tab.textView = textView
        textView.setDocument(document)

        tabs.append(tab)
        currentTabIndex = tabs.count - 1

        switchToTab(at: currentTabIndex)
        // switchToTab already calls updateTabBar, updateWindowTitle, updateStatusBar
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

    func openFile(url: URL) {
        let document = PrismDocument(fileURL: url)
        let tab = TabItem(document: document)
        let textView = createTextViewForTab(tab)
        tab.textView = textView
        textView.setDocument(document)

        tabs.append(tab)
        currentTabIndex = tabs.count - 1

        switchToTab(at: currentTabIndex)
        // switchToTab already calls updateTabBar, updateWindowTitle, updateStatusBar
    }

    private func switchToTab(at index: Int) {
        guard index >= 0 && index < tabs.count else { return }

        currentTabIndex = index

        // Update scroll view with new text view
        if let textView = tabs[index].textView {
            scrollView.documentView = textView
        }

        updateWindowTitle()
        updateStatusBar()
        updateTabBar()
    }

    private func closeTab(at index: Int) {
        guard index >= 0 && index < tabs.count else { return }

        let tab = tabs[index]

        // Check if document is modified
        if tab.document.isModified {
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
                if tab.document.isModified {
                    return // Save failed or was cancelled
                }
            case .alertSecondButtonReturn: // Don't Save
                break
            default: // Cancel
                return
            }
        }

        // Remove tab
        tabs.remove(at: index)

        // If no tabs left, create a new one
        if tabs.isEmpty {
            newDocument()
            return
        }

        // Adjust current index if needed
        if currentTabIndex >= tabs.count {
            currentTabIndex = tabs.count - 1
        } else if currentTabIndex > index {
            currentTabIndex -= 1
        }

        switchToTab(at: currentTabIndex)
    }

    // MARK: - TabBarDelegate

    func tabBar(_ tabBar: TabBarView, didSelectTabAt index: Int) {
        switchToTab(at: index)
    }

    func tabBar(_ tabBar: TabBarView, didCloseTabAt index: Int) {
        closeTab(at: index)
    }

    // MARK: - Document operations

    func saveDocument() {
        guard let tab = currentTab else { return }
        let document = tab.document

        if let url = document.fileURL {
            do {
                try document.saveToFile(url: url)
                updateWindowTitle()
                updateTabBar()
                showSaveSuccess()
            } catch {
                showError(message: "Failed to save file: \(error.localizedDescription)")
            }
        } else {
            saveDocumentAs()
        }
    }

    func saveDocumentAs() {
        guard let tab = currentTab else { return }
        let document = tab.document

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
                    self?.updateTabBar()
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
        guard let tab = currentTab else {
            window?.title = "Prism"
            return
        }

        // Only show filename in title if it's a saved file, otherwise just "Prism"
        if let url = tab.document.fileURL {
            let fileName = url.lastPathComponent
            let modified = tab.document.isModified ? "• " : ""
            window?.title = "\(modified)\(fileName)"
            window?.representedURL = url
        } else {
            window?.title = "Prism"
            window?.representedURL = nil
        }
    }

    private func updateStatusBar() {
        guard let tab = currentTab,
              let textView = tab.textView else { return }

        // Calculate cursor position
        let selectedRange = textView.selectedRange()
        let textUpToCursor = (textView.string as NSString).substring(to: selectedRange.location)
        let lines = textUpToCursor.components(separatedBy: .newlines)
        let cursorLine = lines.count
        let cursorColumn = (lines.last?.count ?? 0) + 1

        statusBar.update(
            document: tab.document,
            cursorLine: cursorLine,
            cursorColumn: cursorColumn
        )
    }

    private func updateTabBar() {
        tabBar.setTabs(tabs, selectedIndex: currentTabIndex)
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
        currentTextView?.toggleWordWrap()
    }

    // MARK: - Drag and Drop

    private func setupDragAndDrop() {
        guard let window = window, let contentView = window.contentView else { return }

        // Register for dragged file types
        contentView.registerForDraggedTypes([.fileURL])

        // Set self as the dragging destination delegate
        // We need to create a custom view that forwards drag events
        if let customView = contentView as? DraggingDestinationView {
            customView.delegate = self
        } else {
            // Replace content view with our custom view that supports dragging
            let draggingView = DraggingDestinationView(frame: contentView.frame)
            draggingView.delegate = self
            draggingView.autoresizingMask = [.width, .height]

            // Move all subviews to the new view
            for subview in contentView.subviews {
                subview.removeFromSuperview()
                draggingView.addSubview(subview)
            }

            window.contentView = draggingView
        }
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
        // Check all tabs for unsaved changes
        for (index, tab) in tabs.enumerated() {
            if tab.document.isModified {
                // Switch to the tab with changes
                switchToTab(at: index)

                let alert = NSAlert()
                alert.messageText = "Do you want to save the changes to \"\(tab.title)\"?"
                alert.informativeText = "Your changes will be lost if you don't save them."
                alert.alertStyle = .warning
                alert.addButton(withTitle: "Save")
                alert.addButton(withTitle: "Don't Save")
                alert.addButton(withTitle: "Cancel")

                let response = alert.runModal()

                switch response {
                case .alertFirstButtonReturn: // Save
                    saveDocument()
                    if tab.document.isModified {
                        return false // Save failed or was cancelled
                    }
                case .alertSecondButtonReturn: // Don't Save
                    continue
                default: // Cancel
                    return false
                }
            }
        }

        return true
    }

    func windowDidBecomeKey(_ notification: Notification) {
        // Update status bar when window becomes active
        updateStatusBar()
    }
}

// MARK: - NSDraggingDestination for Drag and Drop

extension MainWindowController: NSDraggingDestination {
    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        // Check if the dragged items contain file URLs
        guard let items = sender.draggingPasteboard.pasteboardItems else {
            return []
        }

        for item in items {
            if item.types.contains(.fileURL) {
                return .copy
            }
        }

        return []
    }

    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let items = sender.draggingPasteboard.pasteboardItems else {
            return false
        }

        for item in items {
            if let urlString = item.string(forType: .fileURL) {
                // Handle both file:// URLs and plain file paths
                let url: URL
                if urlString.hasPrefix("file://") {
                    guard let fileURL = URL(string: urlString) else { continue }
                    url = fileURL
                } else {
                    url = URL(fileURLWithPath: urlString)
                }

                // Open the dropped file in a new tab
                openFile(url: url)
                return true
            }
        }

        return false
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
