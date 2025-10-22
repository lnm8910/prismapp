import Foundation
import SwiftTreeSitter

/// Manages Tree-sitter language parsers and their configuration
/// NOTE: Language parsers are currently disabled due to SPM build issues
/// This will be re-enabled when proper SPM-compatible parser packages are available
class LanguageRegistry {
    static let shared = LanguageRegistry()

    private var parsers: [String: Parser] = [:]
    private var languages: [String: Language] = [:]

    private init() {
        registerLanguages()
    }

    // MARK: - Language Registration

    private func registerLanguages() {
        // TODO: Add language parsers when SPM-compatible packages are available
        // Currently disabled to allow the app to build
        print("Note: Syntax highlighting is temporarily disabled - language parsers not configured")
    }

    private func registerLanguage(name: String, language: Language) throws {
        let parser = Parser()
        try parser.setLanguage(language)
        parsers[name] = parser
        languages[name] = language
    }

    // MARK: - Public API

    /// Get a parser for the specified language
    func getParser(for language: String) -> Parser? {
        return parsers[language]
    }

    /// Get the language configuration for syntax queries
    func getLanguage(for language: String) -> Language? {
        return languages[language]
    }

    /// Check if a language is supported
    func isSupported(language: String) -> Bool {
        return parsers[language] != nil
    }

    /// Get all supported language names
    func supportedLanguages() -> [String] {
        return Array(parsers.keys).sorted()
    }

    /// Parse text with the appropriate language parser
    func parse(text: String, language: String) -> MutableTree? {
        guard let parser = getParser(for: language) else {
            return nil
        }

        return parser.parse(text)
    }

    /// Parse text incrementally (for edits)
    func parseIncremental(text: String, language: String, oldTree: MutableTree?, edit: InputEdit? = nil) -> MutableTree? {
        guard let parser = getParser(for: language) else {
            return nil
        }

        if let oldTree = oldTree, let edit = edit {
            oldTree.edit(edit)
        }

        // Note: SwiftTreeSitter API may have changed - using regular parse for now
        return parser.parse(text)
    }
}

// MARK: - Syntax Queries

extension LanguageRegistry {
    /// Get syntax highlighting queries for a language
    /// These define how to map Tree-sitter nodes to syntax categories
    func getHighlightQuery(for language: String) -> String? {
        // Basic queries for each language
        // In production, these would be loaded from external files
        switch language {
        case "swift":
            return swiftHighlightQuery
        case "javascript", "typescript", "jsx", "tsx":
            return javascriptHighlightQuery
        case "python":
            return pythonHighlightQuery
        case "rust":
            return rustHighlightQuery
        case "go":
            return goHighlightQuery
        case "json":
            return jsonHighlightQuery
        default:
            return nil
        }
    }

    // MARK: - Query Strings

    private var swiftHighlightQuery: String {
        """
        (comment) @comment
        (multiline_comment) @comment

        (function_declaration name: (simple_identifier) @function)
        (call_expression (simple_identifier) @function.call)

        (class_declaration name: (type_identifier) @type)
        (struct_declaration name: (type_identifier) @type)
        (protocol_declaration name: (type_identifier) @type)
        (enum_declaration name: (type_identifier) @type)

        (import_declaration) @keyword
        ["func" "let" "var" "class" "struct" "enum" "protocol" "extension"
         "if" "else" "guard" "switch" "case" "for" "while" "return"
         "public" "private" "internal" "fileprivate" "static" "override"] @keyword

        (string_literal) @string
        (integer_literal) @number
        (real_literal) @number
        (boolean_literal) @constant.builtin
        """
    }

    private var javascriptHighlightQuery: String {
        """
        (comment) @comment

        (function_declaration name: (identifier) @function)
        (method_definition name: (property_identifier) @method)
        (call_expression function: (identifier) @function.call)

        (class_declaration name: (identifier) @type)

        ["import" "export" "from" "function" "class" "let" "const" "var"
         "if" "else" "switch" "case" "for" "while" "return" "async" "await"] @keyword

        (string) @string
        (template_string) @string
        (number) @number
        (true) @constant.builtin
        (false) @constant.builtin
        (null) @constant.builtin
        """
    }

    private var pythonHighlightQuery: String {
        """
        (comment) @comment

        (function_definition name: (identifier) @function)
        (call (identifier) @function.call)

        (class_definition name: (identifier) @type)

        ["import" "from" "def" "class" "if" "elif" "else" "for" "while"
         "return" "async" "await" "with" "as" "pass" "break" "continue"] @keyword

        (string) @string
        (integer) @number
        (float) @number
        (true) @constant.builtin
        (false) @constant.builtin
        (none) @constant.builtin
        """
    }

    private var rustHighlightQuery: String {
        """
        (line_comment) @comment
        (block_comment) @comment

        (function_item name: (identifier) @function)
        (call_expression function: (identifier) @function.call)

        (struct_item name: (type_identifier) @type)
        (enum_item name: (type_identifier) @type)
        (impl_item type: (type_identifier) @type)

        ["use" "fn" "struct" "enum" "impl" "trait" "let" "mut" "const" "static"
         "if" "else" "match" "for" "while" "loop" "return" "pub" "mod"] @keyword

        (string_literal) @string
        (integer_literal) @number
        (float_literal) @number
        (boolean_literal) @constant.builtin
        """
    }

    private var goHighlightQuery: String {
        """
        (comment) @comment

        (function_declaration name: (identifier) @function)
        (method_declaration name: (field_identifier) @method)
        (call_expression function: (identifier) @function.call)

        (type_declaration (type_spec name: (type_identifier) @type))

        ["import" "package" "func" "type" "struct" "interface" "var" "const"
         "if" "else" "switch" "case" "for" "range" "return" "go" "defer"] @keyword

        (interpreted_string_literal) @string
        (raw_string_literal) @string
        (int_literal) @number
        (float_literal) @number
        (true) @constant.builtin
        (false) @constant.builtin
        (nil) @constant.builtin
        """
    }

    private var jsonHighlightQuery: String {
        """
        (string) @string
        (number) @number
        (true) @constant.builtin
        (false) @constant.builtin
        (null) @constant.builtin
        (pair key: (string) @property)
        """
    }
}
