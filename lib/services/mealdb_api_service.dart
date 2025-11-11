import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class MealDbApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  // Search recipes by name
  Future<List<Recipe>> searchRecipes(String query) async {
    try {
      final url = Uri.parse('$_baseUrl/search.php?s=$query');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          final meals = data['meals'] as List;
          return meals.map((meal) => Recipe.fromJson(meal)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error searching recipes: $e');
      throw Exception('Failed to search recipes');
    }
  }

  // Get recipes by category
  Future<List<Recipe>> getRecipesByCategory(String category) async {
    try {
      final url = Uri.parse('$_baseUrl/filter.php?c=$category');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null && data['meals'] is List) {
          final meals = data['meals'] as List;
          // Get full details for each meal (limit to first 5 to avoid too many requests)
          final recipes = <Recipe>[];
          final limitedMeals = meals.take(5);
          for (final meal in limitedMeals) {
            if (meal is Map<String, dynamic>) {
              final mealId = meal['idMeal']?.toString();
              if (mealId != null) {
                final recipe = await getRecipeById(mealId);
                if (recipe != null) {
                  recipes.add(recipe);
                }
              }
            }
          }
          return recipes;
        }
      }
      return [];
    } catch (e) {
      print('Error getting recipes by category $category: $e');
      return []; // Return empty list instead of throwing
    }
  }

  // Get random recipe
  Future<Recipe?> getRandomRecipe() async {
    try {
      final url = Uri.parse('$_baseUrl/random.php');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          return Recipe.fromJson(data['meals'][0]);
        }
      }
      return null;
    } catch (e) {
      print('Error getting random recipe: $e');
      throw Exception('Failed to get random recipe');
    }
  }

  // Get recipe by ID
  Future<Recipe?> getRecipeById(String id) async {
    try {
      final url = Uri.parse('$_baseUrl/lookup.php?i=$id');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null && data['meals'] is List && data['meals'].isNotEmpty) {
          final mealData = data['meals'][0];
          if (mealData != null && mealData is Map<String, dynamic>) {
            return Recipe.fromJson(mealData);
          }
        }
      }
      return null;
    } catch (e) {
      print('Error getting recipe by ID $id: $e');
      return null; // Return null instead of throwing to prevent cascade failures
    }
  }

  // Get all categories
  Future<List<String>> getCategories() async {
    try {
      final url = Uri.parse('$_baseUrl/categories.php');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['categories'] != null) {
          final categories = data['categories'] as List;
          return categories.map((cat) => cat['strCategory'] as String).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting categories: $e');
      throw Exception('Failed to get categories');
    }
  }

  // Get recipes filtered by goal
  Future<List<Recipe>> getRecipesForGoal(String goal, {int limit = 20}) async {
    try {
      // Get random recipes and filter by goal
      final recipes = <Recipe>[];

      // Try to get recipes from different categories that might match the goal
      final categories = await getCategories();

      for (final category in categories.take(5)) { // Limit to first 5 categories
        final categoryRecipes = await getRecipesByCategory(category);
        recipes.addAll(categoryRecipes);

        if (recipes.length >= limit * 2) break; // Get more than needed to filter
      }

      // Filter recipes that match the goal
      final filteredRecipes = recipes.where((recipe) => recipe.matchesGoal(goal)).take(limit).toList();

      // If not enough recipes, add some random ones that match
      if (filteredRecipes.length < limit) {
        for (int i = 0; i < limit - filteredRecipes.length; i++) {
          final randomRecipe = await getRandomRecipe();
          if (randomRecipe != null && randomRecipe.matchesGoal(goal)) {
            filteredRecipes.add(randomRecipe);
          }
        }
      }

      return filteredRecipes;
    } catch (e) {
      print('Error getting recipes for goal: $e');
      throw Exception('Failed to get recipes for goal');
    }
  }

  // Get healthy recipes
  Future<List<Recipe>> getHealthyRecipes({int limit = 20}) async {
    try {
      final recipes = <Recipe>[];

      // Get recipes from healthy categories
      final healthyCategories = ['Vegetarian', 'Vegan', 'Chicken', 'Seafood', 'Salad'];

      for (final category in healthyCategories) {
        try {
          final categoryRecipes = await getRecipesByCategory(category);
          recipes.addAll(categoryRecipes);
        } catch (e) {
          // Continue if category fails
          continue;
        }
      }

      // Filter healthy recipes
      return recipes.where((recipe) => recipe.isHealthy).take(limit).toList();
    } catch (e) {
      print('Error getting healthy recipes: $e');
      throw Exception('Failed to get healthy recipes');
    }
  }
}