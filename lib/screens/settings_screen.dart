import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/glass_container.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _darkMode = false;
  bool _aiEnabled = true;
  bool _moodTracking = true;
  String _language = 'English';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load settings from SharedPreferences
    // For now, using default values
  }

  Future<void> _saveSettings() async {
    // Save settings to SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          AnimatedGradientBackground(
            colors: GradientThemes.tealTheme,
            child: const SizedBox.expand(),
          ),
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      GlassContainer(
                        padding: const EdgeInsets.all(8),
                        borderRadius: 12,
                        blur: 10,
                        opacity: 0.2,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Settings',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 56),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
          // App Settings Section
          _buildSectionHeader('App Settings'),
          
          _buildGlassSwitchTile(
            title: 'Push Notifications',
            subtitle: 'Receive notifications about expiring items',
            value: _notificationsEnabled,
            icon: Icons.notifications,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          
          _buildGlassSwitchTile(
            title: 'Email Notifications',
            subtitle: 'Receive email updates',
            value: _emailNotifications,
            icon: Icons.email,
            onChanged: (value) {
              setState(() {
                _emailNotifications = value;
              });
            },
          ),
          
          _buildGlassSwitchTile(
            title: 'Dark Mode',
            subtitle: 'Use dark theme',
            value: _darkMode,
            icon: Icons.dark_mode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dark mode coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // AI Assistant Section
          _buildSectionHeader('AI Assistant'),
          
          _buildGlassSwitchTile(
            title: 'Enable AI Features',
            subtitle: 'AI-powered pantry assistant',
            value: _aiEnabled,
            icon: Icons.smart_toy,
            onChanged: (value) {
              setState(() {
                _aiEnabled = value;
              });
              _saveSettings();
            },
          ),
          
          _buildGlassSwitchTile(
            title: 'Mood Tracking',
            subtitle: 'Track mood for personalized suggestions',
            value: _moodTracking,
            icon: Icons.mood,
            onChanged: (value) {
              setState(() {
                _moodTracking = value;
              });
              _saveSettings();
            },
          ),
          
          _buildGlassTile(
            icon: Icons.chat,
            title: 'Open AI Assistant',
            subtitle: 'Chat with your AI friend',
            onTap: () {
              Navigator.pushNamed(context, '/ai-assistant');
            },
          ),
          
          const SizedBox(height: 16),
          
          // Personalization Section
          _buildSectionHeader('Personalization'),
          
          _buildGlassTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: _language,
            onTap: () {
              _showLanguageSelector(context);
            },
          ),
          
          _buildGlassTile(
            icon: Icons.color_lens,
            title: 'Theme Color',
            subtitle: 'Customize app appearance',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Theme customization coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Data Management Section
          _buildSectionHeader('Data Management'),
          
          _buildGlassTile(
            icon: Icons.download,
            title: 'Export Data',
            subtitle: 'Download your pantry data',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data export coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          
          _buildGlassTile(
            icon: Icons.upload,
            title: 'Import Data',
            subtitle: 'Restore from backup',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data import coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Subscription Section
          _buildSectionHeader('Subscription'),
          
          if (user != null) ...[
            _buildGlassTile(
              icon: Icons.workspace_premium,
              title: 'Manage Subscription',
              subtitle: user.isPro
                  ? 'Pro Member'
                  : user.isTrialActive
                      ? 'Trial Active (${user.trialDaysRemaining} days left)'
                      : 'Free Plan',
              onTap: () {
                Navigator.pushNamed(context, '/subscription');
              },
            ),
            
            if (user.isPro)
              _buildGlassTile(
                icon: Icons.receipt,
                title: 'Billing History',
                subtitle: 'View past invoices',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Billing history coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            
            if (user.isPro)
              _buildGlassTile(
                icon: Icons.cancel,
                iconColor: Colors.red,
                title: 'Cancel Subscription',
                subtitle: 'End your subscription',
                onTap: () => _showCancelSubscriptionDialog(context),
              ),
          ],
          
          const SizedBox(height: 16),
          
          // Account Section
          _buildSectionHeader('Account'),
          
          _buildGlassTile(
            icon: Icons.person,
            title: 'Edit Profile',
            subtitle: 'Update your personal information',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit profile coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          
          _buildGlassTile(
            icon: Icons.lock,
            title: 'Change Password',
            subtitle: 'Update your password',
            onTap: () {
              Navigator.pushNamed(context, '/forgot-password');
            },
          ),
          
          _buildGlassTile(
            icon: Icons.delete_forever,
            iconColor: Colors.red,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account',
            onTap: () => _showDeleteAccountDialog(context),
          ),
          
          const SizedBox(height: 16),
          
          // Support Section
          _buildSectionHeader('Support'),
          
          _buildGlassTile(
            icon: Icons.help,
            title: 'Help & FAQ',
            onTap: () {
              Navigator.pushNamed(context, '/help');
            },
          ),
          
          _buildGlassTile(
            icon: Icons.contact_support,
            title: 'Contact Support',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Support email: support@pantory.com'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),
          
          _buildGlassTile(
            icon: Icons.star,
            title: 'Rate the App',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thanks for your support!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Legal Section
          _buildSectionHeader('Legal'),
          
          _buildGlassTile(
            icon: Icons.description,
            title: 'Terms of Service',
            onTap: () {
              Navigator.pushNamed(context, '/terms');
            },
          ),
          
          _buildGlassTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            onTap: () {
              Navigator.pushNamed(context, '/privacy');
            },
          ),
          
          const SizedBox(height: 16),
          
          // About Section
          _buildSectionHeader('About'),
          
          GlassContainer(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 12),
            borderRadius: 12,
            blur: 10,
            opacity: 0.2,
            child: Row(
              children: const [
                Icon(Icons.info, color: Colors.white),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Version',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '1.0.0',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          _buildGlassTile(
            icon: Icons.code,
            title: 'Open Source Licenses',
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: 'Pantory',
                applicationVersion: '1.0.0',
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Logout Button
          if (user != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: GlassButton(
                onPressed: () => _handleLogout(context, authService),
                color: Colors.red.withOpacity(0.2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.logout, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Log Out',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 24),
        ],
      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildGlassTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      borderRadius: 12,
      blur: 10,
      opacity: 0.2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      borderRadius: 12,
      blur: 10,
      opacity: 0.2,
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Future<void> _showCancelSubscriptionDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text(
          'Are you sure you want to cancel your subscription? You will lose access to Pro features at the end of your current billing period.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Subscription'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Subscription cancellation coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Cancel Subscription'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action is permanent and cannot be undone. All your data will be deleted. Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
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

  void _showLanguageSelector(BuildContext context) {
    final languages = ['English', 'Spanish', 'French', 'German', 'Hindi', 'Chinese', 'Japanese'];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        blur: 20,
        opacity: 0.3,
        borderRadius: 24,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Language',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...languages.map((lang) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  onTap: () {
                    setState(() {
                      _language = lang;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Language set to $lang'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  title: Text(
                    lang,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  trailing: _language == lang
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                  tileColor: Colors.white.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
