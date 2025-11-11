import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../themes/app_theme.dart';
import '../providers/ai_coach_provider.dart';

class MealPlanCard extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onSave;
  final VoidCallback? onShare;
  final VoidCallback? onRegenerate;

  const MealPlanCard({
    super.key,
    required this.message,
    this.onSave,
    this.onShare,
    this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 0,
        color: AppColors.glassBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildContent(context),
              const SizedBox(height: 16),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppColors.secondaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.restaurant_menu,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Plan Alimentaire Généré',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Par votre coach IA nutritionnel',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            // TODO: Implémenter le menu d'options
          },
          icon: Icon(
            Icons.more_vert,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      child: SingleChildScrollView(
        child: SelectableText(
          message.content,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            height: 1.6,
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            icon: Icons.save,
            label: 'Sauvegarder',
            color: AppColors.primary,
            onTap: onSave ?? () {
              // TODO: Implémenter la sauvegarde
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Plan sauvegardé !')),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionButton(
            context,
            icon: Icons.share,
            label: 'Partager',
            color: AppColors.secondary,
            onTap: onShare ?? () {
              // TODO: Implémenter le partage
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fonction de partage à venir')),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionButton(
            context,
            icon: Icons.refresh,
            label: 'Régénérer',
            color: AppColors.accent,
            onTap: onRegenerate ?? () {
              // TODO: Implémenter la régénération
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Régénération du plan...')),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Widget pour afficher un résumé du plan alimentaire
class MealPlanSummaryCard extends StatelessWidget {
  final String planContent;
  final DateTime generatedAt;
  final VoidCallback? onViewDetails;
  final VoidCallback? onDelete;

  const MealPlanSummaryCard({
    super.key,
    required this.planContent,
    required this.generatedAt,
    this.onViewDetails,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.glassBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onViewDetails,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.secondaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plan Alimentaire',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _extractPlanSummary(planContent),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Généré ${_formatDate(generatedAt)}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _extractPlanSummary(String content) {
    // Extraire un résumé du contenu du plan
    final lines = content.split('\n');
    final firstMeaningfulLine = lines.firstWhere(
      (line) => line.trim().isNotEmpty && !line.toLowerCase().contains('plan'),
      orElse: () => 'Plan alimentaire personnalisé',
    );

    if (firstMeaningfulLine.length > 50) {
      return firstMeaningfulLine.substring(0, 50) + '...';
    }

    return firstMeaningfulLine;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'hier';
    } else if (difference.inDays < 7) {
      return 'il y a ${difference.inDays} jours';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// Widget pour les suggestions de questions rapides
class QuickQuestionCard extends StatelessWidget {
  final String question;
  final VoidCallback onTap;

  const QuickQuestionCard({
    super.key,
    required this.question,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.glassBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}