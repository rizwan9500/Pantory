import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & FAQ'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          _buildFAQItem(
            'How do I add items to my pantry?',
            'Tap the + button on the home screen, enter item details including name, category, quantity, and expiry date, then tap "Add".',
          ),
          
          _buildFAQItem(
            'How does the 7-day trial work?',
            'When you sign up, you automatically get 7 days of Pro features for free. After the trial ends, you\'ll be on the free plan unless you subscribe.',
          ),
          
          _buildFAQItem(
            'What happens when items expire?',
            'The app will show expired items with a red indicator. You can also enable notifications to get alerts before items expire.',
          ),
          
          _buildFAQItem(
            'How do I use the smart shopping list?',
            'Pro users can tap the magic wand icon on the Shopping List screen to automatically generate a list based on items that are expiring soon or already expired.',
          ),
          
          _buildFAQItem(
            'Can I sync my data across devices?',
            'Currently, data is stored locally on your device. Cross-device sync is coming soon for Pro users!',
          ),
          
          _buildFAQItem(
            'How do I cancel my subscription?',
            'Go to Settings > Manage Subscription > Cancel Subscription. You\'ll continue to have Pro access until the end of your billing period.',
          ),
          
          _buildFAQItem(
            'What payment methods are supported?',
            'We support credit/debit cards, UPI, net banking, and various wallets through Razorpay.',
          ),
          
          _buildFAQItem(
            'How do I get a refund?',
            'Refund requests can be made within 7 days of purchase. Contact support@pantory.com with your order details.',
          ),
          
          _buildFAQItem(
            'What are the Pro features?',
            'Pro features include: ad-free experience, offline mode, advanced analytics, smart shopping lists, priority support, and unlimited sync across devices.',
          ),
          
          _buildFAQItem(
            'How do I export my data?',
            'Data export feature is coming soon. For now, you can contact support for manual data export.',
          ),
          
          const SizedBox(height: 32),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green),
            ),
            child: Column(
              children: [
                const Icon(Icons.contact_support, color: Colors.green, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Still need help?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Contact our support team',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // In a real app, this would open email client or chat
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Email: support@pantory.com'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.email),
                  label: const Text('Contact Support'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              answer,
              style: const TextStyle(
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
