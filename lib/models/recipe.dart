import 'ingredient.dart';

class Recipe {
  final String id;
  final String name;
  final String category;
  final String area;
  final String instructions;
  final String thumbnailUrl;
  final String? youtubeUrl;
  final List<Ingredient> ingredients;
  final List<String> tags;

  Recipe({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.thumbnailUrl,
    this.youtubeUrl,
    required this.ingredients,
    this.tags = const [],
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    // Parse ingredients from the API format
    final ingredients = <Ingredient>[];
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];

      if (ingredient != null && ingredient.toString().isNotEmpty &&
          measure != null && measure.toString().isNotEmpty) {
        ingredients.add(Ingredient(
          name: ingredient.toString(),
          measure: measure.toString(),
        ));
      }
    }

    // Parse tags
    final tagsString = json['strTags'];
    final tags = tagsString != null && tagsString.toString().isNotEmpty
        ? tagsString.toString().split(',').map((tag) => tag.trim()).toList()
        : <String>[];

    return Recipe(
      id: json['idMeal']?.toString() ?? '',
      name: json['strMeal']?.toString() ?? '',
      category: json['strCategory']?.toString() ?? '',
      area: json['strArea']?.toString() ?? '',
      instructions: json['strInstructions']?.toString() ?? '',
      thumbnailUrl: json['strMealThumb']?.toString() ?? '',
      youtubeUrl: json['strYoutube']?.toString(),
      ingredients: ingredients,
      tags: tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idMeal': id,
      'strMeal': name,
      'strCategory': category,
      'strArea': area,
      'strInstructions': instructions,
      'strMealThumb': thumbnailUrl,
      'strYoutube': youtubeUrl,
      'strTags': tags.join(','),
      // Ingredients are stored separately
    };
  }

  // Calculate estimated calories based on ingredients
  double get estimatedCalories {
    return ingredients.fold(0.0, (sum, ingredient) => sum + ingredient.estimateCalories());
  }

  // Calculate estimated macros (simplified)
  double get estimatedProteins {
    // Rough estimate: 20-30% of calories from proteins
    return (estimatedCalories * 0.25) / 4; // 4 calories per gram of protein
  }

  double get estimatedCarbs {
    // Rough estimate: 40-60% of calories from carbs
    return (estimatedCalories * 0.5) / 4; // 4 calories per gram of carb
  }

  double get estimatedFats {
    // Rough estimate: 20-30% of calories from fats
    return (estimatedCalories * 0.25) / 9; // 9 calories per gram of fat
  }

  // Check if recipe matches nutrition goal
  bool matchesGoal(String goal) {
    final calories = estimatedCalories;

    switch (goal) {
      case 'perte':
        return calories < 500; // Low calorie for weight loss
      case 'prise_masse':
        return estimatedProteins > 20; // High protein for muscle gain
      case 'maintien':
      default:
        return calories >= 300 && calories <= 700; // Balanced calories
    }
  }

  // Check if recipe is considered "healthy"
  bool get isHealthy {
    // Criteria for healthy recipe:
    // - Not too high in calories (< 600)
    // - Has vegetables or fruits
    // - Not too much sugar/fat
    final hasVegetables = ingredients.any((ing) =>
        ing.name.toLowerCase().contains('vegetable') ||
        ing.name.toLowerCase().contains('carrot') ||
        ing.name.toLowerCase().contains('onion') ||
        ing.name.toLowerCase().contains('tomato') ||
        ing.name.toLowerCase().contains('lettuce') ||
        ing.name.toLowerCase().contains('spinach') ||
        ing.name.toLowerCase().contains('broccoli') ||
        ing.name.toLowerCase().contains('peas') ||
        ing.name.toLowerCase().contains('beans'));

    final hasFruits = ingredients.any((ing) =>
        ing.name.toLowerCase().contains('fruit') ||
        ing.name.toLowerCase().contains('apple') ||
        ing.name.toLowerCase().contains('banana') ||
        ing.name.toLowerCase().contains('orange') ||
        ing.name.toLowerCase().contains('lemon') ||
        ing.name.toLowerCase().contains('lime'));

    final reasonableCalories = estimatedCalories < 600;
    final notTooFatty = !ingredients.any((ing) =>
        ing.name.toLowerCase().contains('butter') ||
        ing.name.toLowerCase().contains('cream') ||
        ing.name.toLowerCase().contains('mayonnaise'));

    return reasonableCalories && (hasVegetables || hasFruits) && notTooFatty;
  }

  // Generate shopping list from ingredients
  List<String> get shoppingList {
    return ingredients.map((ingredient) => '${ingredient.measure} ${ingredient.name}').toList();
  }

  @override
  String toString() {
    return 'Recipe(id: $id, name: $name, category: $category, calories: ${estimatedCalories.round()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recipe && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}