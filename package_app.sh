#!/bin/bash

# ClipboardManager App Package Script
# This script builds and packages the ClipboardManager app for distribution

set -e  # Exit on any error

echo "🚀 Building ClipboardManager..."
echo "======================================="

# Clean previous builds
rm -rf .build
rm -rf ClipboardManager.app

# Build the project
echo "📦 Compiling Swift sources..."
swift build --configuration release

# Check if build was successful
if [ ! -f ".build/arm64-apple-macosx/release/ClipboardManager" ]; then
    echo "❌ Build failed! Executable not found."
    exit 1
fi

echo "🏗️ Creating app bundle structure..."

# Create app bundle directories
mkdir -p ClipboardManager.app/Contents/MacOS
mkdir -p ClipboardManager.app/Contents/Resources

# Copy executable
cp .build/arm64-apple-macosx/release/ClipboardManager ClipboardManager.app/Contents/MacOS/

# Copy Info.plist
cp Info.plist ClipboardManager.app/Contents/

# Make executable
chmod +x ClipboardManager.app/Contents/MacOS/ClipboardManager

echo "✅ ClipboardManager.app created successfully!"
echo ""
echo "📁 App bundle located at: $(pwd)/ClipboardManager.app"
echo ""
echo "📋 Installation Instructions:"
echo "1. Copy ClipboardManager.app to your Applications folder"
echo "2. Open ClipboardManager from Applications"
echo "3. Grant necessary permissions when prompted"
echo "4. The app will appear in your menu bar as a clipboard icon"
echo ""
echo "🎯 Usage:"
echo "• Click the menu bar icon to access options"
echo "• Press Cmd+Shift+V to show clipboard history"
echo "• Access Settings from the menu bar icon"
echo ""
echo "🔧 Auto-start Setup (macOS 13.0+):"
echo "Use the Settings menu to enable auto-start, or manually configure in:"
echo "System Settings > General > Login Items"
