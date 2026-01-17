import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/auth_service.dart';
import '../services/pantry_service.dart';
import '../models/user_model.dart';
import '../models/mood_model.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/glass_container.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  MoodType? _currentMood;
  List<MoodModel> _moodHistory = [];
  Map<String, int> _userStats = {};

  @override
  void initState() {
    super.initState();
    _loadMoodHistory();
    _loadUserStats();
  }

  Future<void> _loadMoodHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final moodHistoryJson = prefs.getStringList('mood_history') ?? [];
    setState(() {
      _moodHistory = moodHistoryJson
          .map((json) => MoodModel.fromJson(jsonDecode(json)))
          .toList();
      if (_moodHistory.isNotEmpty) {
        _currentMood = MoodType.fromString(_moodHistory.first.mood);
      }
    });
  }

  Future<void> _saveMood(MoodType mood, String? note) async {
    final moodModel = MoodModel(
      mood: mood.label,
      timestamp: DateTime.now(),
      note: note,
    );

    _moodHistory.insert(0, moodModel);
    if (_moodHistory.length > 30) {
      _moodHistory = _moodHistory.sublist(0, 30);
    }

    final prefs = await SharedPreferences.getInstance();
    final moodHistoryJson = _moodHistory
        .map((mood) => jsonEncode(mood.toJson()))
        .toList();
    await prefs.setStringList('mood_history', moodHistoryJson);

    setState(() {
      _currentMood = mood;
    });
  }

  Future<void> _loadUserStats() async {
    final pantryService = Provider.of<PantryService>(context, listen: false);
    final items = pantryService.items;
    
    setState(() {
      _userStats = {
        'totalItems': items.length,
        'categories': items.map((i) => i.category).toSet().length,
        'favorites': items.where((i) => i.isFavorite).length,
        'moodCheckins': _moodHistory.length,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            AnimatedGradientBackground(
              colors: GradientThemes.blueTheme,
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
                              'Profile',
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
                    child: Center(
                    child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_outline, size: 100, color: Colors.white),
                const SizedBox(height: 24),
                const Text(
                  'Please log in to view your profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                GlassButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text(
                    'Log In',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          AnimatedGradientBackground(
            colors: GradientThemes.blueTheme,
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
                            'Profile',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      GlassContainer(
                        padding: const EdgeInsets.all(8),
                        borderRadius: 12,
                        blur: 10,
                        opacity: 0.2,
                        child: IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: () {
                            Navigator.pushNamed(context, '/settings');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              
              // Profile Picture
              Center(
                child: GlassContainer(
                  padding: const EdgeInsets.all(4),
                  borderRadius: 64,
                  blur: 15,
                  opacity: 0.2,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    child: Text(
                      user.name?.substring(0, 1).toUpperCase() ??
                          user.email.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // User Email
              Text(
                user.email,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Mood Tracker Card
              _buildMoodTrackerCard(context),
              
              const SizedBox(height: 16),
              
              // User Statistics Card
              _buildStatisticsCard(context),
              
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
                  color: Colors.white,
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
                SizedBox(
                  width: double.infinity,
                  child: GlassButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/subscription');
                    },
                    color: Colors.amber.withOpacity(0.3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.upgrade, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Upgrade to Pro',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              SizedBox(
                width: double.infinity,
                child: GlassButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.settings, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Settings',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
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
                ),
              ],
            ),
          ),
        ],
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

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      blur: 12,
      opacity: 0.25,
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
                        color: Colors.white70,
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
                  foregroundColor: Colors.blue,
                ),
                child: const Text('View Plans'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
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
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
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

  Widget _buildMoodTrackerCard(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 16,
      blur: 12,
      opacity: 0.25,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.mood, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              const Text(
                'How are you feeling today?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_currentMood != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentMood!.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Feeling ${_currentMood!.label}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showMoodSelector(context),
              icon: const Icon(Icons.edit),
              label: Text(_currentMood == null ? 'Track Your Mood' : 'Update Mood'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (_moodHistory.isNotEmpty) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => _showMoodHistory(context),
              child: const Text(
                'View Mood History',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 16,
      blur: 12,
      opacity: 0.25,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Your Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '📦',
                  '${_userStats['totalItems'] ?? 0}',
                  'Items',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '📁',
                  '${_userStats['categories'] ?? 0}',
                  'Categories',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '⭐',
                  '${_userStats['favorites'] ?? 0}',
                  'Favorites',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '😊',
                  '${_userStats['moodCheckins'] ?? 0}',
                  'Mood Check-ins',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showMoodSelector(BuildContext context) {
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
                'How are you feeling?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ...MoodType.values.map((mood) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  onTap: () {
                    _saveMood(mood, null);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Mood tracked! Talk to AI Assistant for mood-based recipe suggestions!'),
                        action: SnackBarAction(
                          label: 'Open AI',
                          onPressed: () {
                            Navigator.pushNamed(context, '/ai-assistant');
                          },
                        ),
                      ),
                    );
                  },
                  leading: Text(
                    mood.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  title: Text(
                    mood.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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

  void _showMoodHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => GlassContainer(
          blur: 20,
          opacity: 0.3,
          borderRadius: 24,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mood History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _moodHistory.length,
                    itemBuilder: (context, index) {
                      final mood = _moodHistory[index];
                      final moodType = MoodType.fromString(mood.mood);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                moodType.emoji,
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      mood.mood,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatDateTime(mood.timestamp),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return _formatDate(date);
    }
  }
}
