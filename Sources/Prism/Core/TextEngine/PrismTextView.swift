import Cocoa

class PrismTextView: NSTextView {
    // Custom properties
    var document: PrismDocument?

    // Syntax highlighting
    private let syntaxHighlighter = SimpleSyntaxHighlighter()

    // Performance properties
    private var isLargeFile: Bool = false
    private let largeFileThreshold: Int = 10_000_000 // 10MB

    // Callbacks
    var onTextChange: (() -> Void)?

    override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
        super.init(frame: frameRect, textContainer: container)
        setupTextView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTextView()
    }

    private func setupTextView() {
        // Appearance
        backgroundColor = NSColor.textBackgroundColor
        insertionPointColor = NSColor.controlAccentColor

        // Behavior
        isAutomaticQuoteSubstitutionEnabled = false
        isAutomaticDashSubstitutionEnabled = false
        isAutomaticTextReplacementEnabled = false
        isAutomaticSpellingCorrectionEnabled = false

        // Font - using SF Mono for a clean, readable monospace font
        font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)

        // Wrapping (disabled by default for performance)
        textContainer?.containerSize = NSSize(width: CGFloat.greatestFiniteMagnitude,
                                              height: CGFloat.greatestFiniteMagnitude)
        textContainer?.widthTracksTextView = false

        // Enable horizontal scrolling
        isHorizontallyResizable = true
        isVerticallyResizable = true
        autoresizingMask = [.width, .height]

        // Enable undo
        allowsUndo = true

        // Delegate
        delegate = self

        // Text insets for comfortable reading
        textContainerInset = NSSize(width: 5, height: 10)

        // Setup syntax highlighter
        if let textStorage = textStorage {
            syntaxHighlighter.setTextStorage(textStorage)
        }

        // Disable file drag and drop on text view itself
        // (handled by parent window controller instead)
        unregisterDraggedTypes()
        registerForDraggedTypes([.string]) // Only accept text, not files
    }

    func setDocument(_ doc: PrismDocument) {
        document = doc

        // Check if large file
        isLargeFile = doc.fileSize > largeFileThreshold

        if isLargeFile {
            // Disable expensive features for large files
            isAutomaticSpellingCorrectionEnabled = false
            isContinuousSpellCheckingEnabled = false
            isGrammarCheckingEnabled = false
        }

        // Set text
        string = doc.content

        // Setup syntax highlighting
        syntaxHighlighter.setLanguage(doc.language)
        syntaxHighlighter.highlightAll()
    }

    func toggleWordWrap() {
        guard let textContainer = textContainer,
              let scrollView = enclosingScrollView else { return }

        if textContainer.widthTracksTextView {
            // Disable wrap
            textContainer.containerSize = NSSize(
                width: CGFloat.greatestFiniteMagnitude,
                height: CGFloat.greatestFiniteMagnitude
            )
            textContainer.widthTracksTextView = false
            isHorizontallyResizable = true
            scrollView.hasHorizontalScroller = true
        } else {
            // Enable wrap
            textContainer.widthTracksTextView = true
            isHorizontallyResizable = false
            scrollView.hasHorizontalScroller = false
        }

        // Force layout update
        needsLayout = true
    }

    // MARK: - Performance monitoring

    override var string: String {
        get { super.string }
        set {
            let startTime = CFAbsoluteTimeGetCurrent()
            super.string = newValue
            let elapsed = CFAbsoluteTimeGetCurrent() - startTime

            if elapsed > 0.1 {
                print("⚠️ Performance warning: Text setting took \(String(format: "%.3f", elapsed))s for \(newValue.count) chars")
            }
        }
    }

    // MARK: - Current line highlighting

    override func drawBackground(in rect: NSRect) {
        super.drawBackground(in: rect)

        // Draw current line highlight
        drawCurrentLineHighlight()
    }

    private func drawCurrentLineHighlight() {
        guard let layoutManager = layoutManager else { return }

        // Get current line rect
        let selectedRange = self.selectedRange()

        // Only highlight if there's a cursor (no selection)
        guard selectedRange.length == 0 else { return }

        // Don't try to highlight if there's no text or invalid range
        guard string.count > 0,
              selectedRange.location <= string.count else { return }

        // Ensure we have a valid glyph range
        let glyphRange = layoutManager.glyphRange(forCharacterRange: selectedRange,
                                                   actualCharacterRange: nil)

        // Check if glyph range is valid
        guard glyphRange.location < layoutManager.numberOfGlyphs || layoutManager.numberOfGlyphs == 0 else {
            return
        }

        // Get line fragment rect safely
        var effectiveRange = NSRange(location: 0, length: 0)
        let lineRect = layoutManager.lineFragmentRect(forGlyphAt: glyphRange.location,
                                                       effectiveRange: &effectiveRange,
                                                       withoutAdditionalLayout: true)

        // Only draw if we got a valid rect
        guard !lineRect.isEmpty else { return }

        // Draw highlight
        let highlightColor = NSColor.selectedTextBackgroundColor.withAlphaComponent(0.05)
        highlightColor.setFill()

        var highlightRect = lineRect
        highlightRect.origin.x = bounds.minX
        highlightRect.size.width = bounds.width
        NSBezierPath(rect: highlightRect).fill()
    }

    // MARK: - Drag and Drop Override

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        // Check if dragging files - show copy cursor but we'll handle in parent
        if let items = sender.draggingPasteboard.pasteboardItems {
            for item in items {
                if item.types.contains(.fileURL) {
                    return .copy // Show copy cursor for file drags
                }
            }
        }
        // Allow text drags
        return super.draggingEntered(sender)
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        // Check if dragging files - forward to window controller
        if let items = sender.draggingPasteboard.pasteboardItems {
            for item in items {
                if item.types.contains(.fileURL),
                   let urlString = item.string(forType: .fileURL) {
                    // Handle both file:// URLs and plain file paths
                    let url: URL
                    if urlString.hasPrefix("file://") {
                        guard let fileURL = URL(string: urlString) else { continue }
                        url = fileURL
                    } else {
                        url = URL(fileURLWithPath: urlString)
                    }

                    // Find window controller and open file
                    if let windowController = window?.windowController as? MainWindowController {
                        windowController.openFile(url: url)
                        return true
                    }
                }
            }
        }
        // Handle text drags normally
        return super.performDragOperation(sender)
    }
}

// MARK: - NSTextViewDelegate

extension PrismTextView: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        // Mark document as modified
        document?.isModified = true
        document?.content = string
        document?.updateMetadata()

        // Notify delegate
        onTextChange?()

        // Update syntax highlighting incrementally
        // For now, re-highlight all on change
        // TODO: implement incremental updates based on edited range
        syntaxHighlighter.highlightAll()
    }

    func textView(_ textView: NSTextView,
                  shouldChangeTextIn affectedCharRange: NSRange,
                  replacementString: String?) -> Bool {
        // Custom text change logic here if needed
        return true
    }
}
