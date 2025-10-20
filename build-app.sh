#!/bin/bash
# Build script for Prism macOS app bundle

set -e

echo "🔨 Building Prism..."

# Build release version
swift build -c release

echo "📦 Creating app bundle..."

# Create app bundle structure
rm -rf Prism.app
mkdir -p Prism.app/Contents/MacOS
mkdir -p Prism.app/Contents/Resources

# Copy executable (architecture-specific path)
ARCH=$(uname -m)
cp ".build/${ARCH}-apple-macosx/release/Prism" Prism.app/Contents/MacOS/

# Copy Info.plist
cp Sources/Prism/Resources/Info.plist Prism.app/Contents/

# Copy app icon
echo "🎨 Adding app icon..."
cp Prismapp_Logo.png Prism.app/Contents/Resources/AppIcon.png

# Make executable
chmod +x Prism.app/Contents/MacOS/Prism

echo "✅ Build complete! Prism.app created."
echo ""
echo "To run the app:"
echo "  open Prism.app"
echo ""
echo "To install to Applications:"
echo "  cp -r Prism.app /Applications/"
