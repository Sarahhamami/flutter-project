import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class MacroChart extends StatefulWidget {
  final double proteins;
  final double carbs;
  final double fats;
  final double proteinsObjectif;
  final double carbsObjectif;
  final double fatsObjectif;

  const MacroChart({
    super.key,
    required this.proteins,
    required this.carbs,
    required this.fats,
    required this.proteinsObjectif,
    required this.carbsObjectif,
    required this.fatsObjectif,
  });

  @override
  State<MacroChart> createState() => _MacroChartState();
}

class _MacroChartState extends State<MacroChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(MacroChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.proteins != widget.proteins ||
        oldWidget.carbs != widget.carbs ||
        oldWidget.fats != widget.fats ||
        oldWidget.proteinsObjectif != widget.proteinsObjectif ||
        oldWidget.carbsObjectif != widget.carbsObjectif ||
        oldWidget.fatsObjectif != widget.fatsObjectif) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalConsumed = widget.proteins + widget.carbs + widget.fats;
    final totalObjectif = widget.proteinsObjectif + widget.carbsObjectif + widget.fatsObjectif;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.restaurant_menu,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Macronutriments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Barres de progression avec animations
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Column(
                children: [
                  _buildMacroBar(
                    label: 'Protéines',
                    consumed: widget.proteins,
                    objectif: widget.proteinsObjectif,
                    color: Colors.blue,
                    unit: 'g',
                    icon: Icons.fitness_center,
                    animation: _animation,
                  ),
                  const SizedBox(height: 12),
                  _buildMacroBar(
                    label: 'Glucides',
                    consumed: widget.carbs,
                    objectif: widget.carbsObjectif,
                    color: Colors.orange,
                    unit: 'g',
                    icon: Icons.grain,
                    animation: _animation,
                  ),
                  const SizedBox(height: 12),
                  _buildMacroBar(
                    label: 'Lipides',
                    consumed: widget.fats,
                    objectif: widget.fatsObjectif,
                    color: Colors.green,
                    unit: 'g',
                    icon: Icons.opacity,
                    animation: _animation,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          // Totaux avec design amélioré
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total consommé',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey,
                  ),
                ),
                Text(
                  '${totalConsumed.round()}g / ${totalObjectif.round()}g',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroBar({
    required String label,
    required double consumed,
    required double objectif,
    required Color color,
    required String unit,
    required IconData icon,
    required Animation<double> animation,
  }) {
    final percentage = objectif > 0 ? (consumed / objectif).clamp(0.0, 1.5) : 0.0;
    final isExceeded = consumed > objectif;
    final animatedPercentage = percentage * animation.value;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey,
                  ),
                ),
              ),
              Text(
                '${consumed.round()}$unit / ${objectif.round()}$unit',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isExceeded ? Colors.red : color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: animatedPercentage.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isExceeded
                        ? [Colors.red, Colors.redAccent]
                        : [color, color.withOpacity(0.7)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}