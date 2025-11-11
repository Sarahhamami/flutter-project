import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/dashboard_provider.dart';
import '../pages/add_meal_page.dart';
import '../pages/nutrition_profile_page.dart';
import '../pages/hydration_tracker_page.dart';
import '../pages/steps_tracker_page.dart';
import '../pages/recipes_page.dart';
import '../pages/favorites_page.dart';
import '../models/meal.dart';
import '../widgets/calorie_chart.dart';
import '../widgets/macro_chart.dart';
import '../widgets/water_progress.dart';
import '../widgets/modern_progress_indicator.dart';
import '../widgets/modern_card.dart';
import '../widgets/modern_button.dart';
import '../widgets/loading_animation.dart';
import '../widgets/suggestion_dialog.dart';
import '../features/map_tracker/pages/map_tracker_page.dart';
import '../themes/app_theme.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Initialiser les données au chargement de la page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Dashboard Nutritionnel'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.darkGrey,
        elevation: 0,
        actions: [
          ModernIconButton(
            icon: Icons.restaurant_menu,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecipesPage(),
                ),
              );
            },
          ),
          ModernIconButton(
            icon: Icons.favorite,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesPage(),
                ),
              );
            },
          ),
          ModernIconButton(
            icon: Icons.person,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NutritionProfilePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Consumer<DashboardProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: ModernLoadingAnimation(
                  message: 'Chargement de votre dashboard...',
                ),
              );
            }

            if (provider.nutritionProfile == null) {
              return _buildNoProfileView();
            }

            return RefreshIndicator(
              onRefresh: provider.initialize,
              color: AppColors.primary,
              backgroundColor: AppColors.white,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 100, 16, 100),
                child: AnimationLimiter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 600),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(child: widget),
                      ),
                      children: [
                        // En-tête avec résumé du jour
                        _buildDaySummary(provider),
                        const SizedBox(height: 24),

                        // Section graphiques
                        _buildChartsSection(provider),
                        const SizedBox(height: 24),

                        // Section activité
                        _buildActivitySection(),
                        const SizedBox(height: 24),

                        // Section repas
                        _buildMealsSection(provider),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNoProfileView() {
    return EmptyStateWidget(
      icon: Icons.restaurant_menu,
      title: 'Bienvenue dans votre suivi nutritionnel !',
      subtitle: 'Commencez par créer votre profil nutritionnel pour accéder à votre dashboard personnalisé.',
      action: ModernButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NutritionProfilePage(),
            ),
          );
        },
        gradient: AppColors.primaryGradient,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_add, color: AppColors.white),
            SizedBox(width: 8),
            Text('Créer mon profil'),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySummary(DashboardProvider provider) {
    final profile = provider.nutritionProfile!;
    final progress = provider.dailyProgress!;

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Résumé du jour',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGrey,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${DateTime.now().day}/${DateTime.now().month}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'Calories restantes',
                '${provider.caloriesRemaining.round()} kcal',
                Icons.local_fire_department,
                AppColors.primary,
              ),
              _buildSummaryItem(
                'Objectif calories',
                '${profile.calorieObjectif.round()} kcal',
                Icons.flag,
                AppColors.secondary,
              ),
              _buildSummaryItem(
                'Repas ajoutés',
                '${provider.todayMeals.length}',
                Icons.restaurant,
                AppColors.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGrey,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.grey,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildChartsSection(DashboardProvider provider) {
    final profile = provider.nutritionProfile!;
    final progress = provider.dailyProgress!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progression',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 20),

        // Première ligne : Calories et Macros avec indicateurs modernes
        Row(
          children: [
            Expanded(
              child: ModernCard(
                onTap: () => _showCalorieDetails(context, progress, profile),
                child: Column(
                  children: [
                    ModernProgressIndicator(
                      progress: progress.caloriesConsumed / profile.calorieObjectif,
                      size: 80,
                      color: AppColors.primary,
                      label: 'Calories',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${progress.caloriesConsumed.round()}/${profile.calorieObjectif.round()} kcal',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ModernCard(
                onTap: () => _showMacroDetails(context, progress, profile),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildMacroIndicator('P', progress.proteinsConsumed / profile.proteineObjectif, AppColors.primary),
                        _buildMacroIndicator('C', progress.carbsConsumed / profile.glucideObjectif, AppColors.secondary),
                        _buildMacroIndicator('L', progress.fatsConsumed / profile.lipideObjectif, AppColors.accent),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Macros',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Deuxième ligne : Eau et Pas avec indicateurs modernes
        Row(
          children: [
            Expanded(
              child: ModernCard(
                onTap: _navigateToHydrationTracker,
                child: Column(
                  children: [
                    ModernProgressIndicator(
                      progress: progress.waterConsumed / profile.eauObjectif,
                      size: 70,
                      color: AppColors.secondary,
                      label: 'Eau',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${progress.waterConsumed.round()}/${profile.eauObjectif.round()} ml',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ModernCard(
                onTap: _navigateToStepsTracker,
                child: Column(
                  children: [
                    ModernProgressIndicator(
                      progress: progress.stepsTaken / profile.pasObjectif,
                      size: 70,
                      color: AppColors.accent,
                      label: 'Pas',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${progress.stepsTaken}/${profile.pasObjectif}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMealsSection(DashboardProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Repas du jour',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.darkGrey,
              ),
            ),
            ModernButton(
              onPressed: _addMeal,
              backgroundColor: Colors.transparent,
              foregroundColor: AppColors.primary,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 18),
                  SizedBox(width: 4),
                  Text('Ajouter'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        if (provider.todayMeals.isEmpty)
          _buildEmptyMealsView()
        else
          _buildMealsList(provider.todayMeals),
      ],
    );
  }

  Widget _buildEmptyMealsView() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary.withOpacity(0.1), AppColors.secondary.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Aucun repas ajouté aujourd\'hui',
              style: TextStyle(
                color: AppColors.darkGrey,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Commencez par ajouter votre premier repas !',
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ModernButton(
              onPressed: _addMeal,
              gradient: AppColors.primaryGradient,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: AppColors.white),
                  SizedBox(width: 8),
                  Text('Ajouter un repas'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealsList(List<Meal> meals) {
    // Grouper les repas par type
    final groupedMeals = <String, List<Meal>>{};
    for (final meal in meals) {
      if (!groupedMeals.containsKey(meal.type)) {
        groupedMeals[meal.type] = [];
      }
      groupedMeals[meal.type]!.add(meal);
    }

    return AnimationLimiter(
      child: Column(
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 400),
          childAnimationBuilder: (widget) => SlideAnimation(
            horizontalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: groupedMeals.entries.map((entry) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: ModernCard(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          entry.value[0].typeIcon,
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        entry.value[0].typeName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGrey,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary.withOpacity(0.1), AppColors.secondary.withOpacity(0.1)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${entry.value[0].totalCalories.round()} kcal',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: entry.value[0].foods.map((food) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${food.name} (${food.quantity}g)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.darkGrey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadowColor,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                '${food.totalCalories.round()} kcal',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _addMeal() async {
    final result = await Navigator.push<Meal>(
      context,
      MaterialPageRoute(builder: (context) => const AddMealPage()),
    );

    if (result != null && mounted) {
      final success = await context.read<DashboardProvider>().addMeal(result);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Repas ajouté avec succès !')),
        );


      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'ajout du repas')),
        );
      }
    }
  }


  void _navigateToHydrationTracker() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HydrationTrackerPage()),
    );
  }

  void _navigateToStepsTracker() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StepsTrackerPage()),
    );
  }

  void _navigateToMapTracker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MapTrackerPage(),
      ),
    );
  }

  Widget _buildActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activité Physique',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _navigateToStepsTracker,
                child: ModernCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.accent.withOpacity(0.2), AppColors.accent.withOpacity(0.1)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.directions_walk,
                            color: AppColors.accent,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Compteur de Pas',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Suivez vos pas quotidiens',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: _navigateToMapTracker,
                child: ModernCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primary.withOpacity(0.2), AppColors.primary.withOpacity(0.1)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.map,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tracker Parcours',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tracez votre marche et convertissez en pas',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
  Widget _buildMacroIndicator(String label, double progress, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                backgroundColor: AppColors.lightGrey.withOpacity(0.3),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toInt()}%',
          style: TextStyle(
            fontSize: 10,
            color: AppColors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showCalorieDetails(BuildContext context, dynamic progress, dynamic profile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ModernCard(
        borderRadius: 20,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Détails Calories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGrey,
                ),
              ),
              const SizedBox(height: 20),
              ModernProgressIndicator(
                progress: progress.caloriesConsumed / profile.calorieObjectif,
                size: 120,
                color: AppColors.primary,
                label: 'Calories',
              ),
              const SizedBox(height: 16),
              Text(
                '${progress.caloriesConsumed.round()} / ${profile.calorieObjectif.round()} kcal',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.darkGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMacroDetails(BuildContext context, dynamic progress, dynamic profile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ModernCard(
        borderRadius: 20,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Détails Macros',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGrey,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMacroDetail('Protéines', progress.proteinsConsumed, profile.proteineObjectif, AppColors.primary),
                  _buildMacroDetail('Glucides', progress.carbsConsumed, profile.glucideObjectif, AppColors.secondary),
                  _buildMacroDetail('Lipides', progress.fatsConsumed, profile.lipideObjectif, AppColors.accent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroDetail(String label, double consumed, double objectif, Color color) {
    return Column(
      children: [
        ModernProgressIndicator(
          progress: consumed / objectif,
          size: 60,
          color: color,
          label: label.substring(0, 1),
        ),
        const SizedBox(height: 8),
        Text(
          '${consumed.round()}/${objectif.round()}g',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }