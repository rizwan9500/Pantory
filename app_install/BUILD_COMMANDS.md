# Build Commands Quick Reference

## Android

### Release APK (Recommended for Direct Install)
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Split APKs (Smaller Size)
```bash
flutter build apk --split-per-abi --release
```
Output: 
- `app-arm64-v8a-release.apk` (64-bit ARM)
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-x86_64-release.apk` (64-bit x86)

### App Bundle (For Google Play Store)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### Debug APK
```bash
flutter build apk --debug
```

## iOS

### Release IPA
```bash
flutter build ios --release
flutter build ipa --release
```
Output: `build/ios/ipa/*.ipa`

### Debug Build
```bash
flutter build ios --debug
```

### Simulator Build
```bash
flutter build ios --simulator
```

## Build Analysis

### Analyze APK Size
```bash
flutter build apk --analyze-size --target-platform android-arm64
```

### Analyze Bundle Size
```bash
flutter build appbundle --analyze-size
```

## Cleaning

### Clean Build Artifacts
```bash
flutter clean
```

### Full Clean (Including Pub Cache)
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

## Testing Builds

### Install APK to Connected Device
```bash
flutter install
```

### Run Release Build
```bash
flutter run --release
```

## Pre-Build Steps

1. **Clean Previous Builds:**
   ```bash
   flutter clean
   ```

2. **Get Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run Code Generation (if using build_runner):**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

## Post-Build Steps

### Extract and Inspect APK
```bash
unzip -l build/app/outputs/flutter-apk/app-release.apk
```

### Check APK Signature
```bash
apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk
```

### Get APK Info
```bash
aapt dump badging build/app/outputs/flutter-apk/app-release.apk
```

## Environment Variables

### Android
```bash
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
```

### iOS
```bash
export PATH=$PATH:/Applications/Xcode.app/Contents/Developer/usr/bin
```

## Common Build Flags

- `--release` - Build in release mode (optimized)
- `--debug` - Build in debug mode (with debugging info)
- `--profile` - Build in profile mode (performance analysis)
- `--obfuscate` - Obfuscate Dart code
- `--split-debug-info=<path>` - Store debug info separately
- `--no-tree-shake-icons` - Include all icons
- `--target=<path>` - Specify main entry point

## Complete Build Workflow

### Android Release
```bash
cd /path/to/pantory
flutter clean
flutter pub get
flutter build apk --release
adb install build/app/outputs/flutter-apk/app-release.apk
```

### iOS Release
```bash
cd /path/to/pantory
flutter clean
flutter pub get
flutter build ios --release
flutter build ipa --release
open build/ios/archive/Runner.xcarchive
```

## Troubleshooting Commands

### Check Flutter Installation
```bash
flutter doctor -v
```

### List Connected Devices
```bash
flutter devices
```

### Check Flutter Version
```bash
flutter --version
```

### Upgrade Flutter
```bash
flutter upgrade
```

### Fix Dependencies
```bash
flutter pub upgrade
flutter pub get
```
