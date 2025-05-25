# ClipboardManager 📋

A lightweight, native clipboard history manager for macOS that elegantly keeps track of everything you copy.

![ClipboardManager](https://img.shields.io/badge/Platform-macOS%2012.0%2B-blue)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Features

- **📋 Smart Clipboard History** - Instantly access your previously copied items
- **🖼️ Full Image Support** - Seamlessly handles TIFF, PNG, PDF, and JPEG formats
- **🔍 Powerful Search** - Quickly filter through your clipboard history
- **⌨️ Global Hotkey** - Press `Cmd+Shift+V` from anywhere to access your history
- **🔄 One-Click Copy** - Single click to copy any previous item
- **⚡️ Resource Efficient** - Minimal memory and CPU usage
- **🚀 Auto-Launch** - Option to start automatically at login

## 📥 Installation

### Method 1: Simple Installation (Recommended)

```bash
# Build the app with one command
./build.sh && ./minimal_app_builder.sh
```

This will:

- Build the ClipboardManager binary
- Create a proper application bundle
- Install it to your Applications folder

### Method 2: Manual Installation

If you prefer to do it step-by-step:

1. **Build the binary**

   ```bash
   ./build.sh
   ```

2. **Create the app bundle manually**

   ```bash
   # Create app structure
   mkdir -p ClipboardManager.app/Contents/MacOS
   mkdir -p ClipboardManager.app/Contents/Resources

   # Copy the executable
   cp .build/release/ClipboardManager ClipboardManager.app/Contents/MacOS/
   chmod +x ClipboardManager.app/Contents/MacOS/ClipboardManager

   # Copy Info.plist
   cp Info.plist ClipboardManager.app/Contents/

   # Copy to Applications
   cp -r ClipboardManager.app /Applications/
   ```

## 🚀 Getting Started

### First Launch

1. **Open the app** from your Applications folder

   - You may need to right-click and select "Open" the first time

2. **Grant Permissions**

   - When prompted, allow Accessibility permissions
   - Go to **System Settings → Privacy & Security → Accessibility**
   - Ensure ClipboardManager is checked

3. **Look for the icon** in your menu bar (top-right)

### Basic Usage

- **Copy anything** using `Cmd+C` as you normally would
- Press **`Cmd+Shift+V`** to open your clipboard history
- Press **`Cmd+Shift+V`** again or `ESC` to close clipboard history
- **Click once** on any item to copy it to your clipboard
- **Search** by typing when the clipboard window is open

## 🔧 Advanced Features

### Auto-Start Configuration

To have ClipboardManager start automatically at login:

1. Right-click the menu bar icon
2. Select "Settings..."
3. Enable "Start at login"

### Working with Images

ClipboardManager handles images just like text:

- Copy images from any application
- See thumbnails in your clipboard history
- Click once to copy back to clipboard
- Formats supported: TIFF, PNG, PDF, JPEG

### Search Tips

- Type any text to filter items
- Use `image:` to show only images
- Use `text:` to show only text items

## 🛠️ Troubleshooting

### App Not Showing in Menu Bar

1. Check if the app is running: `ps aux | grep ClipboardManager`
2. Try launching manually: `open /Applications/ClipboardManager.app`
3. Rebuild using the simplified method: `.build.sh && ./minimal_app_builder.sh`

### Hotkey Not Working

1. Ensure accessibility permissions are granted
2. Check if the app is running (look for menu bar icon)
3. Try restarting the app: right-click menu bar icon → Quit → relaunch

### Build Issues

If you encounter build problems:

```bash
# Create a minimal app bundle that works without full Xcode
./minimal_app_builder.sh
```

This script uses the already built binary and creates a functioning app bundle without requiring Xcode Command Line Tools.

## 👩‍💻 Development

For developers looking to modify ClipboardManager:

```bash
# Build debug version with more logging
swift build -c debug

# Run with debug output
./.build/debug/ClipboardManager
```

## 📄 License

ClipboardManager is available under the MIT license. See the LICENSE file for more info.

---

Made with ♥️ for macOS users who need a better clipboard experience.
