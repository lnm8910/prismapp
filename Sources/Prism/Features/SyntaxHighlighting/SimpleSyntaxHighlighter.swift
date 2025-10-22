import Foundation
import AppKit

/// Simple regex-based syntax highlighter (fallback for tree-sitter)
/// Provides basic syntax highlighting without external dependencies
class SimpleSyntaxHighlighter {
    private let themeManager = ThemeManager.shared
    private var textStorage: NSTextStorage?
    private var currentLanguage: String = "plaintext"

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

    func setTextStorage(_ textStorage: NSTextStorage) {
        self.textStorage = textStorage
    }

    func setLanguage(_ language: String) {
        currentLanguage = language
    }

    // MARK: - Highlighting

    func highlightAll() {
        guard let textStorage = textStorage else { return }
        let text = textStorage.string

        textStorage.beginEditing()

        // Reset all attributes
        let fullRange = NSRange(location: 0, length: textStorage.length)
        textStorage.removeAttribute(.foregroundColor, range: fullRange)
        textStorage.addAttribute(.foregroundColor,
                                value: themeManager.currentTheme.foreground,
                                range: fullRange)

        // Apply language-specific highlighting
        switch currentLanguage {
        case "swift":
            highlightSwift(text: text)
        case "javascript", "typescript", "jsx", "tsx":
            highlightJavaScript(text: text)
        case "python":
            highlightPython(text: text)
        case "json":
            highlightJSON(text: text)
        default:
            break // Plain text
        }

        textStorage.endEditing()
    }

    func highlightRange(_ range: NSRange) {
        // For simplicity, re-highlight entire document
        highlightAll()
    }

    func updateAfterEdit(range: NSRange, changeInLength delta: Int) {
        highlightAll()
    }

    // MARK: - Language-Specific Highlighting

    private func highlightSwift(text: String) {
        guard textStorage != nil else { return }

        // Swift keywords
        let keywords = [
            "import", "class", "struct", "enum", "protocol", "extension",
            "func", "var", "let", "private", "public", "internal", "fileprivate",
            "static", "override", "final", "lazy", "mutating", "nonmutating",
            "if", "else", "guard", "switch", "case", "default", "for", "while",
            "return", "break", "continue", "fallthrough", "where",
            "try", "catch", "throw", "throws", "rethrows", "defer",
            "init", "deinit", "self", "Self", "super",
            "as", "is", "in", "inout", "associatedtype", "typealias"
        ]

        // Highlight keywords
        for keyword in keywords {
            let pattern = "\\b\(keyword)\\b"
            highlightPattern(pattern, color: themeManager.currentTheme.keyword, in: text)
        }

        // Comments
        highlightPattern("//.*$", color: themeManager.currentTheme.comment, in: text, options: .anchorsMatchLines)
        highlightPattern("/\\*[\\s\\S]*?\\*/", color: themeManager.currentTheme.comment, in: text)

        // Strings
        highlightPattern("\"(?:[^\"\\\\]|\\\\.)*\"", color: themeManager.currentTheme.string, in: text)

        // Numbers
        highlightPattern("\\b\\d+(\\.\\d+)?\\b", color: themeManager.currentTheme.number, in: text)

        // Types (capitalized words)
        highlightPattern("\\b[A-Z][a-zA-Z0-9]*\\b", color: themeManager.currentTheme.type, in: text)

        // Function calls
        highlightPattern("\\b([a-z][a-zA-Z0-9]*)(?=\\s*\\()", color: themeManager.currentTheme.function, in: text)

        // Constants (true, false, nil)
        highlightPattern("\\b(true|false|nil)\\b", color: themeManager.currentTheme.constant, in: text)
    }

    private func highlightJavaScript(text: String) {
        guard textStorage != nil else { return }

        let keywords = [
            "import", "export", "from", "default", "const", "let", "var",
            "function", "async", "await", "return", "class", "extends",
            "if", "else", "switch", "case", "for", "while", "do",
            "try", "catch", "finally", "throw", "new", "this", "super",
            "typeof", "instanceof", "in", "of", "break", "continue"
        ]

        for keyword in keywords {
            highlightPattern("\\b\(keyword)\\b", color: themeManager.currentTheme.keyword, in: text)
        }

        // Comments
        highlightPattern("//.*$", color: themeManager.currentTheme.comment, in: text, options: .anchorsMatchLines)
        highlightPattern("/\\*[\\s\\S]*?\\*/", color: themeManager.currentTheme.comment, in: text)

        // Strings (single and double quotes)
        highlightPattern("\"(?:[^\"\\\\]|\\\\.)*\"", color: themeManager.currentTheme.string, in: text)
        highlightPattern("'(?:[^'\\\\]|\\\\.)*'", color: themeManager.currentTheme.string, in: text)
        highlightPattern("`(?:[^`\\\\]|\\\\.)*`", color: themeManager.currentTheme.string, in: text)

        // Numbers
        highlightPattern("\\b\\d+(\\.\\d+)?\\b", color: themeManager.currentTheme.number, in: text)

        // Function calls
        highlightPattern("\\b([a-zA-Z_$][a-zA-Z0-9_$]*)(?=\\s*\\()", color: themeManager.currentTheme.function, in: text)

        // Constants
        highlightPattern("\\b(true|false|null|undefined)\\b", color: themeManager.currentTheme.constant, in: text)
    }

    private func highlightPython(text: String) {
        guard textStorage != nil else { return }

        let keywords = [
            "import", "from", "as", "def", "class", "return", "if", "elif",
            "else", "for", "while", "break", "continue", "pass", "try",
            "except", "finally", "raise", "with", "lambda", "yield",
            "async", "await", "and", "or", "not", "in", "is"
        ]

        for keyword in keywords {
            highlightPattern("\\b\(keyword)\\b", color: themeManager.currentTheme.keyword, in: text)
        }

        // Comments
        highlightPattern("#.*$", color: themeManager.currentTheme.comment, in: text, options: .anchorsMatchLines)

        // Strings
        highlightPattern("\"\"\"[\\s\\S]*?\"\"\"", color: themeManager.currentTheme.string, in: text)
        highlightPattern("'''[\\s\\S]*?'''", color: themeManager.currentTheme.string, in: text)
        highlightPattern("\"(?:[^\"\\\\]|\\\\.)*\"", color: themeManager.currentTheme.string, in: text)
        highlightPattern("'(?:[^'\\\\]|\\\\.)*'", color: themeManager.currentTheme.string, in: text)

        // Numbers
        highlightPattern("\\b\\d+(\\.\\d+)?\\b", color: themeManager.currentTheme.number, in: text)

        // Function definitions
        highlightPattern("(?<=def\\s)\\w+", color: themeManager.currentTheme.function, in: text)

        // Constants
        highlightPattern("\\b(True|False|None)\\b", color: themeManager.currentTheme.constant, in: text)
    }

    private func highlightJSON(text: String) {
        guard textStorage != nil else { return }

        // Keys
        highlightPattern("\"[^\"]+\"(?=\\s*:)", color: themeManager.currentTheme.property, in: text)

        // String values
        highlightPattern("(?<=:\\s*)\"(?:[^\"\\\\]|\\\\.)*\"", color: themeManager.currentTheme.string, in: text)

        // Numbers
        highlightPattern("\\b-?\\d+(\\.\\d+)?([eE][+-]?\\d+)?\\b", color: themeManager.currentTheme.number, in: text)

        // Boolean and null
        highlightPattern("\\b(true|false|null)\\b", color: themeManager.currentTheme.constant, in: text)
    }

    // MARK: - Helper Methods

    private func highlightPattern(_ pattern: String, color: NSColor, in text: String, options: NSRegularExpression.Options = []) {
        guard let textStorage = textStorage else { return }

        do {
            let regex = try NSRegularExpression(pattern: pattern, options: options)
            let range = NSRange(location: 0, length: text.utf16.count)
            let matches = regex.matches(in: text, options: [], range: range)

            for match in matches {
                textStorage.addAttribute(.foregroundColor, value: color, range: match.range)
            }
        } catch {
            // Silently ignore regex errors
        }
    }

    @objc private func themeDidChange() {
        highlightAll()
    }
}
