import Cocoa
import Carbon

class GlobalHotkey {
    private var hotKeyRef: EventHotKeyRef?
    private let callback: () -> Void
    private let keyCode: UInt32
    private let modifiers: NSEvent.ModifierFlags
    private static var hotkeyInstances: [GlobalHotkey] = []
    
    init(keyCode: UInt32, modifiers: NSEvent.ModifierFlags, callback: @escaping () -> Void) {
        self.keyCode = keyCode
        self.modifiers = modifiers
        self.callback = callback
    }
    
    func register() {
        // Install event handler if this is the first hotkey
        if GlobalHotkey.hotkeyInstances.isEmpty {
            installGlobalEventHandler()
        }
        
        var gMyHotKeyID = EventHotKeyID()
        gMyHotKeyID.signature = OSType(0x666F6F21) // 'foo!'
        gMyHotKeyID.id = UInt32(GlobalHotkey.hotkeyInstances.count + 1)
        
        var carbonModifiers: UInt32 = 0
        
        if modifiers.contains(.command) {
            carbonModifiers |= UInt32(cmdKey)
        }
        if modifiers.contains(.shift) {
            carbonModifiers |= UInt32(shiftKey)
        }
        if modifiers.contains(.option) {
            carbonModifiers |= UInt32(optionKey)
        }
        if modifiers.contains(.control) {
            carbonModifiers |= UInt32(controlKey)
        }
        
        let status = RegisterEventHotKey(
            keyCode,
            carbonModifiers,
            gMyHotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        
        if status != noErr {
            print("Failed to register hotkey: \(status)")
        } else {
            GlobalHotkey.hotkeyInstances.append(self)
            print("Successfully registered hotkey Cmd+Shift+V")
        }
    }
    
    private func installGlobalEventHandler() {
        var eventSpec = EventTypeSpec()
        eventSpec.eventClass = OSType(kEventClassKeyboard)
        eventSpec.eventKind = OSType(kEventHotKeyPressed)
        
        let callback: EventHandlerUPP = { (nextHandler, theEvent, userData) -> OSStatus in
            var hotKeyID = EventHotKeyID()
            let status = GetEventParameter(
                theEvent,
                EventParamName(kEventParamDirectObject),
                EventParamType(typeEventHotKeyID),
                nil,
                MemoryLayout<EventHotKeyID>.size,
                nil,
                &hotKeyID
            )
            
            if status == noErr {
                let hotkeyIndex = Int(hotKeyID.id) - 1
                if hotkeyIndex >= 0 && hotkeyIndex < GlobalHotkey.hotkeyInstances.count {
                    GlobalHotkey.hotkeyInstances[hotkeyIndex].callback()
                }
            }
            
            return noErr
        }
        
        var eventHandlerRef: EventHandlerRef?
        InstallEventHandler(
            GetApplicationEventTarget(),
            callback,
            1,
            &eventSpec,
            nil,
            &eventHandlerRef
        )
    }
    
    deinit {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
        GlobalHotkey.hotkeyInstances.removeAll { $0 === self }
    }
}