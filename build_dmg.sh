#!/bin/bash
# create_simple_dmg.sh - Creates a simple DMG file for distribution

# Set variables
APP_NAME="ClipboardManager"
DMG_NAME="ClipboardManager-v1.0"

echo "🚀 Creating simple DMG for ClipboardManager distribution..."

# Step 1: Build the app if it doesn't exist
if [ ! -d "ClipboardManager.app" ]; then
    echo "📦 App bundle not found. Building app..."
    ./build.sh && ./minimal_app_builder.sh
    if [ $? -ne 0 ]; then
        echo "❌ Failed to build app"
        exit 1
    fi
fi

# Step 2: Clean up any existing DMG files
echo "🧹 Cleaning up previous DMG..."
rm -f "${DMG_NAME}.dmg"

# Step 3: Create README for users
cat > "DMG_README.txt" << 'EOF'
ClipboardManager v1.0 - Installation Instructions

QUICK INSTALL:
1. Drag ClipboardManager.app to your Applications folder
2. Open ClipboardManager from Applications
3. Grant Accessibility permissions when prompted
4. Look for the clipboard icon in your menu bar

USAGE:
• Press Cmd+Shift+V to show clipboard history
• Click any item to copy it to clipboard  
• Type to search through your clipboard history
• Press Cmd+Shift+V again or ESC to close

FEATURES:
✓ Lightweight and fast
✓ Secure local storage
✓ Global hotkey access
✓ Search functionality
✓ Menu bar integration

PERMISSIONS:
ClipboardManager needs Accessibility permissions to:
- Monitor global keyboard shortcuts
- Access clipboard content

Go to: System Settings → Privacy & Security → Accessibility
Make sure ClipboardManager is checked.

Enjoy your enhanced clipboard experience!
EOF

# Step 4: Create the DMG with the app and README
echo "💿 Creating DMG file..."
hdiutil create -srcfolder "ClipboardManager.app" -srcfolder "DMG_README.txt" -volname "${APP_NAME}" -fs HFS+ -format UDZO -imagekey zlib-level=9 "${DMG_NAME}.dmg"

if [ $? -eq 0 ]; then
    echo "✅ DMG created successfully!"
    echo ""
    echo "📋 DMG Details:"
    echo "  📁 File: ${DMG_NAME}.dmg"
    echo "  📏 Size: $(du -h "${DMG_NAME}.dmg" | cut -f1)"
    echo ""
    echo "🚀 Ready for Distribution!"
    echo ""
    echo "📤 How to share:"
    echo "  • Upload ${DMG_NAME}.dmg to cloud storage"
    echo "  • Send via email (if under size limit)"
    echo "  • Share via file transfer service"
    echo "  • Host on your website"
    echo ""
    echo "📥 Installation for recipients:"
    echo "  1. Double-click ${DMG_NAME}.dmg"
    echo "  2. Drag ClipboardManager.app to Applications"
    echo "  3. Read the included README for usage instructions"
    
    # Clean up temporary README
    rm -f "DMG_README.txt"
else
    echo "❌ DMG creation failed!"
    rm -f "DMG_README.txt"
    exit 1
fi
