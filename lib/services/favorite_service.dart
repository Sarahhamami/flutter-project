import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';

class FavoriteService {
  static const String _favoritesKey = 'favorite_recipes_v2';
  static const String _favoritesMetadataKey = 'favorites_metadata';

  // Get all favorite recipes
  Future<List<Recipe>> getFavoriteRecipes() async {
    try {
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
          // Remove corrupted entry
          await _removeCorruptedEntry(jsonStr);
        }
      }

      return favorites;
    } catch (e) {
      print('Error getting favorite recipes: $e');
      return [];
    }
  }

  // Add recipe to favorites
  Future<bool> addToFavorites(Recipe recipe) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavoriteRecipes();

      // Check if already in favorites
      if (favorites.any((fav) => fav.id == recipe.id)) {
        return true; // Already exists
      }

      // Add timestamp metadata
      await _addFavoriteMetadata(recipe.id);

      favorites.add(recipe);
      final favoritesJson = favorites.map((r) => json.encode(r.toJson())).toList();
      await prefs.setStringList(_favoritesKey, favoritesJson);

      return true;
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }
  }

  // Remove recipe from favorites
  Future<bool> removeFromFavorites(String recipeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavoriteRecipes();

      favorites.removeWhere((recipe) => recipe.id == recipeId);
      await _removeFavoriteMetadata(recipeId);

      final favoritesJson = favorites.map((r) => json.encode(r.toJson())).toList();
      await prefs.setStringList(_favoritesKey, favoritesJson);

      return true;
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }
  }

  // Check if recipe is favorite
  Future<bool> isFavorite(String recipeId) async {
    try {
      final favorites = await getFavoriteRecipes();
      return favorites.any((recipe) => recipe.id == recipeId);
    } catch (e) {
      print('Error checking if favorite: $e');
      return false;
    }
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(Recipe recipe) async {
    final isFav = await isFavorite(recipe.id);
    if (isFav) {
      return await removeFromFavorites(recipe.id);
    } else {
      return await addToFavorites(recipe);
    }
  }

  // Get favorite recipes by category
  Future<List<Recipe>> getFavoritesByCategory(String category) async {
    try {
      final favorites = await getFavoriteRecipes();
      return favorites.where((recipe) =>
        recipe.category.toLowerCase() == category.toLowerCase()
      ).toList();
    } catch (e) {
      print('Error getting favorites by category: $e');
      return [];
    }
  }

  // Get favorite recipes by goal suitability
  Future<List<Recipe>> getFavoritesForGoal(String goal) async {
    try {
      final favorites = await getFavoriteRecipes();
      return favorites.where((recipe) => recipe.matchesGoal(goal)).toList();
    } catch (e) {
      print('Error getting favorites for goal: $e');
      return [];
    }
  }

  // Get healthy favorites
  Future<List<Recipe>> getHealthyFavorites() async {
    try {
      final favorites = await getFavoriteRecipes();
      return favorites.where((recipe) => recipe.isHealthy).toList();
    } catch (e) {
      print('Error getting healthy favorites: $e');
      return [];
    }
  }

  // Get recently added favorites (last 30 days)
  Future<List<Recipe>> getRecentFavorites({int days = 30}) async {
    try {
      final favorites = await getFavoriteRecipes();
      final cutoffDate = DateTime.now().subtract(Duration(days: days));

      final recentFavorites = <Recipe>[];
      final metadata = await _getFavoritesMetadata();

      for (final recipe in favorites) {
        final addedDate = metadata[recipe.id];
        if (addedDate != null && addedDate.isAfter(cutoffDate)) {
          recentFavorites.add(recipe);
        }
      }

      // Sort by most recent first
      recentFavorites.sort((a, b) {
        final dateA = metadata[a.id] ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = metadata[b.id] ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateB.compareTo(dateA);
      });

      return recentFavorites;
    } catch (e) {
      print('Error getting recent favorites: $e');
      return [];
    }
  }

  // Clear all favorites
  Future<void> clearAllFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoritesKey);
      await prefs.remove(_favoritesMetadataKey);
    } catch (e) {
      print('Error clearing favorites: $e');
    }
  }

  // Get favorites count
  Future<int> getFavoritesCount() async {
    try {
      final favorites = await getFavoriteRecipes();
      return favorites.length;
    } catch (e) {
      return 0;
    }
  }

  // Private methods for metadata management
  Future<void> _addFavoriteMetadata(String recipeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metadata = await _getFavoritesMetadata();
      metadata[recipeId] = DateTime.now();
      await prefs.setString(_favoritesMetadataKey, json.encode(metadata));
    } catch (e) {
      print('Error adding favorite metadata: $e');
    }
  }

  Future<void> _removeFavoriteMetadata(String recipeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metadata = await _getFavoritesMetadata();
      metadata.remove(recipeId);
      await prefs.setString(_favoritesMetadataKey, json.encode(metadata));
    } catch (e) {
      print('Error removing favorite metadata: $e');
    }
  }

  Future<Map<String, DateTime>> _getFavoritesMetadata() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metadataJson = prefs.getString(_favoritesMetadataKey);

      if (metadataJson == null) return {};

      final metadata = json.decode(metadataJson) as Map<String, dynamic>;
      return metadata.map((key, value) =>
        MapEntry(key, DateTime.parse(value))
      );
    } catch (e) {
      print('Error getting favorites metadata: $e');
      return {};
    }
  }

  Future<void> _removeCorruptedEntry(String corruptedJson) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
      favoritesJson.remove(corruptedJson);
      await prefs.setStringList(_favoritesKey, favoritesJson);
    } catch (e) {
      print('Error removing corrupted entry: $e');
    }
  }
}