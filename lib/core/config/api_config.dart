import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Résultat du test d'une clé API
class ApiTestResult {
  final bool isSuccess;
  final String? errorTitle;
  final String? errorMessage;

  ApiTestResult._({
    required this.isSuccess,
    this.errorTitle,
    this.errorMessage,
  });

  factory ApiTestResult.success() {
    return ApiTestResult._(isSuccess: true);
  }

  factory ApiTestResult.error(String title, String message) {
    return ApiTestResult._(
      isSuccess: false,
      errorTitle: title,
      errorMessage: message,
    );
  }
}

class ApiConfig {
  static const String _geminiApiKeyPref = 'gemini_api_key';

  /// Récupère la clé API Gemini avec priorité :
  /// 1. Clé sauvegardée par l'utilisateur
  /// 2. Clé de développement (debug seulement)
  /// 3. null si aucune clé valide
  static Future<String?> getGeminiApiKey() async {
    final prefs = await SharedPreferences.getInstance();

    // Priorité 1 : Clé sauvegardée par l'utilisateur
    final userKey = prefs.getString(_geminiApiKeyPref);
    if (userKey != null && userKey.trim().isNotEmpty) {
      return userKey.trim();
    }

    // Priorité 2 : Clé de développement (seulement en debug)
    if (kDebugMode) {
      const devKey = String.fromEnvironment('GEMINI_API_KEY');
      if (devKey.isNotEmpty) {
        return devKey;
      }
    }

    return null;
  }

  /// Sauvegarde la clé API saisie par l'utilisateur
  static Future<bool> saveUserApiKey(String key) async {
    if (key.trim().isEmpty) return false;

    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_geminiApiKeyPref, key.trim());
  }

  /// Supprime la clé API sauvegardée
  static Future<bool> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_geminiApiKeyPref);
  }

  /// Vérifie si une clé API est configurée
  static Future<bool> hasApiKey() async {
    final key = await getGeminiApiKey();
    return key != null;
  }

  /// Teste la validité d'une clé API
  static Future<ApiTestResult> testApiKey(String key) async {
    try {
      // Test basique de format
      if (key.trim().isEmpty) {
        return ApiTestResult.error("Clé vide", "Veuillez saisir une clé API");
      }

      if (!key.startsWith('AIza')) {
        return ApiTestResult.error("Format invalide", "La clé doit commencer par 'AIza...'");
      }

      // TODO: Implémenter un test réel avec l'API Gemini
      // Pour l'instant, on simule un test réussi
      await Future.delayed(const Duration(seconds: 1)); // Simulation du délai réseau

      return ApiTestResult.success();
    } catch (e) {
      return ApiTestResult.error("Erreur", "Impossible de tester la clé: $e");
    }
  }
}

class ApiConfigg {
  static const String _geminiApiKeyPref = 'gemini_api_key';

  /// Récupère la clé API Gemini avec priorité :
  /// 1. Clé sauvegardée par l'utilisateur
  /// 2. Clé de développement (debug seulement)
  /// 3. null si aucune clé valide
  static Future<String?> getGeminiApiKey() async {
    final prefs = await SharedPreferences.getInstance();

    // Priorité 1 : Clé sauvegardée par l'utilisateur
    final userKey = prefs.getString(_geminiApiKeyPref);
    if (userKey != null && userKey.trim().isNotEmpty) {
      return userKey.trim();
    }

    // Priorité 2 : Clé de développement (seulement en debug)
    if (kDebugMode) {
      const devKey = String.fromEnvironment('GEMINI_API_KEY');
      if (devKey.isNotEmpty) {
        return devKey;
      }
    }

    return null;
  }

  /// Sauvegarde la clé API saisie par l'utilisateur
  static Future<bool> saveUserApiKey(String key) async {
    if (key.trim().isEmpty) return false;

    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_geminiApiKeyPref, key.trim());
  }

  /// Supprime la clé API sauvegardée
  static Future<bool> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_geminiApiKeyPref);
  }

  /// Vérifie si une clé API est configurée
  static Future<bool> hasApiKey() async {
    final key = await getGeminiApiKey();
    return key != null;
  }

  /// Teste la validité d'une clé API
  static Future<ApiTestResult> testApiKey(String key) async {
    try {
      // Test basique de format
      if (key.trim().isEmpty) {
        return ApiTestResult.error("Clé vide", "Veuillez saisir une clé API");
      }

      if (!key.startsWith('AIza')) {
        return ApiTestResult.error("Format invalide", "La clé doit commencer par 'AIza...'");
      }

      // TODO: Implémenter un test réel avec l'API Gemini
      // Pour l'instant, on simule un test réussi
      await Future.delayed(const Duration(seconds: 1)); // Simulation du délai réseau

      return ApiTestResult.success();
    } catch (e) {
      return ApiTestResult.error("Erreur", "Impossible de tester la clé: $e");
    }
  }
}