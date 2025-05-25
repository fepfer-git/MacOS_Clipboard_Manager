#!/bin/bash
# install.sh - Create an app bundle and install to Applications

echo "Creating macOS app bundle..."

APP_NAME="ClipboardManager"
BUNDLE_PATH="$APP_NAME.app"
EXECUTABLE_PATH=".build/release/$APP_NAME"

# Check if executable exists
if [ ! -f "$EXECUTABLE_PATH" ]; then
    echo "Executable not found. Building first..."
    swift build -c release
fi

# Create app bundle structure
mkdir -p "$BUNDLE_PATH/Contents/MacOS"
mkdir -p "$BUNDLE_PATH/Contents/Resources"

# Copy executable
cp "$EXECUTABLE_PATH" "$BUNDLE_PATH/Contents/MacOS/"

# Create Info.plist
cat > "$BUNDLE_PATH/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.local.ClipboardManager</string>
    <key>CFBundleName</key>
    <string>Clipboard Manager</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSAppleEventsUsageDescription</key>
    <string>This app needs access to control other applications for clipboard management and auto-paste functionality.</string>
    <key>NSSystemAdministrationUsageDescription</key>
    <string>This app needs system access to monitor and manage clipboard content.</string>
</dict>
</plist>
EOF

echo "✅ App bundle created: $BUNDLE_PATH"
echo ""
echo "To install to Applications folder:"
echo "  cp -r $BUNDLE_PATH /Applications/"
echo ""
echo "To run the app bundle:"
echo "  open $BUNDLE_PATH"