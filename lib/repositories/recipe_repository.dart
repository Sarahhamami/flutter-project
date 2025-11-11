import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';
import '../services/mealdb_api_service.dart';

class RecipeRepository {
  final MealDbApiService _apiService;
  static const String _favoritesKey = 'favorite_recipes';
  static const String _recentKey = 'recent_recipes';

  RecipeRepository(this._apiService);

  // Search recipes
  Future<List<Recipe>> searchRecipes(String query) async {
    return await _apiService.searchRecipes(query);
  }

  // Get recipes by category
  Future<List<Recipe>> getRecipesByCategory(String category) async {
    return await _apiService.getRecipesByCategory(category);
  }

  // Get random recipe
  Future<Recipe?> getRandomRecipe() async {
    return await _apiService.getRandomRecipe();
  }

  // Get recipe by ID
  Future<Recipe?> getRecipeById(String id) async {
    return await _apiService.getRecipeById(id);
  }

  // Get recipes filtered by nutrition goal
  Future<List<Recipe>> getRecipesForGoal(String goal, {int limit = 20}) async {
    return await _apiService.getRecipesForGoal(goal, limit: limit);
  }

  // Get healthy recipes
  Future<List<Recipe>> getHealthyRecipes({int limit = 20}) async {
    return await _apiService.getHealthyRecipes(limit: limit);
  }

  // Get all categories
  Future<List<String>> getCategories() async {
    return await _apiService.getCategories();
  }

  // Favorites management
  Future<List<Recipe>> getFavoriteRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

    final favorites = <Recipe>[];
    for (final jsonStr in favoritesJson) {
      try {
        final recipeJson = json.decode(jsonStr);
        final recipe = Recipe.fromJson(recipeJson);
        favorites.add(recipe);
      } catch (e) {
        print('Error parsing favorite recipe: $e');
      }
    }

    return favorites;
  }

  Future<bool> addToFavorites(Recipe recipe) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavoriteRecipes();

      // Check if already in favorites
      if (favorites.any((fav) => fav.id == recipe.id)) {
        return true; // Already exists
      }

      favorites.add(recipe);
      final favoritesJson = favorites.map((r) => json.encode(r.toJson())).toList();
      await prefs.setStringList(_favoritesKey, favoritesJson);
      return true;
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }
  }

  Future<bool> removeFromFavorites(String recipeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavoriteRecipes();
      favorites.removeWhere((recipe) => recipe.id == recipeId);

      final favoritesJson = favorites.map((r) => json.encode(r.toJson())).toList();
      await prefs.setStringList(_favoritesKey, favoritesJson);
      return true;
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }
  }

  Future<bool> isFavorite(String recipeId) async {
    final favorites = await getFavoriteRecipes();
    return favorites.any((recipe) => recipe.id == recipeId);
  }

  // Recent recipes management
  Future<List<Recipe>> getRecentRecipes({int limit = 10}) async {
    final prefs = await SharedPreferences.getInstance();
    final recentJson = prefs.getStringList(_recentKey) ?? [];

    final recent = <Recipe>[];
    for (final jsonStr in recentJson.take(limit)) {
      try {
        final recipeJson = json.decode(jsonStr);
        final recipe = Recipe.fromJson(recipeJson);
        recent.add(recipe);
      } catch (e) {
        print('Error parsing recent recipe: $e');
      }
    }

    return recent;
  }

  Future<void> addToRecent(Recipe recipe) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recent = await getRecentRecipes(limit: 20); // Get more to manage

      // Remove if already exists
      recent.removeWhere((r) => r.id == recipe.id);

      // Add to beginning
      recent.insert(0, recipe);

      // Keep only last 10
      final limitedRecent = recent.take(10).toList();

      final recentJson = limitedRecent.map((r) => json.encode(r.toJson())).toList();
      await prefs.setStringList(_recentKey, recentJson);
    } catch (e) {
      print('Error adding to recent: $e');
    }
  }

  // Clear all stored data
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoritesKey);
    await prefs.remove(_recentKey);
  }
}