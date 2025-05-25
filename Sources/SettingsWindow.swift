import Cocoa
import ServiceManagement

class SettingsWindowController: NSWindowController {
    private var autoStartCheckbox: NSButton!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        setupWindow()
        setupUI()
    }
    
    private func setupWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "ClipboardManager Settings"
        window.center()
        window.isReleasedWhenClosed = false
        
        self.window = window
    }
    
    private func setupUI() {
        guard let window = window else { return }
        
        let contentView = NSView()
        window.contentView = contentView
        
        // Title
        let titleLabel = NSTextField(labelWithString: "ClipboardManager Settings")
        titleLabel.font = NSFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // Auto-start section
        let autoStartLabel = NSTextField(labelWithString: "Startup")
        autoStartLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        autoStartLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(autoStartLabel)
        
        autoStartCheckbox = NSButton(checkboxWithTitle: "Launch ClipboardManager at login", target: self, action: #selector(autoStartToggled))
        autoStartCheckbox.state = isAutoStartEnabled() ? .on : .off
        autoStartCheckbox.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(autoStartCheckbox)
        
        // Version info
        let versionLabel = NSTextField(labelWithString: "Version 1.0.0")
        versionLabel.font = NSFont.systemFont(ofSize: 11)
        versionLabel.textColor = .secondaryLabelColor
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(versionLabel)
        
        // About section
        let aboutLabel = NSTextField(labelWithString: "About")
        aboutLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        aboutLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(aboutLabel)
        
        let descriptionLabel = NSTextField(wrappingLabelWithString: "ClipboardManager is a lightweight clipboard history manager for macOS. Use ⌘+Shift+V to open the clipboard history window.")
        descriptionLabel.font = NSFont.systemFont(ofSize: 11)
        descriptionLabel.textColor = .secondaryLabelColor
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
        
        // Done button
        let doneButton = NSButton(title: "Done", target: self, action: #selector(doneButtonClicked))
        doneButton.bezelStyle = .rounded
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(doneButton)
        
        // Manual instructions for auto-start
        if !isModernAutoStartAvailable() {
            let instructionsLabel = NSTextField(wrappingLabelWithString: "To enable auto-start manually: Go to System Preferences > Users & Groups > Login Items and add ClipboardManager.app")
            instructionsLabel.font = NSFont.systemFont(ofSize: 10)
            instructionsLabel.textColor = .secondaryLabelColor
            instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(instructionsLabel)
            
            // Update constraints to include instructions
            NSLayoutConstraint.activate([
                instructionsLabel.topAnchor.constraint(equalTo: autoStartCheckbox.bottomAnchor, constant: 10),
                instructionsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                instructionsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                aboutLabel.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 20),
            ])
        }
        
        // Constraints
        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // Auto-start section
            autoStartLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            autoStartLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            autoStartCheckbox.topAnchor.constraint(equalTo: autoStartLabel.bottomAnchor, constant: 8),
            autoStartCheckbox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            autoStartCheckbox.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // About section
            aboutLabel.topAnchor.constraint(equalTo: autoStartCheckbox.bottomAnchor, constant: 30),
            aboutLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            descriptionLabel.topAnchor.constraint(equalTo: aboutLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Done button
            doneButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            doneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            doneButton.widthAnchor.constraint(equalToConstant: 80),
            
            // Version
            versionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            versionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
        ])
    }
    
    @objc private func autoStartToggled() {
        let isEnabled = autoStartCheckbox.state == .on
        setAutoStart(enabled: isEnabled)
    }
    
    @objc private func doneButtonClicked() {
        window?.close()
    }
    
    private func isModernAutoStartAvailable() -> Bool {
        if #available(macOS 13.0, *) {
            return true
        }
        return false
    }
    
    private func isAutoStartEnabled() -> Bool {
        if #available(macOS 13.0, *) {
            return SMAppService.mainApp.status == .enabled
        }
        return false // Can't detect on older systems
    }
    
    private func setAutoStart(enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                    print("Auto-start enabled successfully")
                } else {
                    try SMAppService.mainApp.unregister()
                    print("Auto-start disabled successfully")
                }
            } catch {
                print("Failed to \(enabled ? "enable" : "disable") auto-start: \(error)")
                
                // Show error dialog
                let alert = NSAlert()
                alert.messageText = "Auto-start Error"
                alert.informativeText = "Failed to \(enabled ? "enable" : "disable") auto-start. Please try again or check System Settings > General > Login Items."
                alert.alertStyle = .warning
                alert.addButton(withTitle: "OK")
                alert.runModal()
                
                // Revert checkbox state
                autoStartCheckbox.state = enabled ? .off : .on
            }
        } else {
            // Show manual instructions for older systems
            let alert = NSAlert()
            alert.messageText = "Manual Setup Required"
            alert.informativeText = "Auto-start setup requires macOS 13.0 or later. Please manually add ClipboardManager.app to System Preferences > Users & Groups > Login Items."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
            
            // Revert checkbox state
            autoStartCheckbox.state = .off
        }
    }
}