import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class ModernButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double elevation;
  final Duration animationDuration;
  final bool isLoading;
  final Gradient? gradient;

  const ModernButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = 16,
    this.padding,
    this.elevation = 0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.isLoading = false,
    this.gradient,
  });

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton>
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
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
      widget.onPressed!();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.backgroundColor ?? AppColors.primary;
    final foregroundColor = widget.foregroundColor ?? AppColors.white;
    final padding = widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 14);

    Widget buttonContent = widget.isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        : widget.child;

    Widget button = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: widget.gradient == null ? backgroundColor : null,
                gradient: widget.gradient,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: widget.elevation > 0
                    ? [
                        BoxShadow(
                          color: backgroundColor.withOpacity(0.3),
                          blurRadius: widget.elevation * 2,
                          offset: Offset(0, widget.elevation),
                        ),
                      ]
                    : null,
              ),
              child: Center(child: buttonContent),
            ),
          ),
        );
      },
    );

    if (widget.onPressed != null && !widget.isLoading) {
      button = GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: button,
      );
    }

    return button;
  }
}

class ModernFloatingButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final double size;
  final Gradient? gradient;

  const ModernFloatingButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.size = 56,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = this.backgroundColor ?? AppColors.primary;

    return ModernButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      gradient: gradient,
      borderRadius: size / 2,
      padding: EdgeInsets.all(size * 0.2),
      elevation: 8,
      child: icon,
    );
  }
}

class ModernIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;
  final String? tooltip;

  const ModernIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size = 24,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return ModernButton(
      onPressed: onPressed,
      backgroundColor: Colors.transparent,
      borderRadius: 12,
      padding: const EdgeInsets.all(8),
      child: Icon(
        icon,
        color: color ?? AppColors.primary,
        size: size,
      ),
    );
  }
}