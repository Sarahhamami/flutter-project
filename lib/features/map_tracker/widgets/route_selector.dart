import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlong;
import '../../../app_colors.dart';

class RouteSelector extends StatelessWidget {
  final latlong.LatLng? startPoint;
  final latlong.LatLng? endPoint;
  final VoidCallback? onClearRoute;
  final String instruction;

  const RouteSelector({
    Key? key,
    this.startPoint,
    this.endPoint,
    this.onClearRoute,
    required this.instruction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.directions_walk,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Sélection du parcours',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (startPoint != null || endPoint != null)
                IconButton(
                  onPressed: onClearRoute,
                  icon: const Icon(Icons.clear),
                  tooltip: 'Effacer le parcours',
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            instruction,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildPointIndicator(
                'Départ',
                startPoint != null,
                AppColors.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 2,
                  color: startPoint != null && endPoint != null
                      ? AppColors.primary
                      : Colors.grey[300],
                ),
              ),
              const SizedBox(width: 16),
              _buildPointIndicator(
                'Arrivée',
                endPoint != null,
                AppColors.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPointIndicator(String label, bool isSelected, Color color) {
    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? color : Colors.grey[300],
            border: Border.all(
              color: isSelected ? color : Colors.grey[400]!,
              width: 2,
            ),
          ),
          child: isSelected
              ? const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 12,
                )
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? color : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}