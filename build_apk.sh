#!/bin/bash

# DIU Events - Release APK Builder
# Builds a production-ready APK in release mode

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  DIU Events - Release APK Builder                          ║"
echo "║  Builds production APK with optimizations                 ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    echo "📝 Please install Flutter: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "🔍 Flutter version:"
flutter --version
echo ""

# Get build number if provided
BUILD_NUMBER=${1:-"1"}
BUILD_NAME=${2:-"1.0.0"}

echo "📦 Build Configuration:"
echo "  Build Number: $BUILD_NUMBER"
echo "  Build Name: $BUILD_NAME"
echo ""

# Step 1: Clean
echo "Step 1: Cleaning Flutter cache..."
flutter clean
echo "✅ Flutter cache cleaned"
echo ""

# Step 2: Get dependencies
echo "Step 2: Getting dependencies..."
flutter pub get
echo "✅ Dependencies updated"
echo ""

# Step 3: Build APK
echo "Step 3: Building release APK..."
echo "  This may take several minutes..."
echo ""

flutter build apk \
  --release \
  --split-per-abi \
  --build-number=$BUILD_NUMBER \
  --build-name=$BUILD_NAME

echo ""
echo "✅ APK build completed!"
echo ""

# Check if APK was created
if [ -d "build/app/outputs/flutter-apk" ]; then
    echo "📁 APK Output Directory:"
    ls -lh build/app/outputs/flutter-apk/
    echo ""
    echo "📍 APK Location:"
    ls -1 build/app/outputs/flutter-apk/*.apk | while read apk; do
        SIZE=$(du -h "$apk" | cut -f1)
        echo "  ✓ $apk ($SIZE)"
    done
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║  ✅ Release APK Build Complete!                           ║"
    echo "║  Ready for Google Play Store or direct distribution       ║"
    echo "╚════════════════════════════════════════════════════════════╝"
else
    echo "❌ APK output directory not found"
    exit 1
fi
