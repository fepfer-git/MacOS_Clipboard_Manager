#!/bin/bash
# test_image_functionality.sh - Test script for image clipboard functionality

echo "🧪 Testing ClipboardManager Image Functionality"
echo "=============================================="
echo ""

# Check if the app is built
if [ ! -f ".build/release/ClipboardManager" ]; then
    echo "❌ Release build not found. Building now..."
    swift build -c release
fi

echo "✅ Starting ClipboardManager in the background..."
./.build/release/ClipboardManager &
APP_PID=$!

# Wait a moment for the app to start
sleep 2

echo ""
echo "📋 ClipboardManager is now running!"
echo ""
echo "🎯 Test Instructions:"
echo "1. Copy some text to your clipboard"
echo "2. Copy an image (screenshot, image file, etc.) to your clipboard"
echo "3. Press Cmd+Shift+V to open the clipboard window"
echo "4. You should see both text and image items"
echo "5. Click 'Copy' on any item to copy it back to clipboard"
echo "6. Double-click any item to copy and auto-paste it"
echo ""
echo "📸 To test images:"
echo "   - Take a screenshot (Cmd+Shift+4)"
echo "   - Copy an image from a web browser"
echo "   - Copy an image file from Finder"
echo ""
echo "🔍 Image formats supported:"
echo "   - PNG, TIFF, JPEG, PDF"
echo ""
echo "Press any key to stop the ClipboardManager..."
read -n 1 -s

echo ""
echo "🛑 Stopping ClipboardManager..."
kill $APP_PID 2>/dev/null
echo "✅ Test complete!"
