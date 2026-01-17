/// Comprehensive data lists for user preferences
/// This data would ideally come from an LLM API in production

class PreferenceData {
  // ==========================================
  // COUNTRIES (195+ countries worldwide)
  // ==========================================
  static const List<String> countries = [
    'Afghanistan', 'Albania', 'Algeria', 'Andorra', 'Angola',
    'Antigua and Barbuda', 'Argentina', 'Armenia', 'Australia', 'Austria',
    'Azerbaijan', 'Bahamas', 'Bahrain', 'Bangladesh', 'Barbados',
    'Belarus', 'Belgium', 'Belize', 'Benin', 'Bhutan',
    'Bolivia', 'Bosnia and Herzegovina', 'Botswana', 'Brazil', 'Brunei',
    'Bulgaria', 'Burkina Faso', 'Burundi', 'Cambodia', 'Cameroon',
    'Canada', 'Cape Verde', 'Central African Republic', 'Chad', 'Chile',
    'China', 'Colombia', 'Comoros', 'Congo', 'Costa Rica',
    'Croatia', 'Cuba', 'Cyprus', 'Czech Republic', 'Denmark',
    'Djibouti', 'Dominica', 'Dominican Republic', 'East Timor', 'Ecuador',
    'Egypt', 'El Salvador', 'Equatorial Guinea', 'Eritrea', 'Estonia',
    'Ethiopia', 'Fiji', 'Finland', 'France', 'Gabon',
    'Gambia', 'Georgia', 'Germany', 'Ghana', 'Greece',
    'Grenada', 'Guatemala', 'Guinea', 'Guinea-Bissau', 'Guyana',
    'Haiti', 'Honduras', 'Hungary', 'Iceland', 'India',
    'Indonesia', 'Iran', 'Iraq', 'Ireland', 'Israel',
    'Italy', 'Ivory Coast', 'Jamaica', 'Japan', 'Jordan',
    'Kazakhstan', 'Kenya', 'Kiribati', 'North Korea', 'South Korea',
    'Kuwait', 'Kyrgyzstan', 'Laos', 'Latvia', 'Lebanon',
    'Lesotho', 'Liberia', 'Libya', 'Liechtenstein', 'Lithuania',
    'Luxembourg', 'Macedonia', 'Madagascar', 'Malawi', 'Malaysia',
    'Maldives', 'Mali', 'Malta', 'Marshall Islands', 'Mauritania',
    'Mauritius', 'Mexico', 'Micronesia', 'Moldova', 'Monaco',
    'Mongolia', 'Montenegro', 'Morocco', 'Mozambique', 'Myanmar',
    'Namibia', 'Nauru', 'Nepal', 'Netherlands', 'New Zealand',
    'Nicaragua', 'Niger', 'Nigeria', 'Norway', 'Oman',
    'Pakistan', 'Palau', 'Palestine', 'Panama', 'Papua New Guinea',
    'Paraguay', 'Peru', 'Philippines', 'Poland', 'Portugal',
    'Qatar', 'Romania', 'Russia', 'Rwanda', 'Saint Kitts and Nevis',
    'Saint Lucia', 'Saint Vincent and the Grenadines', 'Samoa', 'San Marino', 'Sao Tome and Principe',
    'Saudi Arabia', 'Senegal', 'Serbia', 'Seychelles', 'Sierra Leone',
    'Singapore', 'Slovakia', 'Slovenia', 'Solomon Islands', 'Somalia',
    'South Africa', 'South Sudan', 'Spain', 'Sri Lanka', 'Sudan',
    'Suriname', 'Swaziland', 'Sweden', 'Switzerland', 'Syria',
    'Taiwan', 'Tajikistan', 'Tanzania', 'Thailand', 'Togo',
    'Tonga', 'Trinidad and Tobago', 'Tunisia', 'Turkey', 'Turkmenistan',
    'Tuvalu', 'Uganda', 'Ukraine', 'United Arab Emirates', 'United Kingdom',
    'United States', 'Uruguay', 'Uzbekistan', 'Vanuatu', 'Vatican City',
    'Venezuela', 'Vietnam', 'Yemen', 'Zambia', 'Zimbabwe',
  ];

  // ==========================================
  // CUISINES (100+ world cuisines)
  // ==========================================
  static const List<String> cuisines = [
    'Afghan', 'African', 'Albanian', 'American', 'Andhra',
    'Anglo-Indian', 'Arab', 'Argentine', 'Armenian', 'Asian Fusion',
    'Assamese', 'Australian', 'Austrian', 'Awadhi', 'Azerbaijani',
    'Bangladeshi', 'Barbecue', 'Basque', 'Belgian', 'Bengali',
    'Brazilian', 'British', 'Burmese', 'Cajun', 'Cambodian',
    'Cantonese', 'Caribbean', 'Catalan', 'Chinese', 'Colombian',
    'Continental', 'Creole', 'Croatian', 'Cuban', 'Cypriot',
    'Czech', 'Danish', 'Dutch', 'Eastern European', 'Egyptian',
    'English', 'Ethiopian', 'European', 'Fast Food', 'Filipino',
    'Finnish', 'French', 'Fusion', 'Georgian', 'German',
    'Goan', 'Greek', 'Gujarati', 'Hawaiian', 'Healthy',
    'Hungarian', 'Hyderabadi', 'Indian', 'Indonesian', 'International',
    'Iranian', 'Iraqi', 'Irish', 'Israeli', 'Italian',
    'Jamaican', 'Japanese', 'Jewish', 'Jordanian', 'Karnataka',
    'Kashmiri', 'Kerala', 'Korean', 'Kurdish', 'Latin American',
    'Lebanese', 'Malaysian', 'Maharashtrian', 'Mediterranean', 'Mexican',
    'Middle Eastern', 'Modern Indian', 'Mongolian', 'Moroccan', 'Mughlai',
    'Nepalese', 'New American', 'Nigerian', 'North Indian', 'Norwegian',
    'Pakistani', 'Pan Asian', 'Parsi', 'Persian', 'Peruvian',
    'Polish', 'Portuguese', 'Punjabi', 'Rajasthani', 'Russian',
    'Scandinavian', 'Scottish', 'Seafood', 'Singaporean', 'South American',
    'South Indian', 'Spanish', 'Sri Lankan', 'Street Food', 'Swedish',
    'Swiss', 'Syrian', 'Taiwanese', 'Tamil', 'Thai',
    'Tibetan', 'Turkish', 'Ukrainian', 'Vegetarian', 'Venezuelan',
    'Vietnamese', 'Welsh', 'Western', 'World Cuisine',
  ];

  // ==========================================
  // DIETARY RESTRICTIONS (Expanded list)
  // ==========================================
  static const List<String> dietaryRestrictions = [
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Dairy-Free',
    'Lactose Intolerant',
    'Halal',
    'Kosher',
    'Pescatarian',
    'Keto',
    'Paleo',
    'Low-Carb',
    'Low-Fat',
    'Low-Sodium',
    'Sugar-Free',
    'Diabetic-Friendly',
    'Raw Food',
    'Organic Only',
    'Non-GMO',
    'Whole30',
    'Mediterranean Diet',
    'DASH Diet',
    'Carnivore',
    'Flexitarian',
    'Macrobiotic',
    'Low-FODMAP',
    'Ovo-Vegetarian',
    'Lacto-Vegetarian',
    'Fruitarian',
    'Jain',
    'No Pork',
    'No Beef',
    'No Red Meat',
    'No Processed Foods',
  ];

  // ==========================================
  // ALLERGENS (Comprehensive list)
  // ==========================================
  static const List<String> allergens = [
    // Major Allergens (FDA Top 9)
    'Peanuts',
    'Tree Nuts (Almonds)',
    'Tree Nuts (Walnuts)',
    'Tree Nuts (Cashews)',
    'Tree Nuts (Pistachios)',
    'Tree Nuts (Pecans)',
    'Tree Nuts (Hazelnuts)',
    'Tree Nuts (Macadamia)',
    'Tree Nuts (Brazil Nuts)',
    'Dairy/Milk',
    'Eggs',
    'Soy',
    'Wheat/Gluten',
    'Shellfish (Shrimp)',
    'Shellfish (Crab)',
    'Shellfish (Lobster)',
    'Shellfish (Oysters)',
    'Shellfish (Clams)',
    'Fish (Salmon)',
    'Fish (Tuna)',
    'Fish (Cod)',
    'Sesame',
    
    // Other Common Allergens
    'Corn',
    'Mustard',
    'Celery',
    'Lupin',
    'Molluscs',
    'Sulfites',
    'Latex (Food Cross-Reactivity)',
    'Coconut',
    'Banana',
    'Avocado',
    'Kiwi',
    'Papaya',
    'Mango',
    'Peach',
    'Cherry',
    'Apple',
    'Tomato',
    'Carrot',
    'Potato',
    'Bell Pepper',
    'Chickpeas',
    'Lentils',
    'Pine Nuts',
    'Sunflower Seeds',
    'Poppy Seeds',
    'Garlic',
    'Onion',
    'Yeast',
    'Chocolate',
    'Vanilla',
    'Cinnamon',
    'Coriander',
    'Fennel',
    'Gelatin',
    'Honey',
    'Red Dye',
    'Yellow Dye',
    'Artificial Sweeteners',
    'MSG (Monosodium Glutamate)',
    'Nitrates',
    'Preservatives',
  ];

  // ==========================================
  // COMMON DISLIKED FOODS (500+ items)
  // ==========================================
  static const List<String> dislikedFoods = [
    // Vegetables
    'Mushrooms', 'Olives', 'Onions', 'Garlic', 'Cilantro', 'Parsley',
    'Bell Peppers', 'Broccoli', 'Brussels Sprouts', 'Cauliflower', 'Cabbage',
    'Asparagus', 'Artichokes', 'Eggplant', 'Zucchini', 'Squash',
    'Beets', 'Turnips', 'Radishes', 'Celery', 'Cucumber',
    'Tomatoes', 'Spinach', 'Kale', 'Arugula', 'Lettuce',
    'Peas', 'Green Beans', 'Lima Beans', 'Okra', 'Leeks',
    
    // Fruits
    'Bananas', 'Avocado', 'Coconut', 'Papaya', 'Mango',
    'Pineapple', 'Kiwi', 'Pomegranate', 'Dragon Fruit', 'Star Fruit',
    'Durian', 'Jackfruit', 'Grapefruit', 'Cantaloupe', 'Honeydew',
    'Watermelon', 'Cherries', 'Dates', 'Figs', 'Prunes',
    
    // Proteins
    'Liver', 'Kidney', 'Tripe', 'Tongue', 'Brain',
    'Oysters', 'Clams', 'Mussels', 'Squid', 'Octopus',
    'Anchovies', 'Sardines', 'Mackerel', 'Salmon', 'Tuna',
    'Tofu', 'Tempeh', 'Seitan', 'Black Beans', 'Kidney Beans',
    'Chickpeas', 'Lentils', 'Lamb', 'Veal', 'Duck',
    
    // Dairy & Alternatives
    'Blue Cheese', 'Feta Cheese', 'Goat Cheese', 'Brie', 'Camembert',
    'Cottage Cheese', 'Ricotta', 'Buttermilk', 'Sour Cream', 'Cream Cheese',
    'Yogurt', 'Kefir', 'Almond Milk', 'Soy Milk', 'Oat Milk',
    
    // Grains & Starches
    'Quinoa', 'Couscous', 'Bulgur', 'Barley', 'Farro',
    'Millet', 'Amaranth', 'Buckwheat', 'Wild Rice', 'Brown Rice',
    'Sweet Potatoes', 'Yams', 'Polenta', 'Grits',
    
    // Condiments & Spices
    'Mayonnaise', 'Mustard', 'Ketchup', 'Relish', 'Pickles',
    'Sauerkraut', 'Kimchi', 'Hot Sauce', 'Horseradish', 'Wasabi',
    'Curry', 'Ginger', 'Turmeric', 'Cumin', 'Cardamom',
    'Fennel', 'Anise', 'Licorice', 'Mint', 'Basil',
    'Oregano', 'Thyme', 'Rosemary', 'Sage', 'Dill',
    
    // Nuts & Seeds
    'Almonds', 'Walnuts', 'Cashews', 'Pecans', 'Hazelnuts',
    'Pistachios', 'Macadamia Nuts', 'Brazil Nuts', 'Sunflower Seeds', 'Pumpkin Seeds',
    'Chia Seeds', 'Flax Seeds', 'Sesame Seeds', 'Pine Nuts',
    
    // Sweets & Desserts
    'Dark Chocolate', 'White Chocolate', 'Coconut (in desserts)', 'Raisins',
    'Candied Fruits', 'Marzipan', 'Fondant', 'Gelatin Desserts',
    'Rice Pudding', 'Tapioca Pudding', 'Bread Pudding',
    
    // Beverages
    'Coffee', 'Tea', 'Milk', 'Buttermilk', 'Kombucha',
    'Beer', 'Wine', 'Whiskey', 'Rum', 'Vodka',
    'Energy Drinks', 'Soda', 'Sports Drinks',
    
    // Ethnic/Specialty Foods
    'Sushi', 'Natto', 'Miso', 'Kimchi', 'Poi',
    'Haggis', 'Blood Sausage', 'Head Cheese', 'Pâté',
    'Escargot', 'Frog Legs', 'Caviar', 'Foie Gras',
    
    // Miscellaneous
    'Eggs (runny)', 'Eggs (hard-boiled)', 'Raw Onions', 'Cooked Carrots',
    'Canned Vegetables', 'Frozen Vegetables', 'Processed Meats',
    'Deli Meats', 'Hot Dogs', 'Bologna', 'Spam',
    'Mayonnaise-based Salads', 'Creamy Dressings', 'Vinegar-based Dressings',
    'Spicy Food', 'Very Sweet Food', 'Very Salty Food', 'Bitter Food',
    'Slimy Textures', 'Mushy Textures', 'Chewy Textures',
  ];

  /// Search function for filtering lists
  static List<String> searchList(List<String> items, String query) {
    if (query.isEmpty) return items;
    final lowerQuery = query.toLowerCase();
    return items.where((item) => item.toLowerCase().contains(lowerQuery)).toList();
  }

  /// Get popular items for quick selection
  static List<String> getPopularCountries() {
    return [
      'United States', 'United Kingdom', 'Canada', 'Australia', 'India',
      'China', 'Japan', 'Germany', 'France', 'Italy', 'Spain', 'Mexico',
      'Brazil', 'South Africa', 'Singapore', 'South Korea', 'Thailand',
    ];
  }

  static List<String> getPopularCuisines() {
    return [
      'American', 'Italian', 'Chinese', 'Mexican', 'Indian',
      'Japanese', 'Thai', 'French', 'Mediterranean', 'Greek',
      'Korean', 'Vietnamese', 'Spanish', 'Turkish', 'Middle Eastern',
    ];
  }

  static List<String> getCommonDislikes() {
    return [
      'Mushrooms', 'Olives', 'Cilantro', 'Onions', 'Bell Peppers',
      'Broccoli', 'Brussels Sprouts', 'Avocado', 'Coconut', 'Liver',
      'Oysters', 'Anchovies', 'Blue Cheese', 'Mayonnaise', 'Pickles',
    ];
  }
}
