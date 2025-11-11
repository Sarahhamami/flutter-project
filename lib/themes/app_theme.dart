import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Couleurs vibrantes Material 3 pour l'app nutrition
class AppColors {
  // Couleurs primaires vibrantes
  static const Color primary = Color(0xFF00BFA5);        // Vert teal vibrant
  static const Color secondary = Color(0xFF2196F3);      // Bleu vibrant
  static const Color tertiary = Color(0xFFFF9800);       // Orange vibrant
  static const Color accent = Color(0xFFE91E63);         // Rose vibrant

  // Couleurs neutres modernes
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkGrey = Color(0xFF424242);
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFFAFAFA);

  // Couleurs pour le texte et erreurs
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color error = Color(0xFFF44336);

  // Couleurs spéciales pour le design moderne
  static const Color glassBackground = Color(0x80FFFFFF);
  static const Color shadowColor = Color(0x1F000000);

  // Couleurs santé spécifiques
  static const Color healthyGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color dangerRed = Color(0xFFF44336);
  static const Color infoBlue = Color(0xFF2196F3);

  // Dégradés modernes
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
    colors: [tertiary, Color(0xFFFF5722)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [white, Color(0xFFE8F5E8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [error, Color(0xFFFF5722)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Couleurs pour le dark mode
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkPrimary = Color(0xFF00BFA5);
  static const Color darkSecondary = Color(0xFF2196F3);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        surface: AppColors.background,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
      ),

      // Configuration de l'AppBar moderne avec glassmorphism
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.glassBackground,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        shadowColor: AppColors.shadowColor,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),

      // Configuration des champs de saisie modernes
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: TextStyle(color: AppColors.textSecondary),
        hintStyle: TextStyle(color: AppColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      ),

      // Configuration des boutons modernes avec gradients
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.white,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shadowColor: AppColors.shadowColor,
        ).copyWith(
          backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.pressed)) {
              return AppColors.primary.withOpacity(0.8);
            }
            return AppColors.primary;
          }),
        ),
      ),

      // Configuration des boutons texte
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Configuration des cartes modernes avec glassmorphism
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 8,
        shadowColor: AppColors.shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),

      // Configuration du scaffold
      scaffoldBackgroundColor: AppColors.background,

      // Configuration du texte modernisée avec Google Fonts
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.poppins(
          color: AppColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.poppins(
          color: AppColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: GoogleFonts.poppins(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.poppins(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        labelLarge: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Configuration des FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 8,
      ),

      // Configuration des chips
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightGrey,
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
        labelStyle: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // Dark theme moderne
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        secondary: AppColors.darkSecondary,
        tertiary: AppColors.tertiary,
        surface: AppColors.darkSurface,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.white,
        error: AppColors.error,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface.withOpacity(0.8),
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        shadowColor: AppColors.shadowColor,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
      ),

      scaffoldBackgroundColor: AppColors.darkBackground,

      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 8,
        shadowColor: AppColors.shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),

      textTheme: TextTheme(
        headlineLarge: GoogleFonts.poppins(
          color: AppColors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.poppins(
          color: AppColors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: GoogleFonts.poppins(
          color: AppColors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.poppins(
          color: AppColors.white,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.inter(
          color: AppColors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.inter(
          color: AppColors.white,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.inter(
          color: AppColors.white,
          fontSize: 14,
        ),
        labelLarge: GoogleFonts.inter(
          color: AppColors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Configuration des FloatingActionButton pour dark mode
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.white,
        elevation: 8,
      ),

      // Configuration des chips pour dark mode
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedColor: AppColors.darkPrimary.withOpacity(0.3),
        checkmarkColor: AppColors.darkPrimary,
        labelStyle: GoogleFonts.inter(
          color: AppColors.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}