// This file is deprecated. Use lib/themes/app_theme.dart instead.
// Keeping for backward compatibility but all new code should use AppColors from app_theme.dart
import 'package:flutter/material.dart';

class AppColors {
  // Legacy colors - deprecated, use themes/app_theme.dart instead
  static const Color background = Colors.white;
  static const Color primary = Color(0xFF00BFA5); // Updated to match new theme
  static const Color secondary = Color(0xFF2196F3); // Updated to match new theme
  static const Color green = Color(0xFF4CAF50);
  static const Color blue = Color(0xFF2196F3);
  static const Color gray = Colors.grey;
  static const Color darkGrey = Color(0xFF424242);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color white = Colors.white;
  static const Color shadowColor = Color(0x1F000000);

  // Gradients - deprecated, use themes/app_theme.dart instead
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF26A69A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, Color(0xFF1976D2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}