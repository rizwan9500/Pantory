import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/glass_container.dart';

class TrialInfoScreen extends StatelessWidget {
  const TrialInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      body: Stack(
        children: [
          const AnimatedGradientBackground(
            theme: GradientTheme.orange,
            child: SizedBox.expand(),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  
                  GlassContainer(
                    blur: 15,
                    opacity: 0.2,
                    borderRadius: 80,
                    padding: const EdgeInsets.all(20),
                    child: const Icon(
                      Icons.emoji_events,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  const Text(
                    '🎉 7-Day Free Trial',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  const Text(
                    'Free Features:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                  
                  const Text(
                    'Pro Features (Try for 7 days):',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                  
                  const SizedBox(height: 32),
                  
                  GlassButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    child: const Center(
                      child: Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
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
      child: GlassContainer(
        blur: 10,
        opacity: 0.15,
        borderRadius: 12,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: isFree ? Colors.white70 : Colors.white,
              size: 32,
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
                          color: Colors.white,
                        ),
                      ),
                      if (!isFree) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
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
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
