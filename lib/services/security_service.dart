import 'package:flutter/services.dart';
import 'dart:io';

/// SecurityService - Flutter interface for native security features
/// 
/// Provides access to:
/// - Root/Jailbreak detection
/// - Debugger detection  
/// - Tamper detection
/// - Comprehensive security checks
class SecurityService {
  static const platform = MethodChannel('com.pantory.app/security');
  
  /// Perform comprehensive security check
  /// Returns true if device is secure, false if compromised
  static Future<bool> performSecurityCheck() async {
    if (Platform.isAndroid) {
      try {
        final bool result = await platform.invokeMethod('performSecurityCheck');
        return result;
      } on PlatformException catch (e) {
        print('Failed to perform security check: ${e.message}');
        return false;
      }
    } else if (Platform.isIOS) {
      // iOS security checks can be added here
      // For now, return true (secure) on iOS
      return true;
    }
    return true;
  }
  
  /// Get detailed security report
  /// Returns map with security check results
  static Future<Map<String, dynamic>> getSecurityReport() async {
    if (Platform.isAndroid) {
      try {
        final Map<dynamic, dynamic> result = 
            await platform.invokeMethod('getSecurityReport');
        return Map<String, dynamic>.from(result);
      } on PlatformException catch (e) {
        print('Failed to get security report: ${e.message}');
        return {};
      }
    } else if (Platform.isIOS) {
      // iOS security report can be added here
      return {'platform': 'iOS', 'status': 'Not implemented'};
    }
    return {};
  }
  
  /// Check if device is rooted/jailbroken
  static Future<bool> isDeviceCompromised() async {
    final report = await getSecurityReport();
    
    if (report.isEmpty) return false;
    
    // Check various security flags
    final isRooted = report['isRooted'] ?? false;
    final isDebugger = report['isDebuggerAttached'] ?? false;
    final isTampered = report['isTampered'] ?? false;
    final isHooked = report['isHooked'] ?? false;
    
    return isRooted || isDebugger || isTampered || isHooked;
  }
}
