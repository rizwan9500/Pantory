package com.pantory.app

import android.os.Bundle
import android.util.Log
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.pantory.app/security"
    private lateinit var securityManager: SecurityManager
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Initialize security manager
        securityManager = SecurityManager(this)
        
        // Perform initial security check
        performSecurityCheck()
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Set up method channel for Flutter to call security checks
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "performSecurityCheck" -> {
                    val isSecure = securityManager.performSecurityCheck()
                    result.success(isSecure)
                }
                "getSecurityReport" -> {
                    val report = securityManager.getSecurityReport()
                    result.success(report)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    override fun onResume() {
        super.onResume()
        // Perform security check when app resumes
        performSecurityCheck()
    }
    
    private fun performSecurityCheck() {
        val isSecure = securityManager.performSecurityCheck()
        
        if (!isSecure) {
            Log.w("SecurityManager", "Security check failed - device compromised")
            
            // Show warning to user
            runOnUiThread {
                Toast.makeText(
                    this,
                    "Security Warning: This device appears to be compromised",
                    Toast.LENGTH_LONG
                ).show()
            }
            
            // In production, you might want to:
            // 1. Restrict sensitive features
            // 2. Force logout
            // 3. Close the app
            // 4. Report to backend
        }
    }
}

