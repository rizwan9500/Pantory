import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/pantry_item.dart';
import '../models/shopping_list_item.dart';

class PantryService extends ChangeNotifier {
  List<PantryItem> _items = [];
  List<ShoppingListItem> _shoppingList = [];
  final _uuid = const Uuid();
  bool _isLoading = false;

  // Getters
  List<PantryItem> get items => _items;
  List<PantryItem> get favoriteItems => _items.where((item) => item.isFavorite).toList();
  List<PantryItem> get expiringItems => _items.where((item) => item.isExpiringSoon || item.isExpired).toList();
  List<ShoppingListItem> get shoppingList => _shoppingList;
  bool get isLoading => _isLoading;

  // Statistics
  int get totalItems => _items.length;
  int get expiringSoonCount => _items.where((item) => item.isExpiringSoon).toList().length;
  int get expiredCount => _items.where((item) => item.isExpired).toList().length;
  
  Map<String, int> get itemsByCategory {
    final Map<String, int> categoryMap = {};
    for (var item in _items) {
      categoryMap[item.category] = (categoryMap[item.category] ?? 0) + 1;
    }
    return categoryMap;
  }

  // Common categories
  static const List<String> defaultCategories = [
    'Dairy',
    'Grains',
    'Beverages',
    'Fruits',
    'Vegetables',
    'Meat',
    'Seafood',
    'Snacks',
    'Condiments',
    'Frozen',
    'Bakery',
    'Canned',
    'Other',
  ];

  // Common units
  static const List<String> defaultUnits = [
    'pcs',
    'kg',
    'g',
    'L',
    'ml',
    'lbs',
    'oz',
    'box',
    'pack',
    'bottle',
    'can',
  ];

  PantryService() {
    _loadData();
  }

  // Load data from storage
  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load pantry items
      final itemsJson = prefs.getString('pantry_items');
      if (itemsJson != null) {
        final List<dynamic> decoded = jsonDecode(itemsJson);
        _items = decoded.map((json) => PantryItem.fromJson(json)).toList();
      }

      // Load shopping list
      final shoppingJson = prefs.getString('shopping_list');
      if (shoppingJson != null) {
        final List<dynamic> decoded = jsonDecode(shoppingJson);
        _shoppingList = decoded.map((json) => ShoppingListItem.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error loading pantry data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save data to storage
  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save pantry items
      final itemsJson = jsonEncode(_items.map((item) => item.toJson()).toList());
      await prefs.setString('pantry_items', itemsJson);

      // Save shopping list
      final shoppingJson = jsonEncode(_shoppingList.map((item) => item.toJson()).toList());
      await prefs.setString('shopping_list', shoppingJson);
    } catch (e) {
      debugPrint('Error saving pantry data: $e');
    }
  }

  // Pantry Item CRUD Operations

  // Add item
  Future<void> addItem({
    required String name,
    required String category,
    required int quantity,
    required String unit,
    DateTime? expiryDate,
    String? notes,
  }) async {
    final item = PantryItem(
      id: _uuid.v4(),
      name: name,
      category: category,
      quantity: quantity,
      unit: unit,
      expiryDate: expiryDate,
      addedDate: DateTime.now(),
      notes: notes,
    );

    _items.add(item);
    await _saveData();
    notifyListeners();
  }

  // Update item
  Future<void> updateItem(String id, {
    String? name,
    String? category,
    int? quantity,
    String? unit,
    DateTime? expiryDate,
    String? notes,
    bool? isFavorite,
  }) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(
        name: name,
        category: category,
        quantity: quantity,
        unit: unit,
        expiryDate: expiryDate,
        notes: notes,
        isFavorite: isFavorite,
      );
      await _saveData();
      notifyListeners();
    }
  }

  // Delete item
  Future<void> deleteItem(String id) async {
    _items.removeWhere((item) => item.id == id);
    await _saveData();
    notifyListeners();
  }

  // Toggle favorite
  Future<void> toggleFavorite(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(
        isFavorite: !_items[index].isFavorite,
      );
      await _saveData();
      notifyListeners();
    }
  }

  // Search items
  List<PantryItem> searchItems(String query) {
    if (query.isEmpty) return _items;
    final lowerQuery = query.toLowerCase();
    return _items.where((item) =>
      item.name.toLowerCase().contains(lowerQuery) ||
      item.category.toLowerCase().contains(lowerQuery) ||
      (item.notes?.toLowerCase().contains(lowerQuery) ?? false)
    ).toList();
  }

  // Filter items by category
  List<PantryItem> filterByCategory(String category) {
    return _items.where((item) => item.category == category).toList();
  }

  // Shopping List Operations

  // Add to shopping list
  Future<void> addToShoppingList({
    required String name,
    required String category,
    required int quantity,
    required String unit,
    String? notes,
    bool autoAdded = false,
  }) async {
    final item = ShoppingListItem(
      id: _uuid.v4(),
      name: name,
      category: category,
      quantity: quantity,
      unit: unit,
      addedDate: DateTime.now(),
      notes: notes,
      autoAdded: autoAdded,
    );

    _shoppingList.add(item);
    await _saveData();
    notifyListeners();
  }

  // Toggle shopping list item checked
  Future<void> toggleShoppingItem(String id) async {
    final index = _shoppingList.indexWhere((item) => item.id == id);
    if (index != -1) {
      _shoppingList[index] = _shoppingList[index].copyWith(
        isChecked: !_shoppingList[index].isChecked,
      );
      await _saveData();
      notifyListeners();
    }
  }

  // Remove from shopping list
  Future<void> removeFromShoppingList(String id) async {
    _shoppingList.removeWhere((item) => item.id == id);
    await _saveData();
    notifyListeners();
  }

  // Clear checked items
  Future<void> clearCheckedItems() async {
    _shoppingList.removeWhere((item) => item.isChecked);
    await _saveData();
    notifyListeners();
  }

  // Smart Shopping List - Auto add items that are running low or expired
  Future<void> generateSmartShoppingList() async {
    // Add expired or expiring items to shopping list
    for (var item in _items) {
      if (item.isExpired || item.isExpiringSoon) {
        // Check if already in shopping list
        final exists = _shoppingList.any((shoppingItem) => 
          shoppingItem.name.toLowerCase() == item.name.toLowerCase()
        );
        
        if (!exists) {
          await addToShoppingList(
            name: item.name,
            category: item.category,
            quantity: item.quantity,
            unit: item.unit,
            notes: item.isExpired ? 'Expired - needs replacement' : 'Expiring soon',
            autoAdded: true,
          );
        }
      }
    }
  }

  // Clear all data (for testing or reset)
  Future<void> clearAllData() async {
    _items.clear();
    _shoppingList.clear();
    await _saveData();
    notifyListeners();
  }

  // Add sample data for testing
  Future<void> addSampleData() async {
    await addItem(
      name: 'Milk',
      category: 'Dairy',
      quantity: 1,
      unit: 'L',
      expiryDate: DateTime.now().add(const Duration(days: 2)),
      notes: 'Full fat',
    );

    await addItem(
      name: 'Rice',
      category: 'Grains',
      quantity: 5,
      unit: 'kg',
      expiryDate: DateTime.now().add(const Duration(days: 365)),
      notes: 'Basmati',
    );

    await addItem(
      name: 'Bread',
      category: 'Bakery',
      quantity: 1,
      unit: 'pack',
      expiryDate: DateTime.now().add(const Duration(days: 5)),
    );

    await addItem(
      name: 'Apples',
      category: 'Fruits',
      quantity: 6,
      unit: 'pcs',
      expiryDate: DateTime.now().add(const Duration(days: 7)),
    );

    await addItem(
      name: 'Cheese',
      category: 'Dairy',
      quantity: 200,
      unit: 'g',
      expiryDate: DateTime.now().add(const Duration(days: 14)),
    );
  }
}
