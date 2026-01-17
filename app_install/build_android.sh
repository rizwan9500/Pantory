#!/bin/bash

# Pantory Android Build Script
# This script automates the Android APK build process

echo "=========================================="
echo "  Pantory Android Build Script"
echo "=========================================="
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter is not installed or not in PATH"
    echo "Please install Flutter from https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter detected: $(flutter --version | head -n 1)"
echo ""

# Navigate to project root
cd "$(dirname "$0")/.." || exit 1

echo "📁 Working directory: $(pwd)"
echo ""

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
echo ""

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get
echo ""

# Run build
echo "🔨 Building Android APK (Release mode)..."
echo "This may take 5-10 minutes..."
echo ""

flutter build apk --release

# Check if build was successful
if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "  ✅ BUILD SUCCESSFUL!"
    echo "=========================================="
    echo ""
    echo "📱 APK Location:"
    echo "   build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    echo "📊 APK Size:"
    ls -lh build/app/outputs/flutter-apk/app-release.apk | awk '{print "   " $5}'
    echo ""
    echo "📋 Next Steps:"
    echo "   1. Copy the APK to your Android device"
    echo "   2. Enable 'Install from Unknown Sources' in Settings"
    echo "   3. Open the APK file to install"
    echo ""
    echo "💾 Copying APK to app_install folder..."
    cp build/app/outputs/flutter-apk/app-release.apk app_install/Pantory-release.apk
    echo "   ✅ Saved as: app_install/Pantory-release.apk"
    echo ""
else
    echo ""
    echo "=========================================="
    echo "  ❌ BUILD FAILED"
    echo "=========================================="
    echo ""
    echo "Common issues:"
    echo "   - Android SDK not installed"
    echo "   - Java JDK not configured"
    echo "   - Dependencies not resolved"
    echo ""
    echo "Run 'flutter doctor' to diagnose issues"
    exit 1
fi
