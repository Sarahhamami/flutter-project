class PromptTemplates {
  // Template pour l'analyse nutritionnelle
  static String nutritionAnalysis({
    required String objectif,
    required String donnees7Jours,
    required String preferences,
    required String restrictions,
    required String niveauActivite,
  }) {
    return '''
En tant que coach nutritionnel expert, analyse ces données utilisateur et donne 3 recommandations personnalisées concrètes :

CONTEXTE UTILISATEUR :
- Objectif : $objectif
- Niveau d'activité : $niveauActivite
- Préférences alimentaires : $preferences
- Restrictions/Allergies : $restrictions

DONNÉES DES 7 DERNIERS JOURS :
$donnees7Jours

INSTRUCTIONS :
1. Identifie les patterns positifs et les points d'amélioration
2. Donne 3 recommandations spécifiques et actionnables
3. Adapte les conseils à l'objectif et aux préférences
4. Sois encourageant et positif
5. Utilise un langage simple et accessible

FORMAT DE RÉPONSE :
- Point positif identifié
- Recommandation 1 : [conseil concret]
- Recommandation 2 : [conseil concret]
- Recommandation 3 : [conseil concret]
''';
  }

  // Template pour la génération de plans alimentaires
  static String mealPlanGeneration({
    required String duree,
    required int caloriesCible,
    required String objectif,
    required String preferences,
    required String restrictions,
    required String niveauActivite,
  }) {
    return '''
Génère un plan alimentaire détaillé pour $duree jours adapté aux caractéristiques suivantes :

OBJECTIFS NUTRITIONNELS :
- Calories cibles : $caloriesCible kcal/jour
- Objectif : $objectif
- Niveau d'activité : $niveauActivite

PRÉFÉRENCES ET RESTRICTIONS :
- Préférences : $preferences
- Restrictions : $restrictions

INSTRUCTIONS :
1. Répartis les repas : Petit-déjeuner, Déjeuner, Dîner, 2 collations
2. Pour chaque repas : liste des aliments avec quantités précises
3. Inclus les valeurs nutritionnelles approximatives (calories, protéines, glucides, lipides)
4. Adapte les portions selon l'objectif calorique
5. Varie les aliments pour éviter la monotonie
6. Respecte les préférences et restrictions
7. Inclus une liste de courses organisée par catégories

FORMAT DE RÉPONSE :
**JOUR 1**
*Petit-déjeuner :*
- Aliment 1 : quantité (calories, P/G/L)
- Aliment 2 : quantité (calories, P/G/L)
Total : XXX kcal

*Déjeuner :*
[... même format]

*Liste de courses Jour 1 :*
- Légumes : item1, item2
- Protéines : item1, item2
- Féculents : item1, item2
- Laitiers : item1, item2
- Autres : item1, item2

[Répète pour chaque jour]
''';
  }

  // Template pour les réponses aux questions
  static String questionResponse({
    required String question,
    required String contexteUtilisateur,
    required String historiqueConversation,
  }) {
    return '''
Tu es un coach nutritionnel IA bienveillant et expert. Réponds à cette question de manière utile et personnalisée.

QUESTION UTILISATEUR :
"$question"

CONTEXTE UTILISATEUR :
$contexteUtilisateur

HISTORIQUE RÉCENT DE CONVERSATION :
$historiqueConversation

INSTRUCTIONS :
1. Réponds de manière encourageante et positive
2. Adapte ta réponse au profil de l'utilisateur
3. Sois précis et factuel sur les aspects nutritionnels
4. Si nécessaire, pose des questions pour clarifier
5. Limite ta réponse à 3-4 phrases maximum
6. Utilise un langage accessible

Si la question nécessite des conseils personnalisés, demande plus d'informations sur les préférences ou restrictions alimentaires.
''';
  }

  // Template pour les suggestions de questions
  static String questionSuggestions(String contexteUtilisateur) {
    return '''
En tant que coach nutritionnel IA, génère 3 suggestions de questions pertinentes basées sur le contexte utilisateur.

CONTEXTE UTILISATEUR :
$contexteUtilisateur

INSTRUCTIONS :
1. Les questions doivent être pratiques et utiles
2. Adapte aux objectifs et préférences de l'utilisateur
3. Varie les thèmes : repas, habitudes, suppléments, etc.
4. Formule des questions engageantes

FORMAT :
1. [Question 1]
2. [Question 2]
3. [Question 3]
''';
  }

  // Template pour l'analyse des habitudes
  static String habitAnalysis({
    required String donneesRecentes,
    required String objectif,
    required String tendances,
  }) {
    return '''
Analyse les habitudes alimentaires récentes et identifie les patterns.

DONNÉES RÉCENTES :
$donneesRecentes

OBJECTIF : $objectif

TENDANCES OBSERVÉES :
$tendances

IDENTIFIE :
1. Habitudes positives à maintenir
2. Points d'amélioration prioritaires
3. Suggestions d'ajustements spécifiques
4. Fréquence recommandée pour les repas
''';
  }
}