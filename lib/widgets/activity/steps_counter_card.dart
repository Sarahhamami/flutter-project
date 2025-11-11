import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

class StepsCounterCard extends StatelessWidget {
  final int steps;
  final int goal;
  final double distance;
  final int calories;

  const StepsCounterCard({
    super.key,
    required this.steps,
    required this.goal,
    required this.distance,
    required this.calories,
  });

  @override
  Widget build(BuildContext context) {
    final progress = steps / goal;
    final isGoalReached = steps >= goal;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Icône principale
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isGoalReached ? Colors.green : AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isGoalReached ? Icons.check_circle : Icons.directions_walk,
              color: Colors.white,
              size: 32,
            ),
          ),

          const SizedBox(height: 16),

          // Nombre de pas
          Text(
            steps.toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]} ',
            ),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),

          Text(
            'pas',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.grey,
            ),
          ),

          const SizedBox(height: 16),

          // Barre de progression
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isGoalReached ? Colors.green : AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Pourcentage
          Text(
            '${(progress * 100).round()}% de l\'objectif',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 16),

          // Statistiques supplémentaires
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                distance < 1
                    ? '${(distance * 1000).round()}m'
                    : '${distance.toStringAsFixed(1)}km',
                'Distance',
                Icons.straighten,
              ),
              _buildStatItem(
                '${calories} kcal',
                'Brûlées',
                Icons.local_fire_department,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }
}