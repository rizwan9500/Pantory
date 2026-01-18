import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

/// Supabase-based ingredient database service
/// Provides self-hosted ingredient database with full control
/// No external API dependencies - all data stored in your Supabase instance
class SupabaseIngredientService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  /// Search ingredients from Supabase database
  /// Returns results from your own ingredient database
  Future<List<IngredientItem>> searchIngredients(String query, {int limit = 20}) async {
    try {
      // Search with full-text search on name, scientific name, and variety
      final response = await _supabase
          .from('ingredients')
          .select()
          .or('name.ilike.%$query%,scientific_name.ilike.%$query%,variety.ilike.%$query%')
          .limit(limit);
      
      return (response as List)
          .map((item) => IngredientItem.fromSupabase(item))
          .toList();
    } catch (e) {
      print('Error searching Supabase ingredients: $e');
      return [];
    }
  }
  
  /// Get ingredient by ID
  Future<IngredientItem?> getIngredientById(String id) async {
    try {
      final response = await _supabase
          .from('ingredients')
          .select()
          .eq('id', id)
          .single();
      
      return IngredientItem.fromSupabase(response);
    } catch (e) {
      print('Error getting ingredient: $e');
      return null;
    }
  }
  
  /// Lookup ingredient by barcode
  Future<IngredientItem?> lookupByBarcode(String barcode) async {
    try {
      final response = await _supabase
          .from('ingredients')
          .select()
          .eq('barcode', barcode)
          .maybeSingle();
      
      if (response == null) return null;
      return IngredientItem.fromSupabase(response);
    } catch (e) {
      print('Error looking up barcode: $e');
      return null;
    }
  }
  
  /// Add new ingredient to database
  /// Allows users to contribute to the ingredient database
  Future<IngredientItem?> addIngredient(IngredientItem ingredient) async {
    try {
      final response = await _supabase
          .from('ingredients')
          .insert(ingredient.toSupabase())
          .select()
          .single();
      
      return IngredientItem.fromSupabase(response);
    } catch (e) {
      print('Error adding ingredient: $e');
      return null;
    }
  }
  
  /// Update existing ingredient
  Future<bool> updateIngredient(String id, Map<String, dynamic> updates) async {
    try {
      await _supabase
          .from('ingredients')
          .update(updates)
          .eq('id', id);
      
      return true;
    } catch (e) {
      print('Error updating ingredient: $e');
      return false;
    }
  }
  
  /// Upload ingredient image
  Future<String?> uploadIngredientImage(File imageFile, String ingredientId) async {
    try {
      final fileName = 'ingredient_${ingredientId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'ingredients/$fileName';
      
      await _supabase.storage
          .from('ingredient-images')
          .upload(path, imageFile);
      
      final url = _supabase.storage
          .from('ingredient-images')
          .getPublicUrl(path);
      
      return url;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
  
  /// Get popular/trending ingredients
  Future<List<IngredientItem>> getPopularIngredients({int limit = 20}) async {
    try {
      final response = await _supabase
          .from('ingredients')
          .select()
          .order('usage_count', ascending: false)
          .limit(limit);
      
      return (response as List)
          .map((item) => IngredientItem.fromSupabase(item))
          .toList();
    } catch (e) {
      print('Error getting popular ingredients: $e');
      return [];
    }
  }
  
  /// Get ingredients by category
  Future<List<IngredientItem>> getIngredientsByCategory(String category, {int limit = 50}) async {
    try {
      final response = await _supabase
          .from('ingredients')
          .select()
          .eq('category', category)
          .order('name')
          .limit(limit);
      
      return (response as List)
          .map((item) => IngredientItem.fromSupabase(item))
          .toList();
    } catch (e) {
      print('Error getting ingredients by category: $e');
      return [];
    }
  }
  
  /// Get all categories
  Future<List<String>> getCategories() async {
    try {
      final response = await _supabase
          .from('ingredient_categories')
          .select('name')
          .order('name');
      
      return (response as List)
          .map((item) => item['name'] as String)
          .toList();
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }
  
  /// Increment usage count when ingredient is added to pantry
  Future<void> incrementUsageCount(String ingredientId) async {
    try {
      await _supabase.rpc('increment_ingredient_usage', params: {
        'ingredient_id': ingredientId,
      });
    } catch (e) {
      print('Error incrementing usage count: $e');
    }
  }
  
  /// Search with filters
  Future<List<IngredientItem>> advancedSearch({
    required String query,
    List<String>? categories,
    List<String>? dietaryTags,
    List<String>? excludeAllergens,
    int limit = 20,
  }) async {
    try {
      var queryBuilder = _supabase
          .from('ingredients')
          .select();
      
      // Add search filter
      if (query.isNotEmpty) {
        queryBuilder = queryBuilder.or(
          'name.ilike.%$query%,scientific_name.ilike.%$query%,variety.ilike.%$query%'
        );
      }
      
      // Add category filter
      if (categories != null && categories.isNotEmpty) {
        queryBuilder = queryBuilder.inFilter('category', categories);
      }
      
      // Add dietary tags filter
      if (dietaryTags != null && dietaryTags.isNotEmpty) {
        for (var tag in dietaryTags) {
          queryBuilder = queryBuilder.contains('dietary_tags', [tag]);
        }
      }
      
      // Add allergen exclusion filter
      if (excludeAllergens != null && excludeAllergens.isNotEmpty) {
        for (var allergen in excludeAllergens) {
          queryBuilder = queryBuilder.not('allergens', 'cs', '{$allergen}');
        }
      }
      
      final response = await queryBuilder.limit(limit);
      
      return (response as List)
          .map((item) => IngredientItem.fromSupabase(item))
          .toList();
    } catch (e) {
      print('Error in advanced search: $e');
      return [];
    }
  }
  
  /// Bulk import ingredients (for initial seeding)
  Future<int> bulkImportIngredients(List<Map<String, dynamic>> ingredients) async {
    try {
      await _supabase
          .from('ingredients')
          .insert(ingredients);
      
      return ingredients.length;
    } catch (e) {
      print('Error bulk importing: $e');
      return 0;
    }
  }
  
  /// Get ingredient suggestions based on user's pantry
  Future<List<IngredientItem>> getSuggestionsBasedOnPantry(List<String> pantryIngredientIds) async {
    try {
      final response = await _supabase.rpc('get_ingredient_suggestions', params: {
        'user_pantry_ids': pantryIngredientIds,
      });
      
      return (response as List)
          .map((item) => IngredientItem.fromSupabase(item))
          .toList();
    } catch (e) {
      print('Error getting suggestions: $e');
      return [];
    }
  }
}

/// Ingredient item model for Supabase
class IngredientItem {
  final String id;
  final String name;
  final String? scientificName;
  final String? variety;
  final String? category;
  final String? imageUrl;
  final String? barcode;
  final Map<String, dynamic>? nutritionalInfo;
  final List<String>? allergens;
  final List<String>? dietaryTags;
  final String? brandName;
  final int usageCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  IngredientItem({
    required this.id,
    required this.name,
    this.scientificName,
    this.variety,
    this.category,
    this.imageUrl,
    this.barcode,
    this.nutritionalInfo,
    this.allergens,
    this.dietaryTags,
    this.brandName,
    this.usageCount = 0,
    required this.createdAt,
    this.updatedAt,
  });
  
  /// Create from Supabase response
  factory IngredientItem.fromSupabase(Map<String, dynamic> data) {
    return IngredientItem(
      id: data['id'] as String,
      name: data['name'] as String,
      scientificName: data['scientific_name'] as String?,
      variety: data['variety'] as String?,
      category: data['category'] as String?,
      imageUrl: data['image_url'] as String?,
      barcode: data['barcode'] as String?,
      nutritionalInfo: data['nutritional_info'] as Map<String, dynamic>?,
      allergens: (data['allergens'] as List?)?.cast<String>(),
      dietaryTags: (data['dietary_tags'] as List?)?.cast<String>(),
      brandName: data['brand_name'] as String?,
      usageCount: data['usage_count'] as int? ?? 0,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: data['updated_at'] != null 
          ? DateTime.parse(data['updated_at'] as String) 
          : null,
    );
  }
  
  /// Convert to Supabase format for insertion
  Map<String, dynamic> toSupabase() {
    return {
      'name': name,
      'scientific_name': scientificName,
      'variety': variety,
      'category': category,
      'image_url': imageUrl,
      'barcode': barcode,
      'nutritional_info': nutritionalInfo,
      'allergens': allergens,
      'dietary_tags': dietaryTags,
      'brand_name': brandName,
      'usage_count': usageCount,
    };
  }
  
  /// Display name with variety
  String get displayName {
    if (variety != null && variety!.isNotEmpty) {
      return '$variety $name';
    }
    return name;
  }
}
