import 'package:flutter/foundation.dart';
import '../models/nutrition_profile.dart';
import '../models/daily_progress.dart';
import '../models/meal.dart';
import '../services/sqlite_nutrition_service.dart';
import '../repositories/hydration_repository.dart';
import '../repositories/activity_repository.dart';

class DashboardProvider with ChangeNotifier {
  // Repositories
  final HydrationRepository _hydrationRepository = HydrationRepository();
  final ActivityRepository _activityRepository = ActivityRepository();

  // État de chargement
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Profil nutritionnel
  NutritionProfile? _nutritionProfile;
  NutritionProfile? get nutritionProfile => _nutritionProfile;

  // Progrès quotidien
  DailyProgress? _dailyProgress;
  DailyProgress? get dailyProgress => _dailyProgress;

  // Repas du jour
  List<Meal> _todayMeals = [];
  List<Meal> get todayMeals => _todayMeals;

  // Erreurs
  String? _error;
  String? get error => _error;

  // Initialisation
  Future<void> initialize() async {
    _setLoading(true);
    _error = null;

    try {
      // Charger le profil nutritionnel
      _nutritionProfile = await SqliteNutritionService.getNutritionProfile();

      if (_nutritionProfile != null) {
        final today = DateTime.now();

        // Calculer le progrès quotidien à partir des repas
        final calculatedProgress = await SqliteNutritionService.getDailyProgress(today);

        // Charger les données d'hydratation
        final totalWater = await _hydrationRepository.getTotalWaterForDate(today);

        // Charger les données d'activité
        final dailySteps = await _activityRepository.getStepsForDate(today);

        // Utiliser directement le progrès calculé et fusionner avec les autres données
        _dailyProgress = calculatedProgress.copyWith(
          waterConsumed: totalWater,
          stepsTaken: dailySteps?.steps ?? 0,
        );

        // Charger les repas du jour
        _todayMeals = await SqliteNutritionService.getMealsForDate(DateTime.now());
      }
    } catch (e) {
      _error = 'Erreur lors du chargement des données: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Ajouter un repas
  Future<bool> addMeal(Meal meal) async {
    _setLoading(true);
    try {
      final success = await SqliteNutritionService.saveMeal(meal);
      if (success) {
        // Recharger les données
        await initialize();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Erreur lors de l\'ajout du repas: $e';
      _setLoading(false);
      return false;
    }
  }

  // Supprimer un repas
  Future<bool> deleteMeal(String mealId) async {
    _setLoading(true);
    try {
      final success = await SqliteNutritionService.deleteMeal(mealId, DateTime.now());
      if (success) {
        // Recharger les données
        await initialize();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Erreur lors de la suppression du repas: $e';
      _setLoading(false);
      return false;
    }
  }

  // Mettre à jour l'eau consommée
  Future<bool> updateWater(int newAmount) async {
    if (_dailyProgress == null) return false;

    try {
      final updatedProgress = _dailyProgress!.copyWith(waterConsumed: newAmount);
      // Note: Daily progress is now calculated from meals in SQLite, no direct save needed
      final success = true;

      if (success) {
        _dailyProgress = updatedProgress;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Erreur lors de la mise à jour de l\'eau: $e';
      return false;
    }
  }

  // Mettre à jour les pas
  Future<bool> updateSteps(int newSteps) async {
    if (_dailyProgress == null) return false;

    try {
      final updatedProgress = _dailyProgress!.copyWith(stepsTaken: newSteps);
      // Note: Daily progress is now calculated from meals in SQLite, no direct save needed
      final success = true;

      if (success) {
        _dailyProgress = updatedProgress;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Erreur lors de la mise à jour des pas: $e';
      return false;
    }
  }

  // Mettre à jour le poids actuel
  Future<bool> updateWeight(double newWeight) async {
    if (_dailyProgress == null) return false;

    try {
      final updatedProgress = _dailyProgress!.copyWith(currentWeight: newWeight);
      // Note: Daily progress is now calculated from meals in SQLite, no direct save needed
      final success = true;

      if (success) {
        _dailyProgress = updatedProgress;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Erreur lors de la mise à jour du poids: $e';
      return false;
    }
  }

  // Calculs pour l'affichage
  double get caloriesRemaining {
    if (_nutritionProfile == null || _dailyProgress == null) return 0;
    return (_nutritionProfile!.calorieObjectif - _dailyProgress!.caloriesConsumed).clamp(0, double.infinity);
  }

  double get caloriesPercentage {
    if (_nutritionProfile == null) return 0;
    if (_dailyProgress == null) return 0;
    return _dailyProgress!.getCaloriesPercentage(_nutritionProfile!.calorieObjectif);
  }

  double get waterPercentage {
    if (_nutritionProfile == null) return 0;
    if (_dailyProgress == null) return 0;
    return _dailyProgress!.getWaterPercentage(_nutritionProfile!.eauObjectif);
  }

  double get stepsPercentage {
    if (_nutritionProfile == null) return 0;
    if (_dailyProgress == null) return 0;
    return _dailyProgress!.getStepsPercentage(_nutritionProfile!.pasObjectif);
  }

  // Vérifier si les objectifs sont atteints
  bool get isCaloriesGoalMet {
    return caloriesPercentage >= 1.0;
  }

  bool get isWaterGoalMet {
    return waterPercentage >= 1.0;
  }

  bool get isStepsGoalMet {
    return stepsPercentage >= 1.0;
  }

  // Méthode utilitaire pour gérer le loading
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Nettoyer l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }
}