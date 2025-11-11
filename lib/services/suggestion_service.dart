import '../models/recipe.dart';
import '../models/meal.dart';
import '../models/ingredient.dart';
import '../models/nutrition_profile.dart';
import 'mealdb_api_service.dart';

class SuggestionService {
  final MealDbApiService _apiService;

  SuggestionService(this._apiService);

  // Get meal type categories mapping
  Map<String, List<String>> get _mealTypeCategories => {
    'breakfast': ['Breakfast', 'Starter'],
    'lunch': ['Beef', 'Chicken', 'Seafood', 'Main Course'],
    'dinner': ['Beef', 'Chicken', 'Seafood', 'Main Course', 'Pork'],
    'snack': ['Dessert', 'Side', 'Vegetarian', 'Pasta'],
  };

  // Get contextual suggestions based on meal type and nutrition goal
  Future<List<Recipe>> getContextualSuggestions(
    String mealType,
    NutritionProfile? profile,
    {int limit = 3}
  ) async {
    try {
      final categories = _mealTypeCategories[mealType] ?? ['Main Course'];
      final allRecipes = <Recipe>[];

      // Try to get recipes from one primary category first
      final primaryCategory = categories.first;
      try {
        final categoryRecipes = await _apiService.getRecipesByCategory(primaryCategory);
        allRecipes.addAll(categoryRecipes.take(3)); // Take only first 3 to avoid overload
      } catch (e) {
        print('Failed to get recipes for primary category $primaryCategory: $e');
      }

      // If still not enough, try secondary category
      if (allRecipes.length < limit && categories.length > 1) {
        final secondaryCategory = categories[1];
        try {
          final categoryRecipes = await _apiService.getRecipesByCategory(secondaryCategory);
          allRecipes.addAll(categoryRecipes.take(2));
        } catch (e) {
          print('Failed to get recipes for secondary category $secondaryCategory: $e');
        }
      }

      // If still not enough, add random recipes
      if (allRecipes.length < limit) {  
        for (int i = 0; i < (limit - allRecipes.length + 1); i++) {
          try {
            final randomRecipe = await _apiService.getRandomRecipe();
            if (randomRecipe != null && !_recipeAlreadyExists(randomRecipe, allRecipes)) {
              allRecipes.add(randomRecipe);
            }
          } catch (e) {
            print('Failed to get random recipe: $e');
          }
        }
      }

      // Filter and score recipes
      final scoredRecipes = _scoreRecipes(allRecipes, mealType, profile);

      // Sort by score and return top recipes
      scoredRecipes.sort((a, b) => b.score.compareTo(a.score));
      return scoredRecipes.take(limit).map((sr) => sr.recipe).toList();

    } catch (e) {
      print('Error getting contextual suggestions: $e');
      return _getFallbackRecipes(mealType, limit);
    }
  }

  // Fallback recipes when API fails
  List<Recipe> _getFallbackRecipes(String mealType, int limit) {
    // Return some basic recipe suggestions based on meal type
    final fallbackRecipes = <Recipe>[];

    switch (mealType) {
      case 'breakfast':
        fallbackRecipes.addAll([
          Recipe(
            id: 'fallback_1',
            name: 'Oatmeal with Fruits',
            category: 'Breakfast',
            area: 'Healthy',
            instructions: 'Mix oats with water, cook, add fruits.',
            thumbnailUrl: 'https://via.placeholder.com/300x200?text=Oatmeal',
            ingredients: [
              Ingredient(name: 'Oats', measure: '1 cup'),
              Ingredient(name: 'Banana', measure: '1'),
              Ingredient(name: 'Milk', measure: '1 cup'),
            ],
            tags: ['healthy', 'breakfast'],
          ),
        ]);
        break;
      case 'lunch':
      case 'dinner':
        fallbackRecipes.addAll([
          Recipe(
            id: 'fallback_2',
            name: 'Grilled Chicken Salad',
            category: 'Main Course',
            area: 'Healthy',
            instructions: 'Grill chicken, mix with vegetables.',
            thumbnailUrl: 'https://via.placeholder.com/300x200?text=Chicken+Salad',
            ingredients: [
              Ingredient(name: 'Chicken Breast', measure: '200g'),
              Ingredient(name: 'Lettuce', measure: '2 cups'),
              Ingredient(name: 'Tomatoes', measure: '2'),
            ],
            tags: ['healthy', 'protein'],
          ),
        ]);
        break;
      case 'snack':
        fallbackRecipes.addAll([
          Recipe(
            id: 'fallback_3',
            name: 'Greek Yogurt with Honey',
            category: 'Dessert',
            area: 'Healthy',
            instructions: 'Mix yogurt with honey.',
            thumbnailUrl: 'https://via.placeholder.com/300x200?text=Yogurt',
            ingredients: [
              Ingredient(name: 'Greek Yogurt', measure: '200g'),
              Ingredient(name: 'Honey', measure: '1 tbsp'),
              Ingredient(name: 'Nuts', measure: '1 handful'),
            ],
            tags: ['healthy', 'snack'],
          ),
        ]);
        break;
    }

    return fallbackRecipes.take(limit).toList();
  }

  // Helper to check if recipe already exists in list
  bool _recipeAlreadyExists(Recipe recipe, List<Recipe> existingRecipes) {
    return existingRecipes.any((existing) => existing.id == recipe.id);
  }

  // Score recipes based on relevance
  List<_ScoredRecipe> _scoreRecipes(List<Recipe> recipes, String mealType, NutritionProfile? profile) {
    return recipes.map((recipe) {
      double score = 0;

      // Base score for meal type relevance
      if (_isRecipeSuitableForMealType(recipe, mealType)) {
        score += 20;
      }

      // Score based on nutrition goal
      if (profile != null && recipe.matchesGoal(profile.objectif)) {
        score += 15;
      }

      // Score for healthy recipes
      if (recipe.isHealthy) {
        score += 10;
      }

      // Score based on calorie appropriateness for meal type
      final calories = recipe.estimatedCalories;
      switch (mealType) {
        case 'breakfast':
          if (calories >= 200 && calories <= 500) score += 10;
          break;
        case 'lunch':
        case 'dinner':
          if (calories >= 400 && calories <= 800) score += 10;
          break;
        case 'snack':
          if (calories >= 100 && calories <= 300) score += 10;
          break;
      }

      // Small random factor to add variety
      score += (DateTime.now().millisecondsSinceEpoch % 10);

      return _ScoredRecipe(recipe, score);
    }).toList();
  }

  // Check if recipe is suitable for meal type
  bool _isRecipeSuitableForMealType(Recipe recipe, String mealType) {
    final category = recipe.category.toLowerCase();

    switch (mealType) {
      case 'breakfast':
        return category.contains('breakfast') ||
               category.contains('starter') ||
               recipe.ingredients.any((ing) =>
                 ing.name.toLowerCase().contains('egg') ||
                 ing.name.toLowerCase().contains('bread') ||
                 ing.name.toLowerCase().contains('cereal'));

      case 'lunch':
      case 'dinner':
        return category.contains('main') ||
               category.contains('beef') ||
               category.contains('chicken') ||
               category.contains('seafood') ||
               category.contains('pork');

      case 'snack':
        return category.contains('dessert') ||
               category.contains('side') ||
               category.contains('vegetarian') ||
               category.contains('pasta') ||
               recipe.estimatedCalories < 400;

      default:
        return true;
    }
  }

  // Get suggestions after meal addition
  Future<List<Recipe>> getSuggestionsAfterMeal(Meal meal, NutritionProfile? profile) async {
    // For now, return simple suggestions based on meal type
    // In a more advanced version, we could analyze existing meals and suggest complementary recipes
    return getContextualSuggestions(meal.type, profile, limit: 3);
  }

  // Get diverse suggestions (mix of categories)
  Future<List<Recipe>> getDiverseSuggestions(NutritionProfile? profile, {int limit = 10}) async {
    try {
      final recipes = <Recipe>[];
      final categories = ['Chicken', 'Beef', 'Seafood', 'Vegetarian', 'Pasta'];

      for (final category in categories) {
        try {
          final categoryRecipes = await _apiService.getRecipesByCategory(category);
          recipes.addAll(categoryRecipes.take(2)); // Take 2 from each category
        } catch (e) {
          continue;
        }
      }

      // Filter by goal if profile exists
      if (profile != null) {
        recipes.retainWhere((recipe) => recipe.matchesGoal(profile.objectif));
      }

      // Shuffle for variety and return limited results
      recipes.shuffle();
      return recipes.take(limit).toList();

    } catch (e) {
      print('Error getting diverse suggestions: $e');
      return [];
    }
  }
}

// Helper class for scoring recipes
class _ScoredRecipe {
  final Recipe recipe;
  final double score;

  _ScoredRecipe(this.recipe, this.score);
}