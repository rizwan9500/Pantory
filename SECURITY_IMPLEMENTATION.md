# Pantory Security Implementation

This document details the comprehensive security measures implemented in the Pantory app to prevent unauthorized modifications, reverse engineering, and security breaches.

## Overview

Pantory implements **12 layers of client-side security** across Android and iOS platforms:

### Android Security Layers (12 Layers)

#### Layer 1-3: Root Detection (Triple Method)
1. **RootBeer Library**: Comprehensive root detection using industry-standard library
2. **File System Check**: Scans for common root binaries and files (su, Superuser.apk, Magisk, etc.)
3. **Package Check**: Detects root management apps (SuperSU, Magisk, Xposed, etc.)

#### Layer 4-5: Debugger Detection (Dual Method)
4. **Runtime Debugger Check**: Detects if debugger is actively connected
5. **Debug Flag Check**: Validates app wasn't built with debug flags

#### Layer 6-7: Tamper Detection (Signature Verification)
6. **Signature Validation**: Verifies app signature hasn't been modified
7. **Hash Verification**: SHA-256 hash check of app signature

#### Layer 8: Emulator Detection
8. **Environment Check**: Detects Android emulators and virtual devices

#### Layer 9-10: Hook/Framework Detection
9. **Library Scanning**: Detects Frida, Xposed, Substrate hooking frameworks
10. **Process Inspection**: Checks loaded libraries for hooking tools

#### Layer 11: USB Debugging Detection
11. **ADB Check**: Detects if USB debugging is enabled

#### Layer 12: Developer Mode Detection
12. **System Settings Check**: Detects if developer options are enabled

### iOS Security Layers (Certificate Pinning)

- **Certificate Pinning**: Prevents man-in-the-middle attacks via network security configuration
- **Cleartext Traffic Prevention**: Blocks unencrypted HTTP traffic
- **Domain-Specific Pinning**: Configured for Supabase, Razorpay, and custom APIs

## Implementation Details

### Android Native Security (Kotlin)

**File**: `android/app/src/main/kotlin/com/pantory/app/SecurityManager.kt`

The `SecurityManager` class implements all 12 security layers:

```kotlin
val securityManager = SecurityManager(context)
val isSecure = securityManager.performSecurityCheck()
```

Features:
- Rate-limited security checks (every 5 seconds)
- Comprehensive logging for security events
- Detailed security report generation

**File**: `android/app/src/main/kotlin/com/pantory/app/MainActivity.kt`

Integration points:
- Security check on app startup
- Security check on app resume
- Method channel for Flutter communication
- User notification on security violations

### Flutter Security Service

**File**: `lib/services/security_service.dart`

Provides Flutter interface to native security features:

```dart
// Perform security check
bool isSecure = await SecurityService.performSecurityCheck();

// Get detailed report
Map<String, dynamic> report = await SecurityService.getSecurityReport();

// Quick compromise check
bool isCompromised = await SecurityService.isDeviceCompromised();
```

### Network Security (Certificate Pinning)

**File**: `android/app/src/main/res/xml/network_security_config.xml`

Configuration:
- Disables cleartext (HTTP) traffic
- Prepared for certificate pinning (pins need to be added)
- Domain-specific configurations for:
  - Supabase (`supabase.co`)
  - Razorpay (`razorpay.com`)
  - Custom backend domains

**Configuration in AndroidManifest.xml**:
```xml
android:networkSecurityConfig="@xml/network_security_config"
android:allowBackup="false"
```

### Dependencies

**File**: `android/app/build.gradle`

```gradle
dependencies {
    implementation "androidx.security:security-crypto:1.1.0-alpha06"
    implementation "com.scottyab:rootbeer-lib:0.1.0"
}
```

- **androidx.security:security-crypto**: Encrypted shared preferences
- **com.scottyab:rootbeer-lib**: Comprehensive root detection

## Usage Guide

### 1. Basic Integration in Flutter

Add to your app initialization:

```dart
import 'package:pantory/services/security_service.dart';

// In main app widget or splash screen
Future<void> initApp() async {
  final isSecure = await SecurityService.performSecurityCheck();
  
  if (!isSecure) {
    // Handle insecure device
    // Options:
    // 1. Show warning dialog
    // 2. Restrict sensitive features
    // 3. Force logout
    // 4. Close app
    showSecurityWarning();
  }
}
```

### 2. Periodic Security Checks

Add to critical screens (payment, profile, etc.):

```dart
@override
void initState() {
  super.initState();
  _performSecurityCheck();
}

Future<void> _performSecurityCheck() async {
  final isCompromised = await SecurityService.isDeviceCompromised();
  
  if (isCompromised) {
    Navigator.of(context).pushReplacementNamed('/security-warning');
  }
}
```

### 3. Security Report Display (Admin/Debug)

```dart
Future<void> showSecurityReport() async {
  final report = await SecurityService.getSecurityReport();
  
  print('Security Report:');
  report.forEach((key, value) {
    print('$key: $value');
  });
}
```

## Certificate Pinning Setup

### Step 1: Generate Certificate Pins

For each domain (Supabase, Razorpay, custom backend):

```bash
# Get certificate pin
openssl s_client -servername yourdomain.com -connect yourdomain.com:443 \
  | openssl x509 -pubkey -noout \
  | openssl rsa -pubin -outform der \
  | openssl dgst -sha256 -binary \
  | openssl enc -base64
```

### Step 2: Update network_security_config.xml

Replace placeholder pins:

```xml
<domain-config cleartextTrafficPermitted="false">
    <domain includeSubdomains="true">supabase.co</domain>
    <pin-set expiration="2027-01-01">
        <pin digest="SHA-256">YOUR_PRIMARY_PIN_HERE=</pin>
        <pin digest="SHA-256">YOUR_BACKUP_PIN_HERE=</pin>
    </pin-set>
</domain-config>
```

### Step 3: Test Certificate Pinning

```bash
# Should succeed with valid certificate
flutter run

# Should fail with invalid certificate (MITM attempt)
# Test using proxy with custom certificate
```

## Production Checklist

### Before Release:

- [ ] Generate and add certificate pins for all domains
- [ ] Remove debug-overrides from network_security_config.xml
- [ ] Store expected signature hash for tamper detection
- [ ] Test on rooted device to verify detection works
- [ ] Test with Frida/Xposed to verify hook detection
- [ ] Test certificate pinning with proxy
- [ ] Implement backend logging for security events
- [ ] Add rate limiting for security check failures
- [ ] Configure proper error handling for security violations

### Security Response Strategy:

1. **Detection**: App detects compromise
2. **Logging**: Log event locally and to backend (if available)
3. **User Notification**: Show warning message
4. **Restriction**: Limit sensitive features:
   - Disable payments
   - Disable data sync
   - Require re-authentication
5. **Reporting**: Send anonymous report to backend

## Limitations & Caveats

### What This Security CANNOT Prevent:

1. **Determined Attackers**: Users with root/jailbreak access can bypass client-side checks
2. **OS-Level Exploits**: Cannot protect against operating system vulnerabilities
3. **Physical Access**: Cannot prevent modifications if attacker has device access
4. **Backend Attacks**: Client-side security doesn't protect backend services

### What This Security CAN Prevent:

1. **Casual Modification**: Stops most users from modifying the app
2. **Script Kiddies**: Prevents automated tools and simple hacks
3. **MITM Attacks**: Certificate pinning prevents network interception
4. **App Cloning**: Signature verification prevents simple repackaging
5. **Emulator Testing**: Detects attempts to reverse engineer in emulators
6. **Runtime Manipulation**: Detects debugging and hooking frameworks

## Best Practices

### 1. Defense in Depth
- Never rely on single security layer
- Combine client-side and server-side security
- Implement server-side validation for all critical operations

### 2. Server-Side Verification
```dart
// Always verify on backend
final deviceInfo = await SecurityService.getSecurityReport();
await api.verifyDeviceSecurity(deviceInfo); // Backend validates
```

### 3. Graceful Degradation
- Don't completely block users on minor violations
- Implement tiered restrictions based on threat level
- Provide user education about security

### 4. Regular Updates
- Update certificate pins before expiration
- Update security library dependencies
- Monitor for new attack vectors

### 5. Analytics & Monitoring
- Log security events (without PII)
- Monitor detection rates
- Analyze false positive rates
- Track security trends

## Security Updates

### RootBeer Library
- Version: 0.1.0
- Last Updated: Check regularly for updates
- Update Command: `gradle dependency update`

### Security Crypto
- Version: 1.1.0-alpha06
- Monitor: AndroidX security releases

### Certificate Pins
- Expiration: Set in network_security_config.xml
- Renewal: Update before expiration
- Backup Pins: Always include backup pin

## Troubleshooting

### Security Check Always Fails

**Issue**: `performSecurityCheck()` returns false on legitimate devices

**Solutions**:
1. Check logcat for specific security layer triggering
2. Disable individual checks for testing
3. Verify not running on development build

### Certificate Pinning Breaks Network

**Issue**: Network requests fail after adding pins

**Solutions**:
1. Verify pin format is correct (base64 SHA-256)
2. Check pin expiration date
3. Ensure domain matches exactly
4. Test with debug-overrides enabled first

### Performance Impact

**Issue**: Security checks slow down app

**Solutions**:
1. Rate limiting is built-in (5-second interval)
2. Run checks asynchronously
3. Cache results for short periods
4. Optimize check frequency based on screen sensitivity

## Support

For security concerns or questions:
- Email: security@pantory.com
- GitHub Issues: [Pantory Security Issues](https://github.com/rizwan9500/Pantory/issues)

---

**Last Updated**: January 2026  
**Security Version**: 1.0  
**Status**: Production Ready (after certificate pin configuration)
