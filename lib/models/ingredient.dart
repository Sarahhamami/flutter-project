class Ingredient {
  final String name;
  final String measure;

  Ingredient({
    required this.name,
    required this.measure,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] ?? '',
      measure: json['measure'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'measure': measure,
    };
  }

  // Estimate calories based on common ingredient data
  // This is a simplified estimation - in a real app, you'd use a nutrition database
  double estimateCalories() {
    // Basic calorie estimation per 100g for common ingredients
    final calorieMap = {
      'chicken': 165,
      'beef': 250,
      'pork': 242,
      'fish': 120,
      'rice': 130,
      'pasta': 157,
      'bread': 265,
      'potato': 77,
      'carrot': 41,
      'onion': 40,
      'tomato': 18,
      'lettuce': 15,
      'cheese': 402,
      'milk': 61,
      'egg': 155,
      'butter': 717,
      'oil': 884,
      'flour': 364,
      'sugar': 387,
      'salt': 0,
      'pepper': 0,
      'garlic': 149,
      'ginger': 80,
      'lemon': 29,
      'lime': 30,
      'orange': 47,
      'apple': 52,
      'banana': 89,
      'strawberry': 32,
      'blueberry': 57,
      'spinach': 23,
      'broccoli': 34,
      'mushroom': 22,
      'peas': 81,
      'beans': 347,
      'lentils': 116,
      'chickpeas': 164,
      'nuts': 607,
      'almonds': 579,
      'walnuts': 654,
      'peanuts': 567,
      'honey': 304,
      'yogurt': 61,
      'cream': 340,
      'sour cream': 193,
      'mayonnaise': 680,
      'ketchup': 24,
      'mustard': 66,
      'soy sauce': 53,
      'vinegar': 18,
      'wine': 83,
      'beer': 43,
      'water': 0,
    };

    final lowerName = name.toLowerCase();
    double caloriesPer100g = 0;

    // Find matching ingredient
    for (final entry in calorieMap.entries) {
      if (lowerName.contains(entry.key)) {
        caloriesPer100g = entry.value.toDouble();
        break;
      }
    }

    // Parse measure to get quantity
    final quantity = _parseMeasureToGrams(measure);
    return (caloriesPer100g * quantity) / 100;
  }

  double _parseMeasureToGrams(String measure) {
    if (measure.isEmpty) return 0;

    final lowerMeasure = measure.toLowerCase().trim();

    // Handle common measures
    if (lowerMeasure.contains('cup') || lowerMeasure.contains('tasse')) {
      final match = RegExp(r'(\d*\.?\d+)').firstMatch(lowerMeasure);
      if (match != null) {
        final qty = double.tryParse(match.group(1) ?? '1') ?? 1;
        return qty * 240; // Approximate 1 cup = 240g for most ingredients
      }
    }

    if (lowerMeasure.contains('tbsp') || lowerMeasure.contains('tablespoon')) {
      final match = RegExp(r'(\d*\.?\d+)').firstMatch(lowerMeasure);
      if (match != null) {
        final qty = double.tryParse(match.group(1) ?? '1') ?? 1;
        return qty * 15; // 1 tbsp ≈ 15g
      }
    }

    if (lowerMeasure.contains('tsp') || lowerMeasure.contains('teaspoon')) {
      final match = RegExp(r'(\d*\.?\d+)').firstMatch(lowerMeasure);
      if (match != null) {
        final qty = double.tryParse(match.group(1) ?? '1') ?? 1;
        return qty * 5; // 1 tsp ≈ 5g
      }
    }

    if (lowerMeasure.contains('oz') || lowerMeasure.contains('ounce')) {
      final match = RegExp(r'(\d*\.?\d+)').firstMatch(lowerMeasure);
      if (match != null) {
        final qty = double.tryParse(match.group(1) ?? '1') ?? 1;
        return qty * 28.35; // 1 oz = 28.35g
      }
    }

    if (lowerMeasure.contains('lb') || lowerMeasure.contains('pound')) {
      final match = RegExp(r'(\d*\.?\d+)').firstMatch(lowerMeasure);
      if (match != null) {
        final qty = double.tryParse(match.group(1) ?? '1') ?? 1;
        return qty * 453.59; // 1 lb = 453.59g
      }
    }

    // Try to parse as direct grams or just a number
    final match = RegExp(r'(\d*\.?\d+)').firstMatch(lowerMeasure);
    if (match != null) {
      return double.tryParse(match.group(1) ?? '0') ?? 0;
    }

    // Default fallback
    return 100; // Assume 100g if can't parse
  }

  @override
  String toString() {
    return '$measure $name';
  }
}