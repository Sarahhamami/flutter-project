import 'package:flutter/material.dart';
import '../models/route_data.dart';
import '../services/steps_converter.dart';
import '../../../app_colors.dart';

class DistanceCalculator extends StatelessWidget {
  final RouteData? routeData;
  final VoidCallback? onAddToSteps;

  const DistanceCalculator({
    Key? key,
    this.routeData,
    this.onAddToSteps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (routeData == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.straighten,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Calcul du parcours',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'Distance',
            StepsConverter.formatDistance(routeData!.distanceKm),
            Icons.directions,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Pas estimés',
            '≈ ${StepsConverter.formatSteps(routeData!.estimatedSteps)} pas',
            Icons.directions_walk,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Calories',
            '≈ ${StepsConverter.formatCalories(routeData!.estimatedCalories)} kcal',
            Icons.local_fire_department,
          ),
          if (routeData!.duration != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              'Durée estimée',
              routeData!.duration!,
              Icons.access_time,
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddToSteps,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter aux pas du jour'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}