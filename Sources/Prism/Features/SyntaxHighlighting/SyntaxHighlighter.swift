import Foundation
import AppKit
import SwiftTreeSitter

/// Handles syntax highlighting using Tree-sitter
class SyntaxHighlighter {
    private let languageRegistry = LanguageRegistry.shared
    private let themeManager = ThemeManager.shared

    private var currentLanguage: String = "plaintext"
    private var currentTree: MutableTree?
    private var textStorage: NSTextStorage?

    // Performance tracking
    private var lastHighlightTime: TimeInterval = 0

    init() {
        // Listen for theme changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: ThemeManager.themeDidChangeNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Configuration

    /// Set the text storage to highlight
    func setTextStorage(_ textStorage: NSTextStorage) {
        self.textStorage = textStorage
    }

    /// Set the language for syntax highlighting
    func setLanguage(_ language: String) {
        currentLanguage = language
        currentTree = nil // Reset tree when language changes
    }

    // MARK: - Highlighting

    /// Highlight the entire document
    func highlightAll() {
        guard let textStorage = textStorage else { return }

        let startTime = Date()

        // Skip if language not supported
        guard languageRegistry.isSupported(language: currentLanguage) else {
            applyPlainTextStyle()
            return
        }

        let text = textStorage.string

        // Parse the entire document
        currentTree = languageRegistry.parse(text: text, language: currentLanguage)

        guard let tree = currentTree else {
            applyPlainTextStyle()
            return
        }

        // Apply highlighting
        applyHighlighting(tree: tree, text: text, range: NSRange(location: 0, length: text.utf16.count))

        // Track performance
        lastHighlightTime = Date().timeIntervalSince(startTime)
        if lastHighlightTime > 0.016 { // 60 FPS threshold
            print("⚠️ Syntax highlighting took \(lastHighlightTime * 1000)ms (target: <16ms)")
        }
    }

    /// Highlight a specific range (for incremental updates)
    func highlightRange(_ range: NSRange) {
        guard let textStorage = textStorage else { return }

        // Skip if language not supported
        guard languageRegistry.isSupported(language: currentLanguage) else {
            return
        }

        let text = textStorage.string

        // For now, re-parse entire document
        // TODO: Implement true incremental parsing with edit operations
        currentTree = languageRegistry.parse(text: text, language: currentLanguage)

        guard let tree = currentTree else { return }

        // Apply highlighting to the changed range
        applyHighlighting(tree: tree, text: text, range: range)
    }

    /// Update highlighting after text edit (incremental)
    func updateAfterEdit(range: NSRange, changeInLength delta: Int) {
        guard let textStorage = textStorage else { return }

        // For files larger than 100KB, highlight only visible range
        if textStorage.length > 100_000 {
            highlightRange(range)
            return
        }

        // For smaller files, re-highlight entire document
        highlightAll()
    }

    // MARK: - Private Helpers

    private func applyHighlighting(tree: MutableTree, text: String, range: NSRange) {
        guard let textStorage = textStorage else { return }

        // Reset attributes in range
        textStorage.beginEditing()
        textStorage.removeAttribute(.foregroundColor, range: range)

        // Get the root node
        guard let rootNode = tree.rootNode else {
            textStorage.endEditing()
            return
        }

        // Apply syntax highlighting using Tree-sitter queries
        applyQueryHighlighting(node: rootNode, text: text)

        textStorage.endEditing()
    }

    private func applyQueryHighlighting(node: Node, text: String) {
        guard let textStorage = textStorage else { return }
        guard let queryString = languageRegistry.getHighlightQuery(for: currentLanguage) else {
            return
        }

        guard let language = languageRegistry.getLanguage(for: currentLanguage) else {
            return
        }

        // Create and execute query
        do {
            guard let tree = tree(for: text) else { return }

            let queryData = queryString.data(using: .utf8)!
            let query = try Query(language: language, data: queryData)
            let cursor = query.execute(node: node, in: tree)

            // Process each match
            for match in cursor {
                for capture in match.captures {
                    // Get capture name - use simple indexing for now
                    // TODO: Update when proper API is determined
                    let captureName = "keyword" // Default to keyword for now
                    let pointRange = capture.node.pointRange

                    // Convert Tree-sitter range to NSRange
                    if let nsRange = convertToNSRange(range: pointRange, text: text) {
                        let color = themeManager.color(for: captureName)
                        textStorage.addAttribute(.foregroundColor, value: color, range: nsRange)
                    }
                }
            }
        } catch {
            print("Error executing highlight query: \(error)")
        }
    }

    private func tree(for text: String) -> MutableTree? {
        return currentTree
    }

    private func convertToNSRange(range: Range<Point>, text: String) -> NSRange? {
        // Convert Tree-sitter Point range to NSRange
        // Use row and column to calculate byte offset
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)

        guard range.lowerBound.row < lines.count, range.upperBound.row < lines.count else {
            return nil
        }

        // Calculate byte offsets from row/column
        var startByteOffset = 0
        for i in 0..<Int(range.lowerBound.row) {
            startByteOffset += lines[i].utf8.count + 1 // +1 for newline
        }
        startByteOffset += Int(range.lowerBound.column)

        var endByteOffset = 0
        for i in 0..<Int(range.upperBound.row) {
            endByteOffset += lines[i].utf8.count + 1 // +1 for newline
        }
        endByteOffset += Int(range.upperBound.column)

        // Convert to UTF-16 for NSRange
        let utf16Start = String(text.utf8.prefix(startByteOffset))?.utf16.count ?? 0
        let utf16End = String(text.utf8.prefix(endByteOffset))?.utf16.count ?? 0

        return NSRange(location: utf16Start, length: utf16End - utf16Start)
    }

    private func applyPlainTextStyle() {
        guard let textStorage = textStorage else { return }

        textStorage.beginEditing()
        textStorage.removeAttribute(.foregroundColor, range: NSRange(location: 0, length: textStorage.length))
        textStorage.addAttribute(.foregroundColor, value: themeManager.currentTheme.foreground,
                                range: NSRange(location: 0, length: textStorage.length))
        textStorage.endEditing()
    }

    // MARK: - Theme Changes

    @objc private func themeDidChange() {
        // Re-apply highlighting with new theme
        highlightAll()
    }
}

// MARK: - Performance Monitoring

extension SyntaxHighlighter {
    /// Get the time taken for the last highlighting operation
    var lastHighlightDuration: TimeInterval {
        return lastHighlightTime
    }

    /// Check if highlighting is performant (<16ms for 60 FPS)
    var isPerformant: Bool {
        return lastHighlightTime < 0.016
    }
}
