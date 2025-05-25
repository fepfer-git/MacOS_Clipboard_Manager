import Cocoa
import Foundation

enum ClipboardItemType {
    case text
    case image
}

struct ClipboardItem {
    let id = UUID()
    let content: String
    let imageData: Data?
    let timestamp: Date
    let type: NSPasteboard.PasteboardType
    let itemType: ClipboardItemType
    
    init(content: String, type: NSPasteboard.PasteboardType) {
        self.content = content
        self.imageData = nil
        self.timestamp = Date()
        self.type = type
        self.itemType = .text
    }
    
    init(imageData: Data, type: NSPasteboard.PasteboardType) {
        let formatName = ClipboardItem.formatName(for: type)
        let sizeString = ByteCountFormatter.string(fromByteCount: Int64(imageData.count), countStyle: .binary)
        self.content = "[\(formatName) Image - \(sizeString)]"
        self.imageData = imageData
        self.timestamp = Date()
        self.type = type
        self.itemType = .image
    }
    
    private static func formatName(for type: NSPasteboard.PasteboardType) -> String {
        switch type {
        case .tiff:
            return "TIFF"
        case .png:
            return "PNG"
        case .pdf:
            return "PDF"
        case NSPasteboard.PasteboardType("public.jpeg"):
            return "JPEG"
        default:
            return "Image"
        }
    }
}

protocol ClipboardManagerDelegate: AnyObject {
    func clipboardDidUpdate()
}

class ClipboardManager {
    private var pasteboard = NSPasteboard.general
    private var timer: Timer?
    private var lastChangeCount: Int = 0
    private let maxHistoryItems = 50
    private var isIgnoringNextChange = false
    
    // Add persistence and cloud sync support
    private var localStorage: LocalStorageManager?
    private var cloudStorage: CloudStorageManager?
    
    weak var delegate: ClipboardManagerDelegate?
    
    private(set) var history: [ClipboardItem] = []
    
    init() {
        lastChangeCount = pasteboard.changeCount
        localStorage = LocalStorageManager()
        cloudStorage = CloudStorageManager()
    }
    
    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
        print("Started monitoring clipboard...")
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        print("Stopped monitoring clipboard.")
    }
    
    private func checkClipboard() {
        guard pasteboard.changeCount != lastChangeCount else { return }
        
        // Skip monitoring if we're programmatically copying an item
        if isIgnoringNextChange {
            isIgnoringNextChange = false
            lastChangeCount = pasteboard.changeCount
            return
        }
        
        lastChangeCount = pasteboard.changeCount
        
        // Check for images first (prioritize images over text)
        // Support multiple image formats
        if let imageData = pasteboard.data(forType: .tiff) {
            addClipboardItem(imageData: imageData, type: .tiff)
        } else if let imageData = pasteboard.data(forType: .png) {
            addClipboardItem(imageData: imageData, type: .png)
        } else if let imageData = pasteboard.data(forType: .pdf) {
            addClipboardItem(imageData: imageData, type: .pdf)
        } else if let imageData = pasteboard.data(forType: NSPasteboard.PasteboardType("public.jpeg")) {
            addClipboardItem(imageData: imageData, type: NSPasteboard.PasteboardType("public.jpeg"))
        }
        // Check for string content
        else if let string = pasteboard.string(forType: .string), !string.isEmpty {
            addClipboardItem(content: string, type: .string)
        }
    }
    
    private func addClipboardItem(content: String, type: NSPasteboard.PasteboardType) {
        // Don't add duplicate consecutive items
        if let lastItem = history.first, lastItem.content == content && lastItem.itemType == .text {
            return
        }
        
        let newItem = ClipboardItem(content: content, type: type)
        history.insert(newItem, at: 0)
        
        // Keep only the most recent items
        if history.count > maxHistoryItems {
            history.removeLast(history.count - maxHistoryItems)
        }
        
        print("Added new clipboard item: \(String(content.prefix(50)))\(content.count > 50 ? "..." : "")")
        delegate?.clipboardDidUpdate()
    }
    
    private func addClipboardItem(imageData: Data, type: NSPasteboard.PasteboardType) {
        // Don't add duplicate consecutive images (simple size comparison)
        if let lastItem = history.first, 
           lastItem.itemType == .image,
           let lastImageData = lastItem.imageData,
           lastImageData.count == imageData.count {
            return
        }
        
        let newItem = ClipboardItem(imageData: imageData, type: type)
        history.insert(newItem, at: 0)
        
        // Keep only the most recent items
        if history.count > maxHistoryItems {
            history.removeLast(history.count - maxHistoryItems)
        }
        
        print("Added new clipboard image item: \(imageData.count) bytes")
        delegate?.clipboardDidUpdate()
    }
    
    func copyToPasteboard(_ item: ClipboardItem) {
        // Set flag to ignore the next clipboard change
        isIgnoringNextChange = true
        
        pasteboard.clearContents()
        
        switch item.itemType {
        case .text:
            pasteboard.setString(item.content, forType: item.type)
            print("Copied text item to pasteboard: \(String(item.content.prefix(50)))\(item.content.count > 50 ? "..." : "")")
        case .image:
            if let imageData = item.imageData {
                pasteboard.setData(imageData, forType: item.type)
                print("Copied image item to pasteboard: \(imageData.count) bytes")
            }
        }
        
        lastChangeCount = pasteboard.changeCount
    }
    
    func clearHistory() {
        history.removeAll()
        print("Cleared clipboard history")
        delegate?.clipboardDidUpdate()
    }
    
    func deleteItem(_ item: ClipboardItem) {
        history.removeAll { $0.id == item.id }
        delegate?.clipboardDidUpdate()
    }
    
    func searchItems(query: String) -> [ClipboardItem] {
        if query.isEmpty {
            return history
        }
        return history.filter { item in
            // Search in content (works for both text and image descriptions)
            item.content.localizedCaseInsensitiveContains(query) ||
            // Also search by item type
            (query.localizedCaseInsensitiveContains("image") && item.itemType == .image) ||
            (query.localizedCaseInsensitiveContains("text") && item.itemType == .text)
        }
    }
    
    func enablePersistence() {
        // Load persisted items on startup
        if let savedItems = localStorage?.load() {
            history = savedItems
            print("✅ Loaded \(savedItems.count) items from persistence")
            delegate?.clipboardDidUpdate()
        }
        
        // Auto-save every 30 seconds
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.saveToFile()
        }
    }
    
    func enableCloudSync() {
        // Load items from cloud on startup
        cloudStorage?.loadClipboardItems { [weak self] cloudItems in
            self?.mergeCloudItems(cloudItems)
        }
        
        // Auto-sync every 5 minutes
        Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            if let items = self?.history {
                self?.cloudStorage?.saveClipboardItems(Array(items.prefix(50))) // Sync last 50 items
            }
        }
    }
    
    func saveToFile() {
        localStorage?.save(history)
    }
    
    func clearAllData() {
        // Clear local data
        history.removeAll()
        localStorage?.clear()
        
        // Clear cloud data
        cloudStorage?.clearAllCloudData { success in
            if success {
                print("✅ All data cleared successfully")
            } else {
                print("⚠️  Failed to clear cloud data")
            }
        }
        
        delegate?.clipboardDidUpdate()
    }
    
    private func mergeCloudItems(_ cloudItems: [ClipboardItem]) {
        let localItemIds = Set(history.map { $0.id })
        let newCloudItems = cloudItems.filter { !localItemIds.contains($0.id) }
        
        // Add new cloud items to local storage
        for item in newCloudItems {
            history.insert(item, at: 0)
        }
        
        // Limit total items to prevent memory issues
        if history.count > 1000 {
            history = Array(history.prefix(1000))
        }
        
        // Save to local storage
        saveToFile()
        
        print("✅ Merged \(newCloudItems.count) new items from cloud")
        delegate?.clipboardDidUpdate()
    }
}