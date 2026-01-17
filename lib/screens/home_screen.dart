import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    final isAuthenticated = authService.isAuthenticated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantory'),
        actions: [
          if (user?.isTrialActive == true)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Trial: ${user!.trialDaysRemaining} days left',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Show notifications
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(context, user),
          _buildSearchTab(context, user),
          _buildFavoritesTab(context, user),
          isAuthenticated ? const SizedBox.shrink() : _buildGuestPrompt(context),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                _showAddItemDialog(context, user);
              },
              backgroundColor: Colors.green,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildHomeTab(BuildContext context, UserModel? user) {
    final isPro = user?.isPro ?? false;
    final isFree = !isPro && !(user?.isTrialActive ?? false);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Message
            Text(
              user != null
                  ? 'Welcome back${user.name != null ? ", ${user.name}" : ""}!'
                  : 'Welcome to Pantory!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              user != null
                  ? 'Manage your pantry efficiently'
                  : 'Sign up to unlock all features',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Ad Banner (for free users)
            if (isFree) _buildAdBanner(context),
            
            // Upgrade Banner (for trial or free users)
            if (!isPro) _buildUpgradeBanner(context, user),
            
            const SizedBox(height: 24),
            
            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Items',
                    '24',
                    Icons.inventory,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Expiring Soon',
                    '3',
                    Icons.warning,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Recent Items
            const Text(
              'Recent Items',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            _buildItemCard('Milk', 'Dairy', 'Expires in 2 days', false),
            _buildItemCard('Rice', 'Grains', 'Good condition', false),
            _buildItemCard('Premium Coffee ☕', 'Beverages', 'Pro Feature', !isPro),
            
            const SizedBox(height: 24),
            
            // Ad Banner (for free users)
            if (isFree) _buildAdBanner(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTab(BuildContext context, UserModel? user) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search your pantry...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Expanded(
            child: Center(
              child: Text(
                'Search for items in your pantry',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab(BuildContext context, UserModel? user) {
    final isPro = user?.isPro ?? false;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Favorite Items',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          if (!isPro)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber),
              ),
              child: Column(
                children: [
                  const Icon(Icons.lock, size: 48, color: Colors.amber),
                  const SizedBox(height: 16),
                  const Text(
                    'Favorites is a Pro Feature',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Upgrade to Pro to save your favorite items',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/subscription');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                    ),
                    child: const Text('Upgrade Now'),
                  ),
                ],
              ),
            )
          else
            const Expanded(
              child: Center(
                child: Text(
                  'No favorite items yet',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGuestPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_outline, size: 100, color: Colors.grey),
            const SizedBox(height: 24),
            const Text(
              'Sign in to access your profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Create an account to unlock all features and start your 7-day free trial',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
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
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(String name, String category, String status, bool isLocked) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Icon(
            isLocked ? Icons.lock : Icons.inventory_2,
            color: Colors.green,
          ),
        ),
        title: Text(name),
        subtitle: Text('$category • $status'),
        trailing: isLocked
            ? IconButton(
                icon: const Icon(Icons.upgrade),
                onPressed: () {
                  Navigator.pushNamed(context, '/subscription');
                },
              )
            : IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
              ),
      ),
    );
  }

  Widget _buildAdBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.ad_units, size: 32),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Advertisement Space\nRemove ads with Pro',
              style: TextStyle(fontSize: 12),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/subscription');
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeBanner(BuildContext context, UserModel? user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber[400]!, Colors.amber[700]!],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                user?.isTrialActive == true
                    ? '${user!.trialDaysRemaining} days left in trial'
                    : 'Upgrade to Pro',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Unlock all features, remove ads, and more!',
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/subscription');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.amber[700],
            ),
            child: const Text('View Plans'),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, UserModel? user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Item'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Item Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
