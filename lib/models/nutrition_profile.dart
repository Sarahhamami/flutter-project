class NutritionProfile {
  // Données personnelles
  double poids; // en kg
  double taille; // en cm
  int age;
  String sexe; // 'homme', 'femme'
  String objectif; // 'perte', 'maintien', 'prise_masse'
  String niveauActivite; // 'sedentaire', 'leger', 'modere', 'actif', 'tres_actif'

  // Objectifs calculés automatiquement
  double calorieObjectif;
  double proteineObjectif;
  double glucideObjectif;
  double lipideObjectif;
  int eauObjectif; // en ml
  int pasObjectif;

  NutritionProfile({
    required this.poids,
    required this.taille,
    required this.age,
    required this.sexe,
    required this.objectif,
    required this.niveauActivite,
    this.calorieObjectif = 0,
    this.proteineObjectif = 0,
    this.glucideObjectif = 0,
    this.lipideObjectif = 0,
    this.eauObjectif = 2000,
    this.pasObjectif = 10000,
  });

  // Constructeur depuis JSON (pour Shared Preferences)
  factory NutritionProfile.fromJson(Map<String, dynamic> json) {
    return NutritionProfile(
      poids: json['poids']?.toDouble() ?? 0.0,
      taille: json['taille']?.toDouble() ?? 0.0,
      age: json['age'] ?? 0,
      sexe: json['sexe'] ?? 'homme',
      objectif: json['objectif'] ?? 'maintien',
      niveauActivite: json['niveauActivite'] ?? 'sedentaire',
      calorieObjectif: json['calorieObjectif']?.toDouble() ?? 0.0,
      proteineObjectif: json['proteineObjectif']?.toDouble() ?? 0.0,
      glucideObjectif: json['glucideObjectif']?.toDouble() ?? 0.0,
      lipideObjectif: json['lipideObjectif']?.toDouble() ?? 0.0,
      eauObjectif: json['eauObjectif'] ?? 2000,
      pasObjectif: json['pasObjectif'] ?? 10000,
    );
  }

  // Conversion en JSON (pour Shared Preferences)
  Map<String, dynamic> toJson() {
    return {
      'poids': poids,
      'taille': taille,
      'age': age,
      'sexe': sexe,
      'objectif': objectif,
      'niveauActivite': niveauActivite,
      'calorieObjectif': calorieObjectif,
      'proteineObjectif': proteineObjectif,
      'glucideObjectif': glucideObjectif,
      'lipideObjectif': lipideObjectif,
      'eauObjectif': eauObjectif,
      'pasObjectif': pasObjectif,
    };
  }

  // Méthode pour mettre à jour les objectifs calculés
  void updateCalculatedGoals() {
    // Calcul du métabolisme de base selon Harris-Benedict
    double bmr;
    if (sexe == 'homme') {
      bmr = 88.362 + (13.397 * poids) + (4.799 * taille) - (5.677 * age);
    } else {
      bmr = 447.593 + (9.247 * poids) + (3.098 * taille) - (4.330 * age);
    }

    // Facteur d'activité
    double activityFactor;
    switch (niveauActivite) {
      case 'sedentaire':
        activityFactor = 1.2;
        break;
      case 'leger':
        activityFactor = 1.375;
        break;
      case 'modere':
        activityFactor = 1.55;
        break;
      case 'actif':
        activityFactor = 1.725;
        break;
      case 'tres_actif':
        activityFactor = 1.9;
        break;
      default:
        activityFactor = 1.2;
    }

    // Calcul des calories selon l'objectif
    double maintenanceCalories = bmr * activityFactor;
    switch (objectif) {
      case 'perte':
        calorieObjectif = maintenanceCalories * 0.8; // Déficit de 20%
        break;
      case 'prise_masse':
        calorieObjectif = maintenanceCalories * 1.15; // Surplus de 15%
        break;
      case 'maintien':
      default:
        calorieObjectif = maintenanceCalories;
        break;
    }

    // Répartition des macronutriments (30% protéines, 40% glucides, 30% lipides)
    double caloriesFromProteins = calorieObjectif * 0.3;
    double caloriesFromCarbs = calorieObjectif * 0.4;
    double caloriesFromFats = calorieObjectif * 0.3;

    proteineObjectif = caloriesFromProteins / 4; // 4 calories par gramme de protéines
    glucideObjectif = caloriesFromCarbs / 4; // 4 calories par gramme de glucides
    lipideObjectif = caloriesFromFats / 9; // 9 calories par gramme de lipides

    // Objectifs par défaut pour l'eau et les pas
    eauObjectif = 2000; // ml par jour
    pasObjectif = 10000; // pas par jour
  }

  // Validation des données
  bool isValid() {
    return poids > 0 &&
           taille > 0 &&
           age > 0 &&
           age < 120 &&
           ['homme', 'femme'].contains(sexe) &&
           ['perte', 'maintien', 'prise_masse'].contains(objectif) &&
           ['sedentaire', 'leger', 'modere', 'actif', 'tres_actif'].contains(niveauActivite);
  }

  @override
  String toString() {
    return 'NutritionProfile(poids: $poids kg, taille: $taille cm, age: $age, sexe: $sexe, objectif: $objectif, activité: $niveauActivite)';
  }
}