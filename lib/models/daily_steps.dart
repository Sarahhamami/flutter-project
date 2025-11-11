import 'package:flutter/material.dart';

class DailySteps {
  DateTime date;
  int steps;
  double distance; // en km (calculé automatiquement)
  int caloriesBurned; // estimé

  DailySteps({
    required this.date,
    required this.steps,
  })  : distance = (steps * 0.000762), // 1 pas ≈ 0.762m = 0.000762km
        caloriesBurned = (steps * 0.04).round(); // estimation: ~0.04 kcal par pas

  // Constructeur depuis JSON
  factory DailySteps.fromJson(Map<String, dynamic> json) {
    return DailySteps(
      date: DateTime.parse(json['date']),
      steps: json['steps'],
    );
  }

  // Conversion en JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'steps': steps,
      'distance': distance,
      'caloriesBurned': caloriesBurned,
    };
  }

  // Copie avec modifications
  DailySteps copyWith({
    DateTime? date,
    int? steps,
    double? distance,
    int? caloriesBurned,
  }) {
    return DailySteps._internal(
      date: date ?? this.date,
      steps: steps ?? this.steps,
      distance: distance ?? this.distance,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
    );
  }

  // Constructeur privé pour la copie
  DailySteps._internal({
    required this.date,
    required this.steps,
    required this.distance,
    required this.caloriesBurned,
  });

  // Vérifier si c'est aujourd'hui
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  // Calcul du pourcentage par rapport à l'objectif
  double getStepsPercentage(int objectif) {
    if (objectif <= 0) return 0;
    return (steps / objectif).clamp(0.0, 2.0); // Max 200%
  }

  // Formatage de la distance
  String get formattedDistance {
    if (distance < 1) {
      return '${(distance * 1000).round()} m';
    } else {
      return '${distance.toStringAsFixed(2)} km';
    }
  }

  // Formatage des calories
  String get formattedCalories => '${caloriesBurned} kcal';

  // Niveau d'activité basé sur les pas
  String get activityLevel {
    if (steps < 5000) return 'Sédentaire';
    if (steps < 7500) return 'Légèrement actif';
    if (steps < 10000) return 'Modérément actif';
    if (steps < 12500) return 'Très actif';
    return 'Extrêmement actif';
  }

  // Couleur basée sur le niveau d'activité
  Color get activityColor {
    if (steps < 5000) return Colors.red;
    if (steps < 7500) return Colors.orange;
    if (steps < 10000) return Colors.yellow;
    if (steps < 12500) return Colors.lightGreen;
    return Colors.green;
  }

  @override
  String toString() {
    return '$steps pas (${formattedDistance}) - $activityLevel';
  }
}

// Constantes pour les objectifs de pas
class StepsGoals {
  static const int sedentary = 5000;
  static const int lightlyActive = 7500;
  static const int moderatelyActive = 10000;
  static const int veryActive = 12500;
  static const int extremelyActive = 15000;

  static int getGoal(String activityLevel) {
    switch (activityLevel.toLowerCase()) {
      case 'sedentaire':
        return sedentary;
      case 'légèrement actif':
      case 'lightly active':
        return lightlyActive;
      case 'modérément actif':
      case 'moderately active':
        return moderatelyActive;
      case 'très actif':
      case 'very active':
        return veryActive;
      case 'extrêmement actif':
      case 'extremely active':
        return extremelyActive;
      default:
        return moderatelyActive;
    }
  }
}