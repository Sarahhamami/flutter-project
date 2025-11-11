import 'package:flutter/material.dart';
import 'dart:math';
import '../themes/app_theme.dart';

class WaterProgress extends StatefulWidget {
  final int consumed;
  final int objectif;
  final double size;

  const WaterProgress({
    super.key,
    required this.consumed,
    required this.objectif,
    this.size = 100,
  });

  @override
  State<WaterProgress> createState() => _WaterProgressState();
}

class _WaterProgressState extends State<WaterProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Animation<double> _waveAnimation;

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
    _waveAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(WaterProgress oldWidget) {
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
    final remaining = (widget.objectif - widget.consumed).clamp(0, widget.objectif);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bouteille d'eau moderne avec effets visuels
        AnimatedBuilder(
          animation: Listenable.merge([_animation, _waveAnimation]),
          builder: (context, child) {
            return Container(
              width: widget.size,
              height: widget.size * 1.3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Bouteille vide avec gradient
                  Container(
                    width: widget.size,
                    height: widget.size * 1.2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.grey.withOpacity(0.1),
                          AppColors.grey.withOpacity(0.2),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      border: Border.all(
                        color: AppColors.secondary.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  ),
                  // Remplissage de la bouteille avec effet de vague
                  Positioned(
                    bottom: widget.size * 0.1,
                    left: widget.size * 0.15,
                    right: widget.size * 0.15,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: widget.size * 0.9 * percentage * _animation.value,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.secondary.withOpacity(0.8),
                              AppColors.secondary,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        child: percentage > 0.1
                            ? CustomPaint(
                                painter: WavePainter(
                                  waveAnimation: _waveAnimation.value,
                                  color: AppColors.secondary.withOpacity(0.3),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                  // Gouttes d'eau animées
                  if (percentage > 0.7)
                    ...List.generate(3, (index) {
                      final delay = index * 0.3;
                      final dropAnimation = Tween<double>(begin: 0, end: 1).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(delay, delay + 0.5, curve: Curves.easeInOut),
                        ),
                      );
                      return Positioned(
                        top: widget.size * (0.1 + dropAnimation.value * 0.2),
                        right: widget.size * (0.15 + index * 0.15),
                        child: Transform.scale(
                          scale: dropAnimation.value,
                          child: Icon(
                            Icons.water_drop,
                            size: widget.size * 0.12,
                            color: AppColors.secondary.withOpacity(0.8),
                          ),
                        ),
                      );
                    }),
                  // Reflet sur la bouteille
                  Positioned(
                    top: widget.size * 0.1,
                    left: widget.size * 0.2,
                    child: Container(
                      width: widget.size * 0.3,
                      height: widget.size * 0.6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.white.withOpacity(0.1),
                            Colors.transparent,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        // Texte avec design amélioré
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.grey.withOpacity(0.1),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.opacity,
                    color: AppColors.secondary,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.consumed}ml / ${widget.objectif}ml',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              if (remaining > 0)
                Text(
                  '${remaining}ml restants',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// Peintre personnalisé pour l'effet de vague
class WavePainter extends CustomPainter {
  final double waveAnimation;
  final Color color;

  WavePainter({required this.waveAnimation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final y = sin((x / size.width * 2 * pi) + waveAnimation) * 3 + size.height * 0.8;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.waveAnimation != waveAnimation;
  }
}

// Widget pour les pas avec icône de podomètre
class StepsProgress extends StatelessWidget {
  final int steps;
  final int objectif;

  const StepsProgress({
    super.key,
    required this.steps,
    required this.objectif,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = objectif > 0 ? (steps / objectif).clamp(0.0, 1.0) : 0.0;
    final remaining = (objectif - steps).clamp(0, objectif);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Cercle avec icône de pas
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.1),
            border: Border.all(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.directions_walk,
                size: 32,
                color: AppColors.primary,
              ),
              if (percentage >= 1.0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.green,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Texte
        Column(
          children: [
            Text(
              '${steps.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              'pas',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grey,
              ),
            ),
            if (remaining > 0)
              Text(
                '${remaining.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} restants',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.grey,
                ),
              ),
          ],
        ),
      ],
    );
  }
}