import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/nutrition_profile.dart';
import '../models/daily_progress.dart';
import '../models/meal.dart';

class NutritionDatabaseService {
  static const String _nutritionProfileKey = 'nutrition_profile';
  static const String _dailyProgressKey = 'daily_progress';
  static const String _mealsKey = 'meals';

  static Future<void> init() async {
    // Initialisation des Shared Preferences
    await SharedPreferences.getInstance();
  }

  // === PROFIL NUTRITIONNEL ===

  // Sauvegarde du profil nutritionnel
  static Future<bool> saveNutritionProfile(NutritionProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = jsonEncode(profile.toJson());
      return await prefs.setString(_nutritionProfileKey, profileJson);
    } catch (e) {
      print('Erreur lors de la sauvegarde du profil nutritionnel: $e');
      return false;
    }
  }

  // Chargement du profil nutritionnel
  static Future<NutritionProfile?> getNutritionProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_nutritionProfileKey);

      if (profileJson != null) {
        final profileMap = jsonDecode(profileJson) as Map<String, dynamic>;
        return NutritionProfile.fromJson(profileMap);
      }

      return null;
    } catch (e) {
      print('Erreur lors du chargement du profil nutritionnel: $e');
      return null;
    }
  }

  // === PROGRÈS QUOTIDIEN ===

  // Sauvegarde du progrès quotidien
  static Future<bool> saveDailyProgress(DailyProgress progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = jsonEncode(progress.toJson());
      final dateKey = _getDateKey(progress.date);
      return await prefs.setString('${_dailyProgressKey}_$dateKey', progressJson);
    } catch (e) {
      print('Erreur lors de la sauvegarde du progrès quotidien: $e');
      return false;
    }
  }

  // Chargement du progrès quotidien pour une date spécifique
  static Future<DailyProgress?> getDailyProgress(DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateKey = _getDateKey(date);
      final progressJson = prefs.getString('${_dailyProgressKey}_$dateKey');

      if (progressJson != null) {
        final progressMap = jsonDecode(progressJson) as Map<String, dynamic>;
        return DailyProgress.fromJson(progressMap);
      }

      // Retourner un progrès vide pour aujourd'hui si aucun n'existe
      if (_isToday(date)) {
        return DailyProgress(date: date);
      }

      return null;
    } catch (e) {
      print('Erreur lors du chargement du progrès quotidien: $e');
      return null;
    }
  }

  // Chargement du progrès d'aujourd'hui
  static Future<DailyProgress> getTodayProgress() async {
    final today = DateTime.now();
    final progress = await getDailyProgress(today);
    return progress ?? DailyProgress(date: today);
  }

  // === REPAS ===

  // Sauvegarde d'un repas
  static Future<bool> saveMeal(Meal meal) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final meals = await getMealsForDate(meal.date);

      // Supprimer le repas existant s'il y en a un avec le même ID
      meals.removeWhere((m) => m.id == meal.id);
      meals.add(meal);

      final mealsJson = jsonEncode(meals.map((m) => m.toJson()).toList());
      final dateKey = _getDateKey(meal.date);
      return await prefs.setString('${_mealsKey}_$dateKey', mealsJson);
    } catch (e) {
      print('Erreur lors de la sauvegarde du repas: $e');
      return false;
    }
  }

  // Chargement des repas pour une date spécifique
  static Future<List<Meal>> getMealsForDate(DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateKey = _getDateKey(date);
      final mealsJson = prefs.getString('${_mealsKey}_$dateKey');

      if (mealsJson != null) {
        final mealsList = jsonDecode(mealsJson) as List<dynamic>;
        return mealsList.map((mealJson) => Meal.fromJson(mealJson)).toList();
      }

      return [];
    } catch (e) {
      print('Erreur lors du chargement des repas: $e');
      return [];
    }
  }

  // Chargement des repas d'aujourd'hui
  static Future<List<Meal>> getTodayMeals() async {
    return getMealsForDate(DateTime.now());
  }

  // Suppression d'un repas
  static Future<bool> deleteMeal(String mealId, DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final meals = await getMealsForDate(date);
      meals.removeWhere((meal) => meal.id == mealId);

      final mealsJson = jsonEncode(meals.map((m) => m.toJson()).toList());
      final dateKey = _getDateKey(date);
      return await prefs.setString('${_mealsKey}_$dateKey', mealsJson);
    } catch (e) {
      print('Erreur lors de la suppression du repas: $e');
      return false;
    }
  }

  // === UTILITAIRES ===

  // Nettoyage des données
  static Future<bool> clearData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_nutritionProfileKey) ||
            key.startsWith(_dailyProgressKey) ||
            key.startsWith(_mealsKey)) {
          await prefs.remove(key);
        }
      }
      return true;
    } catch (e) {
      print('Erreur lors du nettoyage des données: $e');
      return false;
    }
  }

  // Vérification si un profil existe
  static Future<bool> hasNutritionProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_nutritionProfileKey);
    } catch (e) {
      print('Erreur lors de la vérification du profil: $e');
      return false;
    }
  }

  // === FONCTIONS UTILITAIRES ===

  static String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  // Calcul du progrès quotidien à partir des repas
  static Future<DailyProgress> calculateDailyProgressFromMeals(DateTime date) async {
    final meals = await getMealsForDate(date);

    double totalCalories = 0;
    double totalProteins = 0;
    double totalCarbs = 0;
    double totalFats = 0;

    for (final meal in meals) {
      totalCalories += meal.totalCalories;
      totalProteins += meal.totalProteins;
      totalCarbs += meal.totalCarbs;
      totalFats += meal.totalFats;
    }

    return DailyProgress(
      date: date,
      caloriesConsumed: totalCalories,
      proteinsConsumed: totalProteins,
      carbsConsumed: totalCarbs,
      fatsConsumed: totalFats,
    );
  }

  // Récupérer les repas récents
  static Future<List<Meal>> getRecentMeals(int days) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final List<Meal> recentMeals = [];

    // Récupérer les repas pour chaque jour de la période
    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      final mealsForDate = await getMealsForDate(date);
      recentMeals.addAll(mealsForDate);
    }

    // Trier par date décroissante
    recentMeals.sort((a, b) => b.date.compareTo(a.date));
    return recentMeals;
  }

  // Récupérer le progrès récent
  static Future<List<DailyProgress>> getRecentProgress(int days) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final List<DailyProgress> recentProgress = [];

    // Récupérer le progrès pour chaque jour de la période
    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      final progress = await getDailyProgress(date);
      if (progress != null) {
        recentProgress.add(progress);
      }
    }

    // Trier par date décroissante
    recentProgress.sort((a, b) => b.date.compareTo(a.date));
    return recentProgress;
  }
}