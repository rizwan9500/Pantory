import 'dart:convert';
import 'package:http/http.dart' as http;

/// Advanced ingredient search service integrating multiple data sources
/// Supports USDA FoodData Central, Open Food Facts, and extensible for more
class IngredientSearchService {
  // API Configuration
  static const String usdaApiKey = 'DEMO_KEY'; // Replace with actual API key
  static const String usdaBaseUrl = 'https://api.nal.usda.gov/fdc/v1';
  static const String openFoodFactsBaseUrl = 'https://world.openfoodfacts.org/api/v2';
  
  // Additional data sources for comprehensive coverage
  static const String nutritionixBaseUrl = 'https://trackapi.nutritionix.com/v2';
  static const String edamamBaseUrl = 'https://api.edamam.com/api/food-database/v2';
  
  /// Search ingredients from multiple sources
  /// Returns aggregated results from USDA, Open Food Facts, and other sources
  Future<IngredientSearchResult> searchIngredients(String query, {
    int limit = 20,
    bool includeUSDA = true,
    bool includeOpenFoodFacts = true,
    bool includeNutritionix = false,
    bool includeEdamam = false,
  }) async {
    final results = <IngredientItem>[];
    final errors = <String>[];
    
    // Search USDA FoodData Central (600,000+ foods)
    if (includeUSDA) {
      try {
        final usdaResults = await _searchUSDA(query, limit);
        results.addAll(usdaResults);
      } catch (e) {
        errors.add('USDA: ${e.toString()}');
      }
    }
    
    // Search Open Food Facts (2.8M+ products)
    if (includeOpenFoodFacts) {
      try {
        final offResults = await _searchOpenFoodFacts(query, limit);
        results.addAll(offResults);
      } catch (e) {
        errors.add('Open Food Facts: ${e.toString()}');
      }
    }
    
    // Search Nutritionix (800,000+ items)
    if (includeNutritionix) {
      try {
        final nutritionixResults = await _searchNutritionix(query, limit);
        results.addAll(nutritionixResults);
      } catch (e) {
        errors.add('Nutritionix: ${e.toString()}');
      }
    }
    
    // Search Edamam (900,000+ foods)
    if (includeEdamam) {
      try {
        final edamamResults = await _searchEdamam(query, limit);
        results.addAll(edamamResults);
      } catch (e) {
        errors.add('Edamam: ${e.toString()}');
      }
    }
    
    // Remove duplicates and rank by relevance
    final uniqueResults = _deduplicateAndRank(results, query);
    
    return IngredientSearchResult(
      query: query,
      items: uniqueResults.take(limit).toList(),
      totalFound: uniqueResults.length,
      sources: _getActiveSources(includeUSDA, includeOpenFoodFacts, includeNutritionix, includeEdamam),
      errors: errors,
    );
  }
  
  /// Search by barcode across multiple databases
  Future<IngredientItem?> searchByBarcode(String barcode) async {
    // Try Open Food Facts first (best barcode database)
    try {
      final result = await _searchOpenFoodFactsByBarcode(barcode);
      if (result != null) return result;
    } catch (e) {
      print('Open Food Facts barcode error: $e');
    }
    
    // Try USDA if available
    try {
      final result = await _searchUSDAByGTIN(barcode);
      if (result != null) return result;
    } catch (e) {
      print('USDA barcode error: $e');
    }
    
    return null;
  }
  
  /// Get ingredient details with comprehensive nutritional information
  Future<IngredientDetails?> getIngredientDetails(String id, String source) async {
    switch (source) {
      case 'USDA':
        return await _getUSDADetails(id);
      case 'OpenFoodFacts':
        return await _getOpenFoodFactsDetails(id);
      case 'Nutritionix':
        return await _getNutritionixDetails(id);
      case 'Edamam':
        return await _getEdamamDetails(id);
      default:
        return null;
    }
  }
  
  /// Get ingredient varieties (e.g., different types of apples)
  Future<List<IngredientVariety>> getIngredientVarieties(String baseIngredient) async {
    final varieties = <IngredientVariety>[];
    
    // Search for varieties in USDA
    final usdaQuery = await _searchUSDA(baseIngredient, 100);
    for (var item in usdaQuery) {
      if (_isVariety(item.name, baseIngredient)) {
        varieties.add(IngredientVariety(
          name: item.name,
          category: item.category,
          source: 'USDA',
          scientificName: item.scientificName,
        ));
      }
    }
    
    return varieties;
  }
  
  // ============================================
  // USDA FoodData Central Integration
  // ============================================
  
  Future<List<IngredientItem>> _searchUSDA(String query, int limit) async {
    final url = Uri.parse('$usdaBaseUrl/foods/search');
    final response = await http.get(
      url.replace(queryParameters: {
        'api_key': usdaApiKey,
        'query': query,
        'pageSize': limit.toString(),
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final foods = data['foods'] as List? ?? [];
      
      return foods.map((food) => IngredientItem(
        id: food['fdcId'].toString(),
        name: food['description'] ?? '',
        brand: food['brandOwner'],
        category: food['foodCategory'] ?? 'Unknown',
        source: 'USDA',
        barcode: food['gtinUpc'],
        scientificName: food['scientificName'],
        nutrients: _parseUSDANutrients(food['foodNutrients']),
      )).toList();
    }
    
    throw Exception('USDA API error: ${response.statusCode}');
  }
  
  Future<IngredientItem?> _searchUSDAByGTIN(String barcode) async {
    final results = await _searchUSDA(barcode, 1);
    return results.isNotEmpty ? results.first : null;
  }
  
  Future<IngredientDetails?> _getUSDADetails(String fdcId) async {
    final url = Uri.parse('$usdaBaseUrl/food/$fdcId');
    final response = await http.get(
      url.replace(queryParameters: {'api_key': usdaApiKey}),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return IngredientDetails.fromUSDA(data);
    }
    
    return null;
  }
  
  Map<String, double> _parseUSDANutrients(dynamic nutrients) {
    final result = <String, double>{};
    if (nutrients is List) {
      for (var nutrient in nutrients) {
        final name = nutrient['nutrientName']?.toString() ?? '';
        final value = (nutrient['value'] as num?)?.toDouble() ?? 0.0;
        if (name.isNotEmpty && value > 0) {
          result[name] = value;
        }
      }
    }
    return result;
  }
  
  // ============================================
  // Open Food Facts Integration
  // ============================================
  
  Future<List<IngredientItem>> _searchOpenFoodFacts(String query, int limit) async {
    final url = Uri.parse('$openFoodFactsBaseUrl/search');
    final response = await http.get(
      url.replace(queryParameters: {
        'search_terms': query,
        'page_size': limit.toString(),
        'fields': 'code,product_name,brands,categories,nutriments,ingredients_text',
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final products = data['products'] as List? ?? [];
      
      return products.map((product) => IngredientItem(
        id: product['code']?.toString() ?? '',
        name: product['product_name'] ?? 'Unknown Product',
        brand: product['brands'],
        category: product['categories']?.toString().split(',').first ?? 'Unknown',
        source: 'OpenFoodFacts',
        barcode: product['code']?.toString(),
        nutrients: _parseOFFNutrients(product['nutriments']),
        ingredients: product['ingredients_text'],
      )).toList();
    }
    
    throw Exception('Open Food Facts API error: ${response.statusCode}');
  }
  
  Future<IngredientItem?> _searchOpenFoodFactsByBarcode(String barcode) async {
    final url = Uri.parse('$openFoodFactsBaseUrl/product/$barcode');
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 1) {
        final product = data['product'];
        return IngredientItem(
          id: barcode,
          name: product['product_name'] ?? 'Unknown Product',
          brand: product['brands'],
          category: product['categories']?.toString().split(',').first ?? 'Unknown',
          source: 'OpenFoodFacts',
          barcode: barcode,
          nutrients: _parseOFFNutrients(product['nutriments']),
          ingredients: product['ingredients_text'],
          imageUrl: product['image_url'],
        );
      }
    }
    
    return null;
  }
  
  Future<IngredientDetails?> _getOpenFoodFactsDetails(String code) async {
    final item = await _searchOpenFoodFactsByBarcode(code);
    return item != null ? IngredientDetails.fromItem(item) : null;
  }
  
  Map<String, double> _parseOFFNutrients(dynamic nutriments) {
    final result = <String, double>{};
    if (nutriments is Map) {
      nutriments.forEach((key, value) {
        if (value is num) {
          result[key.toString()] = value.toDouble();
        }
      });
    }
    return result;
  }
  
  // ============================================
  // Nutritionix Integration (requires API key)
  // ============================================
  
  Future<List<IngredientItem>> _searchNutritionix(String query, int limit) async {
    // Requires x-app-id and x-app-key headers
    // Implementation placeholder - add credentials when available
    return [];
  }
  
  Future<IngredientDetails?> _getNutritionixDetails(String id) async {
    return null;
  }
  
  // ============================================
  // Edamam Integration (requires API key)
  // ============================================
  
  Future<List<IngredientItem>> _searchEdamam(String query, int limit) async {
    // Requires app_id and app_key
    // Implementation placeholder - add credentials when available
    return [];
  }
  
  Future<IngredientDetails?> _getEdamamDetails(String id) async {
    return null;
  }
  
  // ============================================
  // Helper Methods
  // ============================================
  
  List<IngredientItem> _deduplicateAndRank(List<IngredientItem> items, String query) {
    // Remove duplicates based on name similarity
    final seen = <String>{};
    final unique = <IngredientItem>[];
    
    for (var item in items) {
      final key = item.name.toLowerCase().trim();
      if (!seen.contains(key)) {
        seen.add(key);
        unique.add(item);
      }
    }
    
    // Rank by relevance to query
    unique.sort((a, b) {
      final aScore = _relevanceScore(a.name, query);
      final bScore = _relevanceScore(b.name, query);
      return bScore.compareTo(aScore);
    });
    
    return unique;
  }
  
  int _relevanceScore(String name, String query) {
    final nameLower = name.toLowerCase();
    final queryLower = query.toLowerCase();
    
    if (nameLower == queryLower) return 100;
    if (nameLower.startsWith(queryLower)) return 80;
    if (nameLower.contains(queryLower)) return 60;
    
    // Check word matches
    final nameWords = nameLower.split(' ');
    final queryWords = queryLower.split(' ');
    int matches = 0;
    for (var qWord in queryWords) {
      for (var nWord in nameWords) {
        if (nWord.contains(qWord) || qWord.contains(nWord)) {
          matches++;
        }
      }
    }
    
    return matches * 10;
  }
  
  bool _isVariety(String itemName, String baseIngredient) {
    final nameLower = itemName.toLowerCase();
    final baseLower = baseIngredient.toLowerCase();
    return nameLower.contains(baseLower) && nameLower != baseLower;
  }
  
  List<String> _getActiveSources(bool usda, bool off, bool nutritionix, bool edamam) {
    final sources = <String>[];
    if (usda) sources.add('USDA FoodData Central');
    if (off) sources.add('Open Food Facts');
    if (nutritionix) sources.add('Nutritionix');
    if (edamam) sources.add('Edamam');
    return sources;
  }
}

// ============================================
// Data Models
// ============================================

class IngredientSearchResult {
  final String query;
  final List<IngredientItem> items;
  final int totalFound;
  final List<String> sources;
  final List<String> errors;
  
  IngredientSearchResult({
    required this.query,
    required this.items,
    required this.totalFound,
    required this.sources,
    required this.errors,
  });
}

class IngredientItem {
  final String id;
  final String name;
  final String? brand;
  final String category;
  final String source;
  final String? barcode;
  final String? scientificName;
  final String? ingredients;
  final String? imageUrl;
  final Map<String, double> nutrients;
  
  IngredientItem({
    required this.id,
    required this.name,
    this.brand,
    required this.category,
    required this.source,
    this.barcode,
    this.scientificName,
    this.ingredients,
    this.imageUrl,
    this.nutrients = const {},
  });
  
  String get displayName {
    if (brand != null && brand!.isNotEmpty) {
      return '$name ($brand)';
    }
    return name;
  }
}

class IngredientDetails {
  final String id;
  final String name;
  final String? brand;
  final String category;
  final String source;
  final String? barcode;
  final String? scientificName;
  final String? ingredients;
  final String? imageUrl;
  final Map<String, double> nutrients;
  final Map<String, String> additionalInfo;
  
  IngredientDetails({
    required this.id,
    required this.name,
    this.brand,
    required this.category,
    required this.source,
    this.barcode,
    this.scientificName,
    this.ingredients,
    this.imageUrl,
    this.nutrients = const {},
    this.additionalInfo = const {},
  });
  
  factory IngredientDetails.fromUSDA(Map<String, dynamic> data) {
    return IngredientDetails(
      id: data['fdcId'].toString(),
      name: data['description'] ?? '',
      brand: data['brandOwner'],
      category: data['foodCategory'] ?? 'Unknown',
      source: 'USDA',
      barcode: data['gtinUpc'],
      scientificName: data['scientificName'],
      nutrients: {}, // Parse from foodNutrients
      additionalInfo: {
        'dataType': data['dataType'] ?? '',
        'publicationDate': data['publicationDate'] ?? '',
      },
    );
  }
  
  factory IngredientDetails.fromItem(IngredientItem item) {
    return IngredientDetails(
      id: item.id,
      name: item.name,
      brand: item.brand,
      category: item.category,
      source: item.source,
      barcode: item.barcode,
      scientificName: item.scientificName,
      ingredients: item.ingredients,
      imageUrl: item.imageUrl,
      nutrients: item.nutrients,
    );
  }
}

class IngredientVariety {
  final String name;
  final String category;
  final String source;
  final String? scientificName;
  
  IngredientVariety({
    required this.name,
    required this.category,
    required this.source,
    this.scientificName,
  });
}
