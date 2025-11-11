class CalculsNutritionnels {
  // Calcul du métabolisme de base selon Harris-Benedict
  static double calculerMetabolismeBase(double poids, double taille, int age, String sexe) {
    if (sexe == 'homme') {
      return 88.362 + (13.397 * poids) + (4.799 * taille) - (5.677 * age);
    } else {
      return 447.593 + (9.247 * poids) + (3.098 * taille) - (4.330 * age);
    }
  }

  // Calcul du facteur d'activité
  static double getFacteurActivite(String niveauActivite) {
    switch (niveauActivite) {
      case 'sedentaire':
        return 1.2;
      case 'leger':
        return 1.375;
      case 'modere':
        return 1.55;
      case 'actif':
        return 1.725;
      case 'tres_actif':
        return 1.9;
      default:
        return 1.2;
    }
  }

  // Calcul des besoins caloriques selon l'objectif
  static double calculerCaloriesObjectif(double bmr, double facteurActivite, String objectif) {
    double maintenanceCalories = bmr * facteurActivite;

    switch (objectif) {
      case 'perte':
        return maintenanceCalories * 0.8; // Déficit de 20%
      case 'prise_masse':
        return maintenanceCalories * 1.15; // Surplus de 15%
      case 'maintien':
      default:
        return maintenanceCalories;
    }
  }

  // Calcul de la répartition des macronutriments
  static Map<String, double> calculerMacronutriments(double caloriesTotales) {
    // Répartition : 30% protéines, 40% glucides, 30% lipides
    double caloriesProteines = caloriesTotales * 0.3;
    double caloriesGlucides = caloriesTotales * 0.4;
    double caloriesLipides = caloriesTotales * 0.3;

    return {
      'proteines': caloriesProteines / 4, // 4 calories par gramme
      'glucides': caloriesGlucides / 4,   // 4 calories par gramme
      'lipides': caloriesLipides / 9,     // 9 calories par gramme
    };
  }

  // Calcul de l'IMC (Indice de Masse Corporelle)
  static double calculerIMC(double poids, double taille) {
    // taille en cm, conversion en mètres
    double tailleMetres = taille / 100;
    return poids / (tailleMetres * tailleMetres);
  }

  // Classification de l'IMC
  static String classifierIMC(double imc) {
    if (imc < 18.5) {
      return 'Insuffisance pondérale';
    } else if (imc < 25) {
      return 'Poids normal';
    } else if (imc < 30) {
      return 'Surpoids';
    } else if (imc < 35) {
      return 'Obésité modérée';
    } else if (imc < 40) {
      return 'Obésité sévère';
    } else {
      return 'Obésité morbide';
    }
  }

  // Calcul de la dépense calorique pour différentes activités (par heure)
  static double calculerDepenseActivite(double poids, String activite) {
    // Coefficients approximatifs en MET (Metabolic Equivalent of Task)
    double met;
    switch (activite.toLowerCase()) {
      case 'marche':
        met = 3.8;
        break;
      case 'course':
        met = 8.3;
        break;
      case 'velo':
        met = 6.8;
        break;
      case 'natation':
        met = 7.0;
        break;
      case 'muscu':
        met = 3.0;
        break;
      default:
        met = 1.0; // Repos
    }

    // Formule : MET × poids × 3.5 / 200 × 60 minutes
    return met * poids * 3.5 / 200;
  }

  // Calcul des besoins en eau personnalisés
  static int calculerBesoinEau(double poids, String niveauActivite) {
    // Base : 30ml par kg de poids corporel
    int baseEau = (poids * 30).round();

    // Ajustement selon l'activité
    double facteurActivite;
    switch (niveauActivite) {
      case 'sedentaire':
        facteurActivite = 1.0;
        break;
      case 'leger':
        facteurActivite = 1.1;
        break;
      case 'modere':
        facteurActivite = 1.2;
        break;
      case 'actif':
        facteurActivite = 1.3;
        break;
      case 'tres_actif':
        facteurActivite = 1.4;
        break;
      default:
        facteurActivite = 1.0;
    }

    return (baseEau * facteurActivite).round();
  }

  // Calcul de l'objectif de pas par jour
  static int calculerObjectifPas(String niveauActivite) {
    switch (niveauActivite) {
      case 'sedentaire':
        return 5000;
      case 'leger':
        return 7500;
      case 'modere':
        return 10000;
      case 'actif':
        return 12500;
      case 'tres_actif':
        return 15000;
      default:
        return 10000;
    }
  }

  // Validation des valeurs saisies
  static String? validerPoids(double poids) {
    if (poids <= 0) return 'Le poids doit être supérieur à 0';
    if (poids > 300) return 'Le poids semble trop élevé';
    return null;
  }

  static String? validerTaille(double taille) {
    if (taille <= 0) return 'La taille doit être supérieure à 0';
    if (taille < 50 || taille > 250) return 'La taille doit être entre 50 et 250 cm';
    return null;
  }

  static String? validerAge(int age) {
    if (age <= 0) return 'L\'âge doit être supérieur à 0';
    if (age > 120) return 'L\'âge semble trop élevé';
    return null;
  }
}