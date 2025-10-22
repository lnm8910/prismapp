# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Prism** is a planned lightning-fast, native macOS text editor designed to fill the Notepad++ gap on macOS. The project is currently in the **planning phase** with no code implementation yet.

**Core Philosophy**: Prioritize performance and native feel over feature bloat. Target <500ms cold start, <50MB memory usage for single files, and handle files from 1KB to 1GB+ smoothly.

## Current Repository State

This repository contains comprehensive planning documentation but **no actual Swift code** yet. The next step is to create the Xcode project and begin Phase 1 implementation.

### Existing Files
- `README.md` - Brief project description
- `LICENSE` - MIT license
- `instructions.md` - Complete 1,800+ line development guide with code examples, architecture, and roadmap

## Technology Stack (Planned)

- **Language**: Swift 6 with strict concurrency checking
- **UI Framework**: AppKit (not SwiftUI) - for maximum control and performance
- **Text Engine**: NSTextView with custom TextKit 2 layout manager
- **Syntax Highlighting**: Tree-sitter (via Swift bindings)
- **Build System**: Xcode with Swift Package Manager
- **Min macOS Version**: 13.0+
- **License**: MIT

### Why These Choices
- **AppKit over SwiftUI**: NSTextView is battle-tested for text editing with decades of optimization
- **Tree-sitter**: Industry standard for syntax highlighting (used by Neovim, Helix, VS Code), provides incremental parsing at 100 FPS

## Planned Architecture

The project will follow an **MVC (Model-View-Controller)** pattern with the following structure:

```
Prism/
├── App/                    # AppDelegate, app lifecycle
├── Core/
│   ├── Document/           # PrismDocument, DocumentController, FileWatcher
│   ├── TextEngine/         # PrismTextView, LayoutManager, TextStorage, LineNumberView
│   └── Editor/             # EditorState, UndoManager, AutoSave
├── Features/
│   ├── SyntaxHighlighting/ # Tree-sitter integration, LanguageRegistry, Themes
│   ├── FindReplace/        # FindPanel, SearchEngine, RegexEngine
│   ├── Tabs/               # TabBar, TabManager, TabItem
│   └── Preferences/        # PreferencesWindow, Settings
├── UI/
│   ├── Windows/            # MainWindow, WindowController
│   ├── Components/         # StatusBar, Toolbar, Sidebar
│   └── Styles/             # Colors, Fonts
└── Utilities/              # Extensions, FileSystem, Performance, Logger
```

### Key Design Patterns
1. **MVC**: Model (Document, TextStorage), View (PrismTextView, UI components), Controller (WindowController, DocumentController)
2. **Delegate Pattern**: NSTextViewDelegate, NSWindowDelegate, custom delegates for syntax highlighting
3. **Observer Pattern**: NotificationCenter for document changes, Combine for reactive state
4. **Command Pattern**: All user actions as commands for undo/redo

## Development Commands (When Implemented)

### Building
```bash
# Open in Xcode
open Prism.xcodeproj

# Build from command line
xcodebuild -project Prism.xcodeproj -scheme Prism -configuration Debug build

# Build for release
xcodebuild -project Prism.xcodeproj -scheme Prism -configuration Release build
```

### Testing
```bash
# Run all tests
xcodebuild test -project Prism.xcodeproj -scheme Prism

# Run specific test
xcodebuild test -project Prism.xcodeproj -scheme Prism -only-testing:PrismTests/DocumentTests

# Run with code coverage
xcodebuild test -project Prism.xcodeproj -scheme Prism -enableCodeCoverage YES
```

### Code Signing & Distribution
```bash
# Sign the app
codesign --deep --force --verify --verbose \
  --sign "Developer ID Application: Your Name (TEAM_ID)" \
  --options runtime Prism.app

# Verify signature
codesign --verify --verbose Prism.app
spctl --assess --verbose Prism.app

# Create DMG
hdiutil create -volname "Prism" -srcfolder "Prism.app" -ov -format UDZO "Prism.dmg"

# Notarize
xcrun notarytool submit Prism.dmg \
  --apple-id "your@email.com" \
  --team-id "TEAM_ID" \
  --password "app-specific-password" \
  --wait

# Staple notarization
xcrun stapler staple Prism.app
```

## Implementation Phases

### Phase 1: Foundation (Weeks 1-2)
Create functional text editor with basic file operations:
- Xcode project setup with AppKit
- AppDelegate with menu bar (File, Edit, View menus)
- PrismDocument model (file I/O, encoding detection, line ending detection)
- PrismTextView (custom NSTextView with performance optimizations)
- MainWindowController (window management, document operations)
- StatusBar component (line count, encoding, language display)

### Phase 2: Syntax Highlighting (Weeks 3-4)
Integrate Tree-sitter for fast syntax highlighting:
- Swift Package Manager dependencies (SwiftTreeSitter, language parsers)
- LanguageRegistry (register and manage Tree-sitter parsers)
- SyntaxHighlighter (Tree-sitter integration, incremental updates)
- Theme system (color schemes for syntax highlighting)

### Phase 3: Advanced Features (Weeks 5-8)
- LineNumberView (gutter with line numbers)
- FindPanel (find/replace UI with regex support)
- Tab support (multiple documents)
- Word wrap toggle
- Auto-save and crash recovery

## Performance Guidelines

### Critical Performance Targets
- **Cold startup**: <500ms
- **Memory (single file)**: <50MB
- **Memory (10 files)**: <150MB
- **Large file (100MB) scroll**: 60 FPS
- **Syntax highlight delay**: <16ms (60 FPS)

### Performance Optimizations
1. **Large File Handling**: For files >10MB, disable expensive features (spell check, grammar check)
2. **Virtual Rendering**: Only render visible lines + buffer for smooth scrolling
3. **Memory-Mapped Files**: Use memory mapping for files >100MB
4. **Incremental Parsing**: Use Tree-sitter's incremental parsing to update only changed regions
5. **Lazy Loading**: Load documents on-demand, unload when memory pressure increases

### Performance Monitoring
```swift
// Measure performance of operations
PerformanceMonitor.shared.measure("operation_name") {
    // code to measure
}

// Check memory usage
let memoryUsage = PerformanceMonitor.shared.memoryUsage()
```

## Important Code Patterns

### Document Loading with Encoding Detection
```swift
// PrismDocument handles:
// - UTF-8, UTF-16, ASCII encoding detection
// - Line ending detection (LF, CRLF, CR)
// - Language detection from file extension
// - File size tracking for performance optimizations
```

### Text View Configuration
```swift
// PrismTextView disables for performance:
// - Automatic quote/dash substitution
// - Automatic text replacement
// - Automatic spelling correction (for large files)
// - Word wrap (default off, containerSize = .greatestFiniteMagnitude)
```

### Syntax Highlighting Integration
```swift
// Use Tree-sitter for incremental, real-time highlighting
// - Parse text on document load
// - Apply incremental edits to syntax tree
// - Only re-highlight affected regions
// - Use query system for token classification
```

## Testing Strategy

### Unit Tests
- Document loading/saving with various encodings
- Line counting and line ending detection
- Language detection from file extensions
- Text storage operations

### Performance Tests
- Large file loading (100K+ lines)
- Syntax highlighting speed
- Memory usage under various file sizes
- Scroll performance with large files

### UI Tests (Future)
- Menu bar navigation
- Keyboard shortcuts
- Find/replace functionality
- Tab switching

## Code Style & Conventions

### Swift Conventions
- Use Swift 6 strict concurrency
- Prefer `let` over `var`
- Use descriptive variable names
- Add comments for complex logic
- Handle all errors gracefully with user-friendly messages

### Performance Conventions
- Measure operations >16ms (60 FPS threshold)
- Log performance warnings to console
- Profile with Instruments regularly
- Optimize only after measuring

### Git Conventions
- Commit frequently with descriptive messages
- Use conventional commits format: `feat:`, `fix:`, `perf:`, `docs:`
- Test before committing

## Dependencies (Planned)

### Swift Package Manager
```swift
dependencies: [
    .package(url: "https://github.com/ChimeHQ/SwiftTreeSitter", from: "0.7.1"),
    .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.5.0")
]
```

### Tree-sitter Language Parsers
- tree-sitter-swift
- tree-sitter-javascript
- tree-sitter-python
- tree-sitter-rust
- Add more as needed

## Next Steps to Start Development

1. **Create Xcode Project**:
   - File > New > Project > macOS > App
   - Name: Prism, Interface: AppKit, Language: Swift

2. **Setup Git Ignore**:
   - Add Xcode-specific ignores for .xcuserstate, DerivedData, etc.

3. **Implement Phase 1**:
   - Start with AppDelegate and menu bar
   - Create PrismDocument model
   - Build PrismTextView
   - Create MainWindowController
   - Add StatusBar component

4. **Test Early and Often**:
   - Test with files of varying sizes (1KB, 100KB, 1MB, 10MB)
   - Monitor memory usage with Instruments
   - Verify performance targets

## Reference Documentation

The `instructions.md` file contains:
- Complete code examples for all major components
- Detailed implementation steps for each phase
- Performance optimization techniques
- Testing examples
- Build and distribution instructions
- Comprehensive roadmap through v1.0.0

Refer to `instructions.md` for specific code examples and detailed implementation guidance for each component.
- always move generated MD files inside docs folder in project root.