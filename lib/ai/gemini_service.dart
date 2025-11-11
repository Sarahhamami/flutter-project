import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';
import '../core/models/ai_response.dart';

class GeminiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  Future<AiResponse> generateResponse(String prompt) async {
    return _callGeminiAPI(prompt);
  }

  Future<AiResponse> generateMealPlan(String prompt) async {
    return _callGeminiAPI(prompt);
  }

  Future<AiResponse> analyzeNutritionData(String prompt) async {
    return _callGeminiAPI(prompt);
  }

  Future<AiResponse> _callGeminiAPI(String prompt) async {
    try {
      // Récupérer la clé API
      final apiKey = await ApiConfig.getGeminiApiKey();
      if (apiKey == null) {
        return AiResponse.error(
          type: ErrorType.missingApiKey,
          message: 'Aucune clé API Gemini configurée. Veuillez configurer votre clé API dans les paramètres.',
        );
      }

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [{'text': prompt}]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 2048,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        if (text != null) {
          return AiResponse.success(data: text);
        } else {
          return AiResponse.error(
            type: ErrorType.apiError,
            message: 'Réponse vide de l\'API Gemini',
          );
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return AiResponse.error(
          type: ErrorType.invalidApiKey,
          message: 'Clé API Gemini invalide. Vérifiez votre clé dans les paramètres.',
        );
      } else if (response.statusCode == 429) {
        return AiResponse.error(
          type: ErrorType.rateLimitExceeded,
          message: 'Limite d\'utilisation atteinte. Veuillez patienter avant de continuer.',
        );
      } else {
        return AiResponse.error(
          type: ErrorType.apiError,
          message: 'Erreur API Gemini: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('Network')) {
        return AiResponse.error(
          type: ErrorType.networkError,
          message: 'Erreur de connexion. Vérifiez votre connexion internet.',
        );
      }
      return AiResponse.error(
        type: ErrorType.unknown,
        message: 'Erreur inconnue: $e',
      );
    }
  }
}