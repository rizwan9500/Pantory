# Pantory App - Quick Start Guide

## Prerequisites

Before running the app, ensure you have:

1. **Flutter SDK** installed (3.0.0 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   - Verify installation: `flutter doctor`

2. **IDE Setup**
   - Android Studio (recommended) OR VS Code with Flutter extension
   - For iOS: Xcode (Mac only)

3. **Device/Emulator**
   - Android emulator or physical device
   - iOS simulator or physical device (Mac only)

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/rizwan9500/Pantory.git
cd Pantory
```

### 2. Install Dependencies

```bash
flutter pub get
```

This will install all the required packages:
- provider (state management)
- firebase_auth, firebase_core (authentication)
- razorpay_flutter (payment processing)
- shared_preferences (local storage)
- google_sign_in (Google authentication)

### 3. Configure Firebase (Optional for Full Features)

For full authentication features, set up Firebase:

1. Go to https://console.firebase.google.com
2. Create a new project named "Pantory"
3. Add an Android app:
   - Package name: `com.pantory.app`
   - Download `google-services.json`
   - Place it in `android/app/`
4. Add an iOS app:
   - Bundle ID: `com.pantory.app`
   - Download `GoogleService-Info.plist`
   - Place it in `ios/Runner/`
5. Enable Authentication methods (Email/Password, Google)

### 4. Configure Razorpay

1. Sign up at https://razorpay.com
2. Get your API keys from the Dashboard
3. Update `lib/services/subscription_service.dart`:
   ```dart
   'key': 'YOUR_RAZORPAY_KEY_ID', // Replace this
   ```

For testing, use Razorpay test mode keys.

### 5. Run the App

```bash
# Check available devices
flutter devices

# Run on Android
flutter run -d android

# Run on iOS (Mac only)
flutter run -d ios

# Run on Chrome (Web)
flutter run -d chrome
```

## Project Structure Overview

```
Pantory/
├── lib/
│   ├── main.dart                      # App entry point
│   ├── models/                        # Data models
│   │   ├── user_model.dart
│   │   └── subscription_plan.dart
│   ├── screens/                       # UI screens
│   │   ├── welcome_screen.dart
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   ├── forgot_password_screen.dart
│   │   ├── trial_info_screen.dart
│   │   ├── home_screen.dart
│   │   ├── subscription_screen.dart
│   │   ├── profile_screen.dart
│   │   └── settings_screen.dart
│   └── services/                      # Business logic
│       ├── auth_service.dart
│       └── subscription_service.dart
├── android/                           # Android configuration
├── ios/                               # iOS configuration
├── pubspec.yaml                       # Dependencies
└── README.md                          # Documentation
```

## Testing the App

### Test User Flows

1. **Sign Up Flow**
   ```
   Welcome Screen → Sign Up → Enter email/password → Trial Info Screen → Home
   ```

2. **Login Flow**
   ```
   Welcome Screen → Login → Enter credentials → Home
   ```

3. **Subscription Flow**
   ```
   Home → Upgrade Banner → Subscription Plans → Select Plan → Razorpay Payment
   ```

### Test Razorpay Payments

Use these test cards in Razorpay test mode:

- **Card Number:** 4111 1111 1111 1111
- **CVV:** Any 3 digits
- **Expiry:** Any future date
- **Name:** Any name

For UPI testing:
- **UPI ID:** success@razorpay
- **OTP:** Use any 6 digits

## Common Issues & Solutions

### Issue: "Flutter SDK not found"
**Solution:** 
```bash
export PATH="$PATH:/path/to/flutter/bin"
# Add to ~/.bashrc or ~/.zshrc for permanent
```

### Issue: "Dependencies conflict"
**Solution:**
```bash
flutter clean
flutter pub get
```

### Issue: "Android build failed"
**Solution:**
```bash
cd android
./gradlew clean
cd ..
flutter run
```

### Issue: "Razorpay not working"
**Solution:**
- Verify API key is correct
- Ensure you're using test mode keys for testing
- Check network connectivity
- Enable test mode in Razorpay Dashboard

## Features to Test

### Free User Experience
- ✅ Basic pantry management
- ✅ Expiry reminders
- ⚠️ Ad banners visible
- ❌ Pro features locked

### Trial User Experience (7 days)
- ✅ All Pro features accessible
- ✅ Trial countdown visible
- ✅ No ads
- ℹ️ Upgrade prompts still show

### Pro User Experience
- ✅ All features unlocked
- ✅ No ads
- ✅ Subscription status visible in profile
- ✅ Can manage subscription in settings

## Development Tips

### Hot Reload
While the app is running, press `r` to hot reload or `R` to hot restart.

### Debug Mode
The app runs in debug mode by default. To build for release:
```bash
flutter build apk --release      # Android
flutter build ios --release      # iOS
```

### View Logs
```bash
flutter logs
```

### Run Specific Screen
You can modify `main.dart` to change the initial route:
```dart
initialRoute: '/subscription',  // Test subscription screen directly
```

## Support

If you encounter issues:

1. Check `flutter doctor` output for setup problems
2. Review error messages in the console
3. Check the README.md for detailed documentation
4. Open an issue on GitHub

## Next Steps

After basic setup:

1. Test all user flows
2. Customize branding and colors
3. Add actual pantry items functionality
4. Implement real Firebase authentication
5. Set up production Razorpay keys
6. Test on physical devices
7. Prepare for app store submission

---

**Happy Coding! 🚀**
