      class FoodItem {
        String id;
        String name;
        String category; // e.g., 'breakfast', 'lunch', 'dinner', 'snacks'
        double calories; // par 100g
        double proteins; // grammes par 100g
        double carbs; // grammes par 100g
        double fats; // grammes par 100g
        double fiber; // grammes par 100g
        double sugars; // grammes par 100g
        double sodium; // mg par 100g
        double cholesterol; // mg par 100g
        double quantity; // grammes consommés
        String unit; // unité de mesure (g, ml, pieces, etc.)
      
        FoodItem({
          required this.id,
          required this.name,
          required this.category,
          required this.calories,
          required this.proteins,
          required this.carbs,
          required this.fats,
          this.fiber = 0,
          this.sugars = 0,
          this.sodium = 0,
          this.cholesterol = 0,
          required this.quantity,
          this.unit = 'g',
        });

  // Constructeur depuis JSON
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      calories: (json['calories'] ?? 0).toDouble(),
      proteins: (json['proteins'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fats: (json['fats'] ?? 0).toDouble(),
      fiber: (json['fiber'] ?? 0).toDouble(),
      sugars: (json['sugars'] ?? 0).toDouble(),
      sodium: (json['sodium'] ?? 0).toDouble(),
      cholesterol: (json['cholesterol'] ?? 0).toDouble(),
      quantity: (json['quantity'] ?? 100).toDouble(),
      unit: json['unit'] ?? 'g',
    );
  }

  // Conversion en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'calories': calories,
      'proteins': proteins,
      'carbs': carbs,
      'fats': fats,
      'fiber': fiber,
      'sugars': sugars,
      'sodium': sodium,
      'cholesterol': cholesterol,
      'quantity': quantity,
      'unit': unit,
    };
  }

  // Calcul des valeurs nutritionnelles pour la quantité consommée
  double get totalCalories => (calories * quantity) / 100;
  double get totalProteins => (proteins * quantity) / 100;
  double get totalCarbs => (carbs * quantity) / 100;
  double get totalFats => (fats * quantity) / 100;

  // Copie avec modifications
  FoodItem copyWith({
    String? id,
    String? name,
    String? category,
    double? calories,
    double? proteins,
    double? carbs,
    double? fats,
    double? fiber,
    double? sugars,
    double? sodium,
    double? cholesterol,
    double? quantity,
    String? unit,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      calories: calories ?? this.calories,
      proteins: proteins ?? this.proteins,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      fiber: fiber ?? this.fiber,
      sugars: sugars ?? this.sugars,
      sodium: sodium ?? this.sodium,
      cholesterol: cholesterol ?? this.cholesterol,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }

  @override
  String toString() {
    return '$name (${quantity}g)';
  }
}

// Base de données d'aliments prédéfinis (pour démonstration)
class FoodDatabase {
  static final List<FoodItem> commonFoods = [
    FoodItem(
      id: 'rice_white',
      name: 'Riz blanc',
      category: 'snacks',
      calories: 130,
      proteins: 2.7,
      carbs: 28,
      fats: 0.3,
      quantity: 100,
    ),
    FoodItem(
      id: 'chicken_breast',
      name: 'Blanc de poulet',
      category: 'snacks',
      calories: 165,
      proteins: 31,
      carbs: 0,
      fats: 3.6,
      quantity: 100,
    ),
    FoodItem(
      id: 'banana',
      name: 'Banane',
      category: 'snacks',
      calories: 89,
      proteins: 1.1,
      carbs: 23,
      fats: 0.3,
      quantity: 100,
    ),
    FoodItem(
      id: 'eggs',
      name: 'Oeufs',
      category: 'snacks',
      calories: 155,
      proteins: 13,
      carbs: 1.1,
      fats: 11,
      quantity: 100,
    ),
    FoodItem(
      id: 'bread_white',
      name: 'Pain blanc',
      category: 'snacks',
      calories: 265,
      proteins: 9,
      carbs: 49,
      fats: 3.2,
      quantity: 100,
    ),
    FoodItem(
      id: 'milk',
      name: 'Lait entier',
      category: 'snacks',
      calories: 61,
      proteins: 3.3,
      carbs: 4.8,
      fats: 3.3,
      quantity: 100,
    ),
    FoodItem(
      id: 'apple',
      name: 'Pomme',
      category: 'snacks',
      calories: 52,
      proteins: 0.3,
      carbs: 14,
      fats: 0.2,
      quantity: 100,
    ),
    FoodItem(
      id: 'pasta',
      name: 'Pâtes cuites',
      category: 'snacks',
      calories: 157,
      proteins: 5.8,
      carbs: 31,
      fats: 0.9,
      quantity: 100,
    ),
    FoodItem(
      id: 'salmon',
      name: 'Saumon',
      category: 'snacks',
      calories: 208,
      proteins: 22,
      carbs: 0,
      fats: 13,
      quantity: 100,
    ),
    FoodItem(
      id: 'potato',
      name: 'Pomme de terre',
      category: 'snacks',
      calories: 77,
      proteins: 2,
      carbs: 17,
      fats: 0.1,
      quantity: 100,
    ),
  ];

  // Recherche d'aliments par nom
  static List<FoodItem> searchFoods(String query) {
    if (query.isEmpty) return commonFoods;

    return commonFoods
        .where((food) =>
            food.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Trouver un aliment par ID
  static FoodItem? findById(String id) {
    return commonFoods.firstWhere(
      (food) => food.id == id,
      orElse: () => commonFoods.first, // Retourne le premier si non trouvé
    );
  }
}
