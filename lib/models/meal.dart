import 'food_item.dart';

class Meal {
  String id;
  String type; // 'breakfast', 'lunch', 'dinner', 'snack'
  DateTime date;
  List<FoodItem> foods;

  Meal({
    required this.id,
    required this.type,
    required this.date,
    this.foods = const [],
  });

  // Constructeur depuis JSON
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      type: json['type'],
      date: DateTime.parse(json['date']),
      foods: (json['foods'] as List<dynamic>?)
          ?.map((foodJson) => FoodItem.fromJson(foodJson))
          .toList() ?? [],
    );
  }

  // Conversion en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'date': date.toIso8601String(),
      'foods': foods.map((food) => food.toJson()).toList(),
    };
  }

  // Calcul des totaux nutritionnels
  double get totalCalories => foods.fold(0, (sum, food) => sum + food.totalCalories);
  double get totalProteins => foods.fold(0, (sum, food) => sum + food.totalProteins);
  double get totalCarbs => foods.fold(0, (sum, food) => sum + food.totalCarbs);
  double get totalFats => foods.fold(0, (sum, food) => sum + food.totalFats);

  // Nom du type de repas en français
  String get typeName {
    switch (type) {
      case 'breakfast':
        return 'Petit-déjeuner';
      case 'lunch':
        return 'Déjeuner';
      case 'dinner':
        return 'Dîner';
      case 'snack':
        return 'Collation';
      default:
        return type;
    }
  }

  // Icône du type de repas
  String get typeIcon {
    switch (type) {
      case 'breakfast':
        return '🌅';
      case 'lunch':
        return '☀️';
      case 'dinner':
        return '🌙';
      case 'snack':
        return '🍪';
      default:
        return '🍽️';
    }
  }

  // Vérifier si le repas est vide
  bool get isEmpty => foods.isEmpty;

  // Ajouter un aliment
  void addFood(FoodItem food) {
    foods.add(food);
  }

  // Supprimer un aliment
  void removeFood(String foodId) {
    foods.removeWhere((food) => food.id == foodId);
  }

  // Mettre à jour un aliment
  void updateFood(String foodId, FoodItem updatedFood) {
    final index = foods.indexWhere((food) => food.id == foodId);
    if (index != -1) {
      foods[index] = updatedFood;
    }
  }

  // Copie avec modifications
  Meal copyWith({
    String? id,
    String? type,
    DateTime? date,
    List<FoodItem>? foods,
  }) {
    return Meal(
      id: id ?? this.id,
      type: type ?? this.type,
      date: date ?? this.date,
      foods: foods ?? this.foods,
    );
  }

  @override
  String toString() {
    return '$typeName: ${foods.length} aliments, ${totalCalories.round()} kcal';
  }
}

// Types de repas disponibles
class MealType {
  static const String breakfast = 'breakfast';
  static const String lunch = 'lunch';
  static const String dinner = 'dinner';
  static const String snack = 'snack';

  static const List<String> all = [breakfast, lunch, dinner, snack];

  static String getName(String type) {
    switch (type) {
      case breakfast:
        return 'Petit-déjeuner';
      case lunch:
        return 'Déjeuner';
      case dinner:
        return 'Dîner';
      case snack:
        return 'Collation';
      default:
        return type;
    }
  }

  static String getIcon(String type) {
    switch (type) {
      case breakfast:
        return '🌅';
      case lunch:
        return '☀️';
      case dinner:
        return '🌙';
      case snack:
        return '🍪';
      default:
        return '🍽️';
    }
  }
}