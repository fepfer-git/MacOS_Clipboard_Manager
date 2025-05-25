import Cocoa
import Foundation

// MARK: - Helper Functions
func createClipboardIcon() -> NSImage {
    // Try to load the colorful SVG icon first
    if let svgPath = Bundle.main.path(forResource: "MenuBarIcon", ofType: "svg"),
       let svgData = NSData(contentsOfFile: svgPath),
       let svgImage = NSImage(data: svgData as Data) {
        svgImage.size = NSSize(width: 18, height: 18)
        return svgImage
    }
    
    // Fallback to creating a colorful programmatic icon
    let size = NSSize(width: 18, height: 18)
    let image = NSImage(size: size)
    
    image.lockFocus()
    
    // Create clipboard body with gradient colors
    let clipboardRect = NSRect(x: 2, y: 2, width: 12, height: 14)
    let clipRect = NSRect(x: 5, y: 0, width: 6, height: 3)
    
    // Draw clipboard body with blue/purple gradient effect
    NSColor(red: 0.31, green: 0.27, blue: 0.90, alpha: 0.9).setFill() // Blue-purple
    let clipboardPath = NSBezierPath(roundedRect: clipboardRect, xRadius: 2, yRadius: 2)
    clipboardPath.fill()
    
    // Add border
    NSColor(red: 0.25, green: 0.21, blue: 0.75, alpha: 1.0).setStroke()
    clipboardPath.lineWidth = 0.5
    clipboardPath.stroke()
    
    // Draw clipboard clip with orange gradient
    NSColor(red: 0.96, green: 0.62, blue: 0.07, alpha: 1.0).setFill() // Orange
    let clipPath = NSBezierPath(roundedRect: clipRect, xRadius: 1, yRadius: 1)
    clipPath.fill()
    
    // Draw content lines in white
    NSColor.white.withAlphaComponent(0.8).setStroke()
    
    // Line 1
    let line1 = NSBezierPath()
    line1.move(to: NSPoint(x: 4, y: 5))
    line1.line(to: NSPoint(x: 10, y: 5))
    line1.lineWidth = 1.0
    line1.stroke()
    
    // Line 2
    let line2 = NSBezierPath()
    line2.move(to: NSPoint(x: 4, y: 7))
    line2.line(to: NSPoint(x: 12, y: 7))
    line2.lineWidth = 1.0
    line2.stroke()
    
    // Line 3 (shorter)
    let line3 = NSBezierPath()
    line3.move(to: NSPoint(x: 4, y: 9))
    line3.line(to: NSPoint(x: 11, y: 9))
    line3.lineWidth = 1.0
    line3.stroke()
    
    // Add small stack indicators with subtle blue color
    NSColor(red: 0.25, green: 0.21, blue: 0.75, alpha: 0.3).setFill()
    NSRect(x: 0, y: 3, width: 1, height: 11).fill()
    NSRect(x: 15, y: 3, width: 1, height: 11).fill()
    
    image.unlockFocus()
    
    return image
}

// MARK: - Main App Class
class ClipboardManagerApp: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var clipboardManager: ClipboardManager!
    var clipboardWindow: ClipboardWindow!
    // var settingsWindowController: SettingsWindowController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            // Create a custom clipboard icon programmatically
            let iconImage = createClipboardIcon()
            button.image = iconImage
            button.action = #selector(statusItemClicked)
            button.target = self
        }
        
        // Create menu for status item
        let menu = NSMenu()
        
        // Show Clipboard item
        let showClipboardItem = NSMenuItem(title: "Show Clipboard", action: #selector(showClipboard), keyEquivalent: "")
        showClipboardItem.target = self
        menu.addItem(showClipboardItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Settings item
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(showSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit item
        let quitItem = NSMenuItem(title: "Quit ClipboardManager", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem.menu = menu
        
        // Initialize ClipboardManager
        clipboardManager = ClipboardManager()
        clipboardManager.delegate = self
        
        // Create clipboard window
        clipboardWindow = ClipboardWindow()
        clipboardWindow.clipboardManager = clipboardManager
        
        // Start monitoring
        clipboardManager.startMonitoring()
        
        // Setup global hotkey
        setupGlobalHotkey()
        
        print("ClipboardManager started! Press Cmd+Shift+V to show clipboard window or click the menu bar icon.")
    }
    
    @objc func statusItemClicked() {
        toggleClipboardWindow()
    }
    
    @objc func showClipboard() {
        clipboardWindow.showWindow()
    }
    
    @objc func showSettings() {
        // Temporarily disabled - will add settings functionality
        let alert = NSAlert()
        alert.messageText = "Settings"
        alert.informativeText = "Settings functionality will be available in a future update. For now, you can configure auto-start in System Settings > General > Login Items."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @objc func quitApp() {
        NSApp.terminate(nil)
    }
    
    func toggleClipboardWindow() {
        if clipboardWindow.isVisible {
            clipboardWindow.hideWindow()
        } else {
            clipboardWindow.showWindow()
        }
    }
    
    func setupGlobalHotkey() {
        // Register Cmd+Shift+V for showing clipboard
        let showClipboardHotkey = GlobalHotkey(keyCode: 9, modifiers: [.command, .shift]) { [weak self] in
            DispatchQueue.main.async {
                if self?.clipboardWindow.isVisible == true {
                    self?.clipboardWindow.hideWindow()
                } else {
                    self?.clipboardWindow.showWindow()
                }
            }
        }
        showClipboardHotkey.register()
        
        // Register ESC key for closing clipboard window (only when window is visible)
        let escHotkey = GlobalHotkey(keyCode: 53, modifiers: []) { [weak self] in
            DispatchQueue.main.async {
                if self?.clipboardWindow.isVisible == true {
                    self?.clipboardWindow.hideWindow()
                }
            }
        }
        escHotkey.register()
    }
}

extension ClipboardManagerApp: ClipboardManagerDelegate {
    func clipboardDidUpdate() {
        DispatchQueue.main.async {
            self.clipboardWindow.refreshData()
        }
    }
}

// Create and run the app
let app = NSApplication.shared
let delegate = ClipboardManagerApp()
app.delegate = delegate

// Hide dock icon
app.setActivationPolicy(.accessory)

// Run the app
app.run()