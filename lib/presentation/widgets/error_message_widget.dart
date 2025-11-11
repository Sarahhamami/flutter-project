import 'package:flutter/material.dart';
import '../../core/models/ai_response.dart';
import '../../themes/app_theme.dart';
import '../pages/api_config_page.dart';
import '../../../widgets/modern_button.dart';
import '../../../widgets/modern_card.dart';

class ErrorMessageWidget extends StatelessWidget {
  final ErrorType errorType;
  final String? customMessage;
  final VoidCallback? onRetry;

  const ErrorMessageWidget({
    super.key,
    required this.errorType,
    this.customMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(),
            const SizedBox(height: 16),
            _buildTitle(),
            const SizedBox(height: 8),
            _buildMessage(),
            const SizedBox(height: 20),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData icon;
    Color color;

    switch (errorType) {
      case ErrorType.missingApiKey:
      case ErrorType.invalidApiKey:
        icon = Icons.key_off;
        color = Colors.orange;
        break;
      case ErrorType.networkError:
        icon = Icons.wifi_off;
        color = Colors.blue;
        break;
      case ErrorType.rateLimitExceeded:
        icon = Icons.timer_off;
        color = Colors.amber;
        break;
      case ErrorType.apiError:
      case ErrorType.unknown:
      default:
        icon = Icons.error_outline;
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 32,
      ),
    );
  }

  Widget _buildTitle() {
    String title;

    switch (errorType) {
      case ErrorType.missingApiKey:
        title = 'Clé API manquante';
        break;
      case ErrorType.invalidApiKey:
        title = 'Clé API invalide';
        break;
      case ErrorType.networkError:
        title = 'Problème de connexion';
        break;
      case ErrorType.rateLimitExceeded:
        title = 'Limite atteinte';
        break;
      case ErrorType.apiError:
        title = 'Erreur du service';
        break;
      case ErrorType.unknown:
      default:
        title = 'Erreur inconnue';
        break;
    }

    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.darkGrey,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildMessage() {
    String message = customMessage ?? _getDefaultMessage();

    return Text(
      message,
      style: TextStyle(
        fontSize: 14,
        color: AppColors.grey,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  String _getDefaultMessage() {
    switch (errorType) {
      case ErrorType.missingApiKey:
        return 'Vous devez configurer une clé API Gemini pour utiliser le coach IA. C\'est gratuit et rapide !';
      case ErrorType.invalidApiKey:
        return 'La clé API configurée n\'est pas valide. Vérifiez que vous avez copié la bonne clé depuis Google AI Studio.';
      case ErrorType.networkError:
        return 'Impossible de se connecter au service IA. Vérifiez votre connexion internet et réessayez.';
      case ErrorType.rateLimitExceeded:
        return 'Vous avez atteint la limite d\'utilisation. Veuillez patienter quelques minutes avant de continuer.';
      case ErrorType.apiError:
        return 'Le service IA rencontre un problème temporaire. Veuillez réessayer dans quelques instants.';
      case ErrorType.unknown:
      default:
        return 'Une erreur inattendue s\'est produite. Veuillez réessayer ou contacter le support si le problème persiste.';
    }
  }

  Widget _buildActions(BuildContext context) {
    switch (errorType) {
      case ErrorType.missingApiKey:
      case ErrorType.invalidApiKey:
        return ModernButton(
          onPressed: () => _navigateToApiConfig(context),
          gradient: AppColors.primaryGradient,
          child: const Text('Configurer la clé API'),
        );

      case ErrorType.networkError:
      case ErrorType.apiError:
      case ErrorType.unknown:
        return Row(
          children: [
            if (onRetry != null) ...[
              Expanded(
                child: ModernButton(
                  onPressed: onRetry,
                  backgroundColor: Colors.grey.withOpacity(0.1),
                  foregroundColor: Colors.grey,
                  child: const Text('Réessayer'),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: ModernButton(
                onPressed: () => _navigateToApiConfig(context),
                gradient: AppColors.primaryGradient,
                child: const Text('Paramètres'),
              ),
            ),
          ],
        );

      case ErrorType.rateLimitExceeded:
        return ModernButton(
          onPressed: () {
            // Just close the error - user needs to wait
            Navigator.of(context).pop();
          },
          backgroundColor: Colors.amber.withOpacity(0.1),
          foregroundColor: Colors.amber,
          child: const Text('Compris'),
        );
    }
  }

  void _navigateToApiConfig(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ApiConfigPage()),
    );
  }
}