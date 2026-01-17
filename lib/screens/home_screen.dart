import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/pantry_service.dart';
import '../models/user_model.dart';
import '../models/pantry_item.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/glass_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final pantryService = Provider.of<PantryService>(context);
    final user = authService.currentUser;
    final isAuthenticated = authService.isAuthenticated;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Pantory', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          if (user?.isTrialActive == true)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
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
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Show notifications
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          const AnimatedGradientBackground(
            theme: GradientTheme.green,
            child: SizedBox.expand(),
          ),
          SafeArea(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _buildHomeTab(context, user, pantryService),
                _buildSearchTab(context, user, pantryService),
                _buildFavoritesTab(context, user, pantryService),
                isAuthenticated ? const SizedBox.shrink() : _buildGuestPrompt(context),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.2))),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.6),
          elevation: 0,
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
      ),
      floatingActionButton: _selectedIndex == 0
          ? GlassContainer(
              blur: 10,
              opacity: 0.2,
              borderRadius: 16,
              padding: const EdgeInsets.all(16),
              child: InkWell(
                onTap: () {
                  _showAddItemDialog(context, user);
                },
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            )
          : null,
    );
  }

  Widget _buildHomeTab(BuildContext context, UserModel? user, PantryService pantryService) {
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
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              user != null
                  ? 'Manage your pantry efficiently'
                  : 'Sign up to unlock all features',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
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
                    '${pantryService.totalItems}',
                    Icons.inventory,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Expiring Soon',
                    '${pantryService.expiringSoonCount}',
                    Icons.warning,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Quick Action Buttons
            Row(
              children: [
                Expanded(
                  child: GlassContainer(
                    blur: 10,
                    opacity: 0.15,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/shopping-list');
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Shopping List', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassContainer(
                    blur: 10,
                    opacity: 0.15,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/analytics');
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.analytics, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Analytics', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
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
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Show real items from pantry service
            if (pantryService.items.isEmpty)
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    Icon(Icons.inventory_2_outlined, size: 64, color: Colors.white.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text(
                      'No items in your pantry yet',
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    GlassContainer(
                      blur: 10,
                      opacity: 0.15,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: InkWell(
                        onTap: () async {
                          await pantryService.addSampleData();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Sample items added!')),
                            );
                          }
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Add Sample Items', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...pantryService.items.take(5).map((item) =>
                _buildItemCard(
                  item.name,
                  item.category,
                  item.expiryStatus,
                  false,
                  item.id,
                  pantryService,
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Ad Banner (for free users)
            if (isFree) _buildAdBanner(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTab(BuildContext context, UserModel? user, PantryService pantryService) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          GlassContainer(
            blur: 10,
            opacity: 0.15,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search your pantry...',
                hintStyle: TextStyle(color: Colors.white60),
                prefixIcon: Icon(Icons.search, color: Colors.white),
                border: InputBorder.none,
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {
                  // Trigger rebuild to show search results
                });
              },
              controller: _searchController,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _searchController.text.isEmpty
                ? Center(
                    child: Text(
                      'Search for items in your pantry',
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                  )
                : ListView.builder(
                    itemCount: pantryService.searchItems(_searchController.text).length,
                    itemBuilder: (context, index) {
                      final item = pantryService.searchItems(_searchController.text)[index];
                      return _buildItemCard(
                        item.name,
                        item.category,
                        item.expiryStatus,
                        false,
                        item.id,
                        pantryService,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab(BuildContext context, UserModel? user, PantryService pantryService) {
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
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          if (!isPro)
            GlassContainer(
              blur: 10,
              opacity: 0.15,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.lock, size: 48, color: Colors.white),
                  const SizedBox(height: 16),
                  const Text(
                    'Favorites is a Pro Feature',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upgrade to Pro to save your favorite items',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 16),
                  GlassContainer(
                    blur: 10,
                    opacity: 0.2,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/subscription');
                      },
                      child: const Text(
                        'Upgrade Now',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: pantryService.favoriteItems.isEmpty
                  ? Center(
                      child: Text(
                        'No favorite items yet',
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                    )
                  : ListView.builder(
                      itemCount: pantryService.favoriteItems.length,
                      itemBuilder: (context, index) {
                        final item = pantryService.favoriteItems[index];
                        return _buildItemCard(
                          item.name,
                          item.category,
                          item.expiryStatus,
                          false,
                          item.id,
                          pantryService,
                        );
                      },
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
            Icon(Icons.person_outline, size: 100, color: Colors.white.withOpacity(0.7)),
            const SizedBox(height: 24),
            const Text(
              'Sign in to access your profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Create an account to unlock all features and start your 7-day free trial',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 32),
            GlassContainer(
              blur: 10,
              opacity: 0.2,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text(
                  'Sign In',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GlassContainer(
              blur: 10,
              opacity: 0.15,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: const Text(
                  'Create Account',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return GlassContainer(
      blur: 10,
      opacity: 0.15,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(String name, String category, String status, bool isLocked, String itemId, PantryService pantryService) {
    final item = pantryService.items.firstWhere((i) => i.id == itemId, orElse: () => pantryService.items.first);
    
    return GlassContainer(
      blur: 10,
      opacity: 0.15,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: item.isExpired 
                ? Colors.red.withOpacity(0.3)
                : item.isExpiringSoon 
                    ? Colors.orange.withOpacity(0.3)
                    : Colors.green.withOpacity(0.3),
            child: Icon(
              isLocked ? Icons.lock : Icons.inventory_2,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$category • $status',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              item.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: item.isFavorite ? Colors.red[300] : Colors.white,
            ),
            onPressed: () async {
              await pantryService.toggleFavorite(itemId);
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == 'delete') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Item'),
                    content: Text('Are you sure you want to delete "$name"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                
                if (confirmed == true) {
                  await pantryService.deleteItem(itemId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$name deleted')),
                    );
                  }
                }
              } else if (value == 'edit') {
                _showEditItemDialog(context, item, pantryService);
              } else if (value == 'add_to_shopping') {
                await pantryService.addToShoppingList(
                  name: item.name,
                  category: item.category,
                  quantity: item.quantity,
                  unit: item.unit,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item.name} added to shopping list')),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'add_to_shopping', child: Text('Add to Shopping List')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdBanner(BuildContext context) {
    return GlassContainer(
      blur: 10,
      opacity: 0.15,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const Icon(Icons.ad_units, size: 32, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Advertisement Space\nRemove ads with Pro',
              style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9)),
            ),
          ),
          GlassContainer(
            blur: 10,
            opacity: 0.2,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/subscription');
              },
              child: const Text('Upgrade', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeBanner(BuildContext context, UserModel? user) {
    return GlassContainer(
      blur: 10,
      opacity: 0.2,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
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
          GlassContainer(
            blur: 10,
            opacity: 0.3,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/subscription');
              },
              child: const Text(
                'View Plans',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, UserModel? user) {
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final notesController = TextEditingController();
    String selectedCategory = PantryService.defaultCategories.first;
    String selectedUnit = PantryService.defaultUnits.first;
    DateTime? selectedExpiryDate;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name *',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: PantryService.defaultCategories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedUnit,
                        decoration: const InputDecoration(
                          labelText: 'Unit',
                          border: OutlineInputBorder(),
                        ),
                        items: PantryService.defaultUnits.map((unit) {
                          return DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedUnit = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    selectedExpiryDate == null
                        ? 'No expiry date'
                        : 'Expires: ${selectedExpiryDate.toString().split(' ')[0]}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selectedExpiryDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              selectedExpiryDate = null;
                            });
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 7)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                          );
                          if (date != null) {
                            setState(() {
                              selectedExpiryDate = date;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || quantityController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill required fields')),
                  );
                  return;
                }

                final pantryService = Provider.of<PantryService>(context, listen: false);
                await pantryService.addItem(
                  name: nameController.text,
                  category: selectedCategory,
                  quantity: int.tryParse(quantityController.text) ?? 1,
                  unit: selectedUnit,
                  expiryDate: selectedExpiryDate,
                  notes: notesController.text.isEmpty ? null : notesController.text,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${nameController.text} added!')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditItemDialog(BuildContext context, PantryItem item, PantryService pantryService) {
    final nameController = TextEditingController(text: item.name);
    final quantityController = TextEditingController(text: item.quantity.toString());
    final notesController = TextEditingController(text: item.notes ?? '');
    String selectedCategory = item.category;
    String selectedUnit = item.unit;
    DateTime? selectedExpiryDate = item.expiryDate;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name *',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: PantryService.defaultCategories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedUnit,
                        decoration: const InputDecoration(
                          labelText: 'Unit',
                          border: OutlineInputBorder(),
                        ),
                        items: PantryService.defaultUnits.map((unit) {
                          return DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedUnit = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    selectedExpiryDate == null
                        ? 'No expiry date'
                        : 'Expires: ${selectedExpiryDate.toString().split(' ')[0]}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selectedExpiryDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              selectedExpiryDate = null;
                            });
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedExpiryDate ?? DateTime.now().add(const Duration(days: 7)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                          );
                          if (date != null) {
                            setState(() {
                              selectedExpiryDate = date;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || quantityController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill required fields')),
                  );
                  return;
                }

                await pantryService.updateItem(
                  item.id,
                  name: nameController.text,
                  category: selectedCategory,
                  quantity: int.tryParse(quantityController.text) ?? 1,
                  unit: selectedUnit,
                  expiryDate: selectedExpiryDate,
                  notes: notesController.text.isEmpty ? null : notesController.text,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${nameController.text} updated!')),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
