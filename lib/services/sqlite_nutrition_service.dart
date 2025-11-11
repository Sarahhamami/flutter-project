import '../db/database_helper.dart';
import '../models/nutrition_profile.dart';
import '../models/daily_progress.dart';
import '../models/meal.dart';
import '../models/food_item.dart';

class SqliteNutritionService {
  static final DatabaseHelper _dbHelper = DatabaseHelper();

  // Get current user ID
  static Future<int> _getCurrentUserId() async {
    return await _dbHelper.getDefaultUserId();
  }

  // ========================================
  // NUTRITION PROFILE OPERATIONS
  // ========================================

  static Future<bool> saveNutritionProfile(NutritionProfile profile) async {
    try {
      final userId = await _getCurrentUserId();

      // Check if profile already exists
      final existingProfile = await _dbHelper.getNutritionProfile(userId);

      if (existingProfile != null) {
        // Update existing profile
        await _dbHelper.updateNutritionProfile(
          nutritionId: existingProfile['nutrition_id'],
          poids: profile.poids,
          taille: profile.taille,
          age: profile.age,
          objectif: profile.objectif,
          calorieObjectif: profile.calorieObjectif,
          proteineObjectif: profile.proteineObjectif,
          glucideObjectif: profile.glucideObjectif,
          lipideObjectif: profile.lipideObjectif,
          eauObjectif: profile.eauObjectif.toDouble(),
          pasObjectif: profile.pasObjectif,
        );
      } else {
        // Create new profile
        await _dbHelper.createNutritionProfile(
          userId: userId,
          poids: profile.poids,
          taille: profile.taille,
          age: profile.age,
          objectif: profile.objectif,
          calorieObjectif: profile.calorieObjectif,
          proteineObjectif: profile.proteineObjectif,
          glucideObjectif: profile.glucideObjectif,
          lipideObjectif: profile.lipideObjectif,
          eauObjectif: profile.eauObjectif.toDouble(),
          pasObjectif: profile.pasObjectif,
        );
      }
      return true;
    } catch (e) {
      print('Error saving nutrition profile: $e');
      return false;
    }
  }

  static Future<NutritionProfile?> getNutritionProfile() async {
    try {
      final userId = await _getCurrentUserId();
      final profileData = await _dbHelper.getNutritionProfile(userId);

      if (profileData != null) {
        return NutritionProfile(
          poids: profileData['poids']?.toDouble() ?? 0.0,
          taille: profileData['taille']?.toDouble() ?? 0.0,
          age: profileData['age'] ?? 0,
          sexe: 'homme', // Default value since not stored in SQLite table
          objectif: profileData['objectif'] ?? 'maintien',
          niveauActivite: 'modere', // Default value since not stored in SQLite table
          calorieObjectif: profileData['calorie_objectif']?.toDouble() ?? 0.0,
          proteineObjectif: profileData['proteine_objectif']?.toDouble() ?? 0.0,
          glucideObjectif: profileData['glucide_objectif']?.toDouble() ?? 0.0,
          lipideObjectif: profileData['lipide_objectif']?.toDouble() ?? 0.0,
          eauObjectif: (profileData['eau_objectif'] as num?)?.toInt() ?? 2000,
          pasObjectif: profileData['pas_objectif'] ?? 0,
        );
      }
      return null;
    } catch (e) {
      print('Error getting nutrition profile: $e');
      return null;
    }
  }

  // ========================================
  // MEAL OPERATIONS
  // ========================================

  static Future<bool> saveMeal(Meal meal) async {
    try {
      final userId = await _getCurrentUserId();
      final profileData = await _dbHelper.getNutritionProfile(userId);

      if (profileData == null) return false;

      final nutritionId = profileData['nutrition_id'];
      final dateStr = meal.date.toIso8601String().split('T')[0];

      // Create meal in database
      final mealId = await _dbHelper.createMeal(
        nutritionId: nutritionId,
        dateRepas: dateStr,
        typeRepas: meal.type,
        caloriesTotales: meal.totalCalories,
      );

      // Add foods to meal
      for (final food in meal.foods) {
        // First, ensure food exists in Aliment table
        final foodId = await _ensureFoodExists(food);
        if (foodId != null) {
          await _dbHelper.addFoodToMeal(
            repasId: mealId,
            alimentId: foodId,
            quantite: food.quantity,
          );
        }
      }

      return true;
    } catch (e) {
      print('Error saving meal: $e');
      return false;
    }
  }

  static Future<List<Meal>> getMealsForDate(DateTime date) async {
    try {
      final userId = await _getCurrentUserId();
      final profileData = await _dbHelper.getNutritionProfile(userId);

      if (profileData == null) return [];

      final nutritionId = profileData['nutrition_id'];
      final dateStr = date.toIso8601String().split('T')[0];

      final mealsData = await _dbHelper.getMealsForDate(nutritionId, dateStr);
      final meals = <Meal>[];

      for (final mealData in mealsData) {
        final foods = await _getFoodsForMeal(mealData['repas_id']);
        final meal = Meal(
          id: mealData['repas_id'].toString(),
          type: mealData['type_repas'],
          date: date,
          foods: foods,
        );
        meals.add(meal);
      }

      return meals;
    } catch (e) {
      print('Error getting meals for date: $e');
      return [];
    }
  }

  static Future<bool> deleteMeal(String mealId, DateTime date) async {
    try {
      await _dbHelper.deleteMeal(int.parse(mealId));
      return true;
    } catch (e) {
      print('Error deleting meal: $e');
      return false;
    }
  }

  // ========================================
  // FOOD SEARCH OPERATIONS
  // ========================================

  static Future<List<FoodItem>> searchFoods(String query, {int limit = 20}) async {
    try {
      final userId = await _getCurrentUserId();
      final profileData = await _dbHelper.getNutritionProfile(userId);

      if (profileData == null) return [];

      final nutritionId = profileData['nutrition_id'];
      final foodsData = await _dbHelper.searchFoodsByName(query, limit: limit);

      return foodsData.map((foodData) {
        return FoodItem(
          fiber: 0,
          sugars: 0,
          sodium: 0,
          cholesterol: 0,
          quantity: 100,
          id: foodData['aliment_id'].toString(),
          name: foodData['nom'],
          calories: foodData['calories']?.toDouble() ?? 0.0,
          proteins: foodData['proteines']?.toDouble() ?? 0.0,
          carbs: foodData['glucides']?.toDouble() ?? 0.0,
          fats: foodData['lipides']?.toDouble() ?? 0.0,
          unit: 'g',
          category: 'meal',
        );
      }).toList();
    } catch (e) {
      print('Error searching foods: $e');
      return [];
    }
  }

  // ========================================
  // FOOD OPERATIONS
  // ========================================

  static Future<int?> _ensureFoodExists(FoodItem food) async {
    try {
      // Check if food already exists
      final existingFoods = await _dbHelper.searchFoods(food.name);
      if (existingFoods.isNotEmpty) {
        return existingFoods.first['aliment_id'];
      }

      // Create new food
      return await _dbHelper.createFood(
        nom: food.name,
        calories: food.calories,
        proteines: food.proteins,
        glucides: food.carbs,
        lipides: food.fats,
      );
    } catch (e) {
      print('Error ensuring food exists: $e');
      return null;
    }
  }

  static Future<List<FoodItem>> _getFoodsForMeal(int repasId) async {
    try {
      final foodsData = await _dbHelper.getFoodsForMeal(repasId);
      return foodsData.map((foodData) {
        final quantity = foodData['quantite']?.toDouble() ?? 0.0;
        final caloriesPer100g = foodData['calories']?.toDouble() ?? 0.0;

        return FoodItem(
          id: foodData['aliment_id'].toString(),
          name: foodData['nom'],
          category: 'meal', // Default category for meal foods
          calories: caloriesPer100g,
          proteins: foodData['proteines']?.toDouble() ?? 0.0,
          carbs: foodData['glucides']?.toDouble() ?? 0.0,
          fats: foodData['lipides']?.toDouble() ?? 0.0,
          quantity: quantity,
        );
      }).toList();
    } catch (e) {
      print('Error getting foods for meal: $e');
      return [];
    }
  }

  // ========================================
  // HYDRATION OPERATIONS
  // ========================================

  static Future<bool> addWaterIntake(double quantity, DateTime date) async {
    try {
      final userId = await _getCurrentUserId();
      final profileData = await _dbHelper.getNutritionProfile(userId);

      if (profileData == null) return false;

      final nutritionId = profileData['nutrition_id'];
      final dateStr = date.toIso8601String().split('T')[0];

      await _dbHelper.addHydrationEntry(
        nutritionId: nutritionId,
        dateJour: dateStr,
        quantiteBue: quantity,
      );

      return true;
    } catch (e) {
      print('Error adding water intake: $e');
      return false;
    }
  }

  static Future<double> getWaterConsumedForDate(DateTime date) async {
    try {
      final userId = await _getCurrentUserId();
      final profileData = await _dbHelper.getNutritionProfile(userId);

      if (profileData == null) return 0.0;

      final nutritionId = profileData['nutrition_id'];
      final dateStr = date.toIso8601String().split('T')[0];

      return await _dbHelper.getTotalHydrationForDate(nutritionId, dateStr);
    } catch (e) {
      print('Error getting water consumed: $e');
      return 0.0;
    }
  }

  // ========================================
  // STEPS OPERATIONS
  // ========================================

  static Future<bool> addSteps(int steps, DateTime date) async {
    try {
      final userId = await _getCurrentUserId();
      final profileData = await _dbHelper.getNutritionProfile(userId);

      if (profileData == null) return false;

      final nutritionId = profileData['nutrition_id'];
      final dateStr = date.toIso8601String().split('T')[0];

      // Check if entry already exists for today
      final existingEntry = await _dbHelper.getStepsForDate(nutritionId, dateStr);

      if (existingEntry != null) {
        // Update existing entry
        final currentSteps = existingEntry['pas_faits'] ?? 0;
        await _dbHelper.updateStepsForDate(
          nutritionId: nutritionId,
          dateJour: dateStr,
          pasFaits: currentSteps + steps,
        );
      } else {
        // Create new entry
        await _dbHelper.addStepsEntry(
          nutritionId: nutritionId,
          dateJour: dateStr,
          pasFaits: steps,
        );
      }

      return true;
    } catch (e) {
      print('Error adding steps: $e');
      return false;
    }
  }

  static Future<int> getStepsForDate(DateTime date) async {
    try {
      final userId = await _getCurrentUserId();
      final profileData = await _dbHelper.getNutritionProfile(userId);

      if (profileData == null) return 0;

      final nutritionId = profileData['nutrition_id'];
      final dateStr = date.toIso8601String().split('T')[0];

      final stepsData = await _dbHelper.getStepsForDate(nutritionId, dateStr);
      return stepsData?['pas_faits'] ?? 0;
    } catch (e) {
      print('Error getting steps for date: $e');
      return 0;
    }
  }

  // ========================================
  // UTILITY METHODS
  // ========================================

  static Future<DailyProgress> getDailyProgress(DateTime date) async {
    try {
      final userId = await _getCurrentUserId();
      final profileData = await _dbHelper.getNutritionProfile(userId);

      if (profileData == null) {
        return DailyProgress(date: date);
      }

      final nutritionId = profileData['nutrition_id'];
      final dateStr = date.toIso8601String().split('T')[0];

      // Calculate calories and macros directly from foods in meals
      final meals = await getMealsForDate(date);
      double totalCalories = 0.0;
      double totalProteins = 0.0;
      double totalCarbs = 0.0;
      double totalFats = 0.0;

      print('Found ${meals.length} meals for date $dateStr');

      for (final meal in meals) {
        print('Meal ${meal.id} has ${meal.foods.length} foods');
        for (final food in meal.foods) {
          print('Food: ${food.name}, quantity: ${food.quantity}, calories per 100g: ${food.calories}, total calories: ${food.totalCalories}');
          totalCalories += food.totalCalories;
          totalProteins += food.totalProteins;
          totalCarbs += food.totalCarbs;
          totalFats += food.totalFats;
        }
      }

      print('Total calculated calories: $totalCalories');

      // Get hydration and steps from database
      final stats = await _dbHelper.getNutritionStats(nutritionId, dateStr);

      return DailyProgress(
        date: date,
        caloriesConsumed: totalCalories,
        proteinsConsumed: totalProteins,
        carbsConsumed: totalCarbs,
        fatsConsumed: totalFats,
        waterConsumed: stats['total_hydration']?.toDouble() ?? 0.0,
        stepsTaken: stats['steps'] is int ? stats['steps'] as int : (stats['steps'] as double?)?.toInt() ?? 0,
      );
    } catch (e) {
      print('Error getting daily progress: $e');
      return DailyProgress(date: date);
    }
  }

  static Future<bool> hasNutritionProfile() async {
    try {
      final profile = await getNutritionProfile();
      return profile != null;
    } catch (e) {
      return false;
    }
  }

  static Future<void> clearAllData() async {
    try {
      final userId = await _getCurrentUserId();
      final profileData = await _dbHelper.getNutritionProfile(userId);

      if (profileData != null) {
        await _dbHelper.deleteNutritionProfile(profileData['nutrition_id']);
      }
    } catch (e) {
      print('Error clearing nutrition data: $e');
    }
  }
}