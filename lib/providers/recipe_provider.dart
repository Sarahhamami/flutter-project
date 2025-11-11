import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import '../repositories/recipe_repository.dart';
import '../services/mealdb_api_service.dart';

class RecipeProvider with ChangeNotifier {
  final RecipeRepository _repository;

  RecipeProvider() : _repository = RecipeRepository(MealDbApiService());

  // State
  List<Recipe> _recipes = [];
  List<Recipe> _favoriteRecipes = [];
  List<Recipe> _recentRecipes = [];
  bool _isLoading = false;
  String? _error;
  String _currentGoal = 'maintien';

  // Getters
  List<Recipe> get recipes => _recipes;
  List<Recipe> get favoriteRecipes => _favoriteRecipes;
  List<Recipe> get recentRecipes => _recentRecipes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentGoal => _currentGoal;

  // Set current nutrition goal
  void setGoal(String goal) {
    _currentGoal = goal;
    notifyListeners();
  }

  // Load recipes for current goal
  Future<void> loadRecipesForGoal({int limit = 20}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _recipes = await _repository.getRecipesForGoal(_currentGoal, limit: limit);
    } catch (e) {
      _error = e.toString();
      _recipes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search recipes
  Future<void> searchRecipes(String query) async {
    if (query.isEmpty) {
      await loadRecipesForGoal();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _recipes = await _repository.searchRecipes(query);
    } catch (e) {
      _error = e.toString();
      _recipes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get random recipe
  Future<Recipe?> getRandomRecipe() async {
    _isLoading = true;
    notifyListeners();

    try {
      final recipe = await _repository.getRandomRecipe();
      if (recipe != null) {
        await _repository.addToRecent(recipe);
        await loadRecentRecipes();
      }
      return recipe;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load favorite recipes
  Future<void> loadFavoriteRecipes() async {
    try {
      _favoriteRecipes = await _repository.getFavoriteRecipes();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  // Load recent recipes
  Future<void> loadRecentRecipes() async {
    try {
      _recentRecipes = await _repository.getRecentRecipes();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  // Add to favorites
  Future<bool> addToFavorites(Recipe recipe) async {
    final success = await _repository.addToFavorites(recipe);
    if (success) {
      await loadFavoriteRecipes();
    }
    return success;
  }

  // Remove from favorites
  Future<bool> removeFromFavorites(String recipeId) async {
    final success = await _repository.removeFromFavorites(recipeId);
    if (success) {
      await loadFavoriteRecipes();
    }
    return success;
  }

  // Check if recipe is favorite
  Future<bool> isFavorite(String recipeId) async {
    return await _repository.isFavorite(recipeId);
  }

  // Add recipe to recent
  Future<void> addToRecent(Recipe recipe) async {
    await _repository.addToRecent(recipe);
    await loadRecentRecipes();
  }

  // Get recipe by ID
  Future<Recipe?> getRecipeById(String id) async {
    try {
      return await _repository.getRecipeById(id);
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  // Load healthy recipes
  Future<void> loadHealthyRecipes({int limit = 20}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _recipes = await _repository.getHealthyRecipes(limit: limit);
    } catch (e) {
      _error = e.toString();
      _recipes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get recipes by category
  Future<void> loadRecipesByCategory(String category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _recipes = await _repository.getRecipesByCategory(category);
    } catch (e) {
      _error = e.toString();
      _recipes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get categories
  Future<List<String>> getCategories() async {
    try {
      return await _repository.getCategories();
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Initialize provider
  Future<void> initialize() async {
    await loadFavoriteRecipes();
    await loadRecentRecipes();
    await loadRecipesForGoal();
  }

  // Clear cache
  Future<void> clearCache() async {
    await _repository.clearCache();
    _favoriteRecipes = [];
    _recentRecipes = [];
    notifyListeners();
  }
}