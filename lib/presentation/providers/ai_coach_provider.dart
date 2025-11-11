import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../ai/gemini_service.dart';
import '../../ai/nutrition_analyzer.dart';
import '../../ai/meal_planner_ai.dart';
import '../../ai/prompt_templates.dart';
import '../../ai/fallback_responses.dart';
import '../../core/models/ai_response.dart';
import '../../core/config/api_config.dart';
import '../../models/nutrition_profile.dart';
import '../../models/daily_progress.dart';
import '../../models/meal.dart';
import '../../services/nutrition_database_service.dart';

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? type; // 'question', 'recommendation', 'meal_plan', etc.

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      content: json['content'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
    );
  }
}

class AICoachProvider with ChangeNotifier {
  final GeminiService _geminiService;
  final NutritionAnalyzer _nutritionAnalyzer;
  final MealPlannerAI _mealPlannerAI;

  // Rate limiting
  static const int _maxRequestsPerMinute = 10;
  static const Duration _rateLimitWindow = Duration(minutes: 1);
  final List<DateTime> _requestTimestamps = [];
  bool _isRateLimited = false;

  // État
  bool _isLoading = false;
  String? _error;
  List<ChatMessage> _messages = [];
  String? _currentMealPlan;
  List<String> _suggestedQuestions = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ChatMessage> get messages => _messages;
  String? get currentMealPlan => _currentMealPlan;
  List<String> get suggestedQuestions => _suggestedQuestions;
  bool get isRateLimited => _isRateLimited;

  AICoachProvider()
      : _geminiService = GeminiService(),
        _nutritionAnalyzer = NutritionAnalyzer(GeminiService()),
        _mealPlannerAI = MealPlannerAI(GeminiService()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadConversationHistory();
    await _generateInitialSuggestions();
  }

  // Vérifier le rate limiting
  bool _checkRateLimit() {
    final now = DateTime.now();

    // Nettoyer les anciens timestamps
    _requestTimestamps.removeWhere((timestamp) =>
        now.difference(timestamp) > _rateLimitWindow);

    // Vérifier si on dépasse la limite
    if (_requestTimestamps.length >= _maxRequestsPerMinute) {
      _isRateLimited = true;
      notifyListeners();
      return false;
    }

    _requestTimestamps.add(now);
    _isRateLimited = false;
    return true;
  }

  // Envoyer un message à l'IA
  Future<void> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    // Vérifier le rate limiting
    if (!_checkRateLimit()) {
      _error = 'Trop de requêtes. Veuillez patienter avant de continuer.';
      notifyListeners();
      return;
    }

    _setLoading(true);
    _error = null;

    try {
      // Ajouter le message utilisateur
      final userChatMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
        type: 'question',
      );

      _messages.add(userChatMessage);
      notifyListeners();

      // Déterminer le type de requête et générer la réponse appropriée
      String response;
      String responseType;

      if (_isMealPlanRequest(userMessage)) {
        response = await _handleMealPlanRequest(userMessage);
        responseType = 'meal_plan';
      } else if (_isAnalysisRequest(userMessage)) {
        response = await _handleAnalysisRequest(userMessage);
        responseType = 'analysis';
      } else {
        response = await _handleGeneralQuestion(userMessage);
        responseType = 'response';
      }

      // Ajouter la réponse de l'IA
      final aiMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
        type: responseType,
      );

      _messages.add(aiMessage);

      // Sauvegarder la conversation
      await _saveConversationHistory();

      // Générer de nouvelles suggestions
      await _generateQuestionSuggestions();

    } catch (e) {
      String errorMessage = 'Désolé, je rencontre un problème technique. Veuillez réessayer.';

      if (e.toString().contains('rate limit') || e.toString().contains('quota')) {
        errorMessage = 'Limite d\'utilisation atteinte. Veuillez patienter quelques minutes.';
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        errorMessage = 'Problème de connexion. Vérifiez votre connexion internet.';
      }

      _error = 'Erreur lors de la communication avec l\'IA: $e';
      final errorChatMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: errorMessage,
        isUser: false,
        timestamp: DateTime.now(),
        type: 'error',
      );
      _messages.add(errorChatMessage);
    } finally {
      _setLoading(false);
    }
  }

  // Générer un plan alimentaire
  Future<void> generateMealPlan({int durationDays = 7}) async {
    _setLoading(true);
    _error = null;

    try {
      final profile = await NutritionDatabaseService.getNutritionProfile();
      if (profile == null) {
        _error = 'Veuillez d\'abord créer votre profil nutritionnel';
        return;
      }

      final hasApiKey = await _checkApiKeyAvailable();
      if (!hasApiKey) {
        _currentMealPlan = _getFallbackMealPlan(durationDays, profile);
      } else {
        final planResponse = await _mealPlannerAI.generateMealPlan(
          profile: profile,
          durationDays: durationDays,
        );
        _currentMealPlan = planResponse;
      }

      // Ajouter un message dans le chat
      final message = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Voici votre plan alimentaire personnalisé pour $durationDays jours :\n\n$_currentMealPlan',
        isUser: false,
        timestamp: DateTime.now(),
        type: 'meal_plan',
      );

      _messages.add(message);
      await _saveConversationHistory();

    } catch (e) {
      _error = 'Erreur lors de la génération du plan: $e';
    } finally {
      _setLoading(false);
    }
  }

  String _getFallbackMealPlan(int durationDays, dynamic profile) {
    return '''
**PLAN ALIMENTAIRE RECOMMANDÉ ($durationDays jours)**

*Objectifs quotidiens :*
- Calories : ${profile.calorieObjectif.round()} kcal
- Protéines : ${profile.proteineObjectif.round()}g
- Glucides : ${profile.glucideObjectif.round()}g
- Lipides : ${profile.lipideObjectif.round()}g

**CONSEILS GÉNÉRAUX :**
1. Mangez 3 repas principaux + 2 collations par jour
2. Priorisez les protéines maigres (poulet, poisson, œufs, légumineuses)
3. Incluez des légumes à chaque repas
4. Limitez les sucres raffinés et les graisses saturées
5. Buvez au moins 2 litres d'eau par jour

**EXEMPLE DE JOURNÉE TYPE :**

*Petit-déjeuner :*
- 2 œufs brouillés (environ 140 kcal, 12g protéines)
- 1 tranche de pain complet (70 kcal)
- 1 fruit frais (60 kcal)
- Total : ~270 kcal

*Déjeuner :*
- 150g de poulet grillé (250 kcal, 40g protéines)
- Salade de légumes variés (50 kcal)
- 100g de quinoa cuit (110 kcal)
- Total : ~410 kcal

*Dîner :*
- 150g de saumon (280 kcal, 35g protéines)
- Légumes vapeur (60 kcal)
- 100g de patate douce (90 kcal)
- Total : ~430 kcal

*Collations :*
- Yaourt grec 0% (100 kcal, 15g protéines)
- Poignée d'amandes (150 kcal)

**NOTE :** Configurez votre clé API Gemini pour obtenir un plan personnalisé détaillé adapté à vos goûts et restrictions alimentaires.
    ''';
  }

  // Analyser les habitudes alimentaires
  Future<void> analyzeHabits() async {
    _setLoading(true);
    _error = null;

    try {
      final profile = await NutritionDatabaseService.getNutritionProfile();
      final recentProgress = await NutritionDatabaseService.getRecentProgress(7);
      final recentMeals = await NutritionDatabaseService.getRecentMeals(30);

      if (profile == null) {
        _error = 'Veuillez d\'abord créer votre profil nutritionnel';
        return;
      }

      final hasApiKey = await _checkApiKeyAvailable();
      String analysis;

      if (!hasApiKey) {
        analysis = _getFallbackAnalysis(profile, recentProgress, recentMeals);
      } else {
        analysis = await _nutritionAnalyzer.analyzeUserHabits(
          profile: profile,
          recentProgress: recentProgress,
          recentMeals: recentMeals,
        );
      }

      final message = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: analysis,
        isUser: false,
        timestamp: DateTime.now(),
        type: 'analysis',
      );

      _messages.add(message);
      await _saveConversationHistory();

    } catch (e) {
      _error = 'Erreur lors de l\'analyse: $e';
    } finally {
      _setLoading(false);
    }
  }

  String _getFallbackAnalysis(dynamic profile, List recentProgress, List recentMeals) {
    final avgCalories = recentProgress.isNotEmpty
        ? (recentProgress.map((p) => p.caloriesConsumed).reduce((a, b) => a + b) / recentProgress.length).round()
        : 0;

    return '''
**ANALYSE DE VOS HABITUDES ALIMENTAIRES**

*D'après vos données récentes :*

📊 **Aperçu général :**
- Profil : ${profile.poids}kg, objectif ${profile.objectif}
- Moyenne calorique : $avgCalories kcal/jour (objectif : ${profile.calorieObjectif.round()} kcal)
- Nombre de repas trackés : ${recentMeals.length}

💪 **Points positifs :**
- Vous suivez régulièrement vos repas
- Votre profil nutritionnel est bien défini
- Vous êtes engagé dans votre suivi

🎯 **Recommandations générales :**
1. **Équilibre des repas** : Assurez-vous d'avoir des protéines à chaque repas
2. **Hydratation** : Buvez au moins 2 litres d'eau par jour
3. **Variété** : Variez les légumes et fruits pour couvrir tous les nutriments
4. **Régularité** : Mangez à heures fixes pour réguler votre métabolisme

📈 **Objectifs à atteindre :**
- Calories : ${profile.calorieObjectif.round()} kcal/jour
- Protéines : ${profile.proteineObjectif.round()}g/jour
- Glucides : ${profile.glucideObjectif.round()}g/jour
- Lipides : ${profile.lipideObjectif.round()}g/jour

**NOTE :** Configurez votre clé API Gemini pour une analyse personnalisée détaillée de vos habitudes alimentaires.
    ''';
  }

  // Effacer la conversation
  Future<void> clearConversation() async {
    _messages.clear();
    _currentMealPlan = null;
    _suggestedQuestions.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ai_conversation_history');

    await _generateInitialSuggestions();
    notifyListeners();
  }

  // Méthodes privées

  bool _isMealPlanRequest(String message) {
    final lowerMessage = message.toLowerCase();
    return lowerMessage.contains('plan') ||
           lowerMessage.contains('menu') ||
           lowerMessage.contains('repas') ||
           lowerMessage.contains('semaine') ||
           lowerMessage.contains('jour');
  }

  bool _isAnalysisRequest(String message) {
    final lowerMessage = message.toLowerCase();
    return lowerMessage.contains('analyse') ||
           lowerMessage.contains('habitude') ||
           lowerMessage.contains('comment') ||
           lowerMessage.contains('conseil');
  }

  Future<String> _handleMealPlanRequest(String userMessage) async {
    final profile = await NutritionDatabaseService.getNutritionProfile();
    if (profile == null) {
      return 'Je ne peux pas générer de plan alimentaire sans votre profil nutritionnel. Veuillez d\'abord configurer votre profil.';
    }

    // Extraire la durée si mentionnée
    int durationDays = 7;
    if (userMessage.contains('semaine') || userMessage.contains('7')) {
      durationDays = 7;
    } else if (userMessage.contains('jour') || userMessage.contains('1')) {
      durationDays = 1;
    }

    return await _mealPlannerAI.generateMealPlan(
      profile: profile,
      durationDays: durationDays,
    );
  }

  Future<String> _handleAnalysisRequest(String userMessage) async {
    final profile = await NutritionDatabaseService.getNutritionProfile();
    final recentProgress = await NutritionDatabaseService.getRecentProgress(7);
    final recentMeals = await NutritionDatabaseService.getRecentMeals(30);

    if (profile == null) {
      return 'Je ne peux pas analyser vos habitudes sans votre profil nutritionnel.';
    }

    return await _nutritionAnalyzer.analyzeUserHabits(
      profile: profile,
      recentProgress: recentProgress,
      recentMeals: recentMeals,
    );
  }

  Future<String> _handleGeneralQuestion(String userMessage) async {
    // Vérifier d'abord le cache pour les réponses fréquentes
    final cachedResponse = _getCachedResponse(userMessage);
    if (cachedResponse != null) {
      return cachedResponse;
    }

    // Essayer d'abord avec l'IA si clé API disponible
    try {
      final hasApiKey = await _checkApiKeyAvailable();
      if (!hasApiKey) {
        return _getFallbackResponse(userMessage);
      }

      final profile = await NutritionDatabaseService.getNutritionProfile();
      final recentHistory = _getRecentConversationHistory();

      final context = profile != null ? '''
Profil: ${profile.poids}kg, ${profile.taille}cm, objectif: ${profile.objectif}
''' : 'Profil non configuré';

      final prompt = PromptTemplates.questionResponse(
        question: userMessage,
        contexteUtilisateur: context,
        historiqueConversation: recentHistory,
      );

      final aiResponse = await _geminiService.generateResponse(prompt);

      if (aiResponse.isSuccess && aiResponse.hasData) {
        return aiResponse.data!;
      } else {
        // En cas d'erreur IA, utiliser les réponses de secours
        return _getFallbackResponse(userMessage);
      }
    } catch (e) {
      // En cas d'exception, utiliser les réponses de secours
      return _getFallbackResponse(userMessage);
    }
  }

  Future<bool> _checkApiKeyAvailable() async {
    try {
      final key = await ApiConfig.getGeminiApiKey();
      return key != null && key.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  String _getFallbackResponse(String userMessage) {
    final fallback = FallbackResponses.getFallbackResponse(userMessage);
    return fallback ?? FallbackResponses.getGenericResponse();
  }

  Future<void> _generateInitialSuggestions() async {
    _suggestedQuestions = [
      "Comment puis-je augmenter mes protéines ?",
      "Génère un plan alimentaire pour la semaine",
      "Analyse mes habitudes alimentaires",
      "Quels sont les meilleurs snacks pour maigrir ?",
      "Comment équilibrer mes repas ?",
    ];
  }

  Future<void> _generateQuestionSuggestions() async {
    try {
      final profile = await NutritionDatabaseService.getNutritionProfile();
      final context = profile != null ?
        'Objectif: ${profile.objectif}, Activité: ${profile.niveauActivite}' :
        'Profil non configuré';

      final prompt = PromptTemplates.questionSuggestions(context);
      final suggestionsText = await _geminiService.generateResponse(prompt);

      // Parser les suggestions (format simple)
      _suggestedQuestions = suggestionsText
          .data!.split('\n')
          .where((line) => line.trim().isNotEmpty && (line.startsWith('1.') || line.startsWith('2.') || line.startsWith('3.')))
          .map((line) => line.substring(3).trim())
          .toList();

      if (_suggestedQuestions.isEmpty) {
        await _generateInitialSuggestions();
      }
    } catch (e) {
      await _generateInitialSuggestions();
    }
  }

  String _getRecentConversationHistory() {
    final recentMessages = _messages.take(10);
    return recentMessages.map((msg) =>
      '${msg.isUser ? "Utilisateur" : "IA"}: ${msg.content}'
    ).join('\n');
  }

  Future<void> _loadConversationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('ai_conversation_history');

      if (historyJson != null) {
        _messages = historyJson
            .map((jsonStr) => ChatMessage.fromJson(Map<String, dynamic>.from(
                jsonStr as Map)))
            .toList();
        // Trier par timestamp pour s'assurer du bon ordre
        _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      }
    } catch (e) {
      // En cas d'erreur, on garde une liste vide
      _messages = [];
    }
  }

  Future<void> _saveConversationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Limiter à 50 messages pour éviter de surcharger le stockage
      final recentMessages = _messages.length > 50
          ? _messages.sublist(_messages.length - 50)
          : _messages;

      final historyJson = recentMessages
          .map((msg) => msg.toJson())
          .toList();
      await prefs.setStringList('ai_conversation_history', historyJson.cast<String>());
    } catch (e) {
      // Ne pas planter si la sauvegarde échoue
    }
  }

  // Cache des réponses fréquentes pour améliorer les performances
  static const Map<String, String> _responseCache = {
    'bonjour': 'Bonjour ! Je suis votre coach nutritionnel IA. Comment puis-je vous aider aujourd\'hui ?',
    'salut': 'Salut ! Prêt à atteindre vos objectifs nutritionnels ? Que souhaitez-vous savoir ?',
    'aide': 'Je peux vous aider avec : les plans alimentaires, l\'analyse de vos habitudes, des conseils personnalisés, et répondre à vos questions nutritionnelles.',
    'merci': 'De rien ! N\'hésitez pas si vous avez d\'autres questions.',
  };

  String? _getCachedResponse(String query) {
    final lowerQuery = query.toLowerCase().trim();
    return _responseCache[lowerQuery];
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}