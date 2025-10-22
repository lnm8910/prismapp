import AppKit

/// Represents a color theme for syntax highlighting
struct Theme {
    let name: String
    let background: NSColor
    let foreground: NSColor
    let selection: NSColor
    let lineHighlight: NSColor

    // Syntax colors
    let comment: NSColor
    let keyword: NSColor
    let string: NSColor
    let number: NSColor
    let function: NSColor
    let functionCall: NSColor
    let method: NSColor
    let type: NSColor
    let property: NSColor
    let variable: NSColor
    let constant: NSColor
    let operator_: NSColor
    let punctuation: NSColor
}

// MARK: - Predefined Themes

extension Theme {
    /// Default light theme (similar to Xcode light)
    static let light = Theme(
        name: "Light",
        background: NSColor(white: 1.0, alpha: 1.0),
        foreground: NSColor(white: 0.0, alpha: 1.0),
        selection: NSColor(red: 0.7, green: 0.85, blue: 1.0, alpha: 1.0),
        lineHighlight: NSColor(white: 0.95, alpha: 1.0),
        comment: NSColor(red: 0.42, green: 0.54, blue: 0.58, alpha: 1.0),        // Gray
        keyword: NSColor(red: 0.67, green: 0.21, blue: 0.56, alpha: 1.0),        // Purple
        string: NSColor(red: 0.77, green: 0.13, blue: 0.09, alpha: 1.0),         // Red
        number: NSColor(red: 0.11, green: 0.0, blue: 0.81, alpha: 1.0),          // Blue
        function: NSColor(red: 0.24, green: 0.43, blue: 0.77, alpha: 1.0),       // Blue
        functionCall: NSColor(red: 0.24, green: 0.43, blue: 0.77, alpha: 1.0),   // Blue
        method: NSColor(red: 0.24, green: 0.43, blue: 0.77, alpha: 1.0),         // Blue
        type: NSColor(red: 0.22, green: 0.57, blue: 0.53, alpha: 1.0),           // Teal
        property: NSColor(red: 0.24, green: 0.43, blue: 0.77, alpha: 1.0),       // Blue
        variable: NSColor(white: 0.0, alpha: 1.0),                               // Black
        constant: NSColor(red: 0.62, green: 0.42, blue: 0.0, alpha: 1.0),        // Brown
        operator_: NSColor(white: 0.0, alpha: 1.0),                              // Black
        punctuation: NSColor(white: 0.0, alpha: 1.0)                             // Black
    )

    /// Default dark theme (similar to Xcode dark)
    static let dark = Theme(
        name: "Dark",
        background: NSColor(white: 0.15, alpha: 1.0),
        foreground: NSColor(white: 0.93, alpha: 1.0),
        selection: NSColor(red: 0.25, green: 0.35, blue: 0.5, alpha: 1.0),
        lineHighlight: NSColor(white: 0.2, alpha: 1.0),
        comment: NSColor(red: 0.45, green: 0.62, blue: 0.45, alpha: 1.0),        // Green
        keyword: NSColor(red: 0.98, green: 0.38, blue: 0.77, alpha: 1.0),        // Pink
        string: NSColor(red: 0.98, green: 0.38, blue: 0.38, alpha: 1.0),         // Red
        number: NSColor(red: 0.83, green: 0.68, blue: 0.42, alpha: 1.0),         // Orange
        function: NSColor(red: 0.41, green: 0.74, blue: 0.98, alpha: 1.0),       // Light blue
        functionCall: NSColor(red: 0.41, green: 0.74, blue: 0.98, alpha: 1.0),   // Light blue
        method: NSColor(red: 0.41, green: 0.74, blue: 0.98, alpha: 1.0),         // Light blue
        type: NSColor(red: 0.51, green: 0.85, blue: 0.77, alpha: 1.0),           // Teal
        property: NSColor(red: 0.41, green: 0.74, blue: 0.98, alpha: 1.0),       // Light blue
        variable: NSColor(white: 0.93, alpha: 1.0),                              // White
        constant: NSColor(red: 0.78, green: 0.67, blue: 0.42, alpha: 1.0),       // Brown
        operator_: NSColor(white: 0.93, alpha: 1.0),                             // White
        punctuation: NSColor(white: 0.93, alpha: 1.0)                            // White
    )

    /// VS Code-inspired dark theme
    static let vscode = Theme(
        name: "VS Code Dark",
        background: NSColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0),
        foreground: NSColor(red: 0.83, green: 0.83, blue: 0.83, alpha: 1.0),
        selection: NSColor(red: 0.2, green: 0.37, blue: 0.55, alpha: 1.0),
        lineHighlight: NSColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0),
        comment: NSColor(red: 0.38, green: 0.51, blue: 0.36, alpha: 1.0),        // Green
        keyword: NSColor(red: 0.33, green: 0.62, blue: 0.83, alpha: 1.0),        // Blue
        string: NSColor(red: 0.81, green: 0.56, blue: 0.47, alpha: 1.0),         // Orange
        number: NSColor(red: 0.71, green: 0.85, blue: 0.65, alpha: 1.0),         // Light green
        function: NSColor(red: 0.86, green: 0.86, blue: 0.67, alpha: 1.0),       // Yellow
        functionCall: NSColor(red: 0.86, green: 0.86, blue: 0.67, alpha: 1.0),   // Yellow
        method: NSColor(red: 0.86, green: 0.86, blue: 0.67, alpha: 1.0),         // Yellow
        type: NSColor(red: 0.31, green: 0.78, blue: 0.47, alpha: 1.0),           // Green
        property: NSColor(red: 0.61, green: 0.78, blue: 0.91, alpha: 1.0),       // Light blue
        variable: NSColor(red: 0.61, green: 0.78, blue: 0.91, alpha: 1.0),       // Light blue
        constant: NSColor(red: 0.33, green: 0.62, blue: 0.83, alpha: 1.0),       // Blue
        operator_: NSColor(red: 0.83, green: 0.83, blue: 0.83, alpha: 1.0),      // White
        punctuation: NSColor(red: 0.83, green: 0.83, blue: 0.83, alpha: 1.0)     // White
    )
}

// MARK: - Theme Manager

class ThemeManager {
    static let shared = ThemeManager()

    private(set) var currentTheme: Theme
    private var availableThemes: [String: Theme] = [:]

    // Notification for theme changes
    static let themeDidChangeNotification = Notification.Name("ThemeDidChange")

    private init() {
        // Start with system appearance-based theme
        currentTheme = NSApp.effectiveAppearance.name == .darkAqua ? .dark : .light

        // Register available themes
        availableThemes = [
            "Light": .light,
            "Dark": .dark,
            "VS Code Dark": .vscode
        ]
    }

    /// Switch to a different theme
    func setTheme(_ theme: Theme) {
        currentTheme = theme
        NotificationCenter.default.post(name: ThemeManager.themeDidChangeNotification, object: theme)
    }

    /// Switch to a theme by name
    func setTheme(named name: String) {
        if let theme = availableThemes[name] {
            setTheme(theme)
        }
    }

    /// Get all available theme names
    func availableThemeNames() -> [String] {
        return Array(availableThemes.keys).sorted()
    }

    /// Automatically switch theme based on system appearance
    func updateForSystemAppearance() {
        let isDark = NSApp.effectiveAppearance.name == .darkAqua
        setTheme(isDark ? .dark : .light)
    }

    /// Get color for a syntax token type
    func color(for tokenType: String) -> NSColor {
        switch tokenType {
        case "comment":
            return currentTheme.comment
        case "keyword":
            return currentTheme.keyword
        case "string":
            return currentTheme.string
        case "number":
            return currentTheme.number
        case "function":
            return currentTheme.function
        case "function.call":
            return currentTheme.functionCall
        case "method":
            return currentTheme.method
        case "type":
            return currentTheme.type
        case "property":
            return currentTheme.property
        case "variable":
            return currentTheme.variable
        case "constant", "constant.builtin":
            return currentTheme.constant
        case "operator":
            return currentTheme.operator_
        case "punctuation":
            return currentTheme.punctuation
        default:
            return currentTheme.foreground
        }
    }
}
