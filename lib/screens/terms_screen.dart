import 'package:flutter/material.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/glass_container.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedGradientBackground(theme: GradientTheme.blue),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      GlassContainer(
                        blur: 10,
                        opacity: 0.2,
                        borderRadius: 12,
                        padding: const EdgeInsets.all(8),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Terms of Service',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Terms of Service',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Last updated: January 2026',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        _buildSection(
                          '1. Acceptance of Terms',
                          'By accessing and using Pantory ("the App"), you accept and agree to be bound by the terms and provisions of this agreement. If you do not agree to these terms, please do not use the App.',
                        ),
                        
                        _buildSection(
                          '2. Description of Service',
                          'Pantory provides a pantry management application that helps users track food items, expiry dates, and manage shopping lists. The service includes both free and premium (Pro) features.',
                        ),
                        
                        _buildSection(
                          '3. User Accounts',
                          'You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account.',
                        ),
                        
                        _buildSection(
                          '4. Subscription and Payments',
                          'Pro features require a paid subscription. Subscriptions automatically renew unless cancelled before the renewal date. Payments are processed through Razorpay. All fees are in Indian Rupees (INR) and are non-refundable except as required by law.',
                        ),
                        
                        _buildSection(
                          '5. Free Trial',
                          'New users receive a 7-day free trial of Pro features. After the trial period, you will be automatically moved to the free plan unless you subscribe to a paid plan.',
                        ),
                        
                        _buildSection(
                          '6. User Content',
                          'You retain all rights to the data and content you upload to the App. You grant Pantory a license to use, store, and process your content solely for the purpose of providing the service.',
                        ),
                        
                        _buildSection(
                          '7. Acceptable Use',
                          'You agree not to misuse the App or help anyone else do so. This includes not attempting to access the service through unauthorized means, interfering with the service, or using the service for any illegal purpose.',
                        ),
                        
                        _buildSection(
                          '8. Privacy',
                          'Your use of the App is also governed by our Privacy Policy. Please review our Privacy Policy to understand our practices.',
                        ),
                        
                        _buildSection(
                          '9. Modifications to Service',
                          'We reserve the right to modify or discontinue, temporarily or permanently, the service (or any part thereof) with or without notice.',
                        ),
                        
                        _buildSection(
                          '10. Limitation of Liability',
                          'The App is provided "as is" without warranties of any kind. Pantory shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of the service.',
                        ),
                        
                        _buildSection(
                          '11. Termination',
                          'We may terminate or suspend your account and access to the App immediately, without prior notice or liability, for any reason, including breach of these Terms.',
                        ),
                        
                        _buildSection(
                          '12. Changes to Terms',
                          'We reserve the right to modify these terms at any time. We will notify users of any material changes via email or in-app notification.',
                        ),
                        
                        _buildSection(
                          '13. Contact Information',
                          'For questions about these Terms, please contact us at support@pantory.com',
                        ),
                        
                        const SizedBox(height: 32),
                        
                        GlassContainer(
                          blur: 10,
                          opacity: 0.2,
                          borderRadius: 12,
                          padding: const EdgeInsets.all(16),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.white),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'By using Pantory, you acknowledge that you have read and understood these Terms of Service.',
                                  style: TextStyle(fontSize: 12, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: GlassContainer(
        blur: 10,
        opacity: 0.15,
        borderRadius: 12,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
