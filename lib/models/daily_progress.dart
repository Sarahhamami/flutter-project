class DailyProgress {
  DateTime date;
  double caloriesConsumed;
  double proteinsConsumed;
  double carbsConsumed;
  double fatsConsumed;
  int waterConsumed; // en ml
  int stepsTaken;
  double? currentWeight;

  DailyProgress({
    required this.date,
    this.caloriesConsumed = 0,
    this.proteinsConsumed = 0,
    this.carbsConsumed = 0,
    this.fatsConsumed = 0,
    this.waterConsumed = 0,
    this.stepsTaken = 0,
    this.currentWeight,
  });

  // Constructeur depuis JSON
  factory DailyProgress.fromJson(Map<String, dynamic> json) {
    return DailyProgress(
      date: DateTime.parse(json['date']),
      caloriesConsumed: json['caloriesConsumed']?.toDouble() ?? 0,
      proteinsConsumed: json['proteinsConsumed']?.toDouble() ?? 0,
      carbsConsumed: json['carbsConsumed']?.toDouble() ?? 0,
      fatsConsumed: json['fatsConsumed']?.toDouble() ?? 0,
      waterConsumed: json['waterConsumed'] ?? 0,
      stepsTaken: json['stepsTaken'] ?? 0,
      currentWeight: json['currentWeight']?.toDouble(),
    );
  }

  // Conversion en JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'caloriesConsumed': caloriesConsumed,
      'proteinsConsumed': proteinsConsumed,
      'carbsConsumed': carbsConsumed,
      'fatsConsumed': fatsConsumed,
      'waterConsumed': waterConsumed,
      'stepsTaken': stepsTaken,
      'currentWeight': currentWeight,
    };
  }

  // Calcul du pourcentage de calories consommées par rapport à l'objectif
  double getCaloriesPercentage(double calorieObjectif) {
    if (calorieObjectif <= 0) return 0;
    return (caloriesConsumed / calorieObjectif).clamp(0.0, 2.0); // Max 200% pour éviter débordement graphique
  }

  // Calcul du pourcentage d'eau consommée par rapport à l'objectif
  double getWaterPercentage(int waterObjectif) {
    if (waterObjectif <= 0) return 0;
    return (waterConsumed / waterObjectif).clamp(0.0, 1.0);
  }

  // Calcul du pourcentage de pas effectués par rapport à l'objectif
  double getStepsPercentage(int stepsObjectif) {
    if (stepsObjectif <= 0) return 0;
    return (stepsTaken / stepsObjectif).clamp(0.0, 2.0); // Max 200%
  }

  // Vérifier si c'est aujourd'hui
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  // Copie avec modifications
  DailyProgress copyWith({
    DateTime? date,
    double? caloriesConsumed,
    double? proteinsConsumed,
    double? carbsConsumed,
    double? fatsConsumed,
    int? waterConsumed,
    int? stepsTaken,
    double? currentWeight,
  }) {
    return DailyProgress(
      date: date ?? this.date,
      caloriesConsumed: caloriesConsumed ?? this.caloriesConsumed,
      proteinsConsumed: proteinsConsumed ?? this.proteinsConsumed,
      carbsConsumed: carbsConsumed ?? this.carbsConsumed,
      fatsConsumed: fatsConsumed ?? this.fatsConsumed,
      waterConsumed: waterConsumed ?? this.waterConsumed,
      stepsTaken: stepsTaken ?? this.stepsTaken,
      currentWeight: currentWeight ?? this.currentWeight,
    );
  }
}