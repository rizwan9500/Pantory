import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/pantry_service.dart';
import '../services/auth_service.dart';
import '../models/shopping_list_item.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/glass_container.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pantryService = Provider.of<PantryService>(context);
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    final isPro = user?.isPro ?? false;

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
        title: const Text('Shopping List', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          if (isPro)
            IconButton(
              icon: const Icon(Icons.auto_awesome, color: Colors.white),
              tooltip: 'Generate Smart List',
              onPressed: () async {
                await pantryService.generateSmartShoppingList();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Smart shopping list generated!'),
                    ),
                  );
                }
              },
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == 'clear_checked') {
                await pantryService.clearCheckedItems();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Checked items cleared')),
                  );
                }
              } else if (value == 'clear_all') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All'),
                    content: const Text('Clear all items from shopping list?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                );
                
                if (confirmed == true) {
                  pantryService.shoppingList.toList().forEach((item) async {
                    await pantryService.removeFromShoppingList(item.id);
                  });
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_checked',
                child: Text('Clear Checked Items'),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Text('Clear All'),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          const AnimatedGradientBackground(
            theme: GradientTheme.blue,
            child: SizedBox.expand(),
          ),
          SafeArea(
            child: pantryService.shoppingList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.white.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'Your shopping list is empty',
                          style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.8)),
                        ),
                        const SizedBox(height: 8),
                        if (isPro) ...[
                          const SizedBox(height: 16),
                          GlassContainer(
                            blur: 10,
                            opacity: 0.2,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            child: InkWell(
                              onTap: () async {
                                await pantryService.generateSmartShoppingList();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Smart shopping list generated!'),
                                    ),
                                  );
                                }
                              },
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.auto_awesome, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Generate Smart List', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 16),
                          GlassContainer(
                            blur: 10,
                            opacity: 0.15,
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.symmetric(horizontal: 32),
                            child: Column(
                              children: [
                                const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
                                const SizedBox(height: 8),
                                const Text(
                                  'Smart Shopping List',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Upgrade to Pro for automatic shopping list generation',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
                                ),
                                const SizedBox(height: 8),
                                GlassContainer(
                                  blur: 10,
                                  opacity: 0.2,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(context, '/subscription');
                                    },
                                    child: const Text('Upgrade Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: pantryService.shoppingList.length,
                    itemBuilder: (context, index) {
                      final item = pantryService.shoppingList[index];
                      return _buildShoppingItem(context, item, pantryService);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: GlassContainer(
        blur: 10,
        opacity: 0.2,
        borderRadius: 16,
        padding: const EdgeInsets.all(16),
        child: InkWell(
          onTap: () => _showAddShoppingItemDialog(context),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildShoppingItem(BuildContext context, ShoppingListItem item, PantryService pantryService) {
    return GlassContainer(
      blur: 10,
      opacity: 0.15,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Checkbox(
            value: item.isChecked,
            onChanged: (value) async {
              await pantryService.toggleShoppingItem(item.id);
            },
            fillColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return Colors.white;
              }
              return Colors.white.withOpacity(0.3);
            }),
            checkColor: Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    decoration: item.isChecked ? TextDecoration.lineThrough : null,
                    color: item.isChecked ? Colors.white.withOpacity(0.5) : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity} ${item.unit} • ${item.category}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                if (item.notes != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.notes!,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
                if (item.autoAdded)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Auto-added',
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white70),
            onPressed: () async {
              await pantryService.removeFromShoppingList(item.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item.name} removed')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAddShoppingItemDialog(BuildContext context) {
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final notesController = TextEditingController();
    String selectedCategory = PantryService.defaultCategories.first;
    String selectedUnit = PantryService.defaultUnits.first;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add to Shopping List'),
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
                await pantryService.addToShoppingList(
                  name: nameController.text,
                  category: selectedCategory,
                  quantity: int.tryParse(quantityController.text) ?? 1,
                  unit: selectedUnit,
                  notes: notesController.text.isEmpty ? null : notesController.text,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${nameController.text} added to list!')),
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
}
