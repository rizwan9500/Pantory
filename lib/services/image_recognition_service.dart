import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Advanced image recognition service for food identification
/// Supports Google Cloud Vision, AWS Rekognition, and custom models
class ImageRecognitionService {
  // API Configuration
  static const String googleVisionApiKey = 'YOUR_API_KEY'; // Replace with actual key
  static const String googleVisionBaseUrl = 'https://vision.googleapis.com/v1';
  
  static const String awsRekognitionRegion = 'us-east-1';
  static const String awsAccessKey = 'YOUR_ACCESS_KEY';
  static const String awsSecretKey = 'YOUR_SECRET_KEY';
  
  /// Recognize food items from image using multiple AI services
  Future<FoodRecognitionResult> recognizeFood(File imageFile, {
    bool useGoogleVision = true,
    bool useAWSRekognition = false,
    bool useCustomModel = false,
  }) async {
    final results = <RecognizedFood>[];
    final errors = <String>[];
    
    // Convert image to base64
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    
    // Google Cloud Vision
    if (useGoogleVision) {
      try {
        final googleResults = await _recognizeWithGoogleVision(base64Image);
        results.addAll(googleResults);
      } catch (e) {
        errors.add('Google Vision: ${e.toString()}');
      }
    }
    
    // AWS Rekognition
    if (useAWSRekognition) {
      try {
        final awsResults = await _recognizeWithAWSRekognition(bytes);
        results.addAll(awsResults);
      } catch (e) {
        errors.add('AWS Rekognition: ${e.toString()}');
      }
    }
    
    // Custom ML Model
    if (useCustomModel) {
      try {
        final customResults = await _recognizeWithCustomModel(base64Image);
        results.addAll(customResults);
      } catch (e) {
        errors.add('Custom Model: ${e.toString()}');
      }
    }
    
    // Merge and rank results
    final mergedResults = _mergeAndRankResults(results);
    
    return FoodRecognitionResult(
      foods: mergedResults,
      confidence: _calculateOverallConfidence(mergedResults),
      sources: _getActiveSources(useGoogleVision, useAWSRekognition, useCustomModel),
      errors: errors,
    );
  }
  
  /// Detect and decode barcode from image
  Future<BarcodeResult?> detectBarcode(File imageFile) async {
    // Try Google Vision barcode detection
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      final url = Uri.parse('$googleVisionBaseUrl/images:annotate?key=$googleVisionApiKey');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requests': [
            {
              'image': {'content': base64Image},
              'features': [
                {'type': 'TEXT_DETECTION'},
                {'type': 'LOGO_DETECTION'},
              ],
            }
          ],
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseBarcodeFromResponse(data);
      }
    } catch (e) {
      print('Barcode detection error: $e');
    }
    
    return null;
  }
  
  /// Extract nutritional information from food label image
  Future<NutritionLabelData?> extractNutritionLabel(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      // Use Google Vision OCR
      final url = Uri.parse('$googleVisionBaseUrl/images:annotate?key=$googleVisionApiKey');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requests': [
            {
              'image': {'content': base64Image},
              'features': [
                {'type': 'DOCUMENT_TEXT_DETECTION'},
              ],
            }
          ],
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseNutritionLabelFromOCR(data);
      }
    } catch (e) {
      print('Nutrition label extraction error: $e');
    }
    
    return null;
  }
  
  // ============================================
  // Google Cloud Vision Integration
  // ============================================
  
  Future<List<RecognizedFood>> _recognizeWithGoogleVision(String base64Image) async {
    final url = Uri.parse('$googleVisionBaseUrl/images:annotate?key=$googleVisionApiKey');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'requests': [
          {
            'image': {'content': base64Image},
            'features': [
              {'type': 'LABEL_DETECTION', 'maxResults': 20},
              {'type': 'OBJECT_LOCALIZATION', 'maxResults': 20},
              {'type': 'IMAGE_PROPERTIES'},
            ],
          }
        ],
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return _parseGoogleVisionResponse(data);
    }
    
    throw Exception('Google Vision API error: ${response.statusCode}');
  }
  
  List<RecognizedFood> _parseGoogleVisionResponse(Map<String, dynamic> data) {
    final foods = <RecognizedFood>[];
    final responses = data['responses'] as List? ?? [];
    
    if (responses.isEmpty) return foods;
    
    final response = responses[0];
    
    // Parse label annotations
    final labels = response['labelAnnotations'] as List? ?? [];
    for (var label in labels) {
      final description = label['description']?.toString() ?? '';
      final score = (label['score'] as num?)?.toDouble() ?? 0.0;
      
      if (_isFoodLabel(description) && score > 0.5) {
        foods.add(RecognizedFood(
          name: description,
          confidence: score,
          source: 'Google Vision',
          category: _categorizeFoodLabel(description),
        ));
      }
    }
    
    // Parse object localization
    final objects = response['localizedObjectAnnotations'] as List? ?? [];
    for (var obj in objects) {
      final name = obj['name']?.toString() ?? '';
      final score = (obj['score'] as num?)?.toDouble() ?? 0.0;
      
      if (_isFoodObject(name) && score > 0.5) {
        foods.add(RecognizedFood(
          name: name,
          confidence: score,
          source: 'Google Vision',
          category: 'Object Detection',
          boundingBox: _parseBoundingBox(obj['boundingPoly']),
        ));
      }
    }
    
    return foods;
  }
  
  bool _isFoodLabel(String label) {
    final foodKeywords = [
      'food', 'fruit', 'vegetable', 'meat', 'fish', 'dairy', 'bread',
      'grain', 'pasta', 'rice', 'cheese', 'egg', 'milk', 'butter',
      'apple', 'banana', 'orange', 'tomato', 'potato', 'carrot',
      'chicken', 'beef', 'pork', 'salmon', 'tuna', 'shrimp',
    ];
    
    final lowerLabel = label.toLowerCase();
    return foodKeywords.any((keyword) => lowerLabel.contains(keyword));
  }
  
  bool _isFoodObject(String name) {
    return _isFoodLabel(name);
  }
  
  String _categorizeFoodLabel(String label) {
    final categories = {
      'fruit': ['apple', 'banana', 'orange', 'berry', 'grape', 'mango'],
      'vegetable': ['tomato', 'potato', 'carrot', 'lettuce', 'spinach', 'broccoli'],
      'meat': ['chicken', 'beef', 'pork', 'lamb', 'turkey'],
      'seafood': ['fish', 'salmon', 'tuna', 'shrimp', 'crab', 'lobster'],
      'dairy': ['milk', 'cheese', 'yogurt', 'butter', 'cream'],
      'grain': ['bread', 'rice', 'pasta', 'cereal', 'wheat'],
    };
    
    final lowerLabel = label.toLowerCase();
    for (var entry in categories.entries) {
      if (entry.value.any((item) => lowerLabel.contains(item))) {
        return entry.key;
      }
    }
    
    return 'general';
  }
  
  BoundingBox? _parseBoundingBox(dynamic poly) {
    if (poly == null) return null;
    
    final vertices = poly['vertices'] as List? ?? [];
    if (vertices.isEmpty) return null;
    
    return BoundingBox(
      left: (vertices[0]['x'] as num?)?.toDouble() ?? 0.0,
      top: (vertices[0]['y'] as num?)?.toDouble() ?? 0.0,
      right: (vertices[2]['x'] as num?)?.toDouble() ?? 0.0,
      bottom: (vertices[2]['y'] as num?)?.toDouble() ?? 0.0,
    );
  }
  
  // ============================================
  // AWS Rekognition Integration
  // ============================================
  
  Future<List<RecognizedFood>> _recognizeWithAWSRekognition(List<int> imageBytes) async {
    // AWS Rekognition implementation
    // Requires AWS SDK and proper authentication
    // Placeholder for now - implement when AWS credentials available
    return [];
  }
  
  // ============================================
  // Custom ML Model Integration
  // ============================================
  
  Future<List<RecognizedFood>> _recognizeWithCustomModel(String base64Image) async {
    // Custom TensorFlow/PyTorch model integration
    // Can use Flutter's tflite package for on-device inference
    // Placeholder for now
    return [];
  }
  
  // ============================================
  // Helper Methods
  // ============================================
  
  List<RecognizedFood> _mergeAndRankResults(List<RecognizedFood> results) {
    // Group by food name
    final grouped = <String, List<RecognizedFood>>{};
    for (var food in results) {
      final key = food.name.toLowerCase();
      grouped.putIfAbsent(key, () => []).add(food);
    }
    
    // Merge duplicates and average confidence
    final merged = <RecognizedFood>[];
    for (var entry in grouped.entries) {
      if (entry.value.length == 1) {
        merged.add(entry.value.first);
      } else {
        // Average confidence from multiple sources
        final avgConfidence = entry.value
            .map((f) => f.confidence)
            .reduce((a, b) => a + b) / entry.value.length;
        
        merged.add(RecognizedFood(
          name: entry.value.first.name,
          confidence: avgConfidence,
          source: entry.value.map((f) => f.source).join(', '),
          category: entry.value.first.category,
          boundingBox: entry.value.first.boundingBox,
        ));
      }
    }
    
    // Sort by confidence
    merged.sort((a, b) => b.confidence.compareTo(a.confidence));
    
    return merged;
  }
  
  double _calculateOverallConfidence(List<RecognizedFood> foods) {
    if (foods.isEmpty) return 0.0;
    
    // Weighted average with higher weight for top results
    double totalWeight = 0.0;
    double weightedSum = 0.0;
    
    for (int i = 0; i < foods.length; i++) {
      final weight = 1.0 / (i + 1); // Decreasing weight
      totalWeight += weight;
      weightedSum += foods[i].confidence * weight;
    }
    
    return weightedSum / totalWeight;
  }
  
  List<String> _getActiveSources(bool google, bool aws, bool custom) {
    final sources = <String>[];
    if (google) sources.add('Google Cloud Vision');
    if (aws) sources.add('AWS Rekognition');
    if (custom) sources.add('Custom Model');
    return sources;
  }
  
  BarcodeResult? _parseBarcodeFromResponse(Map<String, dynamic> data) {
    // Parse barcode from text detection or logo detection
    // Implementation depends on response structure
    return null;
  }
  
  NutritionLabelData? _parseNutritionLabelFromOCR(Map<String, dynamic> data) {
    // Parse nutrition facts from OCR text
    // Use regex patterns to extract calories, fat, protein, etc.
    final responses = data['responses'] as List? ?? [];
    if (responses.isEmpty) return null;
    
    final text = responses[0]['fullTextAnnotation']?['text']?.toString() ?? '';
    
    // Extract nutrition information using patterns
    return NutritionLabelData(
      calories: _extractValue(text, r'Calories[\s:]+(\d+)'),
      totalFat: _extractValue(text, r'Total Fat[\s:]+(\d+\.?\d*)g'),
      protein: _extractValue(text, r'Protein[\s:]+(\d+\.?\d*)g'),
      carbohydrates: _extractValue(text, r'Total Carbohydrate[\s:]+(\d+\.?\d*)g'),
      rawText: text,
    );
  }
  
  double? _extractValue(String text, String pattern) {
    final regex = RegExp(pattern, caseSensitive: false);
    final match = regex.firstMatch(text);
    if (match != null && match.groupCount > 0) {
      return double.tryParse(match.group(1) ?? '');
    }
    return null;
  }
}

// ============================================
// Data Models
// ============================================

class FoodRecognitionResult {
  final List<RecognizedFood> foods;
  final double confidence;
  final List<String> sources;
  final List<String> errors;
  
  FoodRecognitionResult({
    required this.foods,
    required this.confidence,
    required this.sources,
    required this.errors,
  });
}

class RecognizedFood {
  final String name;
  final double confidence;
  final String source;
  final String category;
  final BoundingBox? boundingBox;
  
  RecognizedFood({
    required this.name,
    required this.confidence,
    required this.source,
    required this.category,
    this.boundingBox,
  });
}

class BoundingBox {
  final double left;
  final double top;
  final double right;
  final double bottom;
  
  BoundingBox({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });
}

class BarcodeResult {
  final String code;
  final String format;
  final BoundingBox? location;
  
  BarcodeResult({
    required this.code,
    required this.format,
    this.location,
  });
}

class NutritionLabelData {
  final double? calories;
  final double? totalFat;
  final double? protein;
  final double? carbohydrates;
  final String rawText;
  
  NutritionLabelData({
    this.calories,
    this.totalFat,
    this.protein,
    this.carbohydrates,
    required this.rawText,
  });
}
