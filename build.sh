#!/bin/bash
# build.sh - Build the application

echo "Building ClipboardManager..."

# Build the project
swift build -c release

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo "📍 Executable location: .build/release/ClipboardManager"
    echo ""
    echo "To run the app:"
    echo "  ./run.sh"
    echo ""
    echo "Or manually:"
    echo "  ./.build/release/ClipboardManager"
else
    echo "❌ Build failed!"
    exit 1
fi