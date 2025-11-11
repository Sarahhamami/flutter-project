import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/food_item.dart';
import '../themes/app_theme.dart';
import '../widgets/modern_card.dart';
import '../widgets/modern_button.dart';
import '../widgets/loading_animation.dart';

class SmartFoodSearch extends StatefulWidget {
  final Function(List<FoodItem>) onFoodsSelected;
  final String? initialQuery;

  const SmartFoodSearch({
    super.key,
    required this.onFoodsSelected,
    this.initialQuery,
  });

  @override
  State<SmartFoodSearch> createState() => _SmartFoodSearchState();
}

class _SmartFoodSearchState extends State<SmartFoodSearch>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _suggestions = [];
  List<FoodItem> _selectedFoods = [];
  bool _isLoading = false;
  String _currentQuery = '';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery ?? '';
    _currentQuery = widget.initialQuery ?? '';

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (_currentQuery.isNotEmpty) {
      _performSearch(_currentQuery);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simple local search based on query
      final localFoods = _getLocalFoods();

      final lowercaseQuery = query.toLowerCase();
      final matchingFoods = localFoods.where((food) =>
        food.name.toLowerCase().contains(lowercaseQuery) ||
        food.category.toLowerCase().contains(lowercaseQuery)
      ).toList();

      setState(() {
        _suggestions = matchingFoods.map((food) => {
          'foods': [food.toJson()],
          'total': {
            'calories': food.calories,
            'proteins': food.proteins,
            'carbs': food.carbs,
            'fats': food.fats,
          },
        }).toList();
        _isLoading = false;
      });

      _animationController.forward(from: 0.0);
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Erreur lors de la recherche');
    }
  }

  List<FoodItem> _getLocalFoods() {
    return [
      FoodItem(
        fiber: 0,
        sugars: 0,
        sodium: 0,
        cholesterol: 0,
        quantity: 100,
        id: 'apple',
        name: 'Apple',
        calories: 52.0,
        proteins: 0.2,
        carbs: 13.8,
        fats: 0.2,
        unit: 'g',
        category: 'fruit',
      ),
      FoodItem(
        fiber: 0,
        sugars: 0,
        sodium: 0,
        cholesterol: 0,
        quantity: 100,
        id: 'banana',
        name: 'Banana',
        calories: 89.0,
        proteins: 1.1,
        carbs: 22.8,
        fats: 0.3,
        unit: 'g',
        category: 'fruit',
      ),
      FoodItem(
        fiber: 0,
        sugars: 0,
        sodium: 0,
        cholesterol: 0,
        quantity: 100,
        id: 'chicken_breast',
        name: 'Chicken Breast',
        calories: 165.0,
        proteins: 31.0,
        carbs: 0.0,
        fats: 3.6,
        unit: 'g',
        category: 'protein',
      ),
      FoodItem(
        fiber: 0,
        sugars: 0,
        sodium: 0,
        cholesterol: 0,
        quantity: 100,
        id: 'rice',
        name: 'White Rice (cooked)',
        calories: 130.0,
        proteins: 2.7,
        carbs: 28.0,
        fats: 0.3,
        unit: 'g',
        category: 'grain',
      ),
      FoodItem(
        fiber: 0,
        sugars: 0,
        sodium: 0,
        cholesterol: 0,
        quantity: 100,
        id: 'bread',
        name: 'White Bread',
        calories: 265.0,
        proteins: 9.0,
        carbs: 49.0,
        fats: 3.2,
        unit: 'g',
        category: 'grain',
      ),
    ];
  }

  void _selectSuggestion(Map<String, dynamic> suggestion) {
    final foods = suggestion['foods'] as List;
    final selectedFoods = foods.map((food) => FoodItem.fromJson(food)).toList();

    setState(() {
      _selectedFoods.addAll(selectedFoods);
      _suggestions = [];
      _searchController.clear();
      _currentQuery = '';
    });

    HapticFeedback.mediumImpact();
  }

  void _removeFood(int index) {
    setState(() => _selectedFoods.removeAt(index));
    HapticFeedback.lightImpact();
  }

  void _confirmSelection() {
    widget.onFoodsSelected(_selectedFoods);
    Navigator.of(context).pop();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '🔍 Découvrez les aliments parfaits !',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          if (_selectedFoods.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: ElevatedButton.icon(
                onPressed: _confirmSelection,
                icon: const Icon(Icons.add, size: 18),
                label: Text(
                  'Ajouter (${_selectedFoods.length})',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Header avec slogan
            Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.secondaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.smart_toy,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Des milliers d\'aliments à explorer',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Trouvez rapidement ce que vous cherchez',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate()
             .scale(duration: const Duration(milliseconds: 800), curve: Curves.elasticOut),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un aliment...',
                    prefixIcon: Icon(Icons.search, color: AppColors.secondary),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.clear, color: AppColors.grey),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _currentQuery = '';
                                _suggestions = [];
                              });
                            },
                          ),
                      ],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    hintStyle: GoogleFonts.inter(color: AppColors.textSecondary.withOpacity(0.7)),
                  ),
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                  onChanged: (value) {
                    setState(() => _currentQuery = value);
                    if (value.length > 2) {
                      _performSearch(value);
                    } else {
                      setState(() => _suggestions = []);
                    }
                  },
                  onSubmitted: _performSearch,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Loading indicator
            if (_isLoading)
              Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Analyse nutritionnelle en cours...',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // Suggestions
            if (_suggestions.isNotEmpty)
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = _suggestions[index];
                      return _buildSuggestionCard(suggestion);
                    },
                  ),
                ),
              ),

            // Selected foods
            if (_selectedFoods.isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowColor,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.healthyGreen,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Aliments sélectionnés (${_selectedFoods.length})',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _selectedFoods.length,
                        itemBuilder: (context, index) {
                          final food = _selectedFoods[index];
                          return _buildSelectedFoodCard(food, index);
                        },
                      ),
                    ),
                    // Total nutrition
                    _buildNutritionTotal(),
                  ],
                ),
              ),

            // Empty state
            if (_suggestions.isEmpty && !_isLoading && _selectedFoods.isEmpty)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(40),
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowColor,
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: AppColors.secondaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.restaurant_menu,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Recherche intelligente',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Décrivez votre repas en langage naturel et laissez-nous faire le reste !',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(Map<String, dynamic> suggestion) {
    final foods = suggestion['foods'] as List;
    final total = suggestion['total'] as Map<String, dynamic>;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _selectSuggestion(suggestion),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food items avec design moderne
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: foods.map<Widget>((food) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${food['name']} (${food['quantity']}${food['unit']})',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Nutrition summary avec design amélioré
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNutritionBadge('Calories', '${total['calories'].round()} kcal', AppColors.primary),
                    _buildNutritionBadge('Protéines', '${total['proteins'].round()}g', AppColors.secondary),
                    _buildNutritionBadge('Glucides', '${total['carbs'].round()}g', AppColors.accent),
                    _buildNutritionBadge('Lipides', '${total['fats'].round()}g', AppColors.tertiary),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Ajouter',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.add_circle, color: AppColors.secondary, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedFoodCard(FoodItem food, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.lightGrey,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icône de l'aliment
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.secondaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.restaurant,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildMiniNutrientChip('${food.quantity}${food.unit}', AppColors.secondary),
                    const SizedBox(width: 8),
                    _buildMiniNutrientChip('${food.calories.round()} kcal', AppColors.primary),
                  ],
                ),
              ],
            ),
          ),

          // Bouton supprimer avec animation
          GestureDetector(
            onTap: () => _removeFood(index),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.dangerRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.remove_circle_outline,
                color: AppColors.dangerRed,
                size: 20,
              ),
            ),
          ).animate()
           .scale(duration: const Duration(milliseconds: 200), curve: Curves.easeOut),
        ],
      ),
    );
  }

  Widget _buildMiniNutrientChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildNutritionTotal() {
    double totalCalories = _selectedFoods.fold(0, (sum, food) => sum + food.calories);
    double totalProteins = _selectedFoods.fold(0, (sum, food) => sum + food.proteins);
    double totalCarbs = _selectedFoods.fold(0, (sum, food) => sum + food.carbs);
    double totalFats = _selectedFoods.fold(0, (sum, food) => sum + food.fats);

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.healthyGreen.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.healthyGreen.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.summarize,
                color: AppColors.healthyGreen,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Résumé nutritionnel',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNutritionBadge('Calories', '${totalCalories.round()} kcal', AppColors.primary),
              _buildNutritionBadge('Protéines', '${totalProteins.round()}g', AppColors.secondary),
              _buildNutritionBadge('Glucides', '${totalCarbs.round()}g', AppColors.accent),
              _buildNutritionBadge('Lipides', '${totalFats.round()}g', AppColors.tertiary),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppColors.secondaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _confirmSelection,
              icon: const Icon(Icons.add, size: 20),
              label: Text(
                'Ajouter au journal (${_selectedFoods.length})',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionBadge(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.glassBackground,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}