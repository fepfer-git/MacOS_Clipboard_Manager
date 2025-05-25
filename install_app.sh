#!/bin/bash

# ClipboardManager Quick Installation Script
# This script installs the pre-built ClipboardManager.app to Applications

set -e

echo "📋 ClipboardManager Quick Installation"
echo "======================================"

# Check if ClipboardManager.app exists
if [ ! -d "ClipboardManager.app" ]; then
    echo "❌ ClipboardManager.app not found!"
    echo "Please run ./package_app.sh first to build the app."
    exit 1
fi

echo "📦 Installing ClipboardManager to Applications folder..."

# Check if Applications directory is writable
if [ -w "/Applications" ]; then
    # Direct copy if writable
    cp -R ClipboardManager.app /Applications/
    echo "✅ ClipboardManager installed successfully!"
else
    # Use sudo if needed
    echo "🔐 Administrator password required for installation..."
    sudo cp -R ClipboardManager.app /Applications/
    sudo chown -R $(whoami):staff /Applications/ClipboardManager.app
    echo "✅ ClipboardManager installed successfully with administrator privileges!"
fi

# Ensure executable permissions
chmod +x /Applications/ClipboardManager.app/Contents/MacOS/ClipboardManager

echo ""
echo "🚀 Installation Complete!"
echo ""
echo "📋 ClipboardManager is now installed in your Applications folder."
echo ""
echo "🎯 To get started:"
echo "   1. Open Applications and double-click ClipboardManager"
echo "   2. Look for the black clipboard icon in your menu bar"
echo "   3. Press Cmd+Shift+V to show clipboard history"
echo "   4. Click the menu bar icon for settings and options"
echo ""
echo "📖 For detailed usage instructions, see INSTALLATION_INSTRUCTIONS.md"
echo ""
echo "✨ Enjoy your enhanced clipboard experience!"