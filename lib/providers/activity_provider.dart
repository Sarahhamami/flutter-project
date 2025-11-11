import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/daily_steps.dart';
import '../repositories/activity_repository.dart';

class ActivityProvider with ChangeNotifier {
  final ActivityRepository _repository = ActivityRepository();

  DailySteps? _todaySteps;
  List<DailySteps> _stepsHistory = [];
  int _dailyGoal = 10000; // pas par défaut
  bool _isLoading = false;

  // Getters
  DailySteps? get todaySteps => _todaySteps;
  List<DailySteps> get stepsHistory => _stepsHistory;
  int get dailyGoal => _dailyGoal;
  bool get isLoading => _isLoading;

  // Calculs pour aujourd'hui
  int get todayStepsCount => _todaySteps?.steps ?? 0;
  double get todayDistance => _todaySteps?.distance ?? 0;
  int get todayCaloriesBurned => _todaySteps?.caloriesBurned ?? 0;
  double get stepsProgress => todayStepsCount / _dailyGoal;
  bool get isGoalReached => todayStepsCount >= _dailyGoal;
  int get remainingSteps => (_dailyGoal - todayStepsCount).clamp(0, _dailyGoal);

  // Statistiques
  double get averageStepsLast7Days {
    if (_stepsHistory.isEmpty) return 0;
    final total = _stepsHistory.fold<int>(0, (sum, steps) => sum + steps.steps);
    return total / _stepsHistory.length;
  }

  DailySteps? get bestDay {
    if (_stepsHistory.isEmpty) return null;
    return _stepsHistory.reduce((a, b) => a.steps > b.steps ? a : b);
  }

  // Initialisation
  Future<void> initialize() async {
    await loadTodaySteps();
    await loadStepsHistory();
  }

  // Charger les pas du jour
  Future<void> loadTodaySteps() async {
    _setLoading(true);
    try {
      _todaySteps = await _repository.getTodaySteps();
      if (_todaySteps == null) {
        // Créer une entrée vide pour aujourd'hui
        _todaySteps = DailySteps(date: DateTime.now(), steps: 0);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors du chargement des pas du jour: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Charger l'historique des 7 derniers jours
  Future<void> loadStepsHistory() async {
    try {
      _stepsHistory = await _repository.getStepsHistory();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors du chargement de l\'historique: $e');
    }
  }

  // Ajouter des pas
  Future<bool> addSteps(int steps) async {
    _setLoading(true);
    try {
      await _repository.addSteps(steps);
      await loadTodaySteps();
      await loadStepsHistory();
      return true;
    } catch (e) {
      debugPrint('Erreur lors de l\'ajout des pas: $e');
      _setLoading(false);
      return false;
    }
  }

  // Mettre à jour les pas du jour
  Future<bool> updateTodaySteps(int newSteps) async {
    if (_todaySteps == null) return false;

    _setLoading(true);
    try {
      final updatedSteps = _todaySteps!.copyWith(steps: newSteps);
      await _repository.saveDailySteps(updatedSteps);
      _todaySteps = updatedSteps;
      await loadStepsHistory();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour des pas: $e');
      _setLoading(false);
      return false;
    }
  }

  // Réinitialiser les pas du jour
  Future<bool> resetTodaySteps() async {
    _setLoading(true);
    try {
      await _repository.resetTodaySteps();
      await loadTodaySteps();
      await loadStepsHistory();
      return true;
    } catch (e) {
      debugPrint('Erreur lors de la réinitialisation: $e');
      _setLoading(false);
      return false;
    }
  }

  // Mettre à jour l'objectif quotidien
  void updateDailyGoal(int newGoal) {
    _dailyGoal = newGoal;
    notifyListeners();
  }

  // Ajouter des pas d'un parcours
  Future<bool> addStepsFromRoute(int steps, double distance) async {
    _setLoading(true);
    try {
      if (_todaySteps == null) {
        _todaySteps = DailySteps(date: DateTime.now(), steps: 0);
      }

      final updatedSteps = _todaySteps!.copyWith(
        steps: _todaySteps!.steps + steps,
        distance: _todaySteps!.distance + distance,
        caloriesBurned: _todaySteps!.caloriesBurned + (steps * 0.04).round(),
      );

      await _repository.saveDailySteps(updatedSteps);
      _todaySteps = updatedSteps;
      await loadStepsHistory();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Erreur lors de l\'ajout des pas du parcours: $e');
      _setLoading(false);
      return false;
    }
  }

  // Simuler des pas (pour tests/démo)
  Future<bool> simulateSteps(int steps) async {
    return await addSteps(steps);
  }

  // Nettoyer les anciennes données
  Future<void> cleanOldData() async {
    try {
      await _repository.cleanOldData();
    } catch (e) {
      debugPrint('Erreur lors du nettoyage des données: $e');
    }
  }

  // Méthode utilitaire pour gérer le loading
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Formatage pour l'affichage
  String get formattedTodaySteps {
    return todayStepsCount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }

  String get formattedGoal {
    return _dailyGoal.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }

  String get formattedProgress => '${(stepsProgress * 100).round()}%';

  String get formattedRemaining {
    return remainingSteps.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }

  String get activityLevel => _todaySteps?.activityLevel ?? 'Aucune donnée';

  // Couleur basée sur le niveau d'activité
  Color get activityColor => _todaySteps?.activityColor ?? Color(0xFF6c757d);
}