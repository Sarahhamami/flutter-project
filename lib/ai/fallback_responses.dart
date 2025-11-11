class FallbackResponses {
  static const Map<String, String> commonQuestions = {
    'bonjour': 'Bonjour ! Je suis votre coach nutritionnel IA. Comment puis-je vous aider aujourd\'hui ?',
    'salut': 'Salut ! Prêt à atteindre vos objectifs nutritionnels ? Que souhaitez-vous savoir ?',
    'hello': 'Hello ! Je suis là pour vous aider avec votre nutrition. Que puis-je faire pour vous ?',
    'aide': 'Je peux vous aider avec : les plans alimentaires, l\'analyse de vos habitudes, des conseils personnalisés, et répondre à vos questions nutritionnelles.',
    'help': 'I can help you with: meal plans, habit analysis, personalized advice, and answering your nutrition questions.',

    // Questions sur les protéines
    'comment augmenter mes proteines': 'Pour augmenter vos protéines : mangez plus de poulet, poisson, œufs, lentilles, tofu, yaourt grec, amandes. Visez 1.6-2.2g/kg de poids corporel.',
    'proteines': 'Les meilleures sources de protéines : poulet, dinde, saumon, thon, œufs, lentilles, pois chiches, tofu, yaourt grec, fromage blanc, amandes, noix.',
    'sources de proteines': 'Protéines animales : poulet, bœuf, poisson, œufs, produits laitiers. Protéines végétales : lentilles, pois chiches, quinoa, tofu, amandes.',

    // Questions sur la perte de poids
    'comment perdre du poids': 'Pour perdre du poids : déficit calorique de 300-500 kcal/jour, alimentation riche en protéines et fibres, activité physique régulière, sommeil de qualité.',
    'perdre du poids': 'Clés pour perdre du poids : 1) Déficit calorique modéré, 2) Protéines à chaque repas, 3) Légumes à volonté, 4) Activité physique, 5) Hydratation.',
    'maigrir': 'Pour maigrir durablement : mangez moins que vos besoins caloriques, privilégiez les aliments riches en nutriments, bougez régulièrement, dormez bien.',

    // Questions sur les repas
    'petit dejeuner': 'Un bon petit-déjeuner : avoine avec fruits et noix, œufs avec légumes, yaourt grec avec granola, smoothie protéiné, ou pain complet avec avocat.',
    'dejeuner': 'Déjeuner équilibré : protéines (viande/poisson/œufs/tofu) + légumes + féculents complets (quinoa/riz/pâtes) + matière grasse saine.',
    'diner': 'Dîner léger : protéines maigres, légumes cuits à la vapeur, petite portion de glucides complexes. Évitez les repas lourds le soir.',

    // Questions sur l'eau
    'combien d eau': 'Buvez au minimum 1.5-2 litres d\'eau par jour. Plus si vous faites du sport ou par temps chaud. Les signes de déshydratation : fatigue, maux de tête.',
    'eau': 'L\'eau est essentielle : 2 litres minimum par jour. Buvez entre les repas, pas pendant. Ajoutez du citron ou des infusions pour varier.',

    // Questions sur les glucides
    'glucides': 'Glucides complexes : avoine, quinoa, patate douce, riz complet, pâtes complètes. Limitez les sucres raffinés et buvez beaucoup d\'eau.',
    'sucres': 'Évitez les sucres raffinés : sodas, bonbons, pâtisseries. Privilégiez les sucres naturels des fruits et légumes.',

    // Questions sur les graisses
    'graisses': 'Bonnes graisses : avocat, huile d\'olive, noix, poissons gras (saumon, maquereau). Limitez les graisses saturées et trans.',
    'huiles': 'Huiles saines : olive, colza, noix. Utilisez-les crues pour conserver leurs bienfaits. Évitez de faire chauffer à haute température.',

    // Questions sur les fibres
    'fibres': 'Sources de fibres : légumes verts, fruits, légumineuses, céréales complètes, noix. Visez 25-30g de fibres par jour.',
    'legumes': 'Mangez 5 portions de légumes par jour : crus, cuits à la vapeur, en soupe. Variez les couleurs pour diversifier les nutriments.',

    // Questions sur les collations
    'collation': 'Collations saines : yaourt grec avec fruits, poignée d\'amandes, bâtonnets de légumes avec houmous, fruit frais, œuf dur.',
    'snacks': 'Snacks équilibrés : protéines + fibres. Exemples : pomme + amandes, carottes + houmous, yaourt + graines.',

    // Questions sur les compléments
    'supplements': 'Les compléments ne remplacent pas une alimentation équilibrée. Envisagez : protéines en poudre, créatine, omega-3, vitamine D si carence.',
    'proteine en poudre': 'La protéine en poudre peut aider à atteindre vos objectifs protéiques, surtout si vous êtes sportif. Choisissez-la sans sucres ajoutés.',

    // Questions sur l'activité physique
    'sport': 'Combinez cardio et musculation. 150 min de cardio modéré par semaine + 2-3 séances de musculation. Adaptez à votre niveau.',
    'muscle': 'Pour gagner du muscle : surplus calorique, protéines élevées (2.2g/kg), musculation progressive, récupération suffisante.',

    // Questions générales
    'equilibre alimentaire': 'Règle des 1/2-1/4-1/4 : 1/2 assiette légumes, 1/4 protéines, 1/4 glucides. Ajoutez une matière grasse saine.',
    'calories': 'Pour maintenir : calculez vos besoins selon votre âge, poids, taille, activité. Pour perdre : déficit de 300-500 kcal/jour.',
    'bio': 'Les aliments bio peuvent être intéressants pour éviter les pesticides, mais l\'essentiel est la variété et la fraîcheur des aliments.',
  };

  static String? getFallbackResponse(String userMessage) {
    final normalizedMessage = userMessage.toLowerCase().trim();

    // Recherche exacte
    if (commonQuestions.containsKey(normalizedMessage)) {
      return commonQuestions[normalizedMessage];
    }

    // Recherche partielle
    for (final entry in commonQuestions.entries) {
      if (normalizedMessage.contains(entry.key) || entry.key.contains(normalizedMessage)) {
        return entry.value;
      }
    }

    // Recherche par mots-clés
    final keywords = normalizedMessage.split(' ');
    for (final keyword in keywords) {
      if (keyword.length > 3) { // Ignore les mots courts
        for (final entry in commonQuestions.entries) {
          if (entry.key.contains(keyword)) {
            return entry.value;
          }
        }
      }
    }

    return null; // Aucune réponse de secours trouvée
  }

  static String getGenericResponse() {
    return 'Je suis en mode dégradé pour le moment. Voici quelques conseils généraux :\n\n'
           '• Mangez varié et équilibré\n'
           '• Buvez au moins 1.5L d\'eau par jour\n'
           '• Privilégiez les protéines maigres\n'
           '• Consommez 5 fruits et légumes par jour\n'
           '• Limitez les sucres raffinés\n\n'
           'Configurez votre clé API Gemini pour des réponses personnalisées !';
  }
}