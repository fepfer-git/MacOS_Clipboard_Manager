# ClipboardManager 📋

ClipboardManager is a lightweight, efficient clipboard history tool for macOS that remembers what you copy, so you don't have to.

## ✨ Features

- **📋 Clipboard History** - Never lose copied text again with persistent history
- **🖥️ Global Hotkey** - Access your clipboard history with `Cmd+Shift+V` from anywhere
- **🖼️ Image Support** - Handles TIFF, PNG, PDF, and JPEG images
- **🔍 Search** - Filter through your clipboard history
- **🏎️ Performance** - Minimal resource usage, even with large clipboard histories
- **📱 Modern UI** - Clean collection view with thumbnails and previews
- **🚀 Auto-Start** - Option to launch automatically with macOS

## 📥 Installation

### Option 1: Download and Install Pre-built App

1. Download the latest release from the Releases page
2. Unzip the archive
3. Drag ClipboardManager.app to your Applications folder

### Option 2: Build from Source

#### Prerequisites

- Xcode 14+ or Swift 5.7+
- macOS 12.0 or higher

#### Step 1: Clone the repository

```bash
git clone https://github.com/yourusername/ClipboardManager.git
cd ClipboardManager
```

#### Step 2: Build the application

```bash
# Build the application
./build_app.sh
```

#### Step 3: Install to Applications folder

```bash
# Install the application
./install_app.sh
```

## 🚀 First Launch

When you first launch ClipboardManager, you'll need to:

1. **Grant Accessibility Permission**:

   - You'll be prompted to grant Accessibility permissions
   - Open System Preferences → Security & Privacy → Privacy → Accessibility
   - Add ClipboardManager to the list of allowed apps

2. **Menu Bar Icon**:
   - Look for the clipboard icon in your menu bar
   - Right-click to access settings and options

## 🔧 Using ClipboardManager

### Basic Usage

- **Copy text or images** as you normally would (`Cmd+C`)
- Press **`Cmd+Shift+V`** to open the clipboard history window
- **Click an item** to copy it back to your clipboard
- **Double-click** to copy and paste in one action

### Search

- Open the clipboard window with `Cmd+Shift+V`
- Start typing to filter items
- Use keywords like "image" or "text" to filter by type

### Managing Clipboard Items

- **Single-click** an item to copy it
- Items are automatically saved between app restarts
- ClipboardManager won't duplicate consecutively copied identical items

## 🛠️ Troubleshooting

### App Won't Start

Make sure:

1. You have macOS 12.0 or higher
2. You've granted necessary permissions in System Preferences
3. Try rebuilding with: `./build_app.sh && ./install_app.sh`

### Hotkey Not Working

1. Check if ClipboardManager is running (look for menu bar icon)
2. Ensure Accessibility permissions are granted
3. Restart the app: right-click menu bar icon → Quit → relaunch

## ⌨️ Building for Development

For developers who want to modify the app:

```bash
# Build debug version
swift build -c debug

# Run the debug build
./.build/debug/ClipboardManager
```

## 📷 Image Support Details

ClipboardManager supports several image formats:

- **TIFF** (.tiff) - High-quality images with lossless compression
- **PNG** (.png) - Web-friendly format with transparency support
- **PDF** (.pdf) - Document format that preserves vector graphics
- **JPEG** (.jpg/.jpeg) - Compressed image format ideal for photographs

Images are displayed with:

- Automatic scaling to fit the view
- Subtle borders for better visualization
- Format and size information

## 🙏 Acknowledgments

- Inspired by the need for a lightweight, native macOS clipboard manager
- Built with Swift and AppKit for optimal performance
