import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  AuthService() {
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final userEmail = prefs.getString('userEmail');
      
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

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, this would call Firebase Auth or your backend
      // For now, create a mock user with 7-day trial
      final now = DateTime.now();
      final trialEndDate = now.add(const Duration(days: 7));
      
      _currentUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
        createdAt: now,
        isTrialActive: true,
        trialEndDate: trialEndDate,
        subscriptionStatus: SubscriptionStatus.trial,
      );

      await _saveUserToStorage(_currentUser!);
      
      _isLoading = false;
      notifyListeners();
      return true;
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

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, this would call Firebase Auth or your backend
      // For now, create a mock user
      _currentUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        createdAt: DateTime.now(),
        subscriptionStatus: SubscriptionStatus.free,
      );

      await _saveUserToStorage(_currentUser!);
      
      _isLoading = false;
      notifyListeners();
      return true;
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

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, this would use GoogleSignIn package
      final now = DateTime.now();
      _currentUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: 'user@google.com',
        name: 'Google User',
        createdAt: now,
        isTrialActive: true,
        trialEndDate: now.add(const Duration(days: 7)),
        subscriptionStatus: SubscriptionStatus.trial,
      );

      await _saveUserToStorage(_currentUser!);
      
      _isLoading = false;
      notifyListeners();
      return true;
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

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, this would call Firebase Auth or your backend
      
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
