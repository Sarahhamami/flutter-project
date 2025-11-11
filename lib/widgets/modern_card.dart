import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class ModernCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color? backgroundColor;
  final List<BoxShadow>? shadows;
  final Duration animationDuration;
  final EdgeInsetsGeometry? margin;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.borderRadius = 20,
    this.backgroundColor,
    this.shadows,
    this.animationDuration = const Duration(milliseconds: 300),
    this.margin,
  });

  @override
  State<ModernCard> createState() => _ModernCardState();
}

class _ModernCardState extends State<ModernCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.backgroundColor ?? AppColors.glassBackground;
    final shadows = widget.shadows ?? [
      BoxShadow(
        color: AppColors.shadowColor,
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ];

    Widget card = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              margin: widget.margin,
              padding: widget.padding ?? const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: shadows,
                border: Border.all(
                  color: AppColors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: widget.child,
            ),
          ),
        );
      },
    );

    if (widget.onTap != null) {
      card = GestureDetector(
        onTap: widget.onTap,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: card,
      );
    }

    return card;
  }
}

class ModernGradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double borderRadius;
  final Gradient? gradient;
  final List<BoxShadow>? shadows;

  const ModernGradientCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.borderRadius = 20,
    this.gradient,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final defaultGradient = gradient ?? AppColors.primaryGradient;
    final shadows = this.shadows ?? [
      BoxShadow(
        color: AppColors.shadowColor,
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ];

    return ModernCard(
      padding: padding,
      onTap: onTap,
      borderRadius: borderRadius,
      backgroundColor: Colors.transparent,
      shadows: shadows,
      child: Container(
        decoration: BoxDecoration(
          gradient: defaultGradient,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: child,
      ),
    );
  }
}