import Cocoa

class StatusBar: NSView {
    private var lineLabel: NSTextField!
    private var cursorLabel: NSTextField!
    private var encodingLabel: NSTextField!
    private var languageLabel: NSTextField!
    private var lineEndingLabel: NSTextField!

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        // Background
        wantsLayer = true
        layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor

        // Add top border
        let border = CALayer()
        border.frame = NSRect(x: 0, y: bounds.height - 1,
                             width: bounds.width, height: 1)
        border.backgroundColor = NSColor.separatorColor.cgColor
        border.autoresizingMask = [.layerWidthSizable, .layerMinYMargin]
        layer?.addSublayer(border)

        // Line count label
        lineLabel = createLabel(x: 10)
        lineLabel.stringValue = "Lines: 0"
        addSubview(lineLabel)

        // Cursor position label
        cursorLabel = createLabel(x: 120)
        cursorLabel.stringValue = "Ln 1, Col 1"
        addSubview(cursorLabel)

        // Line ending label
        lineEndingLabel = createLabel(x: bounds.width - 330)
        lineEndingLabel.autoresizingMask = [.minXMargin]
        lineEndingLabel.stringValue = "LF"
        addSubview(lineEndingLabel)

        // Encoding label
        encodingLabel = createLabel(x: bounds.width - 220)
        encodingLabel.autoresizingMask = [.minXMargin]
        encodingLabel.stringValue = "UTF-8"
        addSubview(encodingLabel)

        // Language label
        languageLabel = createLabel(x: bounds.width - 110)
        languageLabel.autoresizingMask = [.minXMargin]
        languageLabel.stringValue = "Plain Text"
        addSubview(languageLabel)
    }

    private func createLabel(x: CGFloat) -> NSTextField {
        let label = NSTextField(frame: NSRect(x: x, y: 4, width: 100, height: 16))
        label.isBordered = false
        label.isEditable = false
        label.isSelectable = false
        label.backgroundColor = .clear
        label.font = NSFont.systemFont(ofSize: 11)
        label.textColor = .secondaryLabelColor
        return label
    }

    func update(lineCount: Int, cursorLine: Int, cursorColumn: Int, encoding: String.Encoding, language: String, lineEnding: String) {
        lineLabel.stringValue = "Lines: \(lineCount)"
        cursorLabel.stringValue = "Ln \(cursorLine), Col \(cursorColumn)"

        // Display encoding name
        let encodingName: String
        switch encoding {
        case .utf8:
            encodingName = "UTF-8"
        case .utf16:
            encodingName = "UTF-16"
        case .ascii:
            encodingName = "ASCII"
        default:
            encodingName = "Unknown"
        }
        encodingLabel.stringValue = encodingName

        languageLabel.stringValue = language.capitalized
        lineEndingLabel.stringValue = lineEnding
    }

    // Convenience method for simpler updates
    func update(document: PrismDocument, cursorLine: Int, cursorColumn: Int) {
        update(
            lineCount: document.lineCount,
            cursorLine: cursorLine,
            cursorColumn: cursorColumn,
            encoding: document.encoding,
            language: document.language,
            lineEnding: document.lineEnding.displayName
        )
    }
}
