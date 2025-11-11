import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/pages/dashboard_page.dart';
import 'package:flutter_application_1/pages/nutrition_profile_page.dart';
import 'package:flutter_application_1/pages/hydration_tracker_page.dart';
import 'package:flutter_application_1/pages/steps_tracker_page.dart';
import 'package:flutter_application_1/pages/recipes_page.dart';
import 'package:flutter_application_1/pages/favorites_page.dart';
import 'package:flutter_application_1/services/nutrition_database_service.dart';
import 'package:flutter_application_1/providers/dashboard_provider.dart';
import 'package:flutter_application_1/providers/hydration_provider.dart';
import 'package:flutter_application_1/providers/activity_provider.dart';
import 'package:flutter_application_1/providers/recipe_provider.dart';
import 'package:flutter_application_1/themes/app_theme.dart';
import 'package:flutter_application_1/widgets/modern_bottom_navigation.dart';
import 'package:flutter_application_1/widgets/loading_animation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation du service de base de données nutritionnelle
  await NutritionDatabaseService.init();
  print("✅ Nutrition Database Service initialized");


  runApp(const NutritionTrackerApp());
}

class NutritionTrackerApp extends StatelessWidget {
  const NutritionTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => HydrationProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
      ],
      child: MaterialApp(
        title: 'Suivi Nutritionnel',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomePage(),
        routes: {
          '/dashboard': (context) => const DashboardPage(),
          '/profile': (context) => const NutritionProfilePage(),
          '/hydration': (context) => const HydrationTrackerPage(),
          '/steps': (context) => const StepsTrackerPage(),
          '/recipes': (context) => const RecipesPage(),
          '/favorites': (context) => const FavoritesPage(),
        },
      ),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const HydrationTrackerPage(),
    const StepsTrackerPage(),
    const RecipesPage(),
  ];

  final List<ModernBottomNavigationItem> _navigationItems = [
    const ModernBottomNavigationItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
    ),
    const ModernBottomNavigationItem(
      icon: Icons.water_drop_outlined,
      activeIcon: Icons.water_drop,
      label: 'Eau',
    ),
    const ModernBottomNavigationItem(
      icon: Icons.directions_walk_outlined,
      activeIcon: Icons.directions_walk,
      label: 'Pas',
    ),
    const ModernBottomNavigationItem(
      icon: Icons.restaurant_menu_outlined,
      activeIcon: Icons.restaurant_menu,
      label: 'Recettes',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: ModernBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _navigationItems,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    final hasProfile = await NutritionDatabaseService.hasNutritionProfile();

    if (mounted) {
      if (hasProfile) {
        // Si profil existe, aller à la navigation principale
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationPage()),
        );
      } else {
        // Si pas de profil, aller à la page de création de profil
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NutritionProfilePage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.secondaryGradient,
        ),
        child: const Center(
          child: ModernLoadingAnimation(
            message: 'Initialisation de l\'application...',
          ),
        ),
      ),
    );
  }
}
