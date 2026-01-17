/// User preferences for personalized AI recipe suggestions
class UserPreferences {
  final String? country;
  final String? preferredCuisine;
  final List<String> dietaryRestrictions;
  final List<String> allergies;
  final List<String> dislikedFoods;

  UserPreferences({
    this.country,
    this.preferredCuisine,
    this.dietaryRestrictions = const [],
    this.allergies = const [],
    this.dislikedFoods = const [],
  });

  Map<String, dynamic> toJson() => {
    'country': country,
    'preferredCuisine': preferredCuisine,
    'dietaryRestrictions': dietaryRestrictions,
    'allergies': allergies,
    'dislikedFoods': dislikedFoods,
  };

  factory UserPreferences.fromJson(Map<String, dynamic> json) => UserPreferences(
    country: json['country'],
    preferredCuisine: json['preferredCuisine'],
    dietaryRestrictions: json['dietaryRestrictions'] != null 
        ? List<String>.from(json['dietaryRestrictions']) 
        : [],
    allergies: json['allergies'] != null 
        ? List<String>.from(json['allergies']) 
        : [],
    dislikedFoods: json['dislikedFoods'] != null 
        ? List<String>.from(json['dislikedFoods']) 
        : [],
  );

  UserPreferences copyWith({
    String? country,
    String? preferredCuisine,
    List<String>? dietaryRestrictions,
    List<String>? allergies,
    List<String>? dislikedFoods,
  }) {
    return UserPreferences(
      country: country ?? this.country,
      preferredCuisine: preferredCuisine ?? this.preferredCuisine,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      allergies: allergies ?? this.allergies,
      dislikedFoods: dislikedFoods ?? this.dislikedFoods,
    );
  }

  bool hasRestrictions() {
    return dietaryRestrictions.isNotEmpty || 
           allergies.isNotEmpty || 
           dislikedFoods.isNotEmpty;
  }

  /// Check if a recipe ingredient conflicts with user preferences
  bool isIngredientAllowed(String ingredient) {
    final lower = ingredient.toLowerCase();
    
    // Check allergies
    for (final allergy in allergies) {
      if (lower.contains(allergy.toLowerCase())) {
        return false;
      }
    }
    
    // Check disliked foods
    for (final disliked in dislikedFoods) {
      if (lower.contains(disliked.toLowerCase())) {
        return false;
      }
    }
    
    return true;
  }

  /// Check if dietary restrictions are met
  bool meetsRestrictions(List<String> recipeCategories) {
    for (final restriction in dietaryRestrictions) {
      final lower = restriction.toLowerCase();
      
      if (lower.contains('vegetarian')) {
        // Vegetarian can't have meat
        if (recipeCategories.any((cat) => 
            cat.toLowerCase().contains('meat') || 
            cat.toLowerCase().contains('chicken') ||
            cat.toLowerCase().contains('fish'))) {
          return false;
        }
      }
      
      if (lower.contains('vegan')) {
        // Vegan can't have any animal products
        if (recipeCategories.any((cat) => 
            cat.toLowerCase().contains('meat') || 
            cat.toLowerCase().contains('dairy') ||
            cat.toLowerCase().contains('egg') ||
            cat.toLowerCase().contains('fish'))) {
          return false;
        }
      }
      
      if (lower.contains('gluten-free') || lower.contains('celiac')) {
        if (recipeCategories.any((cat) => 
            cat.toLowerCase().contains('wheat') || 
            cat.toLowerCase().contains('bread') ||
            cat.toLowerCase().contains('pasta'))) {
          return false;
        }
      }
      
      if (lower.contains('lactose') || lower.contains('dairy-free')) {
        if (recipeCategories.any((cat) => 
            cat.toLowerCase().contains('dairy') ||
            cat.toLowerCase().contains('milk') ||
            cat.toLowerCase().contains('cheese'))) {
          return false;
        }
      }
    }
    
    return true;
  }
}

/// Common dietary restrictions
class DietaryRestrictions {
  static const String vegetarian = 'Vegetarian';
  static const String vegan = 'Vegan';
  static const String glutenFree = 'Gluten-Free';
  static const String dairyFree = 'Dairy-Free';
  static const String halal = 'Halal';
  static const String kosher = 'Kosher';
  static const String pescatarian = 'Pescatarian';
  static const String keto = 'Keto';
  static const String paleo = 'Paleo';
  
  static List<String> get all => [
    vegetarian, vegan, glutenFree, dairyFree, 
    halal, kosher, pescatarian, keto, paleo,
  ];
}

/// Common allergens
class CommonAllergens {
  static const String peanuts = 'Peanuts';
  static const String treeNuts = 'Tree Nuts';
  static const String dairy = 'Dairy/Milk';
  static const String eggs = 'Eggs';
  static const String soy = 'Soy';
  static const String wheat = 'Wheat/Gluten';
  static const String shellfish = 'Shellfish';
  static const String fish = 'Fish';
  static const String sesame = 'Sesame';
  
  static List<String> get all => [
    peanuts, treeNuts, dairy, eggs, soy, 
    wheat, shellfish, fish, sesame,
  ];
}
