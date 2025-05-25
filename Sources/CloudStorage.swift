import Foundation
import CloudKit
import Cocoa

// MARK: - Cloud Storage Manager
class CloudStorageManager: ObservableObject {
    private let container: CKContainer
    private let publicDatabase: CKDatabase
    private let recordType = "ClipboardItem"
    
    @Published var isCloudAvailable = false
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    
    init() {
        container = CKContainer(identifier: "iCloud.com.clipboardmanager.app")
        publicDatabase = container.publicCloudDatabase
        
        checkCloudAvailability()
    }
    
    // MARK: - Cloud Availability
    func checkCloudAvailability() {
        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    self?.isCloudAvailable = true
                    print("✅ iCloud is available")
                case .noAccount:
                    print("⚠️  No iCloud account")
                    self?.isCloudAvailable = false
                case .restricted:
                    print("⚠️  iCloud is restricted")
                    self?.isCloudAvailable = false
                case .couldNotDetermine:
                    print("⚠️  Could not determine iCloud status")
                    self?.isCloudAvailable = false
                case .temporarilyUnavailable:
                    print("⚠️  iCloud is temporarily unavailable")
                    self?.isCloudAvailable = false
                @unknown default:
                    self?.isCloudAvailable = false
                }
            }
        }
    }
    
    // MARK: - Save to Cloud
    func saveClipboardItems(_ items: [ClipboardItem]) {
        guard isCloudAvailable else {
            print("⚠️  iCloud not available, skipping cloud save")
            return
        }
        
        isSyncing = true
        
        let records = items.map { item in
            createCloudKitRecord(from: item)
        }
        
        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        operation.qualityOfService = .background
        
        operation.modifyRecordsResultBlock = { [weak self] result in
            DispatchQueue.main.async {
                self?.isSyncing = false
                
                switch result {
                case .success:
                    self?.lastSyncDate = Date()
                    print("✅ Successfully synced \(records.count) items to iCloud")
                case .failure(let error):
                    print("❌ Failed to sync to iCloud: \(error.localizedDescription)")
                }
            }
        }
        
        publicDatabase.add(operation)
    }
    
    // MARK: - Load from Cloud
    func loadClipboardItems(completion: @escaping ([ClipboardItem]) -> Void) {
        guard isCloudAvailable else {
            completion([])
            return
        }
        
        isSyncing = true
        
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        // Use the updated CloudKit API
        publicDatabase.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: CKQueryOperation.maximumResults) { [weak self] result in
            DispatchQueue.main.async {
                self?.isSyncing = false
                
                switch result {
                case .success(let matchResults):
                    let items = matchResults.matchResults.compactMap { (recordID, recordResult) -> ClipboardItem? in
                        if case .success(let record) = recordResult {
                            return self?.createClipboardItem(from: record)
                        }
                        return nil
                    }
                    
                    print("✅ Loaded \(items.count) items from iCloud")
                    completion(items)
                    
                case .failure(let error):
                    print("❌ Failed to load from iCloud: \(error.localizedDescription)")
                    completion([])
                }
            }
        }
    }
    
    // MARK: - Delete from Cloud
    func deleteClipboardItem(withId id: UUID) {
        guard isCloudAvailable else { return }
        
        let recordID = CKRecord.ID(recordName: id.uuidString)
        
        publicDatabase.delete(withRecordID: recordID) { recordID, error in
            if let error = error {
                print("❌ Failed to delete from iCloud: \(error.localizedDescription)")
            } else {
                print("✅ Deleted item from iCloud")
            }
        }
    }
    
    // MARK: - Clear All Cloud Data
    func clearAllCloudData(completion: @escaping (Bool) -> Void) {
        guard isCloudAvailable else {
            completion(false)
            return
        }
        
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        
        publicDatabase.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: CKQueryOperation.maximumResults) { [weak self] result in
            switch result {
            case .success(let matchResults):
                let recordIDs = matchResults.matchResults.compactMap { (recordID, recordResult) -> CKRecord.ID? in
                    if case .success = recordResult {
                        return recordID
                    }
                    return nil
                }
                
                guard !recordIDs.isEmpty else {
                    completion(true)
                    return
                }
                
                let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIDs)
                operation.qualityOfService = .userInitiated
                
                operation.modifyRecordsResultBlock = { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            print("✅ Cleared all cloud data")
                            completion(true)
                        case .failure(let error):
                            print("❌ Failed to clear cloud data: \(error.localizedDescription)")
                            completion(false)
                        }
                    }
                }
                
                self?.publicDatabase.add(operation)
                
            case .failure(let error):
                print("❌ Failed to fetch records for deletion: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    // MARK: - Helper Methods
    private func createCloudKitRecord(from item: ClipboardItem) -> CKRecord {
        let record = CKRecord(recordType: recordType, recordID: CKRecord.ID(recordName: item.id.uuidString))
        
        record["content"] = item.content
        record["type"] = item.type.rawValue
        record["timestamp"] = item.timestamp
        record["itemType"] = item.itemType == .text ? "text" : "image"
        
        if let imageData = item.imageData {
            // For images, we need to save to a temporary file and create an asset
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("png")
            
            do {
                try imageData.write(to: tempURL)
                record["imageAsset"] = CKAsset(fileURL: tempURL)
            } catch {
                print("❌ Failed to create image asset: \(error)")
            }
        }
        
        return record
    }
    
    private func createClipboardItem(from record: CKRecord) -> ClipboardItem? {
        guard let content = record["content"] as? String,
              let typeString = record["type"] as? String,
              let _ = record["timestamp"] as? Date,
              let itemTypeString = record["itemType"] as? String else {
            return nil
        }
        
        // Convert string back to NSPasteboard.PasteboardType
        let pasteboardType = NSPasteboard.PasteboardType(typeString)
        
        // Determine if it's an image or text item
        if itemTypeString == "image", let imageAsset = record["imageAsset"] as? CKAsset,
           let fileURL = imageAsset.fileURL,
           let imageData = try? Data(contentsOf: fileURL) {
            return ClipboardItem(imageData: imageData, type: pasteboardType)
        } else {
            return ClipboardItem(content: content, type: pasteboardType)
        }
    }
}

// MARK: - Local Storage Manager
class LocalStorageManager {
    private let fileURL: URL
    
    init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = documentsPath.appendingPathComponent("ClipboardHistory.json")
    }
    
    func save(_ items: [ClipboardItem]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            
            let itemsData = items.map { item in
                ClipboardItemData(
                    id: item.id.uuidString,
                    content: item.content,
                    imageData: item.imageData,
                    timestamp: item.timestamp,
                    type: item.type.rawValue,
                    itemType: item.itemType == .text ? "text" : "image"
                )
            }
            
            let data = try encoder.encode(itemsData)
            try data.write(to: fileURL)
            print("✅ Saved \(items.count) items to local storage")
        } catch {
            print("❌ Failed to save to local storage: \(error)")
        }
    }
    
    func load() -> [ClipboardItem] {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let itemsData = try decoder.decode([ClipboardItemData].self, from: data)
            
            let items = itemsData.compactMap { itemData -> ClipboardItem? in
                let pasteboardType = NSPasteboard.PasteboardType(itemData.type)
                
                if itemData.itemType == "image", let imageData = itemData.imageData {
                    return ClipboardItem(imageData: imageData, type: pasteboardType)
                } else {
                    return ClipboardItem(content: itemData.content, type: pasteboardType)
                }
            }
            
            print("✅ Loaded \(items.count) items from local storage")
            return items
        } catch {
            print("⚠️  No local storage file found or failed to load: \(error)")
            return []
        }
    }
    
    func clear() {
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("✅ Cleared local storage")
        } catch {
            print("⚠️  Failed to clear local storage: \(error)")
        }
    }
}

// MARK: - Data Transfer Object
private struct ClipboardItemData: Codable {
    let id: String
    let content: String
    let imageData: Data?
    let timestamp: Date
    let type: String
    let itemType: String
}
