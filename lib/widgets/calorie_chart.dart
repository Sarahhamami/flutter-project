import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class CalorieChart extends StatefulWidget {
  final double consumed;
  final double objectif;
  final double size;

  const CalorieChart({
    super.key,
    required this.consumed,
    required this.objectif,
    this.size = 120,
  });

  @override
  State<CalorieChart> createState() => _CalorieChartState();
}

class _CalorieChartState extends State<CalorieChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(CalorieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.consumed != widget.consumed ||
        oldWidget.objectif != widget.objectif) {
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
    final percentage = widget.objectif > 0
        ? (widget.consumed / widget.objectif).clamp(0.0, 1.0)
        : 0.0;
    final isExceeded = widget.consumed > widget.objectif;
    final displayPercentage = (percentage * 100).round();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Graphique circulaire avec ombre et gradient
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Cercle de fond avec gradient
                  Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.grey.withOpacity(0.1),
                          AppColors.grey.withOpacity(0.3),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Cercle de progression avec gradient
                  SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: CircularProgressIndicator(
                      value: percentage * _animation.value,
                      strokeWidth: 10,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isExceeded ? Colors.red : AppColors.primary,
                      ),
                    ),
                  ),
                  // Texte au centre avec animation
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$displayPercentage%',
                          style: TextStyle(
                            fontSize: widget.size * 0.22,
                            fontWeight: FontWeight.bold,
                            color: isExceeded ? Colors.red : AppColors.primary,
                          ),
                        ),
                        Text(
                          '${widget.consumed.round()}/${widget.objectif.round()}',
                          style: TextStyle(
                            fontSize: widget.size * 0.13,
                            color: AppColors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        // Label avec icône
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_fire_department,
              color: AppColors.primary,
              size: 18,
            ),
            const SizedBox(width: 4),
            Text(
              'Calories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}