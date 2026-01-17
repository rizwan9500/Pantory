# Advanced Ingredient Search & Image Recognition API Configuration

This document explains how to configure and use the advanced ingredient search and image recognition features.

## Overview

The Pantory app now includes a comprehensive ingredient search system that integrates with multiple data sources to provide access to millions of ingredients worldwide.

### Key Features

- **4M+ Ingredients**: Search across USDA FoodData Central (600K+), Open Food Facts (2.8M+), and more
- **Variety Recognition**: Find specific varieties (e.g., "Fuji apple", "King salmon", "Baby spinach")
- **Image Recognition**: Upload photos to identify food items
- **Barcode Scanning**: Scan product barcodes for instant lookup
- **Multi-Source Aggregation**: Results from multiple databases, deduplicated and ranked
- **Offline Fallback**: Local caching for common ingredients

## Data Sources

### 1. USDA FoodData Central (600,000+ foods)
- **Coverage**: Comprehensive US food database
- **Strengths**: Detailed nutritional data, scientific names, varieties
- **API**: Free with rate limits
- **Status**: ✅ Integrated

**Setup:**
1. Get API key: https://fdc.nal.usda.gov/api-guide.html
2. Replace `DEMO_KEY` in `lib/services/ingredient_search_service.dart`:
   ```dart
   static const String usdaApiKey = 'YOUR_API_KEY_HERE';
   ```

### 2. Open Food Facts (2.8M+ products)
- **Coverage**: Global product database with barcodes
- **Strengths**: Barcode lookup, brand information, ingredients lists
- **API**: Free, no key required
- **Status**: ✅ Integrated

No configuration needed - works out of the box!

### 3. Nutritionix (800,000+ items)
- **Coverage**: Restaurant and branded foods
- **Strengths**: Restaurant menu items, detailed macros
- **API**: Freemium
- **Status**: 🟡 Framework ready, requires API key

**Setup:**
1. Sign up: https://www.nutritionix.com/business/api
2. Get app_id and app_key
3. Update `lib/services/ingredient_search_service.dart`:
   ```dart
   final response = await http.get(
     url,
     headers: {
       'x-app-id': 'YOUR_APP_ID',
       'x-app-key': 'YOUR_APP_KEY',
     },
   );
   ```

### 4. Edamam Food Database (900,000+ foods)
- **Coverage**: Global foods and recipes
- **Strengths**: Recipe integration, meal planning
- **API**: Freemium
- **Status**: 🟡 Framework ready, requires API key

**Setup:**
1. Sign up: https://www.edamam.com/
2. Get app_id and app_key
3. Update `lib/services/ingredient_search_service.dart`

## Image Recognition

### Google Cloud Vision API
- **Capabilities**: Food detection, label recognition, OCR
- **Accuracy**: Industry-leading
- **Cost**: $1.50 per 1000 images (first 1000/month free)
- **Status**: ✅ Framework ready

**Setup:**
1. Create Google Cloud project: https://console.cloud.google.com/
2. Enable Cloud Vision API
3. Create API key
4. Update `lib/services/image_recognition_service.dart`:
   ```dart
   static const String googleVisionApiKey = 'YOUR_API_KEY_HERE';
   ```

### AWS Rekognition (Optional)
- **Capabilities**: Object detection, image analysis
- **Cost**: $0.001 per image
- **Status**: 🟡 Framework ready

**Setup:**
1. Create AWS account
2. Get access key and secret key
3. Update `lib/services/image_recognition_service.dart`

## Barcode Scanning

### Hardware Requirements
- Camera access for real-time scanning
- Works on iOS and Android

### Configuration
No additional setup needed - uses the `mobile_scanner` package already in `pubspec.yaml`.

**Usage in code:**
```dart
final barcodeService = BarcodeScanService();
final result = await barcodeService.scanWithCamera(context);
if (result != null) {
  // Lookup product by barcode
  final product = await searchService.searchByBarcode(result.code);
}
```

## Usage Examples

### 1. Text Search
```dart
final searchService = IngredientSearchService();
final results = await searchService.searchIngredients(
  'Fuji apple',
  limit: 20,
  includeUSDA: true,
  includeOpenFoodFacts: true,
);

for (var item in results.items) {
  print('${item.name} (${item.source}) - ${item.category}');
}
```

### 2. Barcode Lookup
```dart
final searchService = IngredientSearchService();
final item = await searchService.searchByBarcode('012345678901');

if (item != null) {
  print('Found: ${item.name} by ${item.brand}');
}
```

### 3. Image Recognition
```dart
final imageService = ImageRecognitionService();
final file = File('/path/to/image.jpg');

final result = await imageService.recognizeFood(
  file,
  useGoogleVision: true,
);

for (var food in result.foods) {
  print('${food.name} (${food.confidence * 100}% confident)');
}
```

### 4. Ingredient Varieties
```dart
final searchService = IngredientSearchService();
final varieties = await searchService.getIngredientVarieties('apple');

for (var variety in varieties) {
  print('${variety.name} - ${variety.scientificName}');
}
// Output: Fuji apple, Gala apple, Granny Smith apple, etc.
```

## Cost Estimates

### Free Tier (No API keys)
- Open Food Facts: Unlimited
- USDA with DEMO_KEY: 1000 requests/hour

### Paid Services (Optional)
- **Google Cloud Vision**: $1.50/1000 images (first 1000 free/month)
- **USDA Production Key**: Free, higher rate limits
- **Nutritionix**: $50/month for 10K requests
- **Edamam**: $10/month for 10K requests

## Architecture

```
┌─────────────────────────────────────┐
│   Advanced Ingredient Search UI    │
├─────────────────────────────────────┤
│   - Text input                      │
│   - Barcode scanner button          │
│   - Image upload button             │
└──────────────┬──────────────────────┘
               │
    ┌──────────┴──────────┬───────────────────┐
    │                     │                   │
┌───▼────────────┐  ┌────▼──────────┐  ┌────▼─────────────┐
│ Search Service │  │ Image Service │  │ Barcode Service  │
├────────────────┤  ├───────────────┤  ├──────────────────┤
│ - USDA         │  │ - Google      │  │ - mobile_scanner │
│ - Open Food    │  │   Vision      │  │ - Product lookup │
│ - Nutritionix  │  │ - AWS         │  │                  │
│ - Edamam       │  │ - Custom ML   │  │                  │
└────────────────┘  └───────────────┘  └──────────────────┘
```

## Performance Optimization

### Caching Strategy
```dart
// Cache frequently searched items locally
final prefs = await SharedPreferences.getInstance();
final cached = prefs.getString('search_cache_$query');
if (cached != null) {
  return IngredientSearchResult.fromJson(jsonDecode(cached));
}

// Fetch from APIs and cache
final result = await searchIngredients(query);
prefs.setString('search_cache_$query', jsonEncode(result.toJson()));
```

### Parallel Requests
The service automatically makes parallel requests to multiple data sources and aggregates results.

### Rate Limiting
Built-in error handling for API rate limits with fallback to cached data.

## Privacy & Security

- **Local Storage**: All search history and cache stored locally
- **API Keys**: Store in environment variables, not in code
- **No Data Collection**: User searches are not logged
- **HTTPS Only**: All API calls use secure HTTPS

## Troubleshooting

### "USDA API error: 403"
- Replace `DEMO_KEY` with your API key
- Check rate limits (1000/hour for demo key)

### "Google Vision API error: 403"
- Enable Cloud Vision API in Google Cloud Console
- Check API key is correct
- Verify billing is enabled

### "No results found"
- Check internet connection
- Try alternative spellings
- Use more specific terms (e.g., "Fuji apple" instead of "apple")

### Barcode not scanning
- Ensure camera permissions granted
- Good lighting conditions
- Clean, flat barcode surface

## Future Enhancements

- [ ] AI-powered search suggestions
- [ ] Multi-language search
- [ ] Voice search integration
- [ ] Custom ML model for offline recognition
- [ ] Recipe ingredient extraction from images
- [ ] Nutrition label OCR parsing
- [ ] Allergen detection from ingredient lists

## Support

For API-related issues:
- USDA: https://fdc.nal.usda.gov/help.html
- Open Food Facts: https://world.openfoodfacts.org/contact
- Google Vision: https://cloud.google.com/vision/docs/support
- App Issues: Submit GitHub issue

## License

API usage subject to each provider's terms of service. See individual provider websites for details.
