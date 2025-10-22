import Foundation
import AppKit

// This is a test Swift file for syntax highlighting
class PrismEditor {
    private var documents: [String] = []
    private let maxSize: Int = 1000

    init() {
        print("Initializing Prism Editor")
    }

    func openDocument(url: URL) throws {
        let content = try String(contentsOf: url)
        documents.append(content)
    }

    func saveDocument(at url: URL) {
        // Save implementation
        if let data = "Hello, World!".data(using: .utf8) {
            try? data.write(to: url)
        }
    }

    func highlightSyntax() -> Bool {
        guard !documents.isEmpty else {
            return false
        }

        for document in documents {
            let lines = document.split(separator: "\n")
            print("Processing \(lines.count) lines")
        }

        return true
    }
}

// Extension for string utilities
extension String {
    var isSwiftFile: Bool {
        return self.hasSuffix(".swift")
    }

    func countWords() -> Int {
        return self.components(separatedBy: .whitespaces).count
    }
}

// Protocol definition
protocol TextEditor {
    var name: String { get }
    func edit(text: String) -> String
}

// Enum example
enum FileType {
    case swift
    case python
    case javascript
    case plaintext

    var displayName: String {
        switch self {
        case .swift: return "Swift"
        case .python: return "Python"
        case .javascript: return "JavaScript"
        case .plaintext: return "Plain Text"
        }
    }
}

// Numbers and constants
let version = 1.0
let isEnabled = true
let maxConnections = 100
let pi = 3.14159

// Function with various keywords
func processFile(path: String, async: Bool = false) throws -> Data? {
    guard !path.isEmpty else {
        throw NSError(domain: "Invalid path", code: 1)
    }

    if async {
        // Async processing
        return nil
    } else {
        // Sync processing
        let url = URL(fileURLWithPath: path)
        return try Data(contentsOf: url)
    }
}
