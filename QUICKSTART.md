# Prism Quick Start Guide

## ✅ The App is Working!

The issue has been fixed. The app now launches properly with a visible window.

## 🚀 How to Run Prism

### Method 1: Quick Launch (Recommended)
```bash
swift run
```

This will:
1. Build the app (if needed)
2. Launch Prism with a window titled "Prism"
3. You should see the Prism icon in your Dock
4. A text editor window will appear

### Method 2: Create App Bundle
```bash
./build-app.sh
open Prism.app
```

This creates a standalone macOS app that you can:
- Double-click to launch
- Copy to /Applications folder
- Add to your Dock permanently

## 🎯 What You Should See

When you launch Prism, you should see:

1. **Main Window**:
   - Title: "Prism" (or filename when you open a file)
   - Large text editing area with monospaced font
   - Blinking text cursor

2. **Menu Bar** (at top of screen):
   - Prism menu (About, Preferences, Quit)
   - File menu (New, Open, Save, Save As, Close)
   - Edit menu (Undo, Redo, Cut, Copy, Paste, Select All, Find)
   - View menu (Toggle Line Numbers, Toggle Word Wrap)

3. **Status Bar** (at bottom of window):
   - Left side: "Lines: 0" and "Ln 1, Col 1" (cursor position)
   - Right side: "LF", "UTF-8", "Plain Text"

4. **Dock**:
   - You should see the Prism app icon

## 🧪 Quick Tests

### Test 1: Basic Typing
1. Launch Prism: `swift run`
2. Type some text
3. Watch the status bar update with line count and cursor position
4. The current line should have a subtle highlight

### Test 2: File Operations
```bash
# Launch Prism
swift run

# In the app:
# - File > Open (⌘O)
# - Select "test-file.txt"
# - Edit the text
# - File > Save (⌘S)
```

### Test 3: Word Wrap
1. Type a very long line of text
2. View > Toggle Word Wrap
3. The text should wrap to fit the window
4. Toggle again to disable

### Test 4: Encoding Detection
```bash
# The test-file.txt includes:
# - UTF-8 characters: 🎨 🚀 ⚡️ 💻
# - Special chars: © ® ™ € £ ¥
#
# Status bar should show "UTF-8"
```

## ⌨️ Keyboard Shortcuts

All standard macOS shortcuts work:

### File Operations
- **⌘N** - New document
- **⌘O** - Open file
- **⌘S** - Save
- **⌘Shift+S** - Save As
- **⌘W** - Close window
- **⌘Q** - Quit app

### Editing
- **⌘Z** - Undo
- **⌘Shift+Z** - Redo
- **⌘X** - Cut
- **⌘C** - Copy
- **⌘V** - Paste
- **⌘A** - Select All

### View
- **⌘F** - Find (coming in Phase 3)
- **⌘L** - Toggle Line Numbers (coming in Phase 3)
- **⌘W** - Toggle Word Wrap

## 🐛 Troubleshooting

### App doesn't show a window
```bash
# Kill any running instances
killall Prism

# Clean rebuild
swift package clean
swift build
swift run
```

### Window appears but is blank
- Wait a few seconds for the app to fully initialize
- Try clicking in the window area
- Try quitting (⌘Q) and relaunching

### "Command not found" errors
```bash
# Make sure you have Xcode command line tools
xcode-select --install

# Verify Swift is installed
swift --version
```

### Build errors
```bash
# Clean build
rm -rf .build
swift build
```

## 📝 What Works (Phase 1)

✅ **Fully Functional**:
- Text editing with undo/redo
- File open/save/save as
- Encoding detection (UTF-8, UTF-16, ASCII)
- Line ending detection (LF, CRLF, CR)
- Language detection from file extension
- Status bar with live updates
- Word wrap toggle
- Current line highlighting
- Keyboard shortcuts
- Menu bar
- Unsaved changes warning

⏳ **Coming in Phase 2**:
- Syntax highlighting with colors
- Multiple themes
- Tree-sitter integration

⏳ **Coming in Phase 3**:
- Line numbers
- Find & Replace
- Multiple tabs

## 🎉 Success Checklist

When you run Prism, you should be able to:

- [ ] See a window with "Prism" in the title bar
- [ ] See the Prism app icon in the Dock
- [ ] See menu items (Prism, File, Edit, View) in the menu bar
- [ ] Type text and see it appear
- [ ] See status bar at bottom showing "Lines: X" and cursor position
- [ ] Press ⌘N to create a new document
- [ ] Press ⌘O to open the test-file.txt
- [ ] Press ⌘S to save changes
- [ ] See "UTF-8" and "Plain Text" in the status bar
- [ ] Use ⌘Z to undo and ⌘Shift+Z to redo
- [ ] Get a warning when trying to close with unsaved changes

If you can do all of the above, **Phase 1 is working perfectly!** 🎊

## 📚 Next Steps

Once you've verified Phase 1 works:
1. Read [PHASE1_COMPLETE.md](PHASE1_COMPLETE.md) for implementation details
2. Check [BUILD.md](BUILD.md) for advanced build options
3. Review [CLAUDE.md](CLAUDE.md) for architecture documentation
4. See [instructions.md](instructions.md) for Phase 2 planning

## 🆘 Still Having Issues?

If the app still doesn't work:

1. **Check the console output**:
   ```bash
   swift run 2>&1 | tee prism-log.txt
   ```
   This saves all output to `prism-log.txt`

2. **Check system requirements**:
   - macOS 13.0 or later
   - Xcode 15.0 or later
   - Swift 5.9 or later

3. **Try the app bundle method**:
   ```bash
   ./build-app.sh
   open Prism.app
   ```

4. **Check Activity Monitor**:
   - Open Activity Monitor (⌘+Space, type "Activity Monitor")
   - Search for "Prism"
   - If it's running but not visible, quit it and try again

---

**Prism Phase 1 is complete and ready to use!** 🚀
