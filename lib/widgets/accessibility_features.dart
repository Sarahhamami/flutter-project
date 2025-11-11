import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../themes/app_theme.dart';

class AccessibilityFeatures {
  static const double minimumTouchTarget = 44.0;
  static const double minimumTextSize = 14.0;
  static const double recommendedTextSize = 16.0;

  static bool isHighContrastEnabled(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  static bool isBoldTextEnabled(BuildContext context) {
    return MediaQuery.of(context).boldText;
  }

  static bool isReduceMotionEnabled(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  static double getAccessibleFontSize(BuildContext context, double baseSize) {
    final mediaQuery = MediaQuery.of(context);
    double size = baseSize;

    // Respect system text scale factor for accessibility
    size *= mediaQuery.textScaleFactor;

    // Ensure minimum readable size
    if (size < minimumTextSize) {
      size = minimumTextSize;
    }

    // Apply bold text if enabled
    if (isBoldTextEnabled(context)) {
      size *= 1.1;
    }

    return size;
  }

  static Color getAccessibleColor(BuildContext context, Color color) {
    if (isHighContrastEnabled(context)) {
      // Increase contrast for high contrast mode
      return color.computeLuminance() > 0.5 ? Colors.white : Colors.black;
    }
    return color;
  }

  static Duration getAccessibleAnimationDuration(BuildContext context, Duration duration) {
    if (isReduceMotionEnabled(context)) {
      return Duration.zero;
    }
    return duration;
  }
}

class AccessibleText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticsLabel;

  const AccessibleText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final accessibleStyle = style?.copyWith(
      fontSize: AccessibilityFeatures.getAccessibleFontSize(
        context,
        style?.fontSize ?? AccessibilityFeatures.recommendedTextSize,
      ),
      color: AccessibilityFeatures.getAccessibleColor(context, style?.color ?? AppColors.darkGrey),
    );

    return Text(
      text,
      style: accessibleStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      semanticsLabel: semanticsLabel,
    );
  }
}

class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? tooltip;
  final String? semanticsLabel;
  final String? semanticsHint;

  const AccessibleButton({
    super.key,
    required this.child,
    this.onPressed,
    this.tooltip,
    this.semanticsLabel,
    this.semanticsHint,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      hint: semanticsHint,
      button: true,
      enabled: onPressed != null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: AccessibilityFeatures.minimumTouchTarget,
          minHeight: AccessibilityFeatures.minimumTouchTarget,
        ),
        child: Tooltip(
          message: tooltip ?? '',
          child: child,
        ),
      ),
    );
  }
}

class AccessibleCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticsLabel;
  final String? semanticsHint;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double borderRadius;

  const AccessibleCard({
    super.key,
    required this.child,
    this.onTap,
    this.semanticsLabel,
    this.semanticsHint,
    this.padding,
    this.color,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      hint: semanticsHint,
      button: onTap != null,
      enabled: onTap != null,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: AccessibilityFeatures.minimumTouchTarget,
          minHeight: AccessibilityFeatures.minimumTouchTarget,
        ),
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color ?? AppColors.glassBackground,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: AppColors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: child,
      ),
    );
  }
}

class AccessibleSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double>? onChanged;
  final String? semanticsLabel;
  final String? semanticsHint;

  const AccessibleSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    this.onChanged,
    this.semanticsLabel,
    this.semanticsHint,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel ?? 'Slider',
      hint: semanticsHint ?? 'Adjust value between ${min.round()} and ${max.round()}',
      value: '${value.round()}',
      increasedValue: '${(value + 1).clamp(min, max).round()}',
      decreasedValue: '${(value - 1).clamp(min, max).round()}',
      slider: true,
      enabled: onChanged != null,
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
        activeColor: AccessibilityFeatures.getAccessibleColor(context, AppColors.primary),
      ),
    );
  }
}

class AccessibleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticsLabel;
  final String? semanticsHint;

  const AccessibleSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.semanticsLabel,
    this.semanticsHint,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel ?? 'Switch',
      hint: semanticsHint ?? (value ? 'Currently enabled, double tap to disable' : 'Currently disabled, double tap to enable'),
      toggled: value,
      enabled: onChanged != null,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AccessibilityFeatures.getAccessibleColor(context, AppColors.primary),
      ),
    );
  }
}

class ScreenReaderAnnouncement {
  static void announce(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  static void announceError(BuildContext context, String errorMessage) {
    SemanticsService.announce('Error: $errorMessage', TextDirection.ltr);
  }

  static void announceSuccess(BuildContext context, String successMessage) {
    SemanticsService.announce('Success: $successMessage', TextDirection.ltr);
  }
}