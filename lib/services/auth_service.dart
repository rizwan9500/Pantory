import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  
  // Supabase client
  final SupabaseClient _supabase = Supabase.instance.client;

  AuthService() {
    _loadUserFromStorage();
    _setupAuthListener();
  }
  
  // Listen to Supabase auth state changes
  void _setupAuthListener() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        _syncUserFromSupabase(session.user);
      } else if (_currentUser != null) {
        // User logged out
        logout();
      }
    });
  }

  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final userEmail = prefs.getString('userEmail');
      
      // Check if there's an active Supabase session
      final session = _supabase.auth.currentSession;
      if (session != null) {
        await _syncUserFromSupabase(session.user);
        return;
      }
      
      if (userId != null && userEmail != null) {
        final isTrialActive = prefs.getBool('isTrialActive') ?? false;
        final trialEndDateStr = prefs.getString('trialEndDate');
        final subscriptionStatusStr = prefs.getString('subscriptionStatus');
        
        _currentUser = UserModel(
          id: userId,
          email: userEmail,
          name: prefs.getString('userName'),
          createdAt: DateTime.parse(prefs.getString('createdAt') ?? DateTime.now().toIso8601String()),
          isTrialActive: isTrialActive,
          trialEndDate: trialEndDateStr != null ? DateTime.parse(trialEndDateStr) : null,
          subscriptionStatus: SubscriptionStatus.values.firstWhere(
            (e) => e.toString() == subscriptionStatusStr,
            orElse: () => SubscriptionStatus.free,
          ),
          currentPlan: prefs.getString('currentPlan'),
        );
        
        // Check if trial has expired
        if (_currentUser!.isTrialActive && _currentUser!.trialDaysRemaining <= 0) {
          await _expireTrial();
        }
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user from storage: $e');
    }
  }
  
  // Sync user data from Supabase auth to local storage
  Future<void> _syncUserFromSupabase(User supabaseUser) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if this is a new user (no local data)
      final existingUserId = prefs.getString('userId');
      final isNewUser = existingUserId != supabaseUser.id;
      
      // For new users, activate 7-day trial
      final now = DateTime.now();
      final trialEndDate = isNewUser ? now.add(const Duration(days: 7)) : null;
      
      _currentUser = UserModel(
        id: supabaseUser.id,
        email: supabaseUser.email ?? '',
        name: supabaseUser.userMetadata?['name'] as String? ?? 
              supabaseUser.userMetadata?['full_name'] as String?,
        createdAt: isNewUser ? now : DateTime.parse(prefs.getString('createdAt') ?? now.toIso8601String()),
        isTrialActive: isNewUser ? true : (prefs.getBool('isTrialActive') ?? false),
        trialEndDate: isNewUser ? trialEndDate : 
                     (prefs.getString('trialEndDate') != null ? 
                      DateTime.parse(prefs.getString('trialEndDate')!) : null),
        subscriptionStatus: isNewUser ? SubscriptionStatus.trial :
                           SubscriptionStatus.values.firstWhere(
                             (e) => e.toString() == prefs.getString('subscriptionStatus'),
                             orElse: () => SubscriptionStatus.free,
                           ),
        currentPlan: prefs.getString('currentPlan'),
      );
      
      await _saveUserToStorage(_currentUser!);
      notifyListeners();
    } catch (e) {
      debugPrint('Error syncing user from Supabase: $e');
    }
  }

  Future<void> _saveUserToStorage(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', user.id);
      await prefs.setString('userEmail', user.email);
      if (user.name != null) {
        await prefs.setString('userName', user.name!);
      }
      await prefs.setString('createdAt', user.createdAt.toIso8601String());
      await prefs.setBool('isTrialActive', user.isTrialActive);
      if (user.trialEndDate != null) {
        await prefs.setString('trialEndDate', user.trialEndDate!.toIso8601String());
      }
      await prefs.setString('subscriptionStatus', user.subscriptionStatus.toString());
      if (user.currentPlan != null) {
        await prefs.setString('currentPlan', user.currentPlan!);
      }
    } catch (e) {
      debugPrint('Error saving user to storage: $e');
    }
  }

  Future<bool> signUp(String email, String password, {String? name}) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Sign up with Supabase
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: name != null ? {'name': name} : null,
      );

      if (response.user != null) {
        await _syncUserFromSupabase(response.user!);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Sign up error: $e');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Login with Supabase
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _syncUserFromSupabase(response.user!);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Sign in with Google using Supabase
      final response = await _supabase.auth.signInWithOAuth(
        Provider.google,
        redirectTo: 'io.supabase.pantory://login-callback/',
      );

      // OAuth flow will redirect, so we return true here
      // The actual auth state change will be handled by the listener
      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Google login error: $e');
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Send password reset email via Supabase
      await _supabase.auth.resetPasswordForEmail(email);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Reset password error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      // Sign out from Supabase
      await _supabase.auth.signOut();
      
      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  Future<void> _expireTrial() async {
    if (_currentUser == null) return;
    
    _currentUser = _currentUser!.copyWith(
      isTrialActive: false,
      subscriptionStatus: SubscriptionStatus.free,
    );
    
    await _saveUserToStorage(_currentUser!);
    notifyListeners();
  }

  Future<void> updateSubscription(String planId, SubscriptionStatus status) async {
    if (_currentUser == null) return;
    
    _currentUser = _currentUser!.copyWith(
      subscriptionStatus: status,
      currentPlan: planId,
      isTrialActive: false,
    );
    
    await _saveUserToStorage(_currentUser!);
    notifyListeners();
  }

  bool get isFirstTimeUser {
    return _currentUser?.createdAt != null &&
        DateTime.now().difference(_currentUser!.createdAt).inMinutes < 5;
  }
}
