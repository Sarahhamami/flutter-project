import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/water_intake.dart';
import '../repositories/hydration_repository.dart';

class HydrationProvider with ChangeNotifier {
  final HydrationRepository _repository = HydrationRepository();

  List<WaterIntake> _waterIntakes = [];
  int _dailyGoal = 2000; // ml par défaut
  bool _isLoading = false;

  // Getters
  List<WaterIntake> get waterIntakes => _waterIntakes;
  int get dailyGoal => _dailyGoal;
  bool get isLoading => _isLoading;

  // Calculs
  int get totalWaterToday => _waterIntakes.fold(0, (sum, intake) => sum + intake.quantity);
  double get waterProgress => (totalWaterToday / _dailyGoal).clamp(0.0, 1.0);
  bool get isGoalReached => totalWaterToday >= _dailyGoal;
  int get remainingWater => (_dailyGoal - totalWaterToday).clamp(0, _dailyGoal);

  // Initialisation
  Future<void> initialize() async {
    await loadTodayWaterIntakes();
  }

  // Charger les prises d'eau du jour
  Future<void> loadTodayWaterIntakes() async {
    _setLoading(true);
    try {
      _waterIntakes = await _repository.getTodayWaterIntakes();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors du chargement des prises d\'eau: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Ajouter une prise d'eau
  Future<bool> addWaterIntake(WaterIntake intake) async {
    _setLoading(true);
    try {
      await _repository.saveWaterIntake(intake);
      await loadTodayWaterIntakes();
      return true;
    } catch (e) {
      debugPrint('Erreur lors de l\'ajout de la prise d\'eau: $e');
      _setLoading(false);
      return false;
    }
  }

  // Ajouter une quantité d'eau rapide (250ml, 500ml, etc.)
  Future<bool> addQuickWaterIntake(int quantity, {String note = ''}) async {
    final intake = WaterIntake(
      date: DateTime.now(),
      quantity: quantity,
      time: TimeOfDay.now(),
      note: note,
    );
    return await addWaterIntake(intake);
  }

  // Mettre à jour une prise d'eau
  Future<bool> updateWaterIntake(WaterIntake intake) async {
    _setLoading(true);
    try {
      await _repository.updateWaterIntake(intake);
      await loadTodayWaterIntakes();
      return true;
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour de la prise d\'eau: $e');
      _setLoading(false);
      return false;
    }
  }

  // Supprimer une prise d'eau
  Future<bool> deleteWaterIntake(String id) async {
    _setLoading(true);
    try {
      await _repository.deleteWaterIntake(id, DateTime.now());
      await loadTodayWaterIntakes();
      return true;
    } catch (e) {
      debugPrint('Erreur lors de la suppression de la prise d\'eau: $e');
      _setLoading(false);
      return false;
    }
  }

  // Mettre à jour l'objectif quotidien
  void updateDailyGoal(int newGoal) {
    _dailyGoal = newGoal;
    notifyListeners();
  }

  // Récupérer l'historique des 7 derniers jours
  Future<Map<DateTime, int>> getWaterHistory() async {
    try {
      return await _repository.getWaterHistory();
    } catch (e) {
      debugPrint('Erreur lors de la récupération de l\'historique: $e');
      return {};
    }
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

  // Formater le total d'eau pour l'affichage
  String get formattedTotalWater {
    if (totalWaterToday >= 1000) {
      return '${(totalWaterToday / 1000).toStringAsFixed(1)}L';
    } else {
      return '${totalWaterToday}ml';
    }
  }

  // Formater l'objectif pour l'affichage
  String get formattedGoal {
    if (_dailyGoal >= 1000) {
      return '${(_dailyGoal / 1000).toStringAsFixed(1)}L';
    } else {
      return '${_dailyGoal}ml';
    }
  }

  // Calculer le pourcentage formaté
  String get formattedProgress => '${(waterProgress * 100).round()}%';
}