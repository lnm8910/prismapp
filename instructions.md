# Prism - Lightweight Native Mac Text Editor
## Complete Development Guide for Claude Code

---

## Project Vision

Build **Prism**, a beautiful, lightning-fast, native Mac text editor that fills the Notepad++ gap on macOS. The editor should:

- Launch instantly (<500ms cold start)
- Use minimal memory (<50MB with single file)
- Handle files from 1KB to 1GB+ smoothly
- Look stunning with native macOS design language
- Provide professional features (syntax highlighting, regex find/replace, multiple tabs)
- Be 100% open source (MIT license)
- Support extensibility through plugins
- Feel like a true Mac app (not a web wrapper)

**Core Philosophy**: Prioritize performance and native feel over feature bloat. Every feature must justify its memory and complexity cost.

---

## Technology Stack

### Primary Technologies
- **Language**: Swift 6 with strict concurrency checking
- **UI Framework**: AppKit (not SwiftUI) for maximum control and performance
- **Text Engine**: NSTextView with custom TextKit 2 layout manager
- **Syntax Highlighting**: Tree-sitter (via Swift bindings)
- **Build System**: Xcode with Swift Package Manager
- **Version Control**: Git with GitHub repository
- **License**: MIT (permissive, maximum adoption)

### Key Dependencies
```swift
// Package.swift dependencies
.package(url: "https://github.com/tree-sitter/tree-sitter", from: "0.20.0")
.package(url: "https://github.com/sparkle-project/Sparkle", from: "2.5.0")
```

### Why These Choices?
- **AppKit over SwiftUI**: NSTextView is battle-tested for text editing with decades of optimization. SwiftUI's text editing is still immature.
- **Tree-sitter**: Industry standard for syntax highlighting, used by Neovim, Helix, and being adopted by VS Code. Provides incremental parsing at 100 FPS.
- **Sparkle**: Industry standard for Mac auto-updates, used by Sublime Text and hundreds of Mac apps.

---

## Project Architecture

### Directory Structure
```
Prism/
├── Prism.xcodeproj/
├── Prism/
│   ├── App/
│   │   ├── AppDelegate.swift           # App lifecycle
│   │   ├── Info.plist                  # App configuration
│   │   └── Assets.xcassets/            # Icons, colors
│   ├── Core/
│   │   ├── Document/
│   │   │   ├── PrismDocument.swift     # Document model
│   │   │   ├── DocumentController.swift # Document management
│   │   │   └── FileWatcher.swift       # External change detection
│   │   ├── TextEngine/
│   │   │   ├── PrismTextView.swift     # Custom NSTextView
│   │   │   ├── LayoutManager.swift     # Custom layout manager
│   │   │   ├── TextStorage.swift       # Custom text storage
│   │   │   └── LineNumberView.swift    # Gutter with line numbers
│   │   └── Editor/
│   │       ├── EditorState.swift       # Cursor, selection state
│   │       ├── UndoManager.swift       # Custom undo/redo
│   │       └── AutoSave.swift          # Auto-save logic
│   ├── Features/
│   │   ├── SyntaxHighlighting/
│   │   │   ├── SyntaxHighlighter.swift # Tree-sitter integration
│   │   │   ├── LanguageRegistry.swift  # Language detection
│   │   │   └── Themes/                 # Color schemes
│   │   ├── FindReplace/
│   │   │   ├── FindPanel.swift         # Find/replace UI
│   │   │   ├── SearchEngine.swift      # Search logic
│   │   │   └── RegexEngine.swift       # ICU regex wrapper
│   │   ├── Tabs/
│   │   │   ├── TabBar.swift            # Tab UI component
│   │   │   ├── TabManager.swift        # Tab state management
│   │   │   └── TabItem.swift           # Individual tab
│   │   └── Preferences/
│   │       ├── PreferencesWindow.swift # Settings UI
│   │       └── Settings.swift          # Settings model
│   ├── UI/
│   │   ├── Windows/
│   │   │   ├── MainWindow.swift        # Main editor window
│   │   │   └── WindowController.swift  # Window management
│   │   ├── Components/
│   │   │   ├── StatusBar.swift         # Bottom status bar
│   │   │   ├── Toolbar.swift           # Top toolbar
│   │   │   └── Sidebar.swift           # File browser (future)
│   │   └── Styles/
│   │       ├── Colors.swift            # Color palette
│   │       └── Fonts.swift             # Typography
│   ├── Utilities/
│   │   ├── Extensions/
│   │   │   ├── String+Extensions.swift
│   │   │   └── NSView+Extensions.swift
│   │   ├── FileSystem.swift            # File operations
│   │   ├── Performance.swift           # Memory monitoring
│   │   └── Logger.swift                # Logging utility
│   └── Resources/
│       ├── Grammars/                   # Tree-sitter grammars
│       ├── Themes/                     # JSON theme files
│       └── KeyBindings/                # Keybinding configs
├── PrismTests/
│   ├── DocumentTests.swift
│   ├── SyntaxHighlightingTests.swift
│   └── PerformanceTests.swift
└── README.md
```

### Core Design Patterns

1. **Model-View-Controller (MVC)**
   - Model: Document, TextStorage, EditorState
   - View: PrismTextView, LineNumberView, UI components
   - Controller: WindowController, DocumentController

2. **Delegate Pattern**
   - NSTextViewDelegate for text editing events
   - NSWindowDelegate for window lifecycle
   - Custom delegates for syntax highlighting callbacks

3. **Observer Pattern**
   - NotificationCenter for document changes
   - Combine for reactive state management
   - KVO for preference changes

4. **Command Pattern**
   - All user actions as commands for undo/redo
   - Menu actions through command pattern
   - Keyboard shortcuts map to commands

---

## Phase 1: Foundation (Weeks 1-2)

### Goal: Create a functional text editor with basic file operations

### Step 1.1: Project Setup

```bash
# Create new Xcode project
# File > New > Project > macOS > App
# Name: Prism
# Interface: AppKit
# Language: Swift

# Initialize Git
git init
git add .
git commit -m "Initial commit: Xcode project setup"

# Create .gitignore
cat << EOF > .gitignore
# Xcode
*.xcodeproj/*
!*.xcodeproj/project.pbxproj
*.xcworkspace/*
!*.xcworkspace/contents.xcworkspacedata
DerivedData/
*.xcuserstate
*.mode1v3
*.mode2v3
*.perspectivev3
*.pbxuser
!default.pbxuser
!default.mode1v3
!default.mode2v3
!default.perspectivev3

# Swift
*.swp
*~.nib
*.hmap
*.ipa

# CocoaPods
Pods/
EOF
```

### Step 1.2: AppDelegate and Window Setup

**AppDelegate.swift**
```swift
import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var windowController: MainWindowController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create main window
        windowController = MainWindowController()
        windowController?.showWindow(nil)
        
        // Setup menu bar
        setupMenuBar()
        
        // Check for updates (Sparkle integration later)
        // setupAutoUpdates()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false // Keep app running like native Mac apps
    }
    
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return true // Open blank file on launch
    }
    
    private func setupMenuBar() {
        let mainMenu = NSMenu()
        
        // App menu
        let appMenu = NSMenuItem()
        appMenu.submenu = createAppMenu()
        mainMenu.addItem(appMenu)
        
        // File menu
        let fileMenu = NSMenuItem()
        fileMenu.submenu = createFileMenu()
        mainMenu.addItem(fileMenu)
        
        // Edit menu
        let editMenu = NSMenuItem()
        editMenu.submenu = createEditMenu()
        mainMenu.addItem(editMenu)
        
        // View menu
        let viewMenu = NSMenuItem()
        viewMenu.submenu = createViewMenu()
        mainMenu.addItem(viewMenu)
        
        NSApplication.shared.mainMenu = mainMenu
    }
    
    private func createAppMenu() -> NSMenu {
        let menu = NSMenu(title: "Prism")
        
        menu.addItem(NSMenuItem(
            title: "About Prism",
            action: #selector(showAbout),
            keyEquivalent: ""
        ))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(
            title: "Preferences...",
            action: #selector(showPreferences),
            keyEquivalent: ","
        ))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(
            title: "Hide Prism",
            action: #selector(NSApplication.hide(_:)),
            keyEquivalent: "h"
        ))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(
            title: "Quit Prism",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        ))
        
        return menu
    }
    
    private func createFileMenu() -> NSMenu {
        let menu = NSMenu(title: "File")
        
        menu.addItem(NSMenuItem(
            title: "New",
            action: #selector(newDocument),
            keyEquivalent: "n"
        ))
        menu.addItem(NSMenuItem(
            title: "Open...",
            action: #selector(openDocument),
            keyEquivalent: "o"
        ))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(
            title: "Save",
            action: #selector(saveDocument),
            keyEquivalent: "s"
        ))
        menu.addItem(NSMenuItem(
            title: "Save As...",
            action: #selector(saveDocumentAs),
            keyEquivalent: "S"
        ))
        
        return menu
    }
    
    private func createEditMenu() -> NSMenu {
        let menu = NSMenu(title: "Edit")
        
        menu.addItem(NSMenuItem(
            title: "Undo",
            action: #selector(UndoManager.undo),
            keyEquivalent: "z"
        ))
        menu.addItem(NSMenuItem(
            title: "Redo",
            action: #selector(UndoManager.redo),
            keyEquivalent: "Z"
        ))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(
            title: "Cut",
            action: #selector(NSText.cut(_:)),
            keyEquivalent: "x"
        ))
        menu.addItem(NSMenuItem(
            title: "Copy",
            action: #selector(NSText.copy(_:)),
            keyEquivalent: "c"
        ))
        menu.addItem(NSMenuItem(
            title: "Paste",
            action: #selector(NSText.paste(_:)),
            keyEquivalent: "v"
        ))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(
            title: "Find...",
            action: #selector(showFind),
            keyEquivalent: "f"
        ))
        
        return menu
    }
    
    private func createViewMenu() -> NSMenu {
        let menu = NSMenu(title: "View")
        
        menu.addItem(NSMenuItem(
            title: "Toggle Line Numbers",
            action: #selector(toggleLineNumbers),
            keyEquivalent: "l"
        ))
        menu.addItem(NSMenuItem(
            title: "Toggle Word Wrap",
            action: #selector(toggleWordWrap),
            keyEquivalent: "w"
        ))
        
        return menu
    }
    
    // Action methods
    @objc func newDocument() {
        windowController?.newDocument()
    }
    
    @objc func openDocument() {
        windowController?.openDocument()
    }
    
    @objc func saveDocument() {
        windowController?.saveDocument()
    }
    
    @objc func saveDocumentAs() {
        windowController?.saveDocumentAs()
    }
    
    @objc func showAbout() {
        // Show about window
    }
    
    @objc func showPreferences() {
        // Show preferences window
    }
    
    @objc func showFind() {
        windowController?.showFind()
    }
    
    @objc func toggleLineNumbers() {
        windowController?.toggleLineNumbers()
    }
    
    @objc func toggleWordWrap() {
        windowController?.toggleWordWrap()
    }
}
```

### Step 1.3: Document Model

**PrismDocument.swift**
```swift
import Foundation

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
    }
    
    // Initialization
    init(fileURL: URL? = nil) {
        self.fileURL = fileURL
        super.init()
        
        if let url = fileURL {
            loadFromFile(url: url)
        }
    }
    
    // File operations
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
    
    func saveToFile(url: URL? = nil) {
        let targetURL = url ?? fileURL
        guard let targetURL = targetURL else { return }
        
        do {
            // Convert string to data
            guard let data = content.data(using: encoding) else {
                throw NSError(domain: "PrismDocument", code: 1, 
                             userInfo: [NSLocalizedDescriptionKey: "Failed to encode text"])
            }
            
            // Write to file
            try data.write(to: targetURL, options: .atomic)
            
            fileURL = targetURL
            isModified = false
            fileSize = Int64(data.count)
        } catch {
            print("Error saving file: \(error)")
        }
    }
    
    // Helper methods
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
            "py": "python",
            "rb": "ruby",
            "go": "go",
            "rs": "rust",
            "c": "c",
            "cpp": "cpp",
            "h": "c",
            "hpp": "cpp",
            "java": "java",
            "kt": "kotlin",
            "html": "html",
            "css": "css",
            "md": "markdown",
            "json": "json",
            "xml": "xml",
            "yaml": "yaml",
            "yml": "yaml",
            "sh": "bash",
            "zsh": "bash",
            "txt": "plaintext"
        ]
        
        return languageMap[ext] ?? "plaintext"
    }
}
```

### Step 1.4: Custom Text View

**PrismTextView.swift**
```swift
import Cocoa

class PrismTextView: NSTextView {
    // Custom properties
    var document: PrismDocument?
    private var lineNumberView: LineNumberView?
    
    // Performance properties
    private var isLargeFile: Bool = false
    private let largeFileThreshold: Int = 10_000_000 // 10MB
    
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
        backgroundColor = NSColor(named: "EditorBackground") ?? .textBackgroundColor
        insertionPointColor = NSColor(named: "Cursor") ?? .controlAccentColor
        
        // Behavior
        isAutomaticQuoteSubstitutionEnabled = false
        isAutomaticDashSubstitutionEnabled = false
        isAutomaticTextReplacementEnabled = false
        isAutomaticSpellingCorrectionEnabled = false
        
        // Font
        font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        
        // Wrapping (disabled by default for performance)
        textContainer?.containerSize = NSSize(width: CGFloat.greatestFiniteMagnitude, 
                                              height: CGFloat.greatestFiniteMagnitude)
        textContainer?.widthTracksTextView = false
        
        // Enable undo
        allowsUndo = true
        
        // Delegate
        delegate = self
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
    }
    
    override func drawRect(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Custom drawing here (e.g., for highlighting current line)
        drawCurrentLine()
    }
    
    private func drawCurrentLine() {
        guard let layoutManager = layoutManager,
              let textContainer = textContainer else { return }
        
        // Get current line rect
        let selectedRange = self.selectedRange()
        let glyphRange = layoutManager.glyphRange(forCharacterRange: selectedRange, 
                                                   actualCharacterRange: nil)
        let lineRect = layoutManager.lineFragmentRect(forGlyphAt: glyphRange.location, 
                                                       effectiveRange: nil)
        
        // Draw highlight
        let highlightColor = NSColor.selectedTextBackgroundColor.withAlphaComponent(0.1)
        highlightColor.setFill()
        
        var highlightRect = lineRect
        highlightRect.origin.x = 0
        highlightRect.size.width = bounds.width
        NSBezierPath(rect: highlightRect).fill()
    }
    
    // Performance monitoring
    override var string: String {
        get { super.string }
        set {
            let startTime = CFAbsoluteTimeGetCurrent()
            super.string = newValue
            let elapsed = CFAbsoluteTimeGetCurrent() - startTime
            
            if elapsed > 0.1 {
                print("Warning: Text setting took \(elapsed)s for \(newValue.count) chars")
            }
        }
    }
}

// MARK: - NSTextViewDelegate
extension PrismTextView: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        // Mark document as modified
        document?.isModified = true
        document?.content = string
        
        // Update line count
        document?.lineCount = string.components(separatedBy: .newlines).count
        
        // Trigger auto-save (implement later)
        // scheduleAutoSave()
    }
    
    func textView(_ textView: NSTextView, 
                  shouldChangeTextIn affectedCharRange: NSRange, 
                  replacementString: String?) -> Bool {
        // Custom text change logic here
        return true
    }
}
```

### Step 1.5: Main Window Controller

**MainWindowController.swift**
```swift
import Cocoa

class MainWindowController: NSWindowController {
    // UI Components
    private var scrollView: NSScrollView!
    private var textView: PrismTextView!
    private var statusBar: StatusBar!
    private var tabBar: TabBar!
    
    // State
    private var currentDocument: PrismDocument?
    private var documents: [PrismDocument] = []
    
    init() {
        // Create window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1000, height: 700),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        window.title = "Prism"
        window.center()
        window.setFrameAutosaveName("MainWindow")
        
        super.init(window: window)
        
        setupUI()
        
        // Create initial document
        newDocument()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        guard let window = window else { return }
        
        // Create container view
        let containerView = NSView(frame: window.contentView!.bounds)
        containerView.autoresizingMask = [.width, .height]
        window.contentView?.addSubview(containerView)
        
        // Setup scroll view and text view
        setupTextEditor(in: containerView)
        
        // Setup status bar
        setupStatusBar(in: containerView)
        
        // Setup tab bar (future)
        // setupTabBar(in: containerView)
    }
    
    private func setupTextEditor(in containerView: NSView) {
        // Create text container
        let textContainer = NSTextContainer()
        textContainer.containerSize = NSSize(width: CGFloat.greatestFiniteMagnitude, 
                                             height: CGFloat.greatestFiniteMagnitude)
        textContainer.widthTracksTextView = false
        
        // Create layout manager
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        
        // Create text storage
        let textStorage = NSTextStorage()
        textStorage.addLayoutManager(layoutManager)
        
        // Create text view
        textView = PrismTextView(frame: .zero, textContainer: textContainer)
        textView.autoresizingMask = [.width, .height]
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = true
        
        // Create scroll view
        scrollView = NSScrollView(frame: containerView.bounds)
        scrollView.autoresizingMask = [.width, .height]
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.autohidesScrollers = true
        
        // Add to container (leave space for status bar)
        var scrollFrame = containerView.bounds
        scrollFrame.size.height -= 24 // Status bar height
        scrollView.frame = scrollFrame
        
        containerView.addSubview(scrollView)
    }
    
    private func setupStatusBar(in containerView: NSView) {
        let statusBarFrame = NSRect(
            x: 0,
            y: 0,
            width: containerView.bounds.width,
            height: 24
        )
        
        statusBar = StatusBar(frame: statusBarFrame)
        statusBar.autoresizingMask = [.width, .maxYMargin]
        containerView.addSubview(statusBar)
    }
    
    // Document operations
    func newDocument() {
        let document = PrismDocument()
        currentDocument = document
        documents.append(document)
        
        textView.setDocument(document)
        updateWindowTitle()
    }
    
    func openDocument() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        
        panel.begin { [weak self] response in
            if response == .OK, let url = panel.url {
                self?.openFile(url: url)
            }
        }
    }
    
    private func openFile(url: URL) {
        let document = PrismDocument(fileURL: url)
        currentDocument = document
        documents.append(document)
        
        textView.setDocument(document)
        updateWindowTitle()
        updateStatusBar()
    }
    
    func saveDocument() {
        guard let document = currentDocument else { return }
        
        if let url = document.fileURL {
            document.saveToFile(url: url)
            updateWindowTitle()
        } else {
            saveDocumentAs()
        }
    }
    
    func saveDocumentAs() {
        let panel = NSSavePanel()
        panel.canCreateDirectories = true
        
        panel.begin { [weak self] response in
            if response == .OK, let url = panel.url {
                self?.currentDocument?.saveToFile(url: url)
                self?.updateWindowTitle()
            }
        }
    }
    
    // UI Updates
    private func updateWindowTitle() {
        guard let document = currentDocument else {
            window?.title = "Prism"
            return
        }
        
        let fileName = document.fileURL?.lastPathComponent ?? "Untitled"
        let modified = document.isModified ? "• " : ""
        window?.title = "\(modified)\(fileName)"
    }
    
    private func updateStatusBar() {
        guard let document = currentDocument else { return }
        
        statusBar.update(
            lineCount: document.lineCount,
            encoding: document.encoding.description,
            language: document.language
        )
    }
    
    // View actions
    func showFind() {
        // Implement find panel (later)
    }
    
    func toggleLineNumbers() {
        // Implement line number toggle (later)
    }
    
    func toggleWordWrap() {
        // Implement word wrap toggle
        if let textContainer = textView.textContainer {
            if textContainer.widthTracksTextView {
                // Disable wrap
                textContainer.containerSize = NSSize(
                    width: CGFloat.greatestFiniteMagnitude,
                    height: CGFloat.greatestFiniteMagnitude
                )
                textContainer.widthTracksTextView = false
            } else {
                // Enable wrap
                textContainer.widthTracksTextView = true
                textContainer.containerSize = NSSize(
                    width: scrollView.contentSize.width,
                    height: CGFloat.greatestFiniteMagnitude
                )
            }
        }
    }
}
```

### Step 1.6: Status Bar Component

**StatusBar.swift**
```swift
import Cocoa

class StatusBar: NSView {
    private var lineLabel: NSTextField!
    private var encodingLabel: NSTextField!
    private var languageLabel: NSTextField!
    
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
        label.backgroundColor = .clear
        label.font = NSFont.systemFont(ofSize: 11)
        label.textColor = .secondaryLabelColor
        return label
    }
    
    func update(lineCount: Int, encoding: String, language: String) {
        lineLabel.stringValue = "Lines: \(lineCount)"
        encodingLabel.stringValue = encoding
        languageLabel.stringValue = language.capitalized
    }
}
```

---

## Phase 2: Syntax Highlighting (Weeks 3-4)

### Goal: Integrate Tree-sitter for fast, accurate syntax highlighting

### Step 2.1: Install Tree-sitter

```swift
// Package.swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Prism",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/ChimeHQ/SwiftTreeSitter", from: "0.7.1"),
        .package(url: "https://github.com/tree-sitter/tree-sitter-swift", from: "0.1.0"),
        // Add more language parsers as needed
    ],
    targets: [
        .executableTarget(
            name: "Prism",
            dependencies: [
                "SwiftTreeSitter",
            ]
        )
    ]
)
```

### Step 2.2: Language Registry

**LanguageRegistry.swift**
```swift
import Foundation
import SwiftTreeSitter

class LanguageRegistry {
    static let shared = LanguageRegistry()
    
    private var languages: [String: Language] = [:]
    private var queries: [String: Query] = [:]
    
    private init() {
        registerLanguages()
    }
    
    private func registerLanguages() {
        // Register built-in languages
        registerLanguage(name: "swift", parser: tree_sitter_swift())
        registerLanguage(name: "javascript", parser: tree_sitter_javascript())
        registerLanguage(name: "python", parser: tree_sitter_python())
        registerLanguage(name: "rust", parser: tree_sitter_rust())
        // Add more as needed
    }
    
    private func registerLanguage(name: String, parser: UnsafePointer<TSLanguage>) {
        do {
            let language = try Language(language: parser)
            languages[name] = language
            
            // Load highlighting query
            if let queryPath = Bundle.main.path(forResource: name, 
                                                ofType: "scm", 
                                                inDirectory: "Queries"),
               let queryString = try? String(contentsOfFile: queryPath) {
                let query = try language.query(queryString)
                queries[name] = query
            }
        } catch {
            print("Failed to register language \(name): \(error)")
        }
    }
    
    func language(for name: String) -> Language? {
        return languages[name.lowercased()]
    }
    
    func query(for name: String) -> Query? {
        return queries[name.lowercased()]
    }
}
```

### Step 2.3: Syntax Highlighter

**SyntaxHighlighter.swift**
```swift
import Cocoa
import SwiftTreeSitter

class SyntaxHighlighter {
    private var parser: Parser
    private var tree: Tree?
    private var language: Language?
    private var query: Query?
    
    // Theme colors
    private var colorMap: [String: NSColor] = [
        "keyword": NSColor(red: 0.9, green: 0.3, blue: 0.5, alpha: 1.0),
        "function": NSColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0),
        "string": NSColor(red: 0.8, green: 0.5, blue: 0.2, alpha: 1.0),
        "comment": NSColor.secondaryLabelColor,
        "type": NSColor(red: 0.3, green: 0.8, blue: 0.7, alpha: 1.0),
        "variable": NSColor.labelColor,
        "number": NSColor(red: 0.7, green: 0.4, blue: 1.0, alpha: 1.0),
        "operator": NSColor.tertiaryLabelColor,
    ]
    
    init() {
        parser = Parser()
    }
    
    func setLanguage(_ languageName: String) {
        language = LanguageRegistry.shared.language(for: languageName)
        query = LanguageRegistry.shared.query(for: languageName)
        
        if let language = language {
            try? parser.setLanguage(language)
        }
    }
    
    func highlight(text: String, textStorage: NSTextStorage) {
        guard let language = language else { return }
        
        // Parse text
        tree = parser.parse(text)
        
        guard let tree = tree, let query = query else { return }
        
        // Reset formatting
        let fullRange = NSRange(location: 0, length: text.utf16.count)
        textStorage.setAttributes([:], range: fullRange)
        
        // Apply base color
        textStorage.addAttribute(.foregroundColor, 
                                value: NSColor.labelColor, 
                                range: fullRange)
        
        // Execute query
        let cursor = query.execute(in: tree)
        
        // Apply syntax colors
        while let match = cursor.next() {
            for capture in match.captures {
                let captureName = query.captureName(for: capture.index) ?? ""
                
                if let color = colorMap[captureName] {
                    let range = capture.node.range
                    let nsRange = NSRange(range, in: text)
                    
                    textStorage.addAttribute(.foregroundColor, 
                                           value: color, 
                                           range: nsRange)
                }
            }
        }
    }
    
    func incrementalEdit(range: NSRange, delta: Int, text: String, textStorage: NSTextStorage) {
        // For incremental updates (more efficient)
        // Implement Tree-sitter's edit functionality
        
        guard let tree = tree else {
            // Fall back to full re-parse
            highlight(text: text, textStorage: textStorage)
            return
        }
        
        // Apply edit to tree
        let startByte = range.location
        let oldEndByte = range.location + range.length
        let newEndByte = startByte + delta
        
        // Update tree with edit
        // Then re-highlight affected regions only
        
        // For now, fall back to full highlight
        highlight(text: text, textStorage: textStorage)
    }
}

// Helper extension
extension NSRange {
    init(_ range: Range<UInt32>, in string: String) {
        let start = Int(range.lowerBound)
        let end = Int(range.upperBound)
        self.init(location: start, length: end - start)
    }
}
```

### Step 2.4: Integrate with Text View

Update **PrismTextView.swift** to use syntax highlighting:

```swift
class PrismTextView: NSTextView {
    // ... existing code ...
    
    private var syntaxHighlighter: SyntaxHighlighter?
    
    override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
        super.init(frame: frameRect, textContainer: container)
        setupTextView()
        setupSyntaxHighlighting()
    }
    
    private func setupSyntaxHighlighting() {
        syntaxHighlighter = SyntaxHighlighter()
    }
    
    func setDocument(_ doc: PrismDocument) {
        document = doc
        
        // Set language for syntax highlighting
        syntaxHighlighter?.setLanguage(doc.language)
        
        // Set text
        string = doc.content
        
        // Apply syntax highlighting
        if let textStorage = textStorage {
            syntaxHighlighter?.highlight(text: string, textStorage: textStorage)
        }
    }
}

extension PrismTextView: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        document?.isModified = true
        document?.content = string
        
        // Re-highlight on change
        if let textStorage = textStorage, let highlighter = syntaxHighlighter {
            // Use incremental update for better performance
            highlighter.incrementalEdit(
                range: selectedRange(),
                delta: 0,
                text: string,
                textStorage: textStorage
            )
        }
    }
}
```

---

## Phase 3: Advanced Features (Weeks 5-8)

### Line Numbers

**LineNumberView.swift**
```swift
import Cocoa

class LineNumberView: NSView {
    weak var textView: NSTextView?
    private var lineIndices: [Int] = []
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let textView = textView,
              let layoutManager = textView.layoutManager,
              let textContainer = textView.textContainer else { return }
        
        let content = textView.string
        calculateLineIndices(for: content)
        
        // Draw line numbers
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .regular),
            .foregroundColor: NSColor.secondaryLabelColor
        ]
        
        let visibleRect = textView.visibleRect
        let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, 
                                                   in: textContainer)
        let charRange = layoutManager.characterRange(forGlyphRange: glyphRange, 
                                                      actualGlyphRange: nil)
        
        var lineNumber = lineForCharacterIndex(charRange.location)
        var index = charRange.location
        
        while index < NSMaxRange(charRange) {
            let lineRect = layoutManager.lineFragmentRect(
                forGlyphAt: layoutManager.glyphIndexForCharacter(at: index),
                effectiveRange: nil
            )
            
            let numberString = "\(lineNumber + 1)" as NSString
            let numberSize = numberString.size(withAttributes: attributes)
            let numberRect = NSRect(
                x: bounds.width - numberSize.width - 8,
                y: lineRect.origin.y + (lineRect.height - numberSize.height) / 2,
                width: numberSize.width,
                height: numberSize.height
            )
            
            numberString.draw(in: numberRect, withAttributes: attributes)
            
            // Move to next line
            index = NSMaxRange(layoutManager.characterRange(
                forGlyphRange: NSRange(location: layoutManager.glyphIndexForCharacter(at: index), 
                                      length: 1),
                actualGlyphRange: nil
            ))
            lineNumber += 1
        }
    }
    
    private func calculateLineIndices(for string: String) {
        lineIndices = [0]
        
        var index = 0
        for char in string {
            if char == "\n" {
                lineIndices.append(index + 1)
            }
            index += 1
        }
    }
    
    private func lineForCharacterIndex(_ index: Int) -> Int {
        var line = 0
        for lineIndex in lineIndices {
            if lineIndex > index {
                break
            }
            line += 1
        }
        return line - 1
    }
}
```

### Find & Replace

**FindPanel.swift**
```swift
import Cocoa

class FindPanel: NSPanel {
    private var findField: NSTextField!
    private var replaceField: NSTextField!
    private var regexCheckbox: NSButton!
    private var caseSensitiveCheckbox: NSButton!
    
    weak var textView: NSTextView?
    
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 120),
            styleMask: [.titled, .closable, .utilityWindow],
            backing: .buffered,
            defer: false
        )
        
        title = "Find"
        setupUI()
        center()
    }
    
    private func setupUI() {
        let contentView = NSView(frame: bounds)
        self.contentView = contentView
        
        // Find field
        let findLabel = NSTextField(labelWithString: "Find:")
        findLabel.frame = NSRect(x: 20, y: 80, width: 50, height: 20)
        contentView.addSubview(findLabel)
        
        findField = NSTextField(frame: NSRect(x: 80, y: 80, width: 300, height: 24))
        findField.placeholderString = "Search text..."
        contentView.addSubview(findField)
        
        // Replace field
        let replaceLabel = NSTextField(labelWithString: "Replace:")
        replaceLabel.frame = NSRect(x: 20, y: 50, width: 60, height: 20)
        contentView.addSubview(replaceLabel)
        
        replaceField = NSTextField(frame: NSRect(x: 80, y: 50, width: 300, height: 24))
        replaceField.placeholderString = "Replacement text..."
        contentView.addSubview(replaceField)
        
        // Options
        regexCheckbox = NSButton(checkboxWithTitle: "Regex", 
                                target: self, 
                                action: nil)
        regexCheckbox.frame = NSRect(x: 80, y: 20, width: 80, height: 20)
        contentView.addSubview(regexCheckbox)
        
        caseSensitiveCheckbox = NSButton(checkboxWithTitle: "Case Sensitive", 
                                        target: self, 
                                        action: nil)
        caseSensitiveCheckbox.frame = NSRect(x: 170, y: 20, width: 130, height: 20)
        contentView.addSubview(caseSensitiveCheckbox)
        
        // Buttons
        let findButton = NSButton(title: "Find Next", 
                                 target: self, 
                                 action: #selector(findNext))
        findButton.frame = NSRect(x: 220, y: 15, width: 80, height: 28)
        contentView.addSubview(findButton)
        
        let replaceButton = NSButton(title: "Replace", 
                                    target: self, 
                                    action: #selector(replace))
        replaceButton.frame = NSRect(x: 310, y: 15, width: 70, height: 28)
        contentView.addSubview(replaceButton)
    }
    
    @objc func findNext() {
        guard let textView = textView else { return }
        
        let searchText = findField.stringValue
        let options: String.CompareOptions = caseSensitiveCheckbox.state == .on ? [] : [.caseInsensitive]
        
        let startLocation = textView.selectedRange().location + 1
        let searchRange = NSRange(location: startLocation, 
                                 length: textView.string.count - startLocation)
        
        if let range = textView.string.range(
            of: searchText,
            options: options,
            range: Range(searchRange, in: textView.string)
        ) {
            let nsRange = NSRange(range, in: textView.string)
            textView.setSelectedRange(nsRange)
            textView.scrollRangeToVisible(nsRange)
        } else {
            NSSound.beep()
        }
    }
    
    @objc func replace() {
        guard let textView = textView else { return }
        
        let selectedRange = textView.selectedRange()
        if selectedRange.length > 0 {
            textView.insertText(replaceField.stringValue, 
                              replacementRange: selectedRange)
        }
    }
}
```

---

## Performance Optimization Guidelines

### Memory Management

1. **Virtual Rendering** (for large files):
```swift
// Only render visible lines + buffer
class VirtualTextView: NSTextView {
    private let bufferLines = 100
    
    override func draw(_ dirtyRect: NSRect) {
        guard let layoutManager = layoutManager else { return }
        
        let visibleRect = visibleRect
        let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, 
                                                   in: textContainer!)
        
        // Only process visible glyphs
        layoutManager.drawBackground(forGlyphRange: glyphRange, at: .zero)
        layoutManager.drawGlyphs(forGlyphRange: glyphRange, at: .zero)
    }
}
```

2. **Memory-Mapped Files** (for huge files):
```swift
func loadLargeFile(url: URL) throws {
    let fileHandle = try FileHandle(forReadingFrom: url)
    defer { fileHandle.closeFile() }
    
    // Memory map the file
    let data = fileHandle.availableData
    
    // Process in chunks
    let chunkSize = 1024 * 1024 // 1MB chunks
    var offset = 0
    
    while offset < data.count {
        let chunk = data.subdata(in: offset..<min(offset + chunkSize, data.count))
        // Process chunk
        offset += chunkSize
    }
}
```

3. **Lazy Loading**:
```swift
class DocumentManager {
    private var documentCache: [URL: PrismDocument] = [:]
    
    func document(for url: URL) -> PrismDocument {
        if let cached = documentCache[url] {
            return cached
        }
        
        let document = PrismDocument(fileURL: url)
        documentCache[url] = document
        return document
    }
    
    func unloadDocument(url: URL) {
        documentCache.removeValue(forKey: url)
    }
}
```

### Measurement & Profiling

```swift
class PerformanceMonitor {
    static let shared = PerformanceMonitor()
    
    func measure(_ name: String, block: () -> Void) {
        let start = CFAbsoluteTimeGetCurrent()
        block()
        let elapsed = CFAbsoluteTimeGetCurrent() - start
        
        if elapsed > 0.016 { // 16ms = 60 FPS
            print("⚠️ Performance warning: \(name) took \(elapsed * 1000)ms")
        }
    }
    
    func memoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        return kerr == KERN_SUCCESS ? info.resident_size : 0
    }
}
```

---

## Testing Strategy

### Unit Tests

**DocumentTests.swift**
```swift
import XCTest
@testable import Prism

class DocumentTests: XCTestCase {
    func testDocumentCreation() {
        let doc = PrismDocument()
        XCTAssertEqual(doc.content, "")
        XCTAssertEqual(doc.encoding, .utf8)
        XCTAssertFalse(doc.isModified)
    }
    
    func testFileLoading() throws {
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("test.txt")
        
        try "Hello, World!".write(to: tempURL, atomically: true, encoding: .utf8)
        
        let doc = PrismDocument(fileURL: tempURL)
        XCTAssertEqual(doc.content, "Hello, World!")
        XCTAssertEqual(doc.lineCount, 1)
        
        try? FileManager.default.removeItem(at: tempURL)
    }
    
    func testLineCounting() {
        let doc = PrismDocument()
        doc.content = "Line 1\nLine 2\nLine 3"
        doc.lineCount = doc.content.components(separatedBy: .newlines).count
        XCTAssertEqual(doc.lineCount, 3)
    }
}
```

### Performance Tests

**PerformanceTests.swift**
```swift
import XCTest
@testable import Prism

class PerformanceTests: XCTestCase {
    func testLargeFileLoading() {
        let largeText = String(repeating: "Hello, World!\n", count: 100_000)
        
        measure {
            let doc = PrismDocument()
            doc.content = largeText
        }
    }
    
    func testSyntaxHighlighting() {
        let code = """
        func hello() {
            print("Hello, World!")
        }
        """
        
        let highlighter = SyntaxHighlighter()
        highlighter.setLanguage("swift")
        
        measure {
            let textStorage = NSTextStorage(string: code)
            highlighter.highlight(text: code, textStorage: textStorage)
        }
    }
}
```

---

## Build & Distribution

### Xcode Build Settings

```
PRODUCT_NAME = Prism
PRODUCT_BUNDLE_IDENTIFIER = com.yourdomain.prism
MACOSX_DEPLOYMENT_TARGET = 13.0
SWIFT_VERSION = 5.9
ENABLE_HARDENED_RUNTIME = YES
CODE_SIGN_IDENTITY = "Developer ID Application"
CODE_SIGN_STYLE = Manual
DEVELOPMENT_TEAM = YOUR_TEAM_ID
```

### Code Signing

```bash
# Sign the app
codesign --deep --force --verify --verbose \
  --sign "Developer ID Application: Your Name (TEAM_ID)" \
  --options runtime \
  Prism.app

# Verify signature
codesign --verify --verbose Prism.app
spctl --assess --verbose Prism.app

# Notarize
xcrun notarytool submit Prism.dmg \
  --apple-id "your@email.com" \
  --team-id "TEAM_ID" \
  --password "app-specific-password" \
  --wait

# Staple
xcrun stapler staple Prism.app
```

### Create DMG

```bash
# Create DMG for distribution
hdiutil create -volname "Prism" \
  -srcfolder "Prism.app" \
  -ov -format UDZO \
  "Prism.dmg"
```

### Homebrew Cask

```ruby
# prism.rb
cask "prism" do
  version "0.1.0"
  sha256 "YOUR_SHA256"

  url "https://github.com/yourusername/prism/releases/download/v#{version}/Prism.dmg"
  name "Prism"
  desc "Lightweight text editor for macOS"
  homepage "https://prism.app"

  app "Prism.app"

  zap trash: [
    "~/Library/Application Support/Prism",
    "~/Library/Preferences/com.yourdomain.prism.plist",
    "~/Library/Caches/com.yourdomain.prism",
  ]
end
```

---

## Documentation

### README.md

```markdown
# Prism

A lightning-fast, beautiful text editor for macOS.

## Features

- ⚡️ Instant startup (<500ms)
- 🎨 Syntax highlighting for 50+ languages
- 🔍 Powerful find & replace with regex
- 📁 Multiple tabs
- 🎯 Native macOS experience
- 🔌 Extensible through plugins
- 💾 Auto-save & crash recovery

## Installation

### Homebrew

```bash
brew install --cask prism
```

### Manual

Download from [releases](https://github.com/yourusername/prism/releases)

## Development

Requirements:
- macOS 13.0+
- Xcode 15.0+
- Swift 5.9+

```bash
git clone https://github.com/yourusername/prism
cd prism
open Prism.xcodeproj
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

## License

MIT License - see [LICENSE](LICENSE)
```

---

## Roadmap

### Version 0.1.0 (MVP - Weeks 1-4)
- [x] Basic text editing
- [x] File open/save
- [x] Syntax highlighting (5-10 languages)
- [x] Find/replace
- [x] Line numbers
- [x] Status bar

### Version 0.2.0 (Weeks 5-8)
- [ ] Multiple tabs
- [ ] Word wrap toggle
- [ ] Auto-save
- [ ] Crash recovery
- [ ] 30+ language support
- [ ] Multiple themes

### Version 0.3.0 (Weeks 9-12)
- [ ] Split view
- [ ] Minimap
- [ ] Command palette
- [ ] Regex find/replace
- [ ] Project folders
- [ ] File browser sidebar

### Version 0.4.0 (Weeks 13-16)
- [ ] Multi-cursor editing
- [ ] Code folding
- [ ] Plugin system foundation
- [ ] LSP integration
- [ ] Code completion
- [ ] Git integration

### Version 1.0.0 (Weeks 17-24)
- [ ] Robust plugin API
- [ ] Package manager
- [ ] Performance optimization
- [ ] Comprehensive testing
- [ ] Documentation
- [ ] Website & marketing

---

## Key Success Metrics

Monitor these throughout development:

### Performance
- Cold startup time: < 500ms
- Memory usage (single file): < 50MB
- Memory usage (10 files): < 150MB
- Large file (100MB) scroll: 60 FPS
- Syntax highlight delay: < 16ms (60 FPS)

### Quality
- Crash rate: < 0.1%
- Test coverage: > 80%
- Bug reports: < 5 per 1000 users
- GitHub stars: Track weekly growth

### Adoption
- Downloads: Track weekly
- Active users: Track monthly
- Retention: 30-day retention rate
- Community: GitHub issues, discussions, PRs

---

## Implementation Priority

**Week 1-2: Foundation**
1. Project setup
2. Document model
3. Text view
4. Window controller
5. Menu bar
6. Status bar

**Week 3-4: Core Features**
1. Tree-sitter integration
2. Syntax highlighting
3. Language registry
4. Find/replace
5. Preferences

**Week 5-6: Polish**
1. Line numbers
2. Word wrap
3. Auto-save
4. Themes
5. Performance tuning

**Week 7-8: Distribution**
1. Code signing
2. Notarization
3. DMG creation
4. Homebrew cask
5. Documentation

---

## Final Notes for Claude Code

1. **Start Simple**: Build MVP first, then iterate. Don't try to build everything at once.

2. **Test Continuously**: Run the app after each major change. Test with various file sizes (1KB, 100KB, 1MB, 10MB).

3. **Profile Early**: Use Instruments to monitor memory and CPU from the beginning. Fix performance issues as they appear.

4. **Follow HIG**: Study Apple's Human Interface Guidelines. Make it look and feel like a native Mac app.

5. **Handle Errors Gracefully**: Every file operation can fail. Show user-friendly error messages.

6. **Save User's Work**: Auto-save is critical. Users should never lose work from a crash.

7. **Document as You Go**: Write comments for complex logic. Future you will thank present you.

8. **Git Commit Frequently**: Commit working code often with descriptive messages.

9. **Ask for Feedback Early**: Share MVP with friends/colleagues. Get real user feedback.

10. **Stay Focused**: It's tempting to add features. Resist until core is solid.

Remember: **Performance and reliability > feature count**. A fast, stable editor with fewer features beats a slow, buggy editor with more features.

Good luck building Prism! 🎉