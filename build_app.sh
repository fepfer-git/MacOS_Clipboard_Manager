#!/bin/bash

set -e

echo "🚀 Building ClipboardManager for macOS..."

# Clean previous builds
rm -rf .build
rm -rf ClipboardManager.app

# Build the Swift package
echo "📦 Building Swift package..."
swift build -c release --arch arm64 --arch x86_64

# Create app bundle structure
echo "📁 Creating app bundle..."
mkdir -p ClipboardManager.app/Contents/MacOS
mkdir -p ClipboardManager.app/Contents/Resources

# Copy executable
echo "📋 Copying executable..."
cp .build/apple/Products/Release/ClipboardManager ClipboardManager.app/Contents/MacOS/

# Copy Info.plist
echo "📄 Copying Info.plist..."
cp Info.plist ClipboardManager.app/Contents/

# Copy icons and resources
echo "🎨 Copying icons and resources..."
if [ -f "Resources/AppIcon.icns" ]; then
    cp Resources/AppIcon.icns ClipboardManager.app/Contents/Resources/
fi

if [ -f "Resources/MenuBarIcon.svg" ]; then
    cp Resources/MenuBarIcon.svg ClipboardManager.app/Contents/Resources/
fi

# Make executable
chmod +x ClipboardManager.app/Contents/MacOS/ClipboardManager

# Code sign with entitlements (if entitlements file exists)
if [ -f "ClipboardManager.entitlements" ]; then
    echo "🔐 Code signing with entitlements..."
    codesign --force --options runtime --entitlements ClipboardManager.entitlements --sign - ClipboardManager.app
else
    echo "🔐 Code signing..."
    codesign --force --options runtime --sign - ClipboardManager.app
fi

echo "✅ ClipboardManager.app created successfully!"
echo ""
echo "🎯 Installation Instructions:"
echo "1. Drag ClipboardManager.app to your Applications folder"
echo "2. Right-click and select 'Open' the first time to bypass Gatekeeper"
echo "3. Grant accessibility permissions if prompted"
echo "4. Use ⌘+Shift+V to open clipboard history"
echo ""
echo "The app will appear in your menu bar as a clipboard icon."
