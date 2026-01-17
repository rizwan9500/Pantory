import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../models/subscription_plan.dart';

class SubscriptionService extends ChangeNotifier {
  Razorpay? _razorpay;
  bool _isProcessing = false;
  String? _lastError;

  bool get isProcessing => _isProcessing;
  String? get lastError => _lastError;

  SubscriptionService() {
    _initializeRazorpay();
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _isProcessing = false;
    _lastError = null;
    notifyListeners();
    
    debugPrint('Payment Success: ${response.paymentId}');
    // In a real app, verify payment with your backend here
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _isProcessing = false;
    _lastError = response.message;
    notifyListeners();
    
    debugPrint('Payment Error: ${response.code} - ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet: ${response.walletName}');
  }

  Future<void> initiatePayment({
    required SubscriptionPlan plan,
    required String userEmail,
    required String userName,
    Function(String paymentId)? onSuccess,
    Function(String error)? onError,
  }) async {
    try {
      _isProcessing = true;
      _lastError = null;
      notifyListeners();

      // Convert price to paise (smallest currency unit)
      final amountInPaise = (plan.price * 100).toInt();

      var options = {
        'key': 'rzp_test_1DP5mmOlF5G5ag', // Replace with your actual Razorpay key
        'amount': amountInPaise,
        'name': 'Pantory',
        'description': plan.name,
        'prefill': {
          'contact': '',
          'email': userEmail,
        },
        'theme': {
          'color': '#4CAF50',
        },
        'notes': {
          'plan_id': plan.id,
          'user_email': userEmail,
        },
        'subscription_id': '', // Add subscription ID if using Razorpay subscriptions
      };

      _razorpay?.open(options);
    } catch (e) {
      _isProcessing = false;
      _lastError = e.toString();
      notifyListeners();
      
      if (onError != null) {
        onError(e.toString());
      }
      debugPrint('Payment initiation error: $e');
    }
  }

  List<SubscriptionPlan> getAvailablePlans() {
    return SubscriptionPlan.getAvailablePlans();
  }

  @override
  void dispose() {
    _razorpay?.clear();
    super.dispose();
  }
}
