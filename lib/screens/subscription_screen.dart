import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/subscription_service.dart';
import '../models/subscription_plan.dart';
import '../models/user_model.dart';
import 'payment_screen.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subscriptionService = Provider.of<SubscriptionService>(context);
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    final plans = subscriptionService.getAvailablePlans();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Plan'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const Text(
                'Upgrade to Pro',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              if (user?.isTrialActive == true)
                Text(
                  'Trial ends in ${user!.trialDaysRemaining} days',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              
              const SizedBox(height: 32),
              
              // Benefits List
              _buildBenefitItem('Remove all ads'),
              _buildBenefitItem('Offline mode access'),
              _buildBenefitItem('Advanced analytics'),
              _buildBenefitItem('Smart shopping lists'),
              _buildBenefitItem('Priority customer support'),
              _buildBenefitItem('Sync across unlimited devices'),
              
              const SizedBox(height: 32),
              
              // Subscription Plans
              ...plans.map((plan) => _buildPlanCard(
                context,
                plan,
                subscriptionService,
                authService,
                user,
              )),
              
              const SizedBox(height: 16),
              
              // Payment Methods Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Secure Payment Methods',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildPaymentMethod(Icons.credit_card, 'Card'),
                          _buildPaymentMethod(Icons.account_balance, 'UPI'),
                          _buildPaymentMethod(Icons.qr_code, 'QR'),
                          _buildPaymentMethod(Icons.account_balance_wallet, 'Wallet'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Powered by Razorpay',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Terms and Conditions
              const Text(
                'By subscribing, you agree to our Terms of Service and Privacy Policy. Subscription will auto-renew unless cancelled.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    SubscriptionPlan plan,
    SubscriptionService subscriptionService,
    AuthService authService,
    UserModel? user,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: plan.isPopular ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: plan.isPopular
            ? const BorderSide(color: Colors.amber, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Popular Badge
            if (plan.isPopular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'MOST POPULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            
            const SizedBox(height: 12),
            
            // Plan Name
            Text(
              plan.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Plan Description
            Text(
              plan.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  plan.priceText,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    '/ ${plan.durationText}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            
            if (plan.duration.inDays > 30)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  plan.pricePerMonth,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            const Divider(),
            
            const SizedBox(height: 16),
            
            // Features
            ...plan.features.map((feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.check, color: Colors.green, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )),
            
            const SizedBox(height: 16),
            
            // Subscribe Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: subscriptionService.isProcessing
                    ? null
                    : () {
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please log in to subscribe'),
                            ),
                          );
                          return;
                        }

                        // Navigate to payment screen with UPI/QR options
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentScreen(plan: plan),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: plan.isPopular ? Colors.amber : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: subscriptionService.isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        user?.currentPlan == plan.id
                            ? 'Current Plan'
                            : 'Subscribe Now',
                        style: const TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.green),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Future<void> _handleSubscribe(
    BuildContext context,
    SubscriptionPlan plan,
    SubscriptionService subscriptionService,
    AuthService authService,
    UserModel? user,
  ) async {
    if (user == null) {
      // Prompt user to sign up first
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sign Up Required'),
          content: const Text('Please sign up or log in to subscribe to a plan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/signup');
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      );
      return;
    }

    try {
      await subscriptionService.initiatePayment(
        plan: plan,
        userEmail: user.email,
        userName: user.name ?? user.email,
        onSuccess: (paymentId) {
          // Update user subscription status
          authService.updateSubscription(plan.id, SubscriptionStatus.active);
          
          if (!context.mounted) return;
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully subscribed to ${plan.name}!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate to home
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        },
        onError: (error) {
          if (!context.mounted) return;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment failed: $error'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
