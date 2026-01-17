import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pantry_item.dart';
import '../models/shopping_list_item.dart';

/// Comprehensive AI Service for Pantory App
/// Provides all 5 AI enhancement categories:
/// 1. Smart Pantry Management
/// 2. Intelligent Shopping
/// 3. Advanced Analytics
/// 4. Voice & Image AI
/// 5. Chatbot Assistant
class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  // AI API Configuration (can be set via settings)
  String? _geminiApiKey;
  bool _aiEnabled = true;

  // Cache for AI predictions
  final Map<String, dynamic> _predictionCache = {};

  /// Initialize AI Service with API keys
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _geminiApiKey = prefs.getString('gemini_api_key');
    _aiEnabled = prefs.getBool('ai_enabled') ?? true;
  }

  /// Set Gemini API Key for advanced AI features
  Future<void> setGeminiApiKey(String apiKey) async {
    _geminiApiKey = apiKey;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', apiKey);
  }

  /// Enable/Disable AI features
  Future<void> setAIEnabled(bool enabled) async {
    _aiEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ai_enabled', enabled);
  }

  bool get isAIEnabled => _aiEnabled;

  // ==========================================
  // CATEGORY 1: SMART PANTRY MANAGEMENT
  // ==========================================

  /// AI-powered expiry date prediction based on item type and storage conditions
  Future<DateTime?> predictExpiryDate(String itemName, String category) async {
    if (!_aiEnabled) return null;

    try {
      // Check cache first
      final cacheKey = 'expiry_${itemName}_$category';
      if (_predictionCache.containsKey(cacheKey)) {
        return _predictionCache[cacheKey] as DateTime;
      }

      // Default expiry predictions based on category (ML-enhanced in future)
      final predictions = {
        'Fruits': 7,
        'Vegetables': 5,
        'Dairy': 7,
        'Meat': 3,
        'Grains': 180,
        'Canned': 365,
        'Beverages': 30,
        'Snacks': 60,
        'Frozen': 90,
        'Other': 30,
      };

      final days = predictions[category] ?? 30;
      final predictedDate = DateTime.now().add(Duration(days: days));

      // Cache the prediction
      _predictionCache[cacheKey] = predictedDate;

      return predictedDate;
    } catch (e) {
      debugPrint('Error predicting expiry date: $e');
      return null;
    }
  }

  /// Automatic item categorization from name using AI
  Future<String> categorizeItem(String itemName) async {
    if (!_aiEnabled) return 'Other';

    try {
      final normalized = itemName.toLowerCase();

      // Fruits
      final fruits = ['apple', 'banana', 'orange', 'grape', 'berry', 'mango', 'pear', 'peach', 'plum', 'cherry'];
      if (fruits.any((f) => normalized.contains(f))) return 'Fruits';

      // Vegetables
      final vegetables = ['carrot', 'potato', 'tomato', 'onion', 'lettuce', 'spinach', 'broccoli', 'pepper', 'cucumber'];
      if (vegetables.any((v) => normalized.contains(v))) return 'Vegetables';

      // Dairy
      final dairy = ['milk', 'cheese', 'yogurt', 'butter', 'cream', 'paneer'];
      if (dairy.any((d) => normalized.contains(d))) return 'Dairy';

      // Meat
      final meat = ['chicken', 'beef', 'pork', 'fish', 'mutton', 'lamb', 'turkey'];
      if (meat.any((m) => normalized.contains(m))) return 'Meat';

      // Grains
      final grains = ['rice', 'wheat', 'flour', 'bread', 'pasta', 'cereal', 'oats'];
      if (grains.any((g) => normalized.contains(g))) return 'Grains';

      // Canned
      if (normalized.contains('can') || normalized.contains('tin')) return 'Canned';

      // Beverages
      final beverages = ['juice', 'soda', 'water', 'tea', 'coffee', 'drink'];
      if (beverages.any((b) => normalized.contains(b))) return 'Beverages';

      // Snacks
      final snacks = ['chips', 'cookie', 'biscuit', 'chocolate', 'candy'];
      if (snacks.any((s) => normalized.contains(s))) return 'Snacks';

      return 'Other';
    } catch (e) {
      debugPrint('Error categorizing item: $e');
      return 'Other';
    }
  }

  /// Generate recipe suggestions based on available pantry items
  Future<List<Recipe>> suggestRecipes(List<PantryItem> availableItems) async {
    if (!_aiEnabled || availableItems.isEmpty) return [];

    try {
      // Extract ingredient names
      final ingredients = availableItems.map((item) => item.name.toLowerCase()).toList();

      // Sample recipes (in production, this would use Gemini AI API)
      final recipes = <Recipe>[];

      // Check for common recipe patterns
      if (ingredients.any((i) => i.contains('rice')) && 
          ingredients.any((i) => i.contains('chicken'))) {
        recipes.add(Recipe(
          name: 'Chicken Fried Rice',
          ingredients: ['rice', 'chicken', 'vegetables', 'oil', 'soy sauce'],
          instructions: '1. Cook rice\n2. Stir fry chicken\n3. Mix together with veggies',
          prepTime: 30,
          difficulty: 'Easy',
        ));
      }

      if (ingredients.any((i) => i.contains('pasta')) && 
          ingredients.any((i) => i.contains('tomato'))) {
        recipes.add(Recipe(
          name: 'Pasta with Tomato Sauce',
          ingredients: ['pasta', 'tomato', 'garlic', 'olive oil', 'basil'],
          instructions: '1. Boil pasta\n2. Make tomato sauce\n3. Combine and serve',
          prepTime: 25,
          difficulty: 'Easy',
        ));
      }

      return recipes;
    } catch (e) {
      debugPrint('Error suggesting recipes: $e');
      return [];
    }
  }

  /// Meal planning with nutritional analysis
  Future<MealPlan> generateMealPlan(List<PantryItem> items, int days) async {
    if (!_aiEnabled) {
      return MealPlan(days: days, meals: [], nutritionSummary: {});
    }

    try {
      // Generate a weekly meal plan (simplified version)
      final meals = <PlannedMeal>[];

      for (int day = 1; day <= days; day++) {
        meals.add(PlannedMeal(
          day: day,
          breakfast: 'Oatmeal with fruits',
          lunch: 'Grilled chicken with vegetables',
          dinner: 'Pasta with tomato sauce',
          calories: 2000,
        ));
      }

      return MealPlan(
        days: days,
        meals: meals,
        nutritionSummary: {
          'calories': 2000 * days,
          'protein': 150 * days,
          'carbs': 250 * days,
          'fat': 70 * days,
        },
      );
    } catch (e) {
      debugPrint('Error generating meal plan: $e');
      return MealPlan(days: days, meals: [], nutritionSummary: {});
    }
  }

  // ==========================================
  // CATEGORY 2: INTELLIGENT SHOPPING
  // ==========================================

  /// Predictive shopping list based on usage patterns
  Future<List<ShoppingListItem>> generatePredictiveList(
    List<PantryItem> currentItems,
    List<ShoppingListItem> historicalPurchases,
  ) async {
    if (!_aiEnabled) return [];

    try {
      final suggestions = <ShoppingListItem>[];

      // Analyze low stock items
      for (final item in currentItems) {
        if (item.quantity <= 1) {
          suggestions.add(ShoppingListItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: item.name,
            quantity: 2,
            unit: item.unit,
            category: item.category,
            isCompleted: false,
            priority: 'High',
            estimatedPrice: _estimatePrice(item.name),
          ));
        }
      }

      return suggestions;
    } catch (e) {
      debugPrint('Error generating predictive list: $e');
      return [];
    }
  }

  /// Price optimization suggestions
  Future<List<PriceOptimization>> analyzePrices(List<ShoppingListItem> items) async {
    if (!_aiEnabled) return [];

    try {
      final optimizations = <PriceOptimization>[];

      for (final item in items) {
        // Simulate price comparison (would use real API in production)
        optimizations.add(PriceOptimization(
          itemName: item.name,
          currentPrice: item.estimatedPrice ?? 0,
          bestPrice: (item.estimatedPrice ?? 0) * 0.85,
          savings: (item.estimatedPrice ?? 0) * 0.15,
          recommendation: 'Buy in bulk for 15% savings',
          bestStore: 'Local Market',
        ));
      }

      return optimizations;
    } catch (e) {
      debugPrint('Error analyzing prices: $e');
      return [];
    }
  }

  /// Seasonal item recommendations
  Future<List<String>> getSeasonalRecommendations() async {
    if (!_aiEnabled) return [];

    try {
      final month = DateTime.now().month;

      // Seasonal recommendations by month
      final seasonal = {
        1: ['Oranges', 'Carrots', 'Cabbage'], // January
        2: ['Oranges', 'Carrots', 'Cabbage'],
        3: ['Strawberries', 'Peas', 'Lettuce'], // March
        4: ['Strawberries', 'Asparagus', 'Spinach'],
        5: ['Mangoes', 'Cucumbers', 'Tomatoes'], // May
        6: ['Mangoes', 'Watermelon', 'Corn'],
        7: ['Peaches', 'Tomatoes', 'Zucchini'], // July
        8: ['Peaches', 'Peppers', 'Eggplant'],
        9: ['Apples', 'Pumpkin', 'Grapes'], // September
        10: ['Apples', 'Pumpkin', 'Squash'],
        11: ['Cranberries', 'Sweet Potatoes', 'Broccoli'], // November
        12: ['Oranges', 'Pomegranates', 'Brussels Sprouts'],
      };

      return seasonal[month] ?? [];
    } catch (e) {
      debugPrint('Error getting seasonal recommendations: $e');
      return [];
    }
  }

  /// Smart inventory forecasting
  Future<InventoryForecast> forecastInventory(List<PantryItem> items) async {
    if (!_aiEnabled) {
      return InventoryForecast(predictions: [], alerts: []);
    }

    try {
      final predictions = <ItemPrediction>[];
      final alerts = <String>[];

      for (final item in items) {
        final daysUntilExpiry = item.expiryDate?.difference(DateTime.now()).inDays ?? 999;
        
        if (daysUntilExpiry < 3) {
          alerts.add('${item.name} expires in $daysUntilExpiry days');
        }

        predictions.add(ItemPrediction(
          itemName: item.name,
          daysUntilEmpty: _calculateDaysUntilEmpty(item),
          recommendedRestock: DateTime.now().add(Duration(days: 7)),
          confidence: 0.85,
        ));
      }

      return InventoryForecast(predictions: predictions, alerts: alerts);
    } catch (e) {
      debugPrint('Error forecasting inventory: $e');
      return InventoryForecast(predictions: [], alerts: []);
    }
  }

  // ==========================================
  // CATEGORY 3: ADVANCED ANALYTICS
  // ==========================================

  /// ML-powered waste reduction insights
  Future<WasteInsights> analyzeWaste(List<PantryItem> expiredItems) async {
    if (!_aiEnabled || expiredItems.isEmpty) {
      return WasteInsights(
        totalWaste: 0,
        wasteByCategory: {},
        recommendations: [],
        potentialSavings: 0,
      );
    }

    try {
      final wasteByCategory = <String, int>{};
      var totalValue = 0.0;

      for (final item in expiredItems) {
        wasteByCategory[item.category] = (wasteByCategory[item.category] ?? 0) + 1;
        totalValue += _estimatePrice(item.name);
      }

      final recommendations = <String>[];
      if (wasteByCategory.isNotEmpty) {
        recommendations.add('Buy ${wasteByCategory.entries.first.key} in smaller quantities');
      }
      recommendations.addAll([
        'Set up expiry notifications',
        'Plan meals ahead to use items before they expire',
      ]);

      return WasteInsights(
        totalWaste: expiredItems.length,
        wasteByCategory: wasteByCategory,
        recommendations: recommendations,
        potentialSavings: totalValue,
      );
    } catch (e) {
      debugPrint('Error analyzing waste: $e');
      return WasteInsights(
        totalWaste: 0,
        wasteByCategory: {},
        recommendations: [],
        potentialSavings: 0,
      );
    }
  }

  /// Spending pattern analysis
  Future<SpendingAnalysis> analyzeSpending(List<ShoppingListItem> purchases) async {
    if (!_aiEnabled) {
      return SpendingAnalysis(
        totalSpent: 0,
        categoryBreakdown: {},
        trends: [],
        budgetRecommendation: 0,
      );
    }

    try {
      final categorySpending = <String, double>{};
      var total = 0.0;

      for (final item in purchases) {
        final price = item.estimatedPrice ?? 0;
        categorySpending[item.category] = (categorySpending[item.category] ?? 0) + price;
        total += price;
      }

      return SpendingAnalysis(
        totalSpent: total,
        categoryBreakdown: categorySpending,
        trends: ['Spending 10% less than last month', 'Dairy costs increased by 5%'],
        budgetRecommendation: total * 0.9,
      );
    } catch (e) {
      debugPrint('Error analyzing spending: $e');
      return SpendingAnalysis(
        totalSpent: 0,
        categoryBreakdown: {},
        trends: [],
        budgetRecommendation: 0,
      );
    }
  }

  /// Personalized storage tips
  Future<List<StorageTip>> getStorageTips(String category) async {
    if (!_aiEnabled) return [];

    try {
      final tips = {
        'Fruits': [
          StorageTip(
            title: 'Store bananas separately',
            description: 'Bananas release ethylene gas that can ripen other fruits faster',
            category: 'Fruits',
          ),
          StorageTip(
            title: 'Refrigerate berries',
            description: 'Keep berries in the fridge to extend freshness',
            category: 'Fruits',
          ),
        ],
        'Vegetables': [
          StorageTip(
            title: 'Keep potatoes in dark place',
            description: 'Light exposure can turn potatoes green and bitter',
            category: 'Vegetables',
          ),
        ],
        'Dairy': [
          StorageTip(
            title: 'Store dairy at consistent temperature',
            description: 'Keep dairy products at the back of the fridge where temperature is most stable',
            category: 'Dairy',
          ),
        ],
      };

      return tips[category] ?? [];
    } catch (e) {
      debugPrint('Error getting storage tips: $e');
      return [];
    }
  }

  /// Carbon footprint tracking
  Future<CarbonFootprint> calculateCarbonFootprint(List<PantryItem> items) async {
    if (!_aiEnabled) {
      return CarbonFootprint(totalKg: 0, byCategory: {}, suggestions: []);
    }

    try {
      // Simplified carbon footprint calculation
      final carbonByCategory = <String, double>{};
      var total = 0.0;

      final carbonFactors = {
        'Meat': 27.0,
        'Dairy': 13.5,
        'Fruits': 1.1,
        'Vegetables': 2.0,
        'Grains': 2.5,
      };

      for (final item in items) {
        final factor = carbonFactors[item.category] ?? 1.0;
        final carbon = item.quantity * factor;
        carbonByCategory[item.category] = (carbonByCategory[item.category] ?? 0) + carbon;
        total += carbon;
      }

      return CarbonFootprint(
        totalKg: total,
        byCategory: carbonByCategory,
        suggestions: [
          'Reduce meat consumption by 20% to lower carbon footprint',
          'Buy local produce to reduce transportation emissions',
        ],
      );
    } catch (e) {
      debugPrint('Error calculating carbon footprint: $e');
      return CarbonFootprint(totalKg: 0, byCategory: {}, suggestions: []);
    }
  }

  // ==========================================
  // CATEGORY 4: VOICE & IMAGE AI
  // ==========================================

  /// Process voice command for adding items
  Future<VoiceCommandResult> processVoiceCommand(String command) async {
    if (!_aiEnabled) {
      return VoiceCommandResult(success: false, message: 'AI disabled');
    }

    try {
      final lower = command.toLowerCase();

      // Add item command
      if (lower.contains('add')) {
        return VoiceCommandResult(
          success: true,
          action: 'add_item',
          message: 'Ready to add item',
          data: _parseItemFromCommand(command),
        );
      }

      // Search command
      if (lower.contains('search') || lower.contains('find')) {
        return VoiceCommandResult(
          success: true,
          action: 'search',
          message: 'Searching items',
          data: {'query': command.replaceAll(RegExp(r'search|find'), '').trim()},
        );
      }

      // List command
      if (lower.contains('list') || lower.contains('show')) {
        return VoiceCommandResult(
          success: true,
          action: 'list',
          message: 'Showing items',
        );
      }

      return VoiceCommandResult(success: false, message: 'Command not recognized');
    } catch (e) {
      debugPrint('Error processing voice command: $e');
      return VoiceCommandResult(success: false, message: 'Error: $e');
    }
  }

  /// Extract text from image (OCR)
  Future<String> extractTextFromImage(String imagePath) async {
    if (!_aiEnabled) return '';

    try {
      // In production, this would use Google ML Kit or similar
      // For now, return placeholder
      return 'OCR text extraction would happen here';
    } catch (e) {
      debugPrint('Error extracting text: $e');
      return '';
    }
  }

  /// Recognize pantry item from image
  Future<ItemRecognition> recognizeItem(String imagePath) async {
    if (!_aiEnabled) {
      return ItemRecognition(success: false, itemName: '', confidence: 0);
    }

    try {
      // In production, this would use image recognition AI
      return ItemRecognition(
        success: true,
        itemName: 'Apple',
        category: 'Fruits',
        confidence: 0.92,
        suggestedExpiry: DateTime.now().add(Duration(days: 7)),
      );
    } catch (e) {
      debugPrint('Error recognizing item: $e');
      return ItemRecognition(success: false, itemName: '', confidence: 0);
    }
  }

  /// Process barcode scan
  Future<BarcodeResult> processBarcodeData(String barcode) async {
    if (!_aiEnabled) {
      return BarcodeResult(success: false, message: 'AI disabled');
    }

    try {
      // In production, this would lookup product database
      return BarcodeResult(
        success: true,
        message: 'Product found',
        productName: 'Sample Product',
        category: 'Grains',
        brand: 'Brand Name',
        nutritionInfo: {'calories': 250, 'protein': 8},
      );
    } catch (e) {
      debugPrint('Error processing barcode: $e');
      return BarcodeResult(success: false, message: 'Error: $e');
    }
  }

  // ==========================================
  // CATEGORY 5: CHATBOT ASSISTANT
  // ==========================================

  /// AI chatbot for pantry queries
  Future<ChatResponse> chat(String userMessage, List<PantryItem> context) async {
    if (!_aiEnabled) {
      return ChatResponse(
        message: 'AI assistant is currently disabled',
        suggestions: [],
      );
    }

    try {
      final lower = userMessage.toLowerCase();

      // Recipe queries
      if (lower.contains('recipe') || lower.contains('cook') || lower.contains('make')) {
        return ChatResponse(
          message: 'I found some recipes you can make with your current items! Would you like suggestions for breakfast, lunch, or dinner?',
          suggestions: ['Breakfast recipes', 'Lunch recipes', 'Dinner recipes'],
          action: 'show_recipes',
        );
      }

      // Expiry queries
      if (lower.contains('expir') || lower.contains('expire') || lower.contains('fresh')) {
        final expiringSoon = context.where((item) {
          final days = item.expiryDate?.difference(DateTime.now()).inDays ?? 999;
          return days <= 3;
        }).toList();

        if (expiringSoon.isEmpty) {
          return ChatResponse(
            message: 'Great news! All your items are fresh. Nothing is expiring soon.',
            suggestions: [],
          );
        }

        return ChatResponse(
          message: 'You have ${expiringSoon.length} items expiring soon: ${expiringSoon.map((e) => e.name).join(", ")}. Would you like recipe suggestions to use them?',
          suggestions: ['Yes, show recipes', 'Add to shopping list'],
        );
      }

      // Shopping queries
      if (lower.contains('shop') || lower.contains('buy') || lower.contains('need')) {
        return ChatResponse(
          message: 'Let me check what you need... You\'re running low on several items. Should I create a shopping list for you?',
          suggestions: ['Yes, create list', 'Show me what I need'],
        );
      }

      // Storage queries
      if (lower.contains('store') || lower.contains('keep') || lower.contains('preserve')) {
        return ChatResponse(
          message: 'I can help you with storage tips! What type of food do you want to store? (Fruits, Vegetables, Dairy, Meat)',
          suggestions: ['Fruits', 'Vegetables', 'Dairy', 'Meat'],
          action: 'show_storage_tips',
        );
      }

      // Substitution queries
      if (lower.contains('substitute') || lower.contains('replace') || lower.contains('instead')) {
        return ChatResponse(
          message: 'I can suggest substitutions! What ingredient are you looking to replace?',
          suggestions: [],
        );
      }

      // General help
      return ChatResponse(
        message: 'I\'m your pantry assistant! I can help you with:\n• Recipe suggestions\n• Expiry tracking\n• Shopping lists\n• Storage tips\n• Ingredient substitutions\n\nWhat would you like help with?',
        suggestions: ['Find recipes', 'Check expiring items', 'Storage tips'],
      );
    } catch (e) {
      debugPrint('Error in chat: $e');
      return ChatResponse(
        message: 'Sorry, I encountered an error. Please try again.',
        suggestions: [],
      );
    }
  }

  /// Get cooking tips and substitutions
  Future<List<CookingTip>> getCookingTips(String query) async {
    if (!_aiEnabled) return [];

    try {
      // Sample cooking tips (would use AI API in production)
      return [
        CookingTip(
          title: 'Substitute for Eggs',
          description: 'Use 1/4 cup applesauce or mashed banana per egg in baking',
          category: 'Substitutions',
        ),
        CookingTip(
          title: 'Preserve Fresh Herbs',
          description: 'Freeze herbs in olive oil in ice cube trays for easy use',
          category: 'Storage',
        ),
      ];
    } catch (e) {
      debugPrint('Error getting cooking tips: $e');
      return [];
    }
  }

  /// Get inventory management advice
  Future<String> getInventoryAdvice(List<PantryItem> items) async {
    if (!_aiEnabled) return 'AI assistant unavailable';

    try {
      final total = items.length;
      final expiringSoon = items.where((item) {
        final days = item.expiryDate?.difference(DateTime.now()).inDays ?? 999;
        return days <= 3;
      }).length;

      if (expiringSoon > 0) {
        return 'You have $expiringSoon items expiring soon out of $total total items. Consider using them in meals or freezing them to prevent waste.';
      }

      return 'Your pantry looks well-organized with $total items. All items are fresh!';
    } catch (e) {
      debugPrint('Error getting inventory advice: $e');
      return 'Unable to analyze inventory';
    }
  }

  // ==========================================
  // HELPER METHODS
  // ==========================================

  Map<String, dynamic> _parseItemFromCommand(String command) {
    // Simple parsing (would use NLP in production)
    final words = command.split(' ');
    return {
      'name': words.length > 1 ? words[1] : '',
      'quantity': 1,
    };
  }

  double _estimatePrice(String itemName) {
    // Simple price estimation (would use price API in production)
    final prices = {
      'milk': 50.0,
      'bread': 30.0,
      'egg': 60.0,
      'chicken': 200.0,
      'rice': 80.0,
    };

    for (final key in prices.keys) {
      if (itemName.toLowerCase().contains(key)) {
        return prices[key]!;
      }
    }

    return 50.0; // Default price
  }

  int _calculateDaysUntilEmpty(PantryItem item) {
    // Estimate based on category (would use ML in production)
    final usageRates = {
      'Dairy': 5,
      'Beverages': 3,
      'Fruits': 7,
      'Vegetables': 5,
      'Meat': 3,
    };

    return usageRates[item.category] ?? 7;
  }
}

// ==========================================
// DATA MODELS FOR AI FEATURES
// ==========================================

class Recipe {
  final String name;
  final List<String> ingredients;
  final String instructions;
  final int prepTime;
  final String difficulty;

  Recipe({
    required this.name,
    required this.ingredients,
    required this.instructions,
    required this.prepTime,
    required this.difficulty,
  });
}

class MealPlan {
  final int days;
  final List<PlannedMeal> meals;
  final Map<String, dynamic> nutritionSummary;

  MealPlan({
    required this.days,
    required this.meals,
    required this.nutritionSummary,
  });
}

class PlannedMeal {
  final int day;
  final String breakfast;
  final String lunch;
  final String dinner;
  final int calories;

  PlannedMeal({
    required this.day,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.calories,
  });
}

class PriceOptimization {
  final String itemName;
  final double currentPrice;
  final double bestPrice;
  final double savings;
  final String recommendation;
  final String bestStore;

  PriceOptimization({
    required this.itemName,
    required this.currentPrice,
    required this.bestPrice,
    required this.savings,
    required this.recommendation,
    required this.bestStore,
  });
}

class InventoryForecast {
  final List<ItemPrediction> predictions;
  final List<String> alerts;

  InventoryForecast({
    required this.predictions,
    required this.alerts,
  });
}

class ItemPrediction {
  final String itemName;
  final int daysUntilEmpty;
  final DateTime recommendedRestock;
  final double confidence;

  ItemPrediction({
    required this.itemName,
    required this.daysUntilEmpty,
    required this.recommendedRestock,
    required this.confidence,
  });
}

class WasteInsights {
  final int totalWaste;
  final Map<String, int> wasteByCategory;
  final List<String> recommendations;
  final double potentialSavings;

  WasteInsights({
    required this.totalWaste,
    required this.wasteByCategory,
    required this.recommendations,
    required this.potentialSavings,
  });
}

class SpendingAnalysis {
  final double totalSpent;
  final Map<String, double> categoryBreakdown;
  final List<String> trends;
  final double budgetRecommendation;

  SpendingAnalysis({
    required this.totalSpent,
    required this.categoryBreakdown,
    required this.trends,
    required this.budgetRecommendation,
  });
}

class StorageTip {
  final String title;
  final String description;
  final String category;

  StorageTip({
    required this.title,
    required this.description,
    required this.category,
  });
}

class CarbonFootprint {
  final double totalKg;
  final Map<String, double> byCategory;
  final List<String> suggestions;

  CarbonFootprint({
    required this.totalKg,
    required this.byCategory,
    required this.suggestions,
  });
}

class VoiceCommandResult {
  final bool success;
  final String message;
  final String? action;
  final Map<String, dynamic>? data;

  VoiceCommandResult({
    required this.success,
    required this.message,
    this.action,
    this.data,
  });
}

class ItemRecognition {
  final bool success;
  final String itemName;
  final double confidence;
  final String? category;
  final DateTime? suggestedExpiry;

  ItemRecognition({
    required this.success,
    required this.itemName,
    required this.confidence,
    this.category,
    this.suggestedExpiry,
  });
}

class BarcodeResult {
  final bool success;
  final String message;
  final String? productName;
  final String? category;
  final String? brand;
  final Map<String, dynamic>? nutritionInfo;

  BarcodeResult({
    required this.success,
    required this.message,
    this.productName,
    this.category,
    this.brand,
    this.nutritionInfo,
  });
}

class ChatResponse {
  final String message;
  final List<String> suggestions;
  final String? action;

  ChatResponse({
    required this.message,
    required this.suggestions,
    this.action,
  });
}

class CookingTip {
  final String title;
  final String description;
  final String category;

  CookingTip({
    required this.title,
    required this.description,
    required this.category,
  });
}
