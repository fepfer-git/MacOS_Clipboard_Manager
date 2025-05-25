# ClipboardManager 📋

A powerful, native macOS clipboard manager with a clean black icon design, global hotkeys, and auto-start functionality.

## ✨ Features

- **🖤 Clean Black Icon** - Professional menu bar integration with a black clipboard icon
- **⌨️ Global Hotkey** - Press `Cmd+Shift+V` to instantly access clipboard history
- **📋 Clipboard History** - Never lose copied text again with persistent history
- **🚀 Auto-Start** - Launches automatically with macOS (configurable)
- **⚙️ Settings Menu** - Easy configuration via menu bar right-click
- **🎯 Native Performance** - Built with Swift for optimal macOS integration
- **🖼️ Image Support** - Handles TIFF, PNG, PDF, and JPEG images
- **🔍 Search** - Search through clipboard history
- **📱 Modern UI** - Clean collection view with thumbnails and previews

## Image Features Added

### Supported Image Formats

- TIFF (.tiff)
- PNG (.png)
- PDF (.pdf)
- JPEG (.jpg/.jpeg)

### Image Display

- Images are displayed as thumbnails in the collection view
- Image items show format type and file size in the title
- Proper scaling and centering of images

### Image Copying

- Copy button works for both text and images
- Double-click functionality supports images
- Images are copied back to clipboard in their original format

## How to Use

1. **Build the app**: `./build.sh`
2. **Run the app**: `./run.sh`
3. **Copy text or images** to your clipboard as normal
4. **View clipboard history**: Press `Cmd+Shift+V` or click the menu bar icon
5. **Copy items**: Click the "Copy" button or double-click any item
6. **Search**: Use the search field to filter items
7. **Clear history**: Click "Clear All" button

## Technical Implementation

### ClipboardManager.swift

- Enhanced `checkClipboard()` to detect multiple image formats
- Updated `copyToPasteboard()` to handle both text and image copying
- Improved `ClipboardItem` to show descriptive text for images with format and size info

### ClipboardItemView.swift

- Added `customImageView` (renamed to avoid conflict with NSCollectionViewItem's imageView)
- Updated `configure()` method to show either text view or image view based on item type
- Enhanced `copyButtonClicked()` to copy both text and images properly
- Added proper cleanup in `prepareForReuse()`

### UI Layout

- Text and image views occupy the same space but are shown/hidden based on content type
- Images scale proportionally and are centered
- Consistent layout for both text and image items

## Building and Installation

## 🚀 NEW: Complete App Bundle Ready!

### Quick Installation (Recommended)

```bash
# Build and package the complete app
./package_app.sh

# Install to Applications folder
./install_app.sh
```

### What's New

- ✅ **Complete macOS app bundle** (`ClipboardManager.app`)
- ✅ **Black menu bar icon** (no longer adapts to system theme)
- ✅ **Settings menu integration** (right-click the menu bar icon)
- ✅ **Auto-start functionality** (configurable in Settings)
- ✅ **Professional installation process** (drag to Applications)
- ✅ **Comprehensive documentation** (see `INSTALLATION_INSTRUCTIONS.md`)

### Usage

1. **Install**: Run `./install_app.sh` or copy `ClipboardManager.app` to Applications
2. **Launch**: Double-click ClipboardManager in Applications
3. **Access**: Look for the black clipboard icon in your menu bar
4. **Hotkey**: Press `Cmd+Shift+V` to show clipboard history
5. **Settings**: Right-click the menu bar icon → Settings...

### Distribution Ready

The app is now packaged as a complete macOS application bundle that can be:

- Installed via the provided scripts
- Manually copied to Applications folder
- Distributed as a standalone `.app` file
- Configured for auto-start on login

## Legacy Build Instructions

```bash
# Build the project (legacy method)
./build.sh

# Run directly from build
./run.sh

# Create macOS app bundle (legacy)
./install.sh
```

The app runs as a menu bar utility (no dock icon) and monitors clipboard changes in real-time.
