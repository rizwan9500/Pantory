# Pantory App Installation Guide

This folder contains scripts and documentation to help you build the Pantory app for Android and iOS.

## 📱 Quick Start

### Android APK Build

**Requirements:**
- Flutter SDK installed
- Android SDK installed
- Java JDK configured
- 10-20 GB free disk space

**Steps:**
```bash
cd app_install
chmod +x build_android.sh
./build_android.sh
```

**Output:** `Pantory-release.apk` will be created in this folder.

### iOS IPA Build

**Requirements:**
- macOS with Xcode installed
- Apple Developer account
- Provisioning profiles configured
- 10-20 GB free disk space

**Steps:**
```bash
cd app_install
chmod +x build_ios.sh
./build_ios.sh
```

**Output:** `Pantory-release.ipa` will be created in this folder.

## 📋 Detailed Build Instructions

### Android Build Process

1. **Install Prerequisites:**
   ```bash
   # Install Flutter (if not already installed)
   # Visit: https://flutter.dev/docs/get-started/install
   
   # Verify installation
   flutter doctor
   ```

2. **Configure Signing (for release builds):**
   - Create `android/key.properties`:
     ```properties
     storePassword=<your-store-password>
     keyPassword=<your-key-password>
     keyAlias=<your-key-alias>
     storeFile=<path-to-keystore-file>
     ```
   - Generate keystore if needed:
     ```bash
     keytool -genkey -v -keystore ~/pantory-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias pantory
     ```

3. **Run Build Script:**
   ```bash
   ./build_android.sh
   ```

4. **Install on Device:**
   - Transfer `Pantory-release.apk` to your Android device
   - Enable "Install from Unknown Sources" in Settings
   - Tap the APK file to install

### iOS Build Process

1. **Install Prerequisites:**
   ```bash
   # Install Flutter (if not already installed)
   # Visit: https://flutter.dev/docs/get-started/install
   
   # Install Xcode from Mac App Store
   
   # Verify installation
   flutter doctor
   ```

2. **Configure Apple Developer Account:**
   - Open `ios/Runner.xcworkspace` in Xcode
   - Select the Runner target
   - Go to "Signing & Capabilities"
   - Select your Team
   - Ensure provisioning profile is valid

3. **Run Build Script:**
   ```bash
   ./build_ios.sh
   ```

4. **Distribute App:**
   - **TestFlight:** Upload to App Store Connect
   - **Direct Install:** Use Apple Configurator
   - **Enterprise:** Use enterprise distribution certificate

## 🔧 Manual Build Commands

### Android
```bash
# Navigate to project root
cd ..

# Clean and get dependencies
flutter clean
flutter pub get

# Build APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### iOS
```bash
# Navigate to project root
cd ..

# Clean and get dependencies
flutter clean
flutter pub get

# Build iOS
flutter build ios --release

# Build IPA
flutter build ipa --release

# Output: build/ios/ipa/*.ipa
```

## 📦 Build Variants

### Android

**Debug APK (for development):**
```bash
flutter build apk --debug
```

**Split APKs (smaller size per architecture):**
```bash
flutter build apk --split-per-abi
```

**App Bundle (for Play Store):**
```bash
flutter build appbundle --release
```

### iOS

**Debug Build:**
```bash
flutter build ios --debug
```

**Simulator Build:**
```bash
flutter build ios --simulator
```

## 🐛 Troubleshooting

### Android Issues

**Problem:** "Android SDK not found"
- **Solution:** Set `ANDROID_HOME` environment variable
  ```bash
  export ANDROID_HOME=$HOME/Android/Sdk
  export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
  ```

**Problem:** "Gradle build failed"
- **Solution:** 
  - Run `flutter clean`
  - Delete `android/.gradle` folder
  - Run `flutter pub get`
  - Try build again

**Problem:** "Signing key not found"
- **Solution:** Configure `android/key.properties` (see above)

### iOS Issues

**Problem:** "Provisioning profile not found"
- **Solution:** 
  - Open Xcode
  - Go to Preferences > Accounts
  - Download manual profiles
  - Or enable "Automatically manage signing"

**Problem:** "Code signing failed"
- **Solution:**
  - Open `ios/Runner.xcworkspace` in Xcode
  - Select your Team in Signing & Capabilities
  - Ensure certificate is valid

**Problem:** "Command not found: xcodebuild"
- **Solution:** Install Xcode from Mac App Store

## 📊 Build Output Information

### APK Size
- **Release APK:** ~40-60 MB (typical Flutter app)
- **Split APKs:** ~15-25 MB each (per architecture)
- **App Bundle:** ~30-50 MB (optimized for Play Store)

### IPA Size
- **Release IPA:** ~50-70 MB (typical Flutter app)
- **Compressed:** ~30-40 MB (after App Store optimization)

## 🚀 Distribution

### Android
- **Google Play Store:** Use App Bundle (.aab)
- **Direct Distribution:** Use APK (.apk)
- **Internal Testing:** Use APK or Firebase App Distribution

### iOS
- **App Store:** Upload IPA via Xcode or Transporter
- **TestFlight:** Upload to App Store Connect
- **Enterprise:** Use enterprise distribution profile

## 📝 Release Checklist

### Before Building

- [ ] Update version in `pubspec.yaml`
- [ ] Update version code/number
- [ ] Test app thoroughly
- [ ] Update app icons and splash screens
- [ ] Review permissions in AndroidManifest.xml
- [ ] Review Info.plist for iOS
- [ ] Update privacy policy and terms
- [ ] Test on physical devices

### After Building

- [ ] Test installation on clean device
- [ ] Verify all features work
- [ ] Check app size is reasonable
- [ ] Test payment flows
- [ ] Verify authentication works
- [ ] Check push notifications
- [ ] Review app permissions

## 🔗 Useful Links

- [Flutter Documentation](https://flutter.dev/docs)
- [Android Build Guide](https://flutter.dev/docs/deployment/android)
- [iOS Build Guide](https://flutter.dev/docs/deployment/ios)
- [Play Store Console](https://play.google.com/console)
- [App Store Connect](https://appstoreconnect.apple.com)

## 💡 Tips

1. **First Build is Slow:** The first build takes longer as dependencies are downloaded. Subsequent builds are faster.

2. **Clean Builds:** If you encounter issues, try `flutter clean` and rebuild.

3. **Build Cache:** Keep `build/` folder to speed up incremental builds.

4. **Testing:** Always test release builds on physical devices before distribution.

5. **App Size:** Use `flutter build apk --analyze-size` to analyze APK size.

## 📞 Support

For build issues:
1. Run `flutter doctor -v` to check your setup
2. Check Flutter's [troubleshooting guide](https://flutter.dev/docs/get-started/install#platform-setup)
3. Search [Flutter GitHub issues](https://github.com/flutter/flutter/issues)
4. Ask on [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)

---

**Note:** The build scripts create the APK/IPA files and copy them to this `app_install` folder for easy access.
