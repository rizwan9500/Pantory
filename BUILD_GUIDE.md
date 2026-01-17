# Build and Deployment Guide for Pantory

This guide covers building and deploying the Pantory app for Android and iOS platforms.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Google OAuth Setup in Supabase](#google-oauth-setup)
3. [Building for Android](#building-for-android)
4. [Building for iOS](#building-for-ios)
5. [Testing on Physical Devices](#testing-on-physical-devices)
6. [Release Checklist](#release-checklist)

## Prerequisites

### Required Software
- Flutter SDK (3.0.0 or higher)
- Android Studio (for Android builds)
- Xcode (for iOS builds - macOS only)
- Valid developer accounts:
  - Google Play Console account (for Android)
  - Apple Developer account (for iOS)

### Verify Installation
```bash
flutter doctor -v
```

Ensure all checkmarks are green for your target platforms.

## Google OAuth Setup in Supabase

### Step 1: Create Google OAuth Credentials

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable "Google+ API"
4. Go to "Credentials" → "Create Credentials" → "OAuth 2.0 Client ID"

### Step 2: Configure OAuth Consent Screen

1. Fill in:
   - App name: Pantory
   - User support email: your-email@example.com
   - Developer contact: your-email@example.com
2. Add scopes: email, profile
3. Save and continue

### Step 3: Create OAuth Client IDs

#### For Android:
1. Application type: Android
2. Package name: `com.pantory.app`
3. Get SHA-1 fingerprint:
   ```bash
   # Debug key
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   
   # Release key
   keytool -list -v -keystore /path/to/release-keystore.jks -alias your-alias
   ```
4. Add SHA-1 fingerprint to credentials

#### For iOS:
1. Application type: iOS
2. Bundle ID: `com.pantory.app`
3. Download the OAuth client configuration

#### For Web (Supabase redirect):
1. Application type: Web application
2. Authorized redirect URIs:
   ```
   https://J_1ZnzV5Kc62hCop5GKcgA.supabase.co/auth/v1/callback
   ```

### Step 4: Configure Supabase

1. Go to [Supabase Dashboard](https://app.supabase.com/)
2. Select your project
3. Navigate to: Authentication → Providers → Google
4. Enable Google provider
5. Add your OAuth credentials:
   - Client ID: from Google Cloud Console
   - Client Secret: from Google Cloud Console
6. Save changes

### Step 5: Update Redirect URLs

Add these redirect URLs in Google OAuth settings:
```
Android: io.supabase.pantory://login-callback/
iOS: io.supabase.pantory://login-callback/
```

## Building for Android

### Step 1: Configure App Signing

1. Create a keystore (if you don't have one):
   ```bash
   keytool -genkey -v -keystore ~/pantory-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias pantory
   ```

2. Create `android/key.properties`:
   ```properties
   storePassword=YOUR_STORE_PASSWORD
   keyPassword=YOUR_KEY_PASSWORD
   keyAlias=pantory
   storeFile=/path/to/pantory-release-key.jks
   ```

3. Update `android/app/build.gradle`:
   ```gradle
   def keystoreProperties = new Properties()
   def keystorePropertiesFile = rootProject.file('key.properties')
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   }

   android {
       ...
       signingConfigs {
           release {
               keyAlias keystoreProperties['keyAlias']
               keyPassword keystoreProperties['keyPassword']
               storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
               storePassword keystoreProperties['storePassword']
           }
       }
       buildTypes {
           release {
               signingConfig signingConfigs.release
           }
       }
   }
   ```

### Step 2: Update App Configuration

Update `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.pantory.app">
    
    <uses-permission android:name="android.permission.INTERNET"/>
    
    <application
        android:label="Pantory"
        android:icon="@mipmap/ic_launcher">
        
        <!-- Add deep link handling for Supabase -->
        <intent-filter>
            <action android:name="android.intent.action.VIEW" />
            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />
            <data android:scheme="io.supabase.pantory" />
        </intent-filter>
    </application>
</manifest>
```

### Step 3: Build APK

```bash
# Clean previous builds
flutter clean
flutter pub get

# Build debug APK (for testing)
flutter build apk --debug

# Build release APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

Output locations:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

### Step 4: Upload to Play Store

1. Go to [Google Play Console](https://play.google.com/console)
2. Create new app or select existing
3. Complete store listing:
   - Title: Pantory
   - Short description
   - Full description
   - Screenshots (required)
   - Feature graphic
   - App icon
4. Upload AAB file in Release → Production
5. Fill in release notes
6. Submit for review

## Building for iOS

### Step 1: Configure Xcode Project

1. Open iOS project in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. Update Bundle Identifier:
   - Select Runner → General
   - Set Bundle Identifier: `com.pantory.app`

3. Configure Signing:
   - Select Runner → Signing & Capabilities
   - Enable "Automatically manage signing"
   - Select your development team

### Step 2: Update Info.plist

Update `ios/Runner/Info.plist`:
```xml
<dict>
    <!-- Existing keys -->
    
    <!-- Add URL scheme for Supabase -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>io.supabase.pantory</string>
            </array>
        </dict>
    </array>
    
    <!-- Privacy descriptions -->
    <key>NSCameraUsageDescription</key>
    <string>We need camera access to scan barcodes</string>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>We need photo access to add item images</string>
</dict>
```

### Step 3: Build IPA

```bash
# Clean previous builds
flutter clean
flutter pub get

# Build for iOS (device)
flutter build ios --release

# Or build IPA for distribution
flutter build ipa --release
```

Output: `build/ios/ipa/pantory.ipa`

### Step 4: Upload to App Store

**Option A: Using Xcode**
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select "Any iOS Device" as target
3. Product → Archive
4. Window → Organizer → Archives
5. Select your archive → Distribute App
6. Choose "App Store Connect"
7. Follow the wizard

**Option B: Using Transporter**
1. Download Transporter app from Mac App Store
2. Open the IPA file in Transporter
3. Click "Deliver"

**Option C: Using Command Line**
```bash
# Install tools
brew install fastlane

# Configure fastlane
cd ios
fastlane init

# Upload to TestFlight
fastlane beta
```

### Step 5: Complete App Store Listing

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Select your app
3. Complete App Information:
   - Name: Pantory
   - Subtitle
   - Description
   - Keywords
   - Screenshots (required for all device sizes)
   - App icon
   - Privacy Policy URL
4. Submit for review

## Testing on Physical Devices

### Android Device Testing

1. Enable Developer Options on your device:
   - Settings → About Phone
   - Tap "Build Number" 7 times
   
2. Enable USB Debugging:
   - Settings → Developer Options
   - Enable "USB Debugging"

3. Connect device via USB

4. Run app:
   ```bash
   flutter devices  # List connected devices
   flutter run      # Run on connected device
   ```

5. Install APK directly:
   ```bash
   adb install build/app/outputs/flutter-apk/app-release.apk
   ```

### iOS Device Testing

1. Register device in Apple Developer account:
   - Go to Certificates, Identifiers & Profiles
   - Devices → Add device
   - Enter device UDID

2. Connect device via USB

3. Run app:
   ```bash
   flutter devices  # List connected devices
   flutter run      # Run on connected device
   ```

4. Trust developer certificate on device:
   - Settings → General → VPN & Device Management
   - Trust your developer profile

### Testing Checklist

- [ ] User registration and login
- [ ] Google OAuth sign-in
- [ ] Add pantry items
- [ ] Edit and delete items
- [ ] Search functionality
- [ ] Favorites (Pro feature)
- [ ] Shopping list generation
- [ ] Analytics dashboard (Pro)
- [ ] Trial activation (7 days)
- [ ] Subscription flow with Razorpay
- [ ] Notifications (if enabled)
- [ ] Data persistence after app restart
- [ ] Deep links (Supabase OAuth redirect)

## Release Checklist

### Before Release
- [ ] Update version in `pubspec.yaml`
- [ ] Test all features on physical devices
- [ ] Verify Supabase integration
- [ ] Test Razorpay payment flow with test mode
- [ ] Check all screens for UI issues
- [ ] Verify deep links work
- [ ] Test Google OAuth
- [ ] Review and update screenshots
- [ ] Update Privacy Policy if needed
- [ ] Prepare release notes

### Android Release
- [ ] Generate signed APK/AAB
- [ ] Test signed build on device
- [ ] Upload to Play Store
- [ ] Complete store listing
- [ ] Set pricing (free with IAP)
- [ ] Configure Razorpay production keys
- [ ] Submit for review

### iOS Release
- [ ] Generate IPA
- [ ] Test on TestFlight
- [ ] Upload to App Store Connect
- [ ] Complete store listing
- [ ] Set pricing (free with IAP)
- [ ] Configure Razorpay production keys
- [ ] Submit for review

### Post-Release
- [ ] Monitor crash reports
- [ ] Check user reviews
- [ ] Monitor Razorpay transactions
- [ ] Track user analytics
- [ ] Plan updates based on feedback

## Troubleshooting

### Common Android Issues

**Build fails with "SDK not found":**
```bash
flutter config --android-sdk /path/to/android-sdk
```

**Gradle sync fails:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

**App crashes on startup:**
- Check AndroidManifest.xml permissions
- Verify Supabase URL and key
- Check logs: `adb logcat | grep flutter`

### Common iOS Issues

**Code signing error:**
- Verify Bundle ID matches provisioning profile
- Check team selection in Xcode
- Ensure certificates are valid

**Build fails:**
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

**Deep links not working:**
- Verify URL scheme in Info.plist
- Check associated domains configuration

## Support Resources

- Flutter Documentation: https://docs.flutter.dev
- Supabase Documentation: https://supabase.com/docs
- Razorpay Documentation: https://razorpay.com/docs
- Google Play Console: https://support.google.com/googleplay
- App Store Connect: https://developer.apple.com/support/app-store-connect/

## Contact

For technical support or questions:
- Email: support@pantory.com
- GitHub Issues: https://github.com/rizwan9500/Pantory/issues

---

**Last Updated:** January 2026
