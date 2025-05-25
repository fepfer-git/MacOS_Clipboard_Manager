# ClipboardManager Installation Instructions

## 🎉 Congratulations!

Your ClipboardManager app has been successfully built and is ready for installation!

## 📦 What's Included

- **ClipboardManager.app** - The complete macOS application bundle
- **Menu bar integration** - Access via black clipboard icon in menu bar
- **Global hotkey support** - Press `Cmd+Shift+V` to show clipboard history
- **Settings menu** - Configure auto-start and preferences
- **Modern black icon design** - Clean, professional appearance

## 🚀 Installation Steps

### 1. Install the Application

1. **Copy to Applications folder:**

   ```bash
   cp -R ClipboardManager.app /Applications/
   ```

   Or manually drag `ClipboardManager.app` to your `Applications` folder in Finder.

2. **Launch the application:**
   - Open `Applications` folder
   - Double-click `ClipboardManager`
   - The app will appear as a black clipboard icon in your menu bar

### 2. Grant Permissions

When you first run ClipboardManager, macOS may ask for permissions:

1. **Accessibility Permission** (Required for global hotkeys):

   - Go to `System Settings > Privacy & Security > Accessibility`
   - Add ClipboardManager to the list if not already present
   - Enable the toggle for ClipboardManager

2. **Security Warning** (First launch only):
   - If you see "ClipboardManager cannot be opened because it is from an unidentified developer"
   - Right-click on the app and select "Open"
   - Click "Open" in the security dialog

## 🎯 Usage Instructions

### Menu Bar Icon

- **Click** the black clipboard icon in your menu bar to access:
  - Show Clipboard (view clipboard history)
  - Settings... (configure preferences)
  - Quit ClipboardManager

### Keyboard Shortcuts

- **`Cmd+Shift+V`** - Show/hide clipboard history window

### Clipboard Features

- Automatically tracks text copied to clipboard
- Maintains history of recent clipboard items
- Click any item to copy it back to clipboard
- Persistent across app restarts

## ⚙️ Auto-Start Configuration

### Option 1: Via Settings Menu (macOS 13.0+)

1. Click the clipboard icon in menu bar
2. Select "Settings..."
3. Check "Start ClipboardManager at login"

### Option 2: Manual Setup (All macOS versions)

1. Open `System Settings > General > Login Items`
2. Click the `+` button under "Open at Login"
3. Navigate to `Applications` and select `ClipboardManager`
4. Click "Add"

## 🔧 Troubleshooting

### App Won't Launch

1. Ensure you have the latest macOS Command Line Tools installed
2. Try running from Terminal: `/Applications/ClipboardManager.app/Contents/MacOS/ClipboardManager`
3. Check Console app for error messages

### Hotkey Not Working

1. Grant Accessibility permissions in System Settings
2. Restart the app after granting permissions
3. Try using the menu bar icon as an alternative

### Settings Not Saving

1. Ensure ClipboardManager has permission to modify login items
2. Check System Settings > Privacy & Security for any blocked requests

## 📋 Features Summary

- ✅ **Black menu bar icon** - Professional, always-visible design
- ✅ **Global hotkey** - Quick access with `Cmd+Shift+V`
- ✅ **Clipboard history** - Never lose copied text again
- ✅ **Menu integration** - Right-click menu for easy access
- ✅ **Auto-start option** - Launches automatically with macOS
- ✅ **Native macOS app** - Built with Swift for optimal performance

## 🎊 You're All Set!

ClipboardManager is now installed and ready to use. The black clipboard icon in your menu bar indicates the app is running and monitoring your clipboard.

**Next Steps:**

1. Copy some text to test the functionality
2. Press `Cmd+Shift+V` to see your clipboard history
3. Configure auto-start in Settings if desired

Enjoy your enhanced clipboard experience! 📋✨
