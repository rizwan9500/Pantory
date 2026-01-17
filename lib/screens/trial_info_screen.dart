import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class TrialInfoScreen extends StatelessWidget {
  const TrialInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Welcome to Pantory Pro'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              
              // Trophy Icon
              const Icon(
                Icons.emoji_events,
                size: 100,
                color: Colors.amber,
              ),
              
              const SizedBox(height: 32),
              
              const Text(
                '🎉 7-Day Free Trial',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                user?.isTrialActive == true
                    ? 'Your trial ends in ${user!.trialDaysRemaining} days'
                    : 'Start your free trial now!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Free Features
              const Text(
                'Free Features:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              _buildFeatureItem(
                icon: Icons.inventory,
                title: 'Basic Pantry Management',
                subtitle: 'Track your pantry items',
                isFree: true,
              ),
              
              _buildFeatureItem(
                icon: Icons.notifications,
                title: 'Expiry Reminders',
                subtitle: 'Get notified before items expire',
                isFree: true,
              ),
              
              const SizedBox(height: 24),
              
              // Pro Features
              const Text(
                'Pro Features (Try for 7 days):',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              _buildFeatureItem(
                icon: Icons.cloud_off,
                title: 'Offline Mode',
                subtitle: 'Access your pantry anytime',
                isFree: false,
              ),
              
              _buildFeatureItem(
                icon: Icons.analytics,
                title: 'Advanced Analytics',
                subtitle: 'Track usage patterns and savings',
                isFree: false,
              ),
              
              _buildFeatureItem(
                icon: Icons.shopping_cart,
                title: 'Smart Shopping Lists',
                subtitle: 'Auto-generate shopping lists',
                isFree: false,
              ),
              
              _buildFeatureItem(
                icon: Icons.block,
                title: 'No Ads',
                subtitle: 'Enjoy ad-free experience',
                isFree: false,
              ),
              
              const Spacer(),
              
              // Get Started Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Skip Button
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: const Text('Skip'),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isFree,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isFree ? Colors.grey[200] : Colors.amber[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isFree ? Colors.grey[700] : Colors.amber[700],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (!isFree) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
