import 'package:flutter/material.dart';
import '../services/ingredient_search_service.dart';
import '../services/supabase_ingredient_service.dart';
import '../services/image_recognition_service.dart';
import '../services/barcode_scan_service.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/glass_container.dart';
import 'dart:io';

/// Advanced ingredient search screen with multiple input methods
/// - Supabase database (your own ingredient database - PRIMARY)
/// - Text search across multiple external databases (fallback)
/// - Image recognition
/// - Barcode scanning
class AdvancedIngredientSearchScreen extends StatefulWidget {
  const AdvancedIngredientSearchScreen({super.key});

  @override
  State<AdvancedIngredientSearchScreen> createState() => _AdvancedIngredientSearchScreenState();
}

class _AdvancedIngredientSearchScreenState extends State<AdvancedIngredientSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SupabaseIngredientService _supabaseService = SupabaseIngredientService();
  final IngredientSearchService _searchService = IngredientSearchService();
  final ImageRecognitionService _imageService = ImageRecognitionService();
  final BarcodeScanService _barcodeService = BarcodeScanService();
  
  List<IngredientItem> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;
  SearchMode _searchMode = SearchMode.text;
  bool _useSupabase = true; // Primary: Use Supabase database
  bool _useExternalAPIs = false; // Fallback: External APIs when needed
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _searchResults = [];
    });

    try {
      List<IngredientItem> results = [];
      
      // Primary: Search Supabase database first
      if (_useSupabase) {
        results = await _supabaseService.searchIngredients(query, limit: 50);
        
        if (results.isNotEmpty) {
          setState(() {
            _searchResults = results;
            _isLoading = false;
          });
          return;
        }
      }
      
      // Fallback: Search external APIs if no results from Supabase
      if (_useExternalAPIs && results.isEmpty) {
        final result = await _searchService.searchIngredients(
          query,
          limit: 50,
          includeUSDA: true,
          includeOpenFoodFacts: true,
          includeNutritionix: false, // Enable when API key available
          includeEdamam: false, // Enable when API key available
        );
        
        results = result.items;
        
        if (result.errors.isNotEmpty) {
          _errorMessage = 'External APIs: ${result.errors.join(", ")}';
        }
      }

      setState(() {
        _searchResults = results;
        _isLoading = false;
        
        if (results.isEmpty) {
          _errorMessage = _useSupabase 
              ? 'No results found. Try adding ingredients to your Supabase database or enable external APIs.'
              : 'No results found in external databases.';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Search error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _scanBarcode() async {
    setState(() {
      _searchMode = SearchMode.barcode;
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Note: Requires mobile_scanner package
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📷 Barcode scanning requires mobile_scanner package. Add to pubspec.yaml to enable.'),
          duration: Duration(seconds: 3),
        ),
      );
      
      setState(() => _isLoading = false);
      
      // Actual implementation when package is available:
      /*
      final barcodeData = await _barcodeService.scanWithCamera(context);
      if (barcodeData != null) {
        final item = await _searchService.searchByBarcode(barcodeData.code);
        if (item != null) {
          setState(() {
            _searchResults = [item];
            _searchController.text = item.name;
          });
        }
      }
      setState(() => _isLoading = false);
      */
    } catch (e) {
      setState(() {
        _errorMessage = 'Barcode scan error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _recognizeFromImage() async {
    setState(() {
      _searchMode = SearchMode.image;
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Note: Requires image_picker package
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📸 Image recognition requires image_picker and Google Cloud Vision API. Configure API key in image_recognition_service.dart'),
          duration: Duration(seconds: 4),
        ),
      );
      
      setState(() => _isLoading = false);
      
      // Actual implementation when package is available:
      /*
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      
      if (image != null) {
        final result = await _imageService.recognizeFood(
          File(image.path),
          useGoogleVision: true,
        );
        
        if (result.foods.isNotEmpty) {
          // Search for recognized foods
          final topFood = result.foods.first;
          await _performSearch(topFood.name);
        }
      }
      setState(() => _isLoading = false);
      */
    } catch (e) {
      setState(() {
        _errorMessage = 'Image recognition error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Advanced Ingredient Search',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Search Info Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassContainer(
                  padding: const EdgeInsets.all(16),
                  borderRadius: 12,
                  blur: 10,
                  opacity: 0.2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.stars, color: Colors.amber, size: 20),
                          SizedBox(width: 8),
                          Text(
                            '20x Advanced Search',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _useSupabase 
                            ? 'Searching your Supabase ingredient database. ${_useExternalAPIs ? "External APIs enabled as fallback." : "Enable external APIs for additional sources."}'
                            : 'Searching 4M+ ingredients from external APIs (USDA, Open Food Facts).',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Search Methods
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSearchMethodButton(
                        icon: Icons.search,
                        label: 'Text',
                        isActive: _searchMode == SearchMode.text,
                        onTap: () => setState(() => _searchMode = SearchMode.text),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSearchMethodButton(
                        icon: Icons.qr_code_scanner,
                        label: 'Barcode',
                        isActive: _searchMode == SearchMode.barcode,
                        onTap: _scanBarcode,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSearchMethodButton(
                        icon: Icons.camera_alt,
                        label: 'Image',
                        isActive: _searchMode == SearchMode.image,
                        onTap: _recognizeFromImage,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Data Source Settings
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassContainer(
                  padding: const EdgeInsets.all(12),
                  borderRadius: 8,
                  blur: 10,
                  opacity: 0.15,
                  child: Row(
                    children: [
                      Icon(Icons.storage, color: Colors.white70, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Data Sources',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _useSupabase ? 'Supabase (Primary)' : 'External APIs only',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.settings, color: Colors.white70, size: 20),
                        color: Color(0xFF2D1B69),
                        onSelected: (value) {
                          setState(() {
                            if (value == 'supabase') {
                              _useSupabase = !_useSupabase;
                            } else if (value == 'external') {
                              _useExternalAPIs = !_useExternalAPIs;
                            }
                          });
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'supabase',
                            child: Row(
                              children: [
                                Icon(
                                  _useSupabase ? Icons.check_box : Icons.check_box_outline_blank,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Supabase Database',
                                        style: TextStyle(color: Colors.white, fontSize: 13),
                                      ),
                                      Text(
                                        'Your own ingredient DB',
                                        style: TextStyle(color: Colors.white60, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'external',
                            child: Row(
                              children: [
                                Icon(
                                  _useExternalAPIs ? Icons.check_box : Icons.check_box_outline_blank,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'External APIs',
                                        style: TextStyle(color: Colors.white, fontSize: 13),
                                      ),
                                      Text(
                                        'USDA, Open Food Facts',
                                        style: TextStyle(color: Colors.white60, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search ingredients (e.g., "Fuji apple", "Atlantic salmon")...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() {
                                _searchResults = [];
                                _errorMessage = null;
                              });
                            },
                            child: const Icon(Icons.clear, color: Colors.white70),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white30),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                  onSubmitted: _performSearch,
                  onChanged: (value) => setState(() {}),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Error Message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(12),
                    borderRadius: 8,
                    blur: 10,
                    opacity: 0.2,
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Results
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 16),
                            Text(
                              'Searching databases...',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      )
                    : _searchResults.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search,
                                  size: 64,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Search for ingredients',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try: "Fuji apple", "King salmon", "Baby spinach"',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final item = _searchResults[index];
                              return _buildIngredientCard(item);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchMethodButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 12),
        borderRadius: 12,
        blur: 10,
        opacity: isActive ? 0.3 : 0.1,
        child: Column(
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.white70,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientCard(IngredientItem item) {
    return GestureDetector(
      onTap: () => _showIngredientDetails(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: GlassContainer(
          padding: const EdgeInsets.all(16),
          borderRadius: 12,
          blur: 10,
          opacity: 0.2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (item.brand != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.brand!,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getSourceColor(item.source).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _getSourceColor(item.source)),
                    ),
                    child: Text(
                      item.source,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.category, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    item.category,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  if (item.scientificName != null) ...[
                    const SizedBox(width: 16),
                    const Icon(Icons.science, color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.scientificName!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSourceColor(String source) {
    switch (source) {
      case 'USDA':
        return Colors.blue;
      case 'OpenFoodFacts':
        return Colors.green;
      case 'Nutritionix':
        return Colors.orange;
      case 'Edamam':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showIngredientDetails(IngredientItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => GlassContainer(
          blur: 20,
          opacity: 0.3,
          borderRadius: 24,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (item.brand != null)
                Text(
                  item.brand!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
              const SizedBox(height: 16),
              _buildDetailRow('Category', item.category),
              _buildDetailRow('Source', item.source),
              if (item.barcode != null)
                _buildDetailRow('Barcode', item.barcode!),
              if (item.scientificName != null)
                _buildDetailRow('Scientific Name', item.scientificName!),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Add to pantry
                  Navigator.pop(context);
                  Navigator.pop(context, item);
                },
                icon: const Icon(Icons.add),
                label: const Text('Add to Pantry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.9),
                  foregroundColor: Colors.purple.shade900,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum SearchMode {
  text,
  barcode,
  image,
}
