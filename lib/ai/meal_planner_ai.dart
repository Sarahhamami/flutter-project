import '../models/nutrition_profile.dart';
import 'gemini_service.dart';
import 'prompt_templates.dart';

class MealPlannerAI {
  final GeminiService _geminiService;

  MealPlannerAI(this._geminiService);

  Future<String> generateMealPlan({
    required NutritionProfile profile,
    required int durationDays,
    String? customPreferences,
    String? restrictions,
  }) async {
    final preferences = customPreferences ?? _extractPreferences(profile);
    final restrictionsList = restrictions ?? _extractRestrictions(profile);

    final prompt = PromptTemplates.mealPlanGeneration(
      duree: durationDays.toString(),
      caloriesCible: profile.calorieObjectif.round(),
      objectif: _translateObjectif(profile.objectif),
      preferences: preferences,
      restrictions: restrictionsList,
      niveauActivite: _translateActivityLevel(profile.niveauActivite),
    );

    final response = await _geminiService.generateMealPlan(prompt);
    return response.isSuccess ? response.data! : 'Erreur lors de la génération des variations';
  }

  Future<String> generateWeeklyPlan(NutritionProfile profile) async {
    return await generateMealPlan(
      profile: profile,
      durationDays: 7,
    );
  }

  Future<String> generateCustomPlan({
    required NutritionProfile profile,
    required int durationDays,
    required String mealType,
    required String cuisineType,
    required String dietaryRestrictions,
  }) async {
    final customPrompt = '''
Génère un plan alimentaire spécialisé pour $durationDays jours avec ces spécifications :

TYPE DE REPAS FOCUS : $mealType
TYPE DE CUISINE : $cuisineType
RESTRICTIONS ALIMENTAIRES : $dietaryRestrictions

Profil utilisateur :
- Objectif : ${_translateObjectif(profile.objectif)}
- Calories cibles : ${profile.calorieObjectif.round()} kcal/jour
- Niveau d'activité : ${_translateActivityLevel(profile.niveauActivite)}

Concentre-toi particulièrement sur les repas de type "$mealType" avec une cuisine $cuisineType.
Adapte les autres repas en conséquence pour maintenir l'équilibre nutritionnel global.
''';

    final response = await _geminiService.generateMealPlan(customPrompt);
    return response.isSuccess ? response.data! : 'Erreur lors de la génération du plan personnalisé';
  }

  Future<String> adjustMealPlan({
    required String existingPlan,
    required String adjustmentRequest,
    required NutritionProfile profile,
  }) async {
    final prompt = '''
Ajuste ce plan alimentaire selon la demande suivante :

PLAN ACTUEL :
$existingPlan

DEMANDE D'AJUSTEMENT :
$adjustmentRequest

CONTEXTE UTILISATEUR :
- Objectif : ${_translateObjectif(profile.objectif)}
- Calories cibles : ${profile.calorieObjectif.round()} kcal/jour

Fournis le plan ajusté en gardant la même structure et en maintenant l'équilibre nutritionnel.
''';

    final response = await _geminiService.generateMealPlan(prompt);
    return response.isSuccess ? response.data! : 'Erreur lors de la génération du plan alimentaire';
  }

  Future<String> generateShoppingList({
    required String mealPlan,
    required int durationDays,
  }) async {
    final prompt = '''
Extrait et organise la liste de courses complète de ce plan alimentaire de $durationDays jours :

PLAN ALIMENTAIRE :
$mealPlan

INSTRUCTIONS :
1. Regroupe les ingrédients par catégories (légumes, fruits, protéines, produits laitiers, épicerie, etc.)
2. Additionne les quantités pour les ingrédients répétés
3. Utilise des unités de mesure cohérentes
4. Ajoute des suggestions d'alternatives si nécessaire
5. Organise par ordre logique d'achat (produits frais d'abord)

FORMAT :
**LÉGUMES**
- Item : quantité

**FRUITS**
- Item : quantité

**PROTÉINES**
- Item : quantité

**PRODUITS LAITIERS**
- Item : quantité

**ÉPICERIE**
- Item : quantité

**AUTRES**
- Item : quantité
''';

    final response = await _geminiService.generateMealPlan(prompt);
    return response.isSuccess ? response.data! : 'Erreur lors de l\'ajustement du plan';
  }

  Future<String> generateRecipeVariations({
    required String baseRecipe,
    required String variationType,
    required NutritionProfile profile,
  }) async {
    final prompt = '''
Génère des variations de cette recette en respectant le profil nutritionnel :

RECETTE DE BASE :
$baseRecipe

TYPE DE VARIATION DEMANDÉE : $variationType

CONTRAINTES NUTRITIONNELLES :
- Objectif : ${_translateObjectif(profile.objectif)}
- Calories cibles : ${profile.calorieObjectif.round()} kcal/jour
- Protéines cibles : ${profile.proteineObjectif.round()}g/jour

Fournis 3 variations différentes avec :
1. Liste des ingrédients modifiés
2. Instructions de préparation adaptées
3. Valeurs nutritionnelles approximatives
4. Temps de préparation
''';

    final response = await _geminiService.generateMealPlan(prompt);
    return response.isSuccess ? response.data! : 'Erreur lors de la génération de la liste de courses';
  }

  String _extractPreferences(NutritionProfile profile) {
    // À étendre avec un système de préférences utilisateur
    return 'Équilibre entre saveurs, variété alimentaire, repas faciles à préparer, cuisine internationale légère';
  }

  String _extractRestrictions(NutritionProfile profile) {
    // À étendre avec un système d'allergies/restrictions
    return 'Aucune restriction spécifique mentionnée - adaptable selon les besoins';
  }

  String _translateObjectif(String objectif) {
    switch (objectif) {
      case 'perte':
        return 'Perte de poids (déficit calorique modéré)';
      case 'maintien':
        return 'Maintien du poids (équilibre calorique)';
      case 'prise_masse':
        return 'Prise de masse musculaire (surplus calorique contrôlé)';
      default:
        return objectif;
    }
  }

  String _translateActivityLevel(String niveau) {
    switch (niveau) {
      case 'sedentaire':
        return 'Sédentaire - repas plus légers';
      case 'leger':
        return 'Légèrement actif - équilibre standard';
      case 'modere':
        return 'Modérément actif - repas équilibrés';
      case 'actif':
        return 'Très actif - repas plus consistants';
      case 'tres_actif':
        return 'Extrêmement actif - repas riches en énergie';
      default:
        return niveau;
    }
  }
}