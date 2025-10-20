import Cocoa

class PrismTextView: NSTextView {
    // Custom properties
    var document: PrismDocument?

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
            print("Large file detected (\(doc.fileSize) bytes). Some features disabled for performance.")
        }

        // Set text
        string = doc.content
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
    }

    func textView(_ textView: NSTextView,
                  shouldChangeTextIn affectedCharRange: NSRange,
                  replacementString: String?) -> Bool {
        // Custom text change logic here if needed
        return true
    }
}
