# Note: Actual APK and IPA Files

This folder is set up to receive the compiled application files after you run the build scripts.

## Expected Files After Build:

1. **Pantory-release.apk** - Android application (40-60 MB)
   - Created after running `./build_android.sh`
   - Can be installed directly on Android devices
   
2. **Pantory-release.ipa** - iOS application (50-70 MB)
   - Created after running `./build_ios.sh` (macOS only)
   - Can be uploaded to App Store or installed via Apple Configurator

## Why These Files Are Not Pre-Built:

Building mobile apps requires:
- Flutter SDK and platform-specific tools installed
- Platform-specific build environments (Android SDK, Xcode)
- Valid signing certificates for release builds
- 5-15 minutes of build time depending on your machine
- 10-20 GB of disk space for build tools and artifacts

## How to Get These Files:

### Option 1: Build Yourself (Recommended)
```bash
# For Android
./build_android.sh

# For iOS (macOS only)
./build_ios.sh
```

### Option 2: Use Flutter Commands Directly
See `BUILD_COMMANDS.md` for manual build instructions.

### Option 3: Use CI/CD
Set up GitHub Actions or other CI/CD to automatically build and publish releases.

## File Locations After Build:

The build scripts automatically copy the compiled files to this folder:
- Android: `build/app/outputs/flutter-apk/app-release.apk` → `Pantory-release.apk`
- iOS: `build/ios/ipa/*.ipa` → `Pantory-release.ipa`

## Important Notes:

- These files are **NOT included in git** (see `.gitignore`)
- Build artifacts can be 100+ MB in size
- Each developer must build their own copies
- Release builds require proper signing configuration

---

For detailed build instructions, see `README.md` in this folder.
