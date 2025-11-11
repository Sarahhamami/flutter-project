import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/water_intake.dart';

class HydrationRepository {
  static const String _waterIntakesKey = 'water_intakes';

  // Clé pour aujourd'hui
  String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // Clé pour une date spécifique
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Récupérer les prises d'eau du jour
  Future<List<WaterIntake>> getTodayWaterIntakes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('${_waterIntakesKey}_${_getTodayKey()}');
    if (data != null) {
      final List<dynamic> jsonList = json.decode(data);
      return jsonList.map((json) => WaterIntake.fromJson(json)).toList();
    }
    return [];
  }

  // Récupérer les prises d'eau pour une date spécifique
  Future<List<WaterIntake>> getWaterIntakesForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('${_waterIntakesKey}_${_getDateKey(date)}');
    if (data != null) {
      final List<dynamic> jsonList = json.decode(data);
      return jsonList.map((json) => WaterIntake.fromJson(json)).toList();
    }
    return [];
  }

  // Sauvegarder une prise d'eau
  Future<void> saveWaterIntake(WaterIntake intake) async {
    final intakes = await getWaterIntakesForDate(intake.date);
    intakes.add(intake);
    await _saveWaterIntakes(intake.date, intakes);
  }

  // Mettre à jour une prise d'eau
  Future<void> updateWaterIntake(WaterIntake intake) async {
    final intakes = await getWaterIntakesForDate(intake.date);
    final index = intakes.indexWhere((item) => item.id == intake.id);
    if (index != -1) {
      intakes[index] = intake;
      await _saveWaterIntakes(intake.date, intakes);
    }
  }

  // Supprimer une prise d'eau
  Future<void> deleteWaterIntake(String id, DateTime date) async {
    final intakes = await getWaterIntakesForDate(date);
    intakes.removeWhere((item) => item.id == id);
    await _saveWaterIntakes(date, intakes);
  }

  // Méthode privée pour sauvegarder la liste
  Future<void> _saveWaterIntakes(DateTime date, List<WaterIntake> intakes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = json.encode(intakes.map((intake) => intake.toJson()).toList());
    await prefs.setString('${_waterIntakesKey}_${_getDateKey(date)}', jsonData);
  }

  // Calculer le total d'eau pour une date
  Future<int> getTotalWaterForDate(DateTime date) async {
    final intakes = await getWaterIntakesForDate(date);
    int total = 0;
    for (final intake in intakes) {
      total += intake.quantity;
    }
    return total;
  }

  // Récupérer l'historique des 7 derniers jours
  Future<Map<DateTime, int>> getWaterHistory() async {
    final Map<DateTime, int> history = {};
    final now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final total = await getTotalWaterForDate(date);
      history[date] = total;
    }

    return history;
  }

  // Nettoyer les anciennes données (plus de 30 jours)
  Future<void> cleanOldData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    for (final key in keys) {
      if (key.startsWith(_waterIntakesKey)) {
        // Extraire la date de la clé
        final datePart = key.replaceFirst('${_waterIntakesKey}_', '');
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
}