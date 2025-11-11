import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/api_config.dart';
import '../../themes/app_theme.dart';
import '../../../widgets/modern_button.dart';
import '../../../widgets/modern_card.dart';

class ApiConfigPage extends StatefulWidget {
  const ApiConfigPage({super.key});

  @override
  State<ApiConfigPage> createState() => _ApiConfigPageState();
}

class _ApiConfigPageState extends State<ApiConfigPage> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isLoading = false;
  bool _isTesting = false;
  String? _currentApiKey;
  String? _testResult;

  @override
  void initState() {
    super.initState();
    _loadCurrentApiKey();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentApiKey() async {
    setState(() => _isLoading = true);
    try {
      _currentApiKey = await ApiConfig.getGeminiApiKey();
      if (_currentApiKey != null) {
        // Masquer la clé pour la sécurité (afficher seulement les derniers caractères)
        final maskedKey = '*' * (_currentApiKey!.length - 4) + _currentApiKey!.substring(_currentApiKey!.length - 4);
        _apiKeyController.text = maskedKey;
      }
    } catch (e) {
      _showErrorSnackBar('Erreur lors du chargement de la clé API');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testApiKey() async {
    final keyToTest = _apiKeyController.text.trim();

    if (keyToTest.isEmpty) {
      setState(() => _testResult = 'Veuillez saisir une clé API');
      return;
    }

    // Si la clé est masquée, utiliser la clé actuelle
    final actualKey = keyToTest.startsWith('*') ? _currentApiKey : keyToTest;

    if (actualKey == null) {
      setState(() => _testResult = 'Aucune clé API à tester');
      return;
    }

    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    try {
      final result = await ApiConfig.testApiKey(actualKey);
      setState(() {
        if (result.isSuccess) {
          _testResult = '✅ Clé API valide';
        } else {
          _testResult = '❌ ${result.errorTitle}: ${result.errorMessage}';
        }
      });
    } catch (e) {
      setState(() => _testResult = '❌ Erreur lors du test: $e');
    } finally {
      setState(() => _isTesting = false);
    }
  }

  Future<void> _saveApiKey() async {
    final keyToSave = _apiKeyController.text.trim();

    if (keyToSave.isEmpty) {
      _showErrorSnackBar('Veuillez saisir une clé API');
      return;
    }

    // Si la clé est masquée, ne rien faire
    if (keyToSave.startsWith('*')) {
      _showSuccessSnackBar('La clé API est déjà sauvegardée');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await ApiConfig.saveUserApiKey(keyToSave);
      if (success) {
        _showSuccessSnackBar('Clé API sauvegardée avec succès');
        await _loadCurrentApiKey();
      } else {
        _showErrorSnackBar('Erreur lors de la sauvegarde');
      }
    } catch (e) {
      _showErrorSnackBar('Erreur: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearApiKey() async {
    setState(() => _isLoading = true);

    try {
      final success = await ApiConfig.clearApiKey();
      if (success) {
        _apiKeyController.clear();
        _currentApiKey = null;
        _testResult = null;
        _showSuccessSnackBar('Clé API supprimée');
      } else {
        _showErrorSnackBar('Erreur lors de la suppression');
      }
    } catch (e) {
      _showErrorSnackBar('Erreur: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _launchGoogleAiStudio() async {
    const url = 'https://aistudio.google.com/';
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault);
      } else {
        _showErrorSnackBar('Impossible d\'ouvrir le navigateur');
      }
    } catch (e) {
      _showErrorSnackBar('Erreur lors de l\'ouverture du lien');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Configuration API Gemini'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.darkGrey,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.secondaryGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildApiKeyGuide(),
                const SizedBox(height: 24),
                _buildApiKeyInput(),
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.key,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Configuration de l\'API Gemini',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Pour utiliser le coach IA, vous devez configurer une clé API Gemini gratuite.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiKeyGuide() {
    return Column(
      children: [
        // Explication pourquoi Google Cloud
        ModernCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.help_outline,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '🤔 Pourquoi un projet Google Cloud ?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Google a besoin d\'un "conteneur" pour gérer votre usage de l\'IA. C\'est comme un dossier pour votre application.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '✅ C\'est gratuit - vous ne serez pas facturé\n⏱️ 1 minute suffit pour le créer',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Guide étape par étape
        ModernCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📋 Guide complet (6 étapes)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
            const SizedBox(height: 16),
            // Étape 1-4 : Google Cloud Console
            ExpansionTile(
              title: Text(
                "🛠️ 1-4. Créer le projet Google Cloud",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              children: [
                _buildStep(1, "Ouvrir Google Cloud Console", "console.cloud.google.com"),
                _buildStep(2, "Cliquer sur 'Select Project' en haut", "Puis 'New Project'"),
                _buildStep(3, "Nommer le projet", "Ex: 'NutritionApp' ou 'MonCoachIA'"),
                _buildStep(4, "Attendre la création", "Sélectionnez-le une fois créé"),
              ],
            ),

            const SizedBox(height: 8),

            // Étape 5-6 : Google AI Studio
            ExpansionTile(
              title: Text(
                "🔑 5-6. Créer la clé API Gemini",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
              children: [
                _buildStep(5, "Aller sur Google AI Studio", "aistudio.google.com"),
                _buildStep(6, "Créer une nouvelle clé API", "Sélectionnez votre projet créé"),
                _buildStep(7, "Copier la clé générée", "Elle commence par 'AIza...'"),
              ],
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Boutons d'action
        Row(
          children: [
            Expanded(
              child: ModernButton(
                onPressed: () => _launchUrl('https://console.cloud.google.com/', mode: LaunchMode.platformDefault),
                backgroundColor: Colors.blue.withOpacity(0.1),
                foregroundColor: Colors.blue,
                child: const Text('Google Cloud Console'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ModernButton(
                onPressed: _launchGoogleAiStudio,
                gradient: AppColors.primaryGradient,
                child: const Text('Google AI Studio'),
              ),
            ),
          ],
        ),
      ],
    );
  }
            const SizedBox(height: 16),
            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: ModernButton(
                    onPressed: () => _launchUrl('https://console.cloud.google.com/', mode: LaunchMode.platformDefault),
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    foregroundColor: Colors.blue,
                    child: const Text('Google Cloud Console'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ModernButton(
                    onPressed: _launchGoogleAiStudio,
                    gradient: AppColors.primaryGradient,
                    child: const Text('Google AI Studio'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.darkGrey,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeyInput() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Votre clé API Gemini',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _apiKeyController,
              decoration: InputDecoration(
                hintText: 'Collez votre clé API ici...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.grey.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.grey.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              obscureText: true, // Masquer la clé pour la sécurité
              style: TextStyle(
                fontFamily: 'monospace',
                color: AppColors.darkGrey,
              ),
            ),
            if (_testResult != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _testResult!.startsWith('✅')
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _testResult!.startsWith('✅')
                        ? Colors.green
                        : Colors.red,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _testResult!.startsWith('✅') ? Icons.check_circle : Icons.error,
                      color: _testResult!.startsWith('✅') ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _testResult!,
                        style: TextStyle(
                          color: _testResult!.startsWith('✅') ? Colors.green : Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ModernButton(
                onPressed: _isLoading ? null : _testApiKey,
                backgroundColor: Colors.orange.withOpacity(0.1),
                foregroundColor: Colors.orange,
                child: _isTesting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                        ),
                      )
                    : const Text('Tester la clé'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ModernButton(
                onPressed: _isLoading ? null : _saveApiKey,
                gradient: AppColors.primaryGradient,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Sauvegarder'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ModernButton(
          onPressed: _isLoading ? null : _clearApiKey,
          backgroundColor: Colors.red.withOpacity(0.1),
          foregroundColor: Colors.red,
          child: const Text('Supprimer la clé'),
        ),
      ],
    );
  }
}