import 'package:flutter/material.dart';
import '../../models/water_intake.dart';
import '../../themes/app_theme.dart';

class WaterIntakeCard extends StatelessWidget {
  final WaterIntake intake;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const WaterIntakeCard({
    super.key,
    required this.intake,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icône d'eau
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.water_drop,
                color: AppColors.secondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // Informations
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${intake.quantity} ml',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'À ${intake.formattedTime}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                  ),
                  if (intake.note.isNotEmpty)
                    Text(
                      intake.note,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey.withOpacity(0.8),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),

            // Boutons d'action
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.primary),
                  onPressed: onEdit,
                  tooltip: 'Modifier',
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red.withOpacity(0.7)),
                  onPressed: () => _showDeleteConfirmation(context),
                  tooltip: 'Supprimer',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text('Voulez-vous vraiment supprimer cette prise d\'eau ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}