#!/bin/bash
# minimal_app_builder.sh - Creates app bundle using existing binary

echo "🔨 Creating minimal app bundle for ClipboardManager..."

# Check if the binary exists
if [ ! -f ".build/release/ClipboardManager" ]; then
  echo "❌ Binary not found! Did you run ./build.sh first?"
  exit 1
fi

# Clean previous bundle if it exists
rm -rf ClipboardManager.app

# Create app bundle structure
echo "📁 Creating app bundle structure..."
mkdir -p ClipboardManager.app/Contents/MacOS
mkdir -p ClipboardManager.app/Contents/Resources

# Copy executable
echo "📋 Copying executable..."
cp .build/release/ClipboardManager ClipboardManager.app/Contents/MacOS/
chmod +x ClipboardManager.app/Contents/MacOS/ClipboardManager

# Copy Info.plist
echo "📄 Copying Info.plist..."
cp Info.plist ClipboardManager.app/Contents/

# Copy icons if they exist
echo "🎨 Checking for icons..."
if [ -d "Resources" ]; then
  if [ -f "Resources/AppIcon.icns" ]; then
    echo "  - Found AppIcon.icns"
    cp Resources/AppIcon.icns ClipboardManager.app/Contents/Resources/
  fi
  if [ -f "Resources/MenuBarIcon.svg" ]; then
    echo "  - Found MenuBarIcon.svg"
    cp Resources/MenuBarIcon.svg ClipboardManager.app/Contents/Resources/
  fi
fi

echo "✅ ClipboardManager.app created successfully!"
echo ""
echo "📦 Installing to Applications folder..."
cp -r ClipboardManager.app /Applications/

echo "🚀 Installation complete! You can now:"
echo "  1. Find ClipboardManager in your Applications folder"
echo "  2. Use ⌘+Shift+V to access clipboard history once running"
echo ""
echo "Note: You may need to right-click and select 'Open' the first time"