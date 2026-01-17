import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_outline, size: 100, color: Colors.grey),
                const SizedBox(height: 24),
                const Text(
                  'Please log in to view your profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Log In'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              
              // Profile Picture
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.green[100],
                  child: Text(
                    user.name?.substring(0, 1).toUpperCase() ??
                        user.email.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // User Name
              Text(
                user.name ?? user.email.split('@')[0],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // User Email
              Text(
                user.email,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Subscription Status Card
              _buildSubscriptionCard(context, user),
              
              const SizedBox(height: 24),
              
              // Account Information
              const Text(
                'Account Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              _buildInfoTile(
                icon: Icons.calendar_today,
                title: 'Member Since',
                subtitle: _formatDate(user.createdAt),
              ),
              
              _buildInfoTile(
                icon: Icons.workspace_premium,
                title: 'Subscription',
                subtitle: _getSubscriptionStatusText(user),
              ),
              
              if (user.isTrialActive)
                _buildInfoTile(
                  icon: Icons.access_time,
                  title: 'Trial Period',
                  subtitle: '${user.trialDaysRemaining} days remaining',
                ),
              
              const SizedBox(height: 24),
              
              // Action Buttons
              if (!user.isPro) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/subscription');
                  },
                  icon: const Icon(Icons.upgrade),
                  label: const Text('Upgrade to Pro'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
                icon: const Icon(Icons.settings),
                label: const Text('Settings'),
              ),
              
              const SizedBox(height: 16),
              
              OutlinedButton.icon(
                onPressed: () => _handleLogout(context, authService),
                icon: const Icon(Icons.logout),
                label: const Text('Log Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context, UserModel user) {
    Color statusColor;
    IconData statusIcon;
    String statusTitle;
    String statusSubtitle;

    if (user.isPro) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusTitle = 'Pro Member';
      statusSubtitle = 'You have full access to all features';
    } else if (user.isTrialActive) {
      statusColor = Colors.amber;
      statusIcon = Icons.schedule;
      statusTitle = 'Trial Active';
      statusSubtitle = '${user.trialDaysRemaining} days remaining';
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.person;
      statusTitle = 'Free Plan';
      statusSubtitle = 'Upgrade to unlock Pro features';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [statusColor.withOpacity(0.7), statusColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(statusIcon, size: 48, color: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        statusSubtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!user.isPro) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/subscription');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: statusColor,
                  ),
                  child: const Text('View Plans'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getSubscriptionStatusText(UserModel user) {
    if (user.isPro) {
      return 'Pro ${user.currentPlan != null ? "- ${user.currentPlan}" : ""}';
    } else if (user.isTrialActive) {
      return 'Trial (${user.trialDaysRemaining} days left)';
    } else {
      return 'Free';
    }
  }

  Future<void> _handleLogout(BuildContext context, AuthService authService) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await authService.logout();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    }
  }
}
