import Foundation
import AppKit

class PrismDocument: NSObject {
    // Document properties
    var fileURL: URL?
    var content: String = ""
    var encoding: String.Encoding = .utf8
    var isModified: Bool = false

    // Metadata
    var fileSize: Int64 = 0
    var lineCount: Int = 0
    var language: String = "plaintext"
    var lineEnding: LineEnding = .lf

    enum LineEnding: String {
        case lf = "\n"      // Unix/Mac
        case crlf = "\r\n"  // Windows
        case cr = "\r"      // Old Mac

        var displayName: String {
            switch self {
            case .lf: return "LF"
            case .crlf: return "CRLF"
            case .cr: return "CR"
            }
        }
    }

    // Initialization
    init(fileURL: URL? = nil) {
        self.fileURL = fileURL
        super.init()

        if let url = fileURL {
            loadFromFile(url: url)
        }
    }

    // MARK: - File operations

    func loadFromFile(url: URL) {
        do {
            // Read file
            let data = try Data(contentsOf: url)

            // Detect encoding
            encoding = detectEncoding(data: data)

            // Convert to string
            if let text = String(data: data, encoding: encoding) {
                content = text
                fileURL = url
                fileSize = Int64(data.count)

                // Detect line ending
                lineEnding = detectLineEnding(text: text)

                // Count lines
                lineCount = text.components(separatedBy: .newlines).count

                // Detect language from extension
                language = detectLanguage(url: url)

                isModified = false
            }
        } catch {
            print("Error loading file: \(error)")
        }
    }

    func saveToFile(url: URL? = nil) throws {
        let targetURL = url ?? fileURL
        guard let targetURL = targetURL else {
            throw NSError(domain: "PrismDocument", code: 1,
                         userInfo: [NSLocalizedDescriptionKey: "No file URL specified"])
        }

        // Convert string to data
        guard let data = content.data(using: encoding) else {
            throw NSError(domain: "PrismDocument", code: 2,
                         userInfo: [NSLocalizedDescriptionKey: "Failed to encode text"])
        }

        // Write to file
        try data.write(to: targetURL, options: .atomic)

        fileURL = targetURL
        isModified = false
        fileSize = Int64(data.count)
    }

    // MARK: - Helper methods

    private func detectEncoding(data: Data) -> String.Encoding {
        // Try UTF-8 first
        if String(data: data, encoding: .utf8) != nil {
            return .utf8
        }

        // Try UTF-16
        if String(data: data, encoding: .utf16) != nil {
            return .utf16
        }

        // Fall back to ASCII
        return .ascii
    }

    private func detectLineEnding(text: String) -> LineEnding {
        if text.contains("\r\n") {
            return .crlf
        } else if text.contains("\r") {
            return .cr
        } else {
            return .lf
        }
    }

    private func detectLanguage(url: URL) -> String {
        let ext = url.pathExtension.lowercased()

        // Language map
        let languageMap: [String: String] = [
            "swift": "swift",
            "js": "javascript",
            "ts": "typescript",
            "tsx": "typescript",
            "jsx": "javascript",
            "py": "python",
            "rb": "ruby",
            "go": "go",
            "rs": "rust",
            "c": "c",
            "cpp": "cpp",
            "cc": "cpp",
            "cxx": "cpp",
            "h": "c",
            "hpp": "cpp",
            "hxx": "cpp",
            "java": "java",
            "kt": "kotlin",
            "html": "html",
            "htm": "html",
            "css": "css",
            "scss": "scss",
            "sass": "sass",
            "md": "markdown",
            "markdown": "markdown",
            "json": "json",
            "xml": "xml",
            "yaml": "yaml",
            "yml": "yaml",
            "sh": "bash",
            "bash": "bash",
            "zsh": "zsh",
            "fish": "fish",
            "txt": "plaintext",
            "": "plaintext"
        ]

        return languageMap[ext] ?? "plaintext"
    }

    func updateMetadata() {
        lineCount = content.components(separatedBy: .newlines).count
        fileSize = Int64(content.utf8.count)
    }
}
