#!/bin/bash

set -e

echo "🚀 Building ClipboardManager for macOS..."

# Clean previous app bundle
rm -rf ClipboardManager.app

# Build using debug configuration (since release has issues)
echo "📦 Building Swift package..."
swift build

# Create app bundle structure
echo "📁 Creating app bundle..."
mkdir -p ClipboardManager.app/Contents/MacOS
mkdir -p ClipboardManager.app/Contents/Resources

# Copy executable from debug build
echo "📋 Copying executable..."
cp .build/debug/ClipboardManager ClipboardManager.app/Contents/MacOS/

# Copy Info.plist
echo "📄 Copying Info.plist..."
cp Info.plist ClipboardManager.app/Contents/

# Make executable
chmod +x ClipboardManager.app/Contents/MacOS/ClipboardManager

echo "✅ ClipboardManager.app created successfully!"
echo ""
echo "🎯 Installation Instructions:"
echo "1. Drag ClipboardManager.app to your Applications folder"
echo "2. Right-click and select 'Open' the first time to bypass Gatekeeper"
echo "3. Grant accessibility permissions if prompted"
echo "4. Use ⌘+Shift+V to open clipboard history"
echo ""
echo "The app will appear in your menu bar as a black clipboard icon."
