import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_steps.dart';

class ActivityRepository {
  static const String _dailyStepsKey = 'daily_steps';

  // Clé pour aujourd'hui
  String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // Clé pour une date spécifique
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Récupérer les pas du jour
  Future<DailySteps?> getTodaySteps() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('${_dailyStepsKey}_${_getTodayKey()}');
    if (data != null) {
      final jsonData = json.decode(data);
      return DailySteps.fromJson(jsonData);
    }
    return null;
  }

  // Récupérer les pas pour une date spécifique
  Future<DailySteps?> getStepsForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('${_dailyStepsKey}_${_getDateKey(date)}');
    if (data != null) {
      final jsonData = json.decode(data);
      return DailySteps.fromJson(jsonData);
    }
    return null;
  }

  // Sauvegarder les pas du jour
  Future<void> saveDailySteps(DailySteps dailySteps) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = json.encode(dailySteps.toJson());
    await prefs.setString('${_dailyStepsKey}_${_getDateKey(dailySteps.date)}', jsonData);
  }

  // Mettre à jour les pas du jour
  Future<void> updateDailySteps(DailySteps dailySteps) async {
    await saveDailySteps(dailySteps);
  }

  // Ajouter des pas aux pas existants du jour
  Future<void> addSteps(int additionalSteps) async {
    final today = DateTime.now();
    final existingSteps = await getStepsForDate(today);

    if (existingSteps != null) {
      final updatedSteps = existingSteps.copyWith(
        steps: existingSteps.steps + additionalSteps,
      );
      await saveDailySteps(updatedSteps);
    } else {
      final newSteps = DailySteps(
        date: today,
        steps: additionalSteps,
      );
      await saveDailySteps(newSteps);
    }
  }

  // Réinitialiser les pas du jour
  Future<void> resetTodaySteps() async {
    final today = DateTime.now();
    final newSteps = DailySteps(date: today, steps: 0);
    await saveDailySteps(newSteps);
  }

  // Récupérer l'historique des 7 derniers jours
  Future<List<DailySteps>> getStepsHistory() async {
    final List<DailySteps> history = [];
    final now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final steps = await getStepsForDate(date);
      if (steps != null) {
        history.add(steps);
      } else {
        // Ajouter une entrée vide pour les jours sans données
        history.add(DailySteps(date: date, steps: 0));
      }
    }

    return history;
  }

  // Calculer la moyenne des pas sur les 7 derniers jours
  Future<double> getAverageStepsLast7Days() async {
    final history = await getStepsHistory();
    if (history.isEmpty) return 0;

    final totalSteps = history.fold<int>(0, (sum, steps) => sum + steps.steps);
    return totalSteps / history.length;
  }

  // Récupérer le meilleur jour (plus de pas)
  Future<DailySteps?> getBestDay() async {
    final history = await getStepsHistory();
    if (history.isEmpty) return null;

    return history.reduce((a, b) => a.steps > b.steps ? a : b);
  }

  // Vérifier si l'objectif du jour est atteint
  Future<bool> isGoalReached(int goal) async {
    final todaySteps = await getTodaySteps();
    return todaySteps != null && todaySteps.steps >= goal;
  }

  // Nettoyer les anciennes données (plus de 30 jours)
  Future<void> cleanOldData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    for (final key in keys) {
      if (key.startsWith(_dailyStepsKey)) {
        // Extraire la date de la clé
        final datePart = key.replaceFirst('${_dailyStepsKey}_', '');
        try {
          final date = DateTime.parse(datePart);
          if (date.isBefore(thirtyDaysAgo)) {
            await prefs.remove(key);
          }
        } catch (e) {
          // Clé malformée, on l'ignore
          continue;
        }
      }
    }
  }

  // Simuler des pas pour les tests/démo
  Future<void> simulateSteps(int steps) async {
    await addSteps(steps);
  }
}