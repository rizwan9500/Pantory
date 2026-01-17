import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/pantry_service.dart';
import '../services/auth_service.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/glass_container.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pantryService = Provider.of<PantryService>(context);
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    final isPro = user?.isPro ?? false;

    if (!isPro) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Analytics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: Stack(
          children: [
            const AnimatedGradientBackground(
              theme: GradientTheme.purple,
              child: SizedBox.expand(),
            ),
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.analytics, size: 100, color: Colors.white),
                      const SizedBox(height: 24),
                      const Text(
                        'Advanced Analytics',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Unlock detailed insights about your pantry with Pro subscription',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white.withOpacity(0.8)),
                      ),
                      const SizedBox(height: 32),
                      GlassContainer(
                        blur: 10,
                        opacity: 0.2,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/subscription');
                          },
                          child: const Text(
                            'Upgrade to Pro',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Analytics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          const AnimatedGradientBackground(
            theme: GradientTheme.purple,
            child: SizedBox.expand(),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview Stats
                  const Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
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
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Expired',
                          '${pantryService.expiredCount}',
                          Icons.dangerous,
                          Colors.red,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Favorites',
                          '${pantryService.favoriteItems.length}',
                          Icons.favorite,
                          Colors.pink,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Category Breakdown
                  const Text(
                    'Items by Category',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (pantryService.itemsByCategory.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'No items to analyze yet',
                          style: TextStyle(color: Colors.white.withOpacity(0.7)),
                        ),
                      ),
                    )
                  else
                    ...pantryService.itemsByCategory.entries.map((entry) {
                      final percentage = (entry.value / pantryService.totalItems * 100).toStringAsFixed(1);
                      return _buildCategoryBar(
                        entry.key,
                        entry.value,
                        percentage,
                        context,
                      );
                    }),
                  
                  const SizedBox(height: 32),
                  
                  // Expiry Insights
                  const Text(
                    'Expiry Insights',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (pantryService.expiringItems.isEmpty)
                    GlassContainer(
                      blur: 10,
                      opacity: 0.15,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[300], size: 32),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'All items are in good condition!',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...pantryService.expiringItems.map((item) {
                      final color = item.isExpired ? Colors.red : Colors.orange;
                      return GlassContainer(
                        blur: 10,
                        opacity: 0.15,
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: color.withOpacity(0.3),
                              child: Icon(
                                item.isExpired ? Icons.dangerous : Icons.warning,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.category} • ${item.expiryStatus}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              item.daysUntilExpiry != null
                                  ? '${item.daysUntilExpiry} days'
                                  : 'Expired',
                              style: TextStyle(
                                color: color.shade200,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  
                  const SizedBox(height: 32),
                  
                  // Quick Actions
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: GlassContainer(
                          blur: 10,
                          opacity: 0.2,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          child: InkWell(
                            onTap: () async {
                              await pantryService.generateSmartShoppingList();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Smart shopping list generated!'),
                                  ),
                                );
                                Navigator.pushNamed(context, '/shopping-list');
                              }
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shopping_cart, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Generate Shopping List',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBar(String category, int count, String percentage, BuildContext context) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
      Colors.pink,
      Colors.cyan,
    ];
    
    final colorIndex = category.hashCode % colors.length;
    final color = colors[colorIndex.abs()];
    
    return GlassContainer(
      blur: 10,
      opacity: 0.15,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              Text(
                '$count items ($percentage%)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: double.parse(percentage) / 100,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color.shade300),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
