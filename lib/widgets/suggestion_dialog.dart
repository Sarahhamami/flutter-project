import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../models/meal.dart';
import '../models/food_item.dart';
import '../models/nutrition_profile.dart';
import '../providers/recipe_provider.dart';
import '../providers/dashboard_provider.dart';
import '../services/favorite_service.dart';
import '../services/mealdb_api_service.dart';
import '../themes/app_theme.dart';
import 'recipe_detail_dialog.dart';

class SuggestionDialog extends StatefulWidget {
  final Meal addedMeal;

  const SuggestionDialog({
    super.key,
    required this.addedMeal,
  });

  @override
  State<SuggestionDialog> createState() => _SuggestionDialogState();
}

class _SuggestionDialogState extends State<SuggestionDialog> {
  final FavoriteService _favoriteService = FavoriteService();

  List<Recipe> _suggestions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    setState(() => _isLoading = true);

    try {
      final dashboardProvider = context.read<DashboardProvider>();
      final profile = dashboardProvider.nutritionProfile;

      if (profile == null) {
        throw Exception('Profil nutritionnel non trouvé');
      }

      // Get remaining nutritional needs
      final progress = dashboardProvider.dailyProgress!;
      final remainingCalories = profile.calorieObjectif - progress.caloriesConsumed;
      final remainingProteins = profile.proteineObjectif - progress.proteinsConsumed;
      final remainingCarbs = profile.glucideObjectif - progress.carbsConsumed;
      final remainingFats = profile.lipideObjectif - progress.fatsConsumed;

      // Generate suggestions based on remaining needs
      _suggestions = await _generateSuggestions(
        remainingCalories,
        remainingProteins,
        remainingCarbs,
        remainingFats,
        profile,
      );
    } catch (e) {
      _error = e.toString();
      _suggestions = [];
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<List<Recipe>> _generateSuggestions(
    double remainingCalories,
    double remainingProteins,
    double remainingCarbs,
    double remainingFats,
    NutritionProfile profile,
  ) async {
    final mealDbService = MealDbApiService();
    final suggestions = <Recipe>[];

    try {
      // Get recipes based on meal type and nutritional needs
      final categories = await mealDbService.getCategories();

      // Choose category based on nutritional focus
      String category;
      if (remainingProteins > remainingCarbs && remainingProteins > remainingFats) {
        category = 'Chicken'; // High protein
      } else if (remainingCarbs > remainingProteins && remainingCarbs > remainingFats) {
        category = 'Pasta'; // High carbs
      } else {
        category = 'Dessert'; // Balanced or high fat
      }

      final recipes = await mealDbService.getRecipesByCategory(category);

      // Filter and score recipes based on nutritional fit
      final scoredRecipes = recipes.where((recipe) {
        final calories = recipe.estimatedCalories;
        final proteins = recipe.estimatedProteins;
        final carbs = recipe.estimatedCarbs;
        final fats = recipe.estimatedFats;

        // Check if recipe fits within remaining nutritional needs
        return calories <= remainingCalories * 0.8 && // Use up to 80% of remaining calories
               proteins <= remainingProteins * 0.9 &&
               carbs <= remainingCarbs * 0.9 &&
               fats <= remainingFats * 0.9;
      }).toList();

      // Sort by nutritional balance score
      scoredRecipes.sort((a, b) {
        final scoreA = _calculateNutritionalScore(a, remainingCalories, remainingProteins, remainingCarbs, remainingFats);
        final scoreB = _calculateNutritionalScore(b, remainingCalories, remainingProteins, remainingCarbs, remainingFats);
        return scoreB.compareTo(scoreA); // Higher score first
      });

      // Return top 3 suggestions
      suggestions.addAll(scoredRecipes.take(3));

      // If we don't have enough suggestions, add some general healthy recipes
      if (suggestions.length < 3) {
        final healthyRecipes = await mealDbService.getRecipesByCategory('Vegetarian');
        final additionalRecipes = healthyRecipes.where((recipe) =>
          !suggestions.any((s) => s.id == recipe.id) &&
          recipe.estimatedCalories <= remainingCalories * 0.6
        ).take(3 - suggestions.length);

        suggestions.addAll(additionalRecipes);
      }

    } catch (e) {
      // Fallback: return some default healthy recipes
      try {
        final fallbackRecipes = await mealDbService.getRecipesByCategory('Vegetarian');
        suggestions.addAll(fallbackRecipes.take(3));
      } catch (e) {
        // If all fails, create mock suggestions
        suggestions.addAll(_createMockSuggestions());
      }
    }

    return suggestions;
  }

  double _calculateNutritionalScore(
    Recipe recipe,
    double remainingCalories,
    double remainingProteins,
    double remainingCarbs,
    double remainingFats,
  ) {
    final calories = recipe.estimatedCalories;
    final proteins = recipe.estimatedProteins;
    final carbs = recipe.estimatedCarbs;
    final fats = recipe.estimatedFats;

    // Calculate how well the recipe fits the remaining nutritional needs
    final calorieFit = calories / remainingCalories;
    final proteinFit = proteins / remainingProteins;
    final carbFit = carbs / remainingCarbs;
    final fatFit = fats / remainingFats;

    // Score based on balance (closer to ideal ratios is better)
    final idealRatios = [0.3, 0.4, 0.3]; // Protein:Carb:Fat ideal split
    final actualRatios = [
      proteins / calories,
      carbs / calories,
      fats / calories,
    ];

    double balanceScore = 0;
    for (int i = 0; i < 3; i++) {
      balanceScore += 1 - (actualRatios[i] - idealRatios[i]).abs();
    }

    // Combine fit and balance scores
    final fitScore = (calorieFit + proteinFit + carbFit + fatFit) / 4;
    return (balanceScore + fitScore) / 2;
  }

  List<Recipe> _createMockSuggestions() {
    return [
      Recipe(
        id: 'mock1',
        name: 'Healthy Chicken Salad',
        category: 'Chicken',
        area: 'American',
        instructions: 'Mix all ingredients together.',
        thumbnailUrl: 'https://www.themealdb.com/images/media/meals/1548772327.jpg',
        youtubeUrl: 'https://www.youtube.com/watch?v=example1',
        ingredients: [],
        tags: ['Healthy', 'Protein'],
      ),
      Recipe(
        id: 'mock2',
        name: 'Quinoa Bowl',
        category: 'Vegetarian',
        area: 'Mediterranean',
        instructions: 'Cook quinoa and add vegetables.',
        thumbnailUrl: 'https://www.themealdb.com/images/media/meals/1548772327.jpg',
        youtubeUrl: 'https://www.youtube.com/watch?v=example2',
        ingredients: [],
        tags: ['Healthy', 'Gluten-Free'],
      ),
      Recipe(
        id: 'mock3',
        name: 'Grilled Salmon',
        category: 'Seafood',
        area: 'European',
        instructions: 'Grill salmon with herbs.',
        thumbnailUrl: 'https://www.themealdb.com/images/media/meals/1548772327.jpg',
        youtubeUrl: 'https://www.youtube.com/watch?v=example3',
        ingredients: [],
        tags: ['Healthy', 'Omega-3'],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),

            // Content
            Flexible(
              child: _buildContent(),
            ),

            // Actions
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Suggestions personnalisées',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Découvrez des recettes adaptées à vos besoins nutritionnels restants',
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Erreur de chargement',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadSuggestions,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (_suggestions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant_menu,
                size: 48,
                color: AppColors.grey.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Aucune suggestion disponible',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Vous avez déjà atteint vos objectifs nutritionnels !',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final recipe = _suggestions[index];
        return _buildSuggestionItem(recipe);
      },
    );
  }

  Widget _buildSuggestionItem(Recipe recipe) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showRecipeDetails(recipe),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Recipe image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(recipe.thumbnailUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Recipe info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${recipe.category} • ${recipe.area}',
                      style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${recipe.estimatedCalories.round()} cal',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (recipe.youtubeUrl != null) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.play_circle_fill, color: Colors.red, size: 16),
                        ],
                        if (recipe.isHealthy) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Healthy',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: AppColors.primary),
                    onPressed: () => _quickAddRecipe(recipe),
                    tooltip: 'Ajouter au journal',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                  FutureBuilder<bool>(
                    future: _favoriteService.isFavorite(recipe.id),
                    builder: (context, snapshot) {
                      final isFavorite = snapshot.data ?? false;
                      return IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : AppColors.grey,
                          size: 20,
                        ),
                        onPressed: () => _toggleFavorite(recipe),
                        tooltip: isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Autres suggestions'),
            onPressed: _loadSuggestions,
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showRecipeDetails(Recipe recipe) {
    showDialog(
      context: context,
      builder: (context) => RecipeDetailDialog(recipe: recipe),
    );
  }

  Future<void> _quickAddRecipe(Recipe recipe) async {
    try {
      // Convert recipe to meal format
      final foods = recipe.ingredients.map((ingredient) {
        return FoodItem(
          fiber: 0,
          sugars: 0,
          sodium: 0,
          cholesterol: 0,
          id: DateTime.now().millisecondsSinceEpoch.toString() + ingredient.name,
          name: ingredient.name,
          category: 'recipe',
          calories: ingredient.estimateCalories(),
          proteins: 0,
          carbs: 0,
          fats: 0,
          quantity: 100,
        );
      }).toList();

      final meal = Meal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: widget.addedMeal.type, // Same type as the added meal
        date: DateTime.now(),
        foods: foods.cast<FoodItem>(),
      );

      // Add to dashboard
      final success = await context.read<DashboardProvider>().addMeal(meal);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recette "${recipe.name}" ajoutée à votre journal !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(); // Close dialog
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'ajout: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleFavorite(Recipe recipe) async {
    final success = await _favoriteService.toggleFavorite(recipe);
    if (success && mounted) {
      setState(() {}); // Refresh UI
      final isFavorite = await _favoriteService.isFavorite(recipe.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite
                ? 'Ajouté aux favoris'
                : 'Retiré des favoris',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}