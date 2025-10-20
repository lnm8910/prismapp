import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var windowController: MainWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set activation policy to regular app (shows in Dock, can have windows)
        NSApp.setActivationPolicy(.regular)

        // Setup menu bar first
        setupMenuBar()

        // Create main window
        windowController = MainWindowController()
        windowController?.showWindow(nil)

        // Activate the app (bring to foreground)
        NSApp.activate(ignoringOtherApps: true)
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
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(
            title: "Close Window",
            action: #selector(NSWindow.performClose(_:)),
            keyEquivalent: "w"
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
        menu.addItem(NSMenuItem(
            title: "Select All",
            action: #selector(NSText.selectAll(_:)),
            keyEquivalent: "a"
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

    // MARK: - Action methods

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
        let alert = NSAlert()
        alert.messageText = "About Prism"
        alert.informativeText = "Prism - A lightning-fast native text editor for macOS\n\nVersion 0.1.0\nMIT License"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    @objc func showPreferences() {
        // TODO: Implement preferences window in Phase 3
        let alert = NSAlert()
        alert.messageText = "Preferences"
        alert.informativeText = "Preferences will be available in a future version."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
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
