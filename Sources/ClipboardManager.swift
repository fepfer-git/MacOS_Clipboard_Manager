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
    
    weak var delegate: ClipboardManagerDelegate?
    
    private(set) var history: [ClipboardItem] = []
    
    init() {
        lastChangeCount = pasteboard.changeCount
    }
    
    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
        print("📋 Started monitoring clipboard...")
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        print("📋 Stopped monitoring clipboard.")
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
        
        print("📋 Added clipboard item: \(String(content.prefix(50)))\(content.count > 50 ? "..." : "")")
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
        
        print("📋 Added clipboard image: \(imageData.count) bytes")
        delegate?.clipboardDidUpdate()
    }
    
    func copyToPasteboard(_ item: ClipboardItem) {
        // Set flag to ignore the next clipboard change
        isIgnoringNextChange = true
        
        pasteboard.clearContents()
        
        switch item.itemType {
        case .text:
            pasteboard.setString(item.content, forType: item.type)
            print("📋 Copied text to pasteboard: \(String(item.content.prefix(50)))\(item.content.count > 50 ? "..." : "")")
        case .image:
            if let imageData = item.imageData {
                pasteboard.setData(imageData, forType: item.type)
                print("📋 Copied image to pasteboard: \(imageData.count) bytes")
            }
        }
        
        lastChangeCount = pasteboard.changeCount
    }
    
    func clearHistory() {
        history.removeAll()
        print("📋 Cleared clipboard history")
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
    
    func getItems() -> [ClipboardItem] {
        return history
    }
}