import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: January 2026',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            
            _buildSection(
              'Introduction',
              'Pantory ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.',
            ),
            
            _buildSection(
              '1. Information We Collect',
              'We collect information you provide directly to us, including:\n\n• Account information (email, name, password)\n• Pantry items and related data\n• Shopping lists\n• Usage data and preferences\n• Payment information (processed securely through Razorpay)',
            ),
            
            _buildSection(
              '2. How We Use Your Information',
              'We use the information we collect to:\n\n• Provide, maintain, and improve our services\n• Process your transactions and subscriptions\n• Send you notifications about expiring items\n• Provide customer support\n• Analyze usage patterns to improve the app\n• Send you updates and marketing communications (with your consent)',
            ),
            
            _buildSection(
              '3. Data Storage',
              'Your data is primarily stored locally on your device. For Pro users with sync enabled, data is also stored securely on our servers with encryption. We use industry-standard security measures to protect your information.',
            ),
            
            _buildSection(
              '4. Third-Party Services',
              'We use third-party services that may collect information:\n\n• Firebase (authentication and analytics)\n• Razorpay (payment processing)\n• Google Sign-In (authentication)\n\nThese services have their own privacy policies and we encourage you to review them.',
            ),
            
            _buildSection(
              '5. Data Sharing',
              'We do not sell your personal information. We may share your information only in these circumstances:\n\n• With your consent\n• With service providers who assist our operations\n• To comply with legal obligations\n• To protect our rights and prevent fraud',
            ),
            
            _buildSection(
              '6. Your Rights',
              'You have the right to:\n\n• Access your personal data\n• Correct inaccurate data\n• Request deletion of your data\n• Export your data\n• Opt-out of marketing communications\n• Withdraw consent at any time',
            ),
            
            _buildSection(
              '7. Children\'s Privacy',
              'Our service is not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13.',
            ),
            
            _buildSection(
              '8. Data Retention',
              'We retain your information for as long as your account is active or as needed to provide services. You can request deletion of your account and data at any time through the app settings.',
            ),
            
            _buildSection(
              '9. Security',
              'We implement appropriate technical and organizational measures to protect your personal information. However, no method of transmission over the Internet is 100% secure.',
            ),
            
            _buildSection(
              '10. International Users',
              'Your information may be transferred to and processed in countries other than your own. By using Pantory, you consent to such transfers.',
            ),
            
            _buildSection(
              '11. Changes to This Policy',
              'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new policy on this page and updating the "Last updated" date.',
            ),
            
            _buildSection(
              '12. Contact Us',
              'If you have questions about this Privacy Policy, please contact us at:\n\nEmail: privacy@pantory.com\nSupport: support@pantory.com',
            ),
            
            const SizedBox(height: 32),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.security, color: Colors.green[700]),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Your Privacy Matters',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We take your privacy seriously and are committed to protecting your personal information. Your data belongs to you, and we will never sell it to third parties.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
