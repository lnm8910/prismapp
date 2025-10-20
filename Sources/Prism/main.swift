import Cocoa

// Create the application
let app = NSApplication.shared

// Create and set the app delegate
let appDelegate = AppDelegate()
app.delegate = appDelegate

// Run the application
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
