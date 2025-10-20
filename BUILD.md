# Building Prism

This guide explains how to build and run Prism text editor.

## Prerequisites

- macOS 13.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later

## Quick Start

### Method 1: Build and Run with Swift Package Manager

```bash
# Build the project
swift build

# Run directly (will launch GUI)
swift run
```

### Method 2: Open in Xcode

```bash
# Generate Xcode project
swift package generate-xcodeproj

# Open in Xcode
open Prism.xcodeproj
```

Then in Xcode:
1. Select the "Prism" scheme
2. Click Run (⌘R)

### Method 3: Build Release Version

```bash
# Build optimized release version
swift build -c release

# The binary will be at:
# .build/release/Prism
```

## Creating a macOS App Bundle

To create a proper macOS app bundle:

```bash
# Build release version
swift build -c release

# Create app bundle structure
mkdir -p Prism.app/Contents/MacOS
mkdir -p Prism.app/Contents/Resources

# Copy executable
cp .build/release/Prism Prism.app/Contents/MacOS/

# Copy Info.plist
cp Sources/Prism/Resources/Info.plist Prism.app/Contents/

# Make executable
chmod +x Prism.app/Contents/MacOS/Prism

# Launch the app
open Prism.app
```

## Development Workflow

### Building
```bash
swift build
```

### Running
```bash
swift run
```

### Testing (when tests are added)
```bash
swift test
```

### Cleaning Build Artifacts
```bash
swift package clean
```

## Project Structure

```
Prism/
├── Package.swift              # Swift Package Manager manifest
├── Sources/
│   └── Prism/
│       ├── App/              # App lifecycle (AppDelegate)
│       ├── Core/             # Core functionality
│       │   ├── Document/     # Document model and management
│       │   └── TextEngine/   # Text view and text handling
│       ├── UI/               # User interface
│       │   ├── Windows/      # Window controllers
│       │   └── Components/   # UI components
│       └── Resources/        # Resources (Info.plist, etc.)
└── BUILD.md                  # This file
```

## Troubleshooting

### "Command line tool support not found"
Install Xcode Command Line Tools:
```bash
xcode-select --install
```

### GUI not appearing
Make sure you're running on macOS with a display. The app requires AppKit and cannot run in headless mode.

### Build errors about missing symbols
Clean and rebuild:
```bash
swift package clean
swift build
```

## Next Steps

After building:
1. Test basic file operations (New, Open, Save)
2. Test text editing functionality
3. Verify menu bar and keyboard shortcuts work
4. Test with files of various sizes

## Phase 1 Features

Currently implemented:
- ✅ Basic text editing
- ✅ File open/save operations
- ✅ Menu bar with File, Edit, View menus
- ✅ Status bar showing line count, cursor position, encoding, language
- ✅ Word wrap toggle
- ✅ Current line highlighting
- ✅ Performance optimizations for large files
- ✅ Encoding detection (UTF-8, UTF-16, ASCII)
- ✅ Line ending detection (LF, CRLF, CR)
- ✅ Language detection from file extension

Coming in Phase 2:
- Syntax highlighting with Tree-sitter
- Multiple language support
- Theme system

Coming in Phase 3:
- Line numbers
- Find & Replace
- Multiple tabs
- Advanced features
