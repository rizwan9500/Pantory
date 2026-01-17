#!/bin/bash

# Pantory iOS Build Script
# This script automates the iOS IPA build process
# NOTE: This script must be run on macOS with Xcode installed

echo "=========================================="
echo "  Pantory iOS Build Script"
echo "=========================================="
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Error: iOS builds require macOS with Xcode"
    echo "Current OS: $OSTYPE"
    echo ""
    echo "To build for iOS, you need:"
    echo "   - macOS computer"
    echo "   - Xcode installed"
    echo "   - Apple Developer account"
    echo "   - Provisioning profiles configured"
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter is not installed or not in PATH"
    echo "Please install Flutter from https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter detected: $(flutter --version | head -n 1)"
echo ""

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode is not installed"
    echo "Please install Xcode from the Mac App Store"
    exit 1
fi

echo "✅ Xcode detected: $(xcodebuild -version | head -n 1)"
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

# Build for iOS
echo "🔨 Building iOS (Release mode)..."
echo "This may take 10-15 minutes..."
echo ""

flutter build ios --release

# Check if iOS build was successful
if [ $? -ne 0 ]; then
    echo ""
    echo "=========================================="
    echo "  ❌ iOS BUILD FAILED"
    echo "=========================================="
    echo ""
    echo "Common issues:"
    echo "   - Provisioning profiles not configured"
    echo "   - Signing certificates missing"
    echo "   - Team ID not set in Xcode"
    echo ""
    echo "Run 'flutter doctor' to diagnose issues"
    exit 1
fi

# Build IPA
echo ""
echo "📦 Creating IPA archive..."
flutter build ipa --release

# Check if IPA build was successful
if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "  ✅ BUILD SUCCESSFUL!"
    echo "=========================================="
    echo ""
    
    # Find the IPA file
    IPA_PATH=$(find build/ios/ipa -name "*.ipa" | head -n 1)
    
    if [ -n "$IPA_PATH" ]; then
        echo "📱 IPA Location:"
        echo "   $IPA_PATH"
        echo ""
        echo "📊 IPA Size:"
        ls -lh "$IPA_PATH" | awk '{print "   " $5}'
        echo ""
        echo "📋 Next Steps:"
        echo "   1. Upload to App Store Connect via Xcode or Transporter app"
        echo "   2. Or install directly via Apple Configurator for testing"
        echo "   3. Or distribute via TestFlight"
        echo ""
        echo "💾 Copying IPA to app_install folder..."
        cp "$IPA_PATH" app_install/Pantory-release.ipa
        echo "   ✅ Saved as: app_install/Pantory-release.ipa"
        echo ""
    else
        echo "⚠️  IPA file not found in expected location"
        echo "Check build/ios/ipa/ directory manually"
    fi
else
    echo ""
    echo "=========================================="
    echo "  ❌ IPA CREATION FAILED"
    echo "=========================================="
    echo ""
    echo "The iOS build succeeded but IPA creation failed."
    echo ""
    echo "You can manually create an IPA:"
    echo "   1. Open ios/Runner.xcworkspace in Xcode"
    echo "   2. Select 'Product > Archive'"
    echo "   3. Export as IPA from the Archives window"
    echo ""
    exit 1
fi
