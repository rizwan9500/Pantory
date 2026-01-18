package com.pantory.app

import android.content.Context
import android.content.pm.ApplicationInfo
import android.os.Build
import android.os.Debug
import com.scottyab.rootbeer.RootBeer
import java.io.File
import java.security.MessageDigest
import android.content.pm.PackageManager
import android.util.Log

/**
 * SecurityManager - Comprehensive security checks for Pantory app
 * 
 * Implements multiple layers of security:
 * - Root/Jailbreak detection
 * - Debugger detection
 * - Tamper detection
 * - Emulator detection
 * - Hook/Frida detection
 */
class SecurityManager(private val context: Context) {
    
    companion object {
        private const val TAG = "SecurityManager"
        private const val SECURITY_CHECK_INTERVAL = 5000L // 5 seconds
    }
    
    private val rootBeer = RootBeer(context)
    private var lastSecurityCheck = 0L
    
    /**
     * Perform comprehensive security check
     * Returns true if device is secure, false if compromised
     */
    fun performSecurityCheck(): Boolean {
        val currentTime = System.currentTimeMillis()
        
        // Rate limit security checks
        if (currentTime - lastSecurityCheck < SECURITY_CHECK_INTERVAL) {
            return true
        }
        
        lastSecurityCheck = currentTime
        
        val checks = mapOf(
            "Root Detection" to !isDeviceRooted(),
            "Debugger Detection" to !isDebuggerAttached(),
            "Tamper Detection" to !isAppTampered(),
            "Emulator Detection" to !isEmulator(),
            "Hook Detection" to !isHooked(),
            "USB Debug Detection" to !isUsbDebuggingEnabled(),
            "Developer Mode" to !isDeveloperModeEnabled()
        )
        
        val compromised = checks.filterValues { !it }
        
        if (compromised.isNotEmpty()) {
            Log.w(TAG, "Security compromised: ${compromised.keys.joinToString()}")
            return false
        }
        
        return true
    }
    
    /**
     * Layer 1-3: Root Detection (Multiple methods)
     */
    private fun isDeviceRooted(): Boolean {
        // Method 1: RootBeer library (comprehensive check)
        if (rootBeer.isRooted) {
            Log.w(TAG, "Root detected via RootBeer")
            return true
        }
        
        // Method 2: Check for common root files
        val rootFiles = arrayOf(
            "/system/app/Superuser.apk",
            "/sbin/su",
            "/system/bin/su",
            "/system/xbin/su",
            "/data/local/xbin/su",
            "/data/local/bin/su",
            "/system/sd/xbin/su",
            "/system/bin/failsafe/su",
            "/data/local/su",
            "/su/bin/su",
            "/system/xbin/daemonsu",
            "/system/etc/init.d/99SuperSUDaemon"
        )
        
        for (path in rootFiles) {
            if (File(path).exists()) {
                Log.w(TAG, "Root file detected: $path")
                return true
            }
        }
        
        // Method 3: Check for common root apps
        val rootApps = arrayOf(
            "com.noshufou.android.su",
            "com.noshufou.android.su.elite",
            "eu.chainfire.supersu",
            "com.koushikdutta.superuser",
            "com.thirdparty.superuser",
            "com.yellowes.su",
            "com.topjohnwu.magisk"
        )
        
        for (packageName in rootApps) {
            if (isPackageInstalled(packageName)) {
                Log.w(TAG, "Root app detected: $packageName")
                return true
            }
        }
        
        return false
    }
    
    /**
     * Layer 4-5: Debugger Detection (Multiple methods)
     */
    private fun isDebuggerAttached(): Boolean {
        // Method 1: Check if debugger is connected
        if (Debug.isDebuggerConnected()) {
            Log.w(TAG, "Debugger connected")
            return true
        }
        
        // Method 2: Check if waiting for debugger
        if (Debug.waitingForDebugger()) {
            Log.w(TAG, "Waiting for debugger")
            return true
        }
        
        // Method 3: Check application flags
        val isDebuggable = (context.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
        if (isDebuggable) {
            Log.w(TAG, "App is debuggable")
            return true
        }
        
        return false
    }
    
    /**
     * Layer 6-7: Tamper Detection (Signature verification)
     */
    private fun isAppTampered(): Boolean {
        try {
            // Get the app's signature
            val packageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                context.packageManager.getPackageInfo(
                    context.packageName,
                    PackageManager.GET_SIGNING_CERTIFICATES
                )
            } else {
                @Suppress("DEPRECATION")
                context.packageManager.getPackageInfo(
                    context.packageName,
                    PackageManager.GET_SIGNATURES
                )
            }
            
            val signatures = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                packageInfo.signingInfo?.apkContentsSigners
            } else {
                @Suppress("DEPRECATION")
                packageInfo.signatures
            }
            
            if (signatures == null || signatures.isEmpty()) {
                Log.w(TAG, "No signatures found - app may be tampered")
                return true
            }
            
            // In production, compare against known good signature hash
            // For now, just verify signature exists
            val signature = signatures[0]
            val md = MessageDigest.getInstance("SHA-256")
            val digest = md.digest(signature.toByteArray())
            val hexString = digest.joinToString("") { "%02x".format(it) }
            
            Log.d(TAG, "App signature hash: $hexString")
            
            // TODO: Compare against stored/expected signature hash
            // if (hexString != EXPECTED_SIGNATURE_HASH) return true
            
        } catch (e: Exception) {
            Log.e(TAG, "Error checking signature: ${e.message}")
            return true
        }
        
        return false
    }
    
    /**
     * Layer 8: Emulator Detection
     */
    private fun isEmulator(): Boolean {
        val emulatorIndicators = listOf(
            Build.FINGERPRINT.startsWith("generic"),
            Build.FINGERPRINT.startsWith("unknown"),
            Build.MODEL.contains("google_sdk"),
            Build.MODEL.contains("Emulator"),
            Build.MODEL.contains("Android SDK built for x86"),
            Build.MANUFACTURER.contains("Genymotion"),
            Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic"),
            "google_sdk" == Build.PRODUCT
        )
        
        if (emulatorIndicators.any { it }) {
            Log.w(TAG, "Emulator detected")
            return true
        }
        
        return false
    }
    
    /**
     * Layer 9-10: Hook/Frida Detection
     */
    private fun isHooked(): Boolean {
        // Check for Frida server
        val fridaPorts = arrayOf(27042, 27043)
        
        // Check for common hooking frameworks
        val hookingLibs = arrayOf(
            "frida",
            "xposed",
            "substrate",
            "YAHFA"
        )
        
        try {
            // Check loaded libraries
            val mapsFile = File("/proc/self/maps")
            if (mapsFile.exists()) {
                val content = mapsFile.readText()
                for (lib in hookingLibs) {
                    if (content.contains(lib, ignoreCase = true)) {
                        Log.w(TAG, "Hooking library detected: $lib")
                        return true
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error checking for hooks: ${e.message}")
        }
        
        // Check for Xposed
        if (isPackageInstalled("de.robv.android.xposed.installer") ||
            isPackageInstalled("com.saurik.substrate")) {
            Log.w(TAG, "Hooking framework detected")
            return true
        }
        
        return false
    }
    
    /**
     * Layer 11: USB Debugging Detection
     */
    private fun isUsbDebuggingEnabled(): Boolean {
        try {
            val adbEnabled = android.provider.Settings.Secure.getInt(
                context.contentResolver,
                android.provider.Settings.Global.ADB_ENABLED,
                0
            )
            
            if (adbEnabled == 1) {
                Log.w(TAG, "USB debugging enabled")
                return true
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error checking USB debugging: ${e.message}")
        }
        
        return false
    }
    
    /**
     * Layer 12: Developer Mode Detection
     */
    private fun isDeveloperModeEnabled(): Boolean {
        try {
            val developerMode = android.provider.Settings.Secure.getInt(
                context.contentResolver,
                android.provider.Settings.Global.DEVELOPMENT_SETTINGS_ENABLED,
                0
            )
            
            if (developerMode == 1) {
                Log.w(TAG, "Developer mode enabled")
                return true
            }
        } catch (e: Exception) {
            // Setting might not exist on all devices
            Log.d(TAG, "Could not check developer mode: ${e.message}")
        }
        
        return false
    }
    
    /**
     * Helper: Check if package is installed
     */
    private fun isPackageInstalled(packageName: String): Boolean {
        return try {
            context.packageManager.getPackageInfo(packageName, 0)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }
    
    /**
     * Get security status report
     */
    fun getSecurityReport(): Map<String, Boolean> {
        return mapOf(
            "isRooted" to isDeviceRooted(),
            "isDebuggerAttached" to isDebuggerAttached(),
            "isTampered" to isAppTampered(),
            "isEmulator" to isEmulator(),
            "isHooked" to isHooked(),
            "isUsbDebugging" to isUsbDebuggingEnabled(),
            "isDeveloperMode" to isDeveloperModeEnabled()
        )
    }
}
