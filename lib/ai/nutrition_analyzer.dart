import '../models/nutrition_profile.dart';
import '../models/daily_progress.dart';
import '../models/meal.dart';
import 'gemini_service.dart';
import 'prompt_templates.dart';

class NutritionAnalyzer {
  final GeminiService _geminiService;

  NutritionAnalyzer(this._geminiService);

  Future<String> analyzeUserHabits({
    required NutritionProfile profile,
    required List<DailyProgress> recentProgress,
    required List<Meal> recentMeals,
  }) async {
    // Préparer les données des 7 derniers jours
    final last7Days = _prepareLast7DaysData(recentProgress, recentMeals);

    // Préparer les préférences et restrictions (à adapter selon le modèle)
    final preferences = _extractPreferences(profile);
    final restrictions = _extractRestrictions(profile);

    final prompt = PromptTemplates.nutritionAnalysis(
      objectif: _translateObjectif(profile.objectif),
      donnees7Jours: last7Days,
      preferences: preferences,
      restrictions: restrictions,
      niveauActivite: _translateActivityLevel(profile.niveauActivite),
    );

    final response = await _geminiService.analyzeNutritionData(prompt);
    return response.isSuccess ? response.data! : 'Erreur lors de l\'analyse nutritionnelle';
  }

  Future<String> analyzeMealPatterns({
    required List<Meal> meals,
    required NutritionProfile profile,
  }) async {
    final mealData = _prepareMealData(meals);
    final trends = _identifyTrends(meals);

    final prompt = PromptTemplates.habitAnalysis(
      donneesRecentes: mealData,
      objectif: _translateObjectif(profile.objectif),
      tendances: trends,
    );

    final response = await _geminiService.analyzeNutritionData(prompt);
    return response.isSuccess ? response.data! : 'Erreur lors de l\'analyse des habitudes';
  }

  Future<String> generateRecommendations({
    required NutritionProfile profile,
    required DailyProgress todayProgress,
  }) async {
    final context = '''
Profil: ${profile.poids}kg, ${profile.taille}cm, ${profile.age} ans, ${_translateObjectif(profile.objectif)}
Progression aujourd'hui: ${todayProgress.caloriesConsumed.round()}/${profile.calorieObjectif.round()} kcal
Macros: P:${todayProgress.proteinsConsumed.round()}/${profile.proteineObjectif.round()}g, G:${todayProgress.carbsConsumed.round()}/${profile.glucideObjectif.round()}g, L:${todayProgress.fatsConsumed.round()}/${profile.lipideObjectif.round()}g
''';

    final prompt = PromptTemplates.questionResponse(
      question: "Quelles sont les meilleures recommandations pour atteindre mes objectifs aujourd'hui ?",
      contexteUtilisateur: context,
      historiqueConversation: "",
    );

    final response = await _geminiService.generateResponse(prompt);
    return response.isSuccess ? response.data! : 'Erreur lors de la génération des recommandations';
  }

  String _prepareLast7DaysData(List<DailyProgress> progress, List<Meal> meals) {
    final buffer = StringBuffer();
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayProgress = progress.where((p) =>
        p.date.year == date.year &&
        p.date.month == date.month &&
        p.date.day == date.day
      ).toList();

      final dayMeals = meals.where((m) =>
        m.date.year == date.year &&
        m.date.month == date.month &&
        m.date.day == date.day
      ).toList();

      buffer.writeln('**${_formatDate(date)}**');
      if (dayProgress.isNotEmpty) {
        final p = dayProgress.first;
        buffer.writeln('Calories: ${p.caloriesConsumed.round()} | Protéines: ${p.proteinsConsumed.round()}g | Glucides: ${p.carbsConsumed.round()}g | Lipides: ${p.fatsConsumed.round()}g');
      } else {
        buffer.writeln('Aucune donnée');
      }

      if (dayMeals.isNotEmpty) {
        buffer.writeln('Repas: ${dayMeals.length} (${dayMeals.map((m) => m.typeName).join(", ")})');
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  String _prepareMealData(List<Meal> meals) {
    final buffer = StringBuffer();

    for (final meal in meals.take(10)) { // Limiter aux 10 derniers repas
      buffer.writeln('${meal.typeName} (${_formatDate(meal.date)}):');
      buffer.writeln('- ${meal.foods.length} aliments');
      buffer.writeln('- Total: ${meal.totalCalories.round()} kcal, P:${meal.totalProteins.round()}g, G:${meal.totalCarbs.round()}g, L:${meal.totalFats.round()}g');
      buffer.writeln();
    }

    return buffer.toString();
  }

  String _identifyTrends(List<Meal> meals) {
    if (meals.isEmpty) return 'Aucune donnée disponible';

    final buffer = StringBuffer();

    // Analyser la fréquence des repas
    final mealTypes = meals.map((m) => m.type).toList();
    final breakfastCount = mealTypes.where((t) => t == 'breakfast').length;
    final lunchCount = mealTypes.where((t) => t == 'lunch').length;
    final dinnerCount = mealTypes.where((t) => t == 'dinner').length;
    final snackCount = mealTypes.where((t) => t == 'snack').length;

    buffer.writeln('Fréquence des repas:');
    buffer.writeln('- Petit-déjeuners: $breakfastCount');
    buffer.writeln('- Déjeuners: $lunchCount');
    buffer.writeln('- Dîners: $dinnerCount');
    buffer.writeln('- Collations: $snackCount');

    // Analyser les heures des repas (si disponible)
    // TODO: Ajouter analyse temporelle si les heures sont disponibles

    return buffer.toString();
  }

  String _extractPreferences(NutritionProfile profile) {
    // Pour l'instant, retourner des préférences génériques
    // À étendre avec un système de préférences utilisateur
    return 'Équilibre entre saveurs, variété alimentaire, repas faciles à préparer';
  }

  String _extractRestrictions(NutritionProfile profile) {
    // Pour l'instant, retourner des restrictions génériques
    // À étendre avec un système d'allergies/restrictions
    return 'Aucune restriction spécifique mentionnée';
  }

  String _translateObjectif(String objectif) {
    switch (objectif) {
      case 'perte':
        return 'Perte de poids';
      case 'maintien':
        return 'Maintien du poids';
      case 'prise_masse':
        return 'Prise de masse musculaire';
      default:
        return objectif;
    }
  }

  String _translateActivityLevel(String niveau) {
    switch (niveau) {
      case 'sedentaire':
        return 'Sédentaire (peu ou pas d\'activité physique)';
      case 'leger':
        return 'Légèrement actif (activité légère 1-3 jours/semaine)';
      case 'modere':
        return 'Modérément actif (activité modérée 3-5 jours/semaine)';
      case 'actif':
        return 'Très actif (activité intense 6-7 jours/semaine)';
      case 'tres_actif':
        return 'Extrêmement actif (activité physique intense quotidienne + travail physique)';
      default:
        return niveau;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Aujourd\'hui';
    } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
      return 'Hier';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}