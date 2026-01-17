import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/auth_service.dart';
import '../models/user_preferences.dart';
import '../data/preference_data.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/glass_container.dart';
import '../widgets/searchable_dropdown.dart';
import '../widgets/multi_select_dropdown.dart';

/// User Preferences Screen for collecting dietary restrictions, allergies, and food preferences
class UserPreferencesScreen extends StatefulWidget {
  const UserPreferencesScreen({super.key});

  @override
  State<UserPreferencesScreen> createState() => _UserPreferencesScreenState();
}

class _UserPreferencesScreenState extends State<UserPreferencesScreen> {
  String? _selectedCountry;
  String? _selectedCuisine;
  List<String> _selectedRestrictions = [];
  List<String> _selectedAllergies = [];
  List<String> _selectedDislikes = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefsJson = prefs.getString('user_preferences');
      
      if (prefsJson != null) {
        final userPrefs = UserPreferences.fromJson(jsonDecode(prefsJson));
        setState(() {
          _selectedCountry = userPrefs.country;
          _selectedCuisine = userPrefs.preferredCuisine;
          _selectedRestrictions = List.from(userPrefs.dietaryRestrictions);
          _selectedAllergies = List.from(userPrefs.allergies);
          _selectedDislikes = List.from(userPrefs.dislikedFoods);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePreferences() async {
    try {
      final userPrefs = UserPreferences(
        country: _selectedCountry,
        preferredCuisine: _selectedCuisine,
        dietaryRestrictions: _selectedRestrictions,
        allergies: _selectedAllergies,
        dislikedFoods: _selectedDislikes,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_preferences', jsonEncode(userPrefs.toJson()));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Preferences saved! AI will now personalize recipes for you.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving preferences: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Stack(
          children: [
            const AnimatedGradientBackground(
              theme: GradientTheme.purple,
              child: SizedBox.expand(),
            ),
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const AnimatedGradientBackground(
            theme: GradientTheme.purple,
            child: SizedBox.expand(),
          ),
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                _buildAppBar(),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildIntroCard(),
                        const SizedBox(height: 24),
                        _buildRegionalSection(),
                        const SizedBox(height: 24),
                        _buildDietaryRestrictionsSection(),
                        const SizedBox(height: 24),
                        _buildAllergiesSection(),
                        const SizedBox(height: 24),
                        _buildDislikesSection(),
                        const SizedBox(height: 32),
                        _buildSaveButton(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: GlassContainer(
              blur: 10,
              opacity: 0.2,
              borderRadius: 12,
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Food Preferences',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 16,
      blur: 12,
      opacity: 0.2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.restaurant_menu, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Personalize Your Experience',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Tell us about your dietary needs and food preferences. Our AI will use this information to suggest safe, delicious recipes tailored just for you! 💚',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('🌍 Regional Preferences'),
        const SizedBox(height: 8),
        Text(
          'Select from ${PreferenceData.countries.length}+ countries and ${PreferenceData.cuisines.length}+ cuisines',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        GlassContainer(
          padding: const EdgeInsets.all(16),
          borderRadius: 12,
          blur: 10,
          opacity: 0.2,
          child: Column(
            children: [
              SearchableDropdown(
                label: 'Country',
                hint: 'Select your country',
                items: PreferenceData.countries,
                selectedValue: _selectedCountry,
                icon: Icons.flag,
                popularItems: PreferenceData.getPopularCountries(),
                onChanged: (value) {
                  setState(() => _selectedCountry = value);
                },
              ),
              const SizedBox(height: 16),
              SearchableDropdown(
                label: 'Preferred Cuisine',
                hint: 'Select your favorite cuisine',
                items: PreferenceData.cuisines,
                selectedValue: _selectedCuisine,
                icon: Icons.dinner_dining,
                popularItems: PreferenceData.getPopularCuisines(),
                onChanged: (value) {
                  setState(() => _selectedCuisine = value);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDietaryRestrictionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('🥗 Dietary Restrictions'),
        const SizedBox(height: 8),
        Text(
          'Select from ${PreferenceData.dietaryRestrictions.length}+ dietary restrictions',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        GlassContainer(
          padding: const EdgeInsets.all(16),
          borderRadius: 12,
          blur: 10,
          opacity: 0.2,
          child: MultiSelectDropdown(
            label: 'Select Dietary Restrictions',
            hint: 'Tap to select',
            items: PreferenceData.dietaryRestrictions,
            selectedValues: _selectedRestrictions,
            icon: Icons.restaurant,
            onChanged: (values) {
              setState(() => _selectedRestrictions = values);
            },
          ),
        ),
        if (_selectedRestrictions.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedRestrictions.map((restriction) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white60),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      restriction,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildAllergiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('⚠️ Allergies'),
        const SizedBox(height: 8),
        Text(
          'Select from ${PreferenceData.allergens.length}+ allergens - we\'ll exclude these from recipe suggestions',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        GlassContainer(
          padding: const EdgeInsets.all(16),
          borderRadius: 12,
          blur: 10,
          opacity: 0.2,
          child: MultiSelectDropdown(
            label: 'Select Allergies',
            hint: 'Tap to select',
            items: PreferenceData.allergens,
            selectedValues: _selectedAllergies,
            icon: Icons.warning,
            highlightColor: Colors.red,
            onChanged: (values) {
              setState(() => _selectedAllergies = values);
            },
          ),
        ),
        if (_selectedAllergies.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedAllergies.map((allergy) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.shade300, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      allergy,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildDislikesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('👎 Foods You Dislike'),
        const SizedBox(height: 8),
        Text(
          'Select from ${PreferenceData.dislikedFoods.length}+ common disliked foods',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        GlassContainer(
          padding: const EdgeInsets.all(16),
          borderRadius: 12,
          blur: 10,
          opacity: 0.2,
          child: MultiSelectDropdown(
            label: 'Select Disliked Foods',
            hint: 'Tap to select',
            items: PreferenceData.dislikedFoods,
            selectedValues: _selectedDislikes,
            icon: Icons.no_meals,
            popularItems: PreferenceData.getCommonDislikes(),
            onChanged: (values) {
              setState(() => _selectedDislikes = values);
            },
          ),
        ),
        if (_selectedDislikes.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedDislikes.map((food) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white60),
                ),
                child: Text(
                  food,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  void _addDislikedFood() {
    // This method is no longer needed with dropdown
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: _savePreferences,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade400, Colors.blue.shade400],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.save, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                'Save Preferences',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
