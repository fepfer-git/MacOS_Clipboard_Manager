#!/bin/bash
# run.sh - Run the application

echo "Starting Clipboard Manager..."

# Check if the executable exists
if [ ! -f ".build/release/ClipboardManager" ]; then
    echo "Executable not found. Building first..."
    ./build.sh
fi

# Run the application
./.build/release/ClipboardManager
