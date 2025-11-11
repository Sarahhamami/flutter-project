import 'package:flutter/material.dart';
import 'package:flutter_application_1/custom_app_bar.dart';
import 'package:flutter_application_1/user/current_user.dart';
import 'package:flutter_application_1/pages/dashboard_page.dart';
import 'package:flutter_application_1/themes/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Auto-navigate to dashboard after a short delay for better UX
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = CurrentUser().getUser();
    final firstName = user?['prenom'] ?? 'Guest';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: customAppBar(context),
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hero Section with Animation
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 80,
                        color: AppColors.white,
                      ).animate()
                       .scale(duration: 800.ms, curve: Curves.elasticOut)
                       .then()
                       .shake(duration: 500.ms),

                      const SizedBox(height: 24),

                      Text(
                        'Transformez votre santé, un repas à la fois !',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ).animate()
                       .fadeIn(duration: const Duration(milliseconds: 600), delay: const Duration(milliseconds: 200))
                       .slide(begin: const Offset(0, 0.3), end: Offset.zero),

                      const SizedBox(height: 16),

                      Text(
                        'Votre journal nutritionnel intelligent',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AppColors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ).animate()
                       .fadeIn(duration: const Duration(milliseconds: 600), delay: const Duration(milliseconds: 400))
                       .slide(begin: const Offset(0, 0.3), end: Offset.zero),

                      const SizedBox(height: 8),

                      Text(
                        'Commencez votre voyage santé aujourd\'hui',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.white.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ).animate()
                       .fadeIn(duration: const Duration(milliseconds: 600), delay: const Duration(milliseconds: 600))
                       .slide(begin: const Offset(0, 0.3), end: Offset.zero),
                    ],
                  ),
                ).animate()
                 .scale(duration: 800.ms, curve: Curves.elasticOut),

                const SizedBox(height: 48),

                // Welcome Message
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowColor,
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Bienvenue, $firstName ! 👋',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ).animate()
                       .fadeIn(duration: const Duration(milliseconds: 600), delay: const Duration(milliseconds: 800))
                       .slide(begin: const Offset(0, 0.3), end: Offset.zero),

                      const SizedBox(height: 16),

                      Text(
                        'Préparez-vous à découvrir une nouvelle façon de gérer votre alimentation et votre bien-être.',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ).animate()
                       .fadeIn(duration: const Duration(milliseconds: 600), delay: const Duration(milliseconds: 1000))
                       .slide(begin: const Offset(0, 0.3), end: Offset.zero),
                    ],
                  ),
                ).animate()
                 .fadeIn(duration: 600.ms, delay: 800.ms)
                 .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 32),

                // Loading indicator
                Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chargement de votre expérience personnalisée...',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ).animate()
                 .fadeIn(duration: const Duration(milliseconds: 600), delay: const Duration(milliseconds: 1200)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
