import Foundation
import AppKit
import SwiftTreeSitter

/// Handles syntax highlighting using Tree-sitter
class SyntaxHighlighter {
    private let languageRegistry = LanguageRegistry.shared
    private let themeManager = ThemeManager.shared

    private var currentLanguage: String = "plaintext"
    private var currentTree: Tree?
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

    private func applyHighlighting(tree: Tree, text: String, range: NSRange) {
        guard let textStorage = textStorage else { return }

        // Reset attributes in range
        textStorage.beginEditing()
        textStorage.removeAttribute(.foregroundColor, range: range)

        // Get the root node
        let rootNode = tree.rootNode

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
            let query = try Query(language: language, source: queryString)
            let cursor = query.execute(node: node, in: tree(for: text))

            // Process each match
            for match in cursor {
                for capture in match.captures {
                    let captureName = query.captureNames[Int(capture.index)]
                    let range = capture.node.range

                    // Convert Tree-sitter range to NSRange
                    if let nsRange = convertToNSRange(range: range, text: text) {
                        let color = themeManager.color(for: captureName)
                        textStorage.addAttribute(.foregroundColor, value: color, range: nsRange)
                    }
                }
            }
        } catch {
            print("Error executing highlight query: \(error)")
        }
    }

    private func tree(for text: String) -> Tree? {
        return currentTree
    }

    private func convertToNSRange(range: Range<Point>, text: String) -> NSRange? {
        // Convert Tree-sitter Point range to NSRange
        let startByte = range.lowerBound.byte
        let endByte = range.upperBound.byte

        guard startByte <= text.utf8.count, endByte <= text.utf8.count else {
            return nil
        }

        // Get UTF-16 offsets for NSRange
        let utf16Start = text.utf8.prefix(Int(startByte)).utf16.count
        let utf16Length = text.utf8.prefix(Int(endByte)).utf16.count - utf16Start

        return NSRange(location: utf16Start, length: utf16Length)
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
