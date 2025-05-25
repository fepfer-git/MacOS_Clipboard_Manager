import Cocoa
import Foundation

class ClipboardWindow: NSObject {
    private var window: NSWindow!
    private var scrollView: NSScrollView!
    private var collectionView: NSCollectionView!
    private var searchField: NSSearchField!
    private var clearButton: NSButton!
    
    var clipboardManager: ClipboardManager!
    private var filteredItems: [ClipboardItem] = []
    private var searchQuery: String = ""
    
    override init() {
        super.init()
        setupWindow()
        setupUI()
    }
    
    private func setupWindow() {
        // Create window
        let windowRect = NSRect(x: 0, y: 0, width: 800, height: 600)
        window = NSWindow(
            contentRect: windowRect,
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "ClipboardManager"
        window.center()
        window.isReleasedWhenClosed = false
        
        // Configure window to not appear in dock and behave like a utility window
        window.level = .normal  // Changed from .floating to .normal
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        // Make window hide when it loses focus
        window.hidesOnDeactivate = false
        
        // Set window delegate
        window.delegate = self
    }
    
    private func setupUI() {
        guard let contentView = window.contentView else { return }
        
        // Create main container
        let containerView = NSView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        // Setup search field
        searchField = NSSearchField()
        searchField.placeholderString = "Search clipboard history..."
        searchField.delegate = self
        searchField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(searchField)
        
        // Setup clear button
        clearButton = NSButton()
        clearButton.title = "Clear All"
        clearButton.bezelStyle = .rounded
        clearButton.target = self
        clearButton.action = #selector(clearAllClicked)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(clearButton)
        
        // Setup collection view
        setupCollectionView()
        containerView.addSubview(scrollView)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Container fills the content view
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // Search field at top
            searchField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            searchField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            searchField.trailingAnchor.constraint(equalTo: clearButton.leadingAnchor, constant: -10),
            searchField.heightAnchor.constraint(equalToConstant: 30),
            
            // Clear button at top right
            clearButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            clearButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            clearButton.widthAnchor.constraint(equalToConstant: 80),
            clearButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Collection view fills remaining space
            scrollView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 15),
            scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            scrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        ])
    }
    
    private func setupCollectionView() {
        // Create collection view
        collectionView = NSCollectionView()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Create flow layout with larger items and smaller gaps
        let layout = NSCollectionViewFlowLayout()
        layout.itemSize = NSSize(width: 240, height: 180)  // Increased from 200x150
        layout.minimumInteritemSpacing = 8  // Slightly increased from 5 for better visual separation
        layout.minimumLineSpacing = 8      // Slightly increased from 5 for better visual separation
        layout.sectionInset = NSEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)  // Reduced from 5 to 3
        
        collectionView.collectionViewLayout = layout
        
        // Register item class
        collectionView.register(ClipboardItemView.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier("ClipboardItem"))
        
        // Create scroll view
        scrollView = NSScrollView()
        scrollView.documentView = collectionView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set background color
        scrollView.backgroundColor = NSColor.controlBackgroundColor
        collectionView.backgroundColors = [NSColor.controlBackgroundColor]
    }
    
    func showWindow() {
        refreshData()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        // Focus on search field
        window.makeFirstResponder(searchField)
    }
    
    func hideWindow() {
        window.orderOut(nil)
    }
    
    var isVisible: Bool {
        return window.isVisible
    }
    
    func refreshData() {
        updateFilteredItems()
        collectionView.reloadData()
    }
    
    private func updateFilteredItems() {
        guard let clipboardManager = clipboardManager else {
            filteredItems = []
            return
        }
        
        filteredItems = clipboardManager.searchItems(query: searchQuery)
    }
    
    @objc private func clearAllClicked() {
        let alert = NSAlert()
        alert.messageText = "Clear Clipboard History"
        alert.informativeText = "Are you sure you want to clear all clipboard history? This action cannot be undone."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Clear")
        alert.addButton(withTitle: "Cancel")
        
        alert.beginSheetModal(for: window) { response in
            if response == .alertFirstButtonReturn {
                self.clipboardManager.clearHistory()
                self.refreshData()
            }
        }
    }
}

// MARK: - NSCollectionViewDataSource
extension ClipboardWindow: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredItems.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("ClipboardItem"), for: indexPath) as! ClipboardItemView
        
        if indexPath.item < filteredItems.count {
            let clipboardItem = filteredItems[indexPath.item]
            item.configure(with: clipboardItem)
            item.delegate = self
        }
        
        return item
    }
}

// MARK: - NSCollectionViewDelegate
extension ClipboardWindow: NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        // Handle selection if needed
    }
}

// MARK: - NSSearchFieldDelegate
extension ClipboardWindow: NSSearchFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        if let searchField = obj.object as? NSSearchField {
            searchQuery = searchField.stringValue
            updateFilteredItems()
            collectionView.reloadData()
        }
    }
}

// MARK: - NSWindowDelegate
extension ClipboardWindow: NSWindowDelegate {
    func windowDidResignKey(_ notification: Notification) {
        // Hide window when it loses focus (like a typical utility window)
        hideWindow()
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        hideWindow()
        return false // Don't actually close, just hide
    }
}

// MARK: - ClipboardItemViewDelegate
extension ClipboardWindow: ClipboardItemViewDelegate {
    func clipboardItemView(_ view: ClipboardItemView, didClickItem item: ClipboardItem) {
        // Single click copies the item using ClipboardManager to prevent duplicates
        clipboardManager.copyToPasteboard(item)
        // Optional: Could add sound or additional feedback here
        NSSound.beep()
    }
    
    func clipboardItemView(_ view: ClipboardItemView, didDoubleClickItem item: ClipboardItem) {
        clipboardManager.copyToPasteboard(item)
        hideWindow()
        
        // Optional: Paste to current application
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.pasteToCurrentApplication()
        }
    }
    
    private func pasteToCurrentApplication() {
        // Simulate Cmd+V to paste
        let source = CGEventSource(stateID: .hidSystemState)
        
        // Key down
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true) // V key
        keyDown?.flags = .maskCommand
        keyDown?.post(tap: .cghidEventTap)
        
        // Key up
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        keyUp?.flags = .maskCommand
        keyUp?.post(tap: .cghidEventTap)
    }
}