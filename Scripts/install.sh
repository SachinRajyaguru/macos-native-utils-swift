#!/bin/bash

# macOS Native Utils Swift - Installation Script
# This script compiles the project and installs it globally

set -e  # Exit on any error

echo "🔧 macOS Native Utils - Installing..."

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/.build/release"
INSTALL_PATH="/usr/local/bin"
APP_NAME="macapps"

# Step 1: Build the Swift package
echo "📦 Building Swift package..."
cd "$PROJECT_DIR"
swift build -c release

# Step 2: Verify build output exists
if [ ! -f "$BUILD_DIR/$APP_NAME" ]; then
    echo "❌ Build failed: Executable not found at $BUILD_DIR/$APP_NAME"
    exit 1
fi

# Step 3: Install to global bin directory
echo "🚀 Installing to $INSTALL_PATH/$APP_NAME..."
if [ ! -d "$INSTALL_PATH" ]; then
    echo "📁 Creating $INSTALL_PATH directory..."
    sudo mkdir -p "$INSTALL_PATH"
fi

sudo cp "$BUILD_DIR/$APP_NAME" "$INSTALL_PATH/$APP_NAME"
sudo chmod +x "$INSTALL_PATH/$APP_NAME"

# Step 4: Verify installation
if command -v $APP_NAME &> /dev/null; then
    echo "✅ Installation successful!"
    echo "📍 Location: $(which $APP_NAME)"
    echo "🎉 You can now run '$APP_NAME' from anywhere in your terminal"
else
    echo "⚠️  Installation completed but executable not found in PATH"
    echo "   Try running: sudo /usr/local/bin/$APP_NAME"
fi
