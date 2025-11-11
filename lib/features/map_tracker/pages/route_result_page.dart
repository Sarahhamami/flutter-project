import 'package:flutter/material.dart';
import 'package:flutter_application_1/app_colors.dart';
import '../models/route_data.dart';
import '../services/steps_converter.dart';


class RouteResultPage extends StatelessWidget {
  final RouteData routeData;

  const RouteResultPage({
    Key? key,
    required this.routeData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat du parcours'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Route summary card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.directions_walk,
                      size: 48,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Parcours calculé',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildResultRow(
                      'Distance',
                      StepsConverter.formatDistance(routeData.distanceKm),
                      Icons.straighten,
                    ),
                    const SizedBox(height: 16),
                    _buildResultRow(
                      'Pas estimés',
                      '${StepsConverter.formatSteps(routeData.estimatedSteps)} pas',
                      Icons.directions_walk,
                    ),
                    const SizedBox(height: 16),
                    _buildResultRow(
                      'Calories brûlées',
                      '≈ ${StepsConverter.formatCalories(routeData.estimatedCalories)} kcal',
                      Icons.local_fire_department,
                    ),
                    if (routeData.duration != null) ...[
                      const SizedBox(height: 16),
                      _buildResultRow(
                        'Durée estimée',
                        routeData.duration!,
                        Icons.access_time,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(routeData),
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter aux pas'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.map),
                    label: const Text('Modifier'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Tips card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Conseils',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• Les estimations sont basées sur une vitesse de marche moyenne\n'
                      '• Le nombre réel de pas peut varier selon votre rythme\n'
                      '• Pensez à vous hydrater pendant votre marche\n'
                      '• Utilisez une application de suivi GPS pour plus de précision',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}