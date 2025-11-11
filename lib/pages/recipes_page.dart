import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../providers/dashboard_provider.dart';
import '../models/recipe.dart';
import '../widgets/recipe_card.dart';
import '../widgets/recipe_detail_dialog.dart';
import '../themes/app_theme.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'goal'; // 'goal', 'healthy', 'favorites', 'recent'

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final recipeProvider = context.read<RecipeProvider>();
    final dashboardProvider = context.read<DashboardProvider>();

    // Set goal from nutrition profile
    if (dashboardProvider.nutritionProfile != null) {
      recipeProvider.setGoal(dashboardProvider.nutritionProfile!.objectif);
    }

    // Initialize in next frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      recipeProvider.initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recettes'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: _getRandomRecipe,
            tooltip: 'Recette aléatoire',
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Consumer2<RecipeProvider, DashboardProvider>(
          builder: (context, recipeProvider, dashboardProvider, child) {
            return Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher une recette...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),

                // Filter tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildFilterChip('Objectif', 'goal'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Healthy', 'healthy'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Favoris', 'favorites'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Récent', 'recent'),
                    ],
                  ),
                ),

                // Current goal indicator
                if (dashboardProvider.nutritionProfile != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.flag, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Objectif: ${_getGoalText(dashboardProvider.nutritionProfile!.objectif)}',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Content
                Expanded(
                  child: _buildContent(recipeProvider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String filter) {
    final isSelected = _selectedFilter == filter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedFilter = filter);
          _loadFilteredRecipes();
        }
      },
      backgroundColor: AppColors.white,
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildContent(RecipeProvider recipeProvider) {
    if (recipeProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (recipeProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              recipeProvider.error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFilteredRecipes,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    final recipes = _getCurrentRecipes(recipeProvider);

    if (recipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedFilter == 'favorites' ? Icons.favorite_border : Icons.restaurant,
              size: 48,
              color: AppColors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyMessage(),
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFilteredRecipes,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return RecipeCard(
            recipe: recipe,
            onTap: () => _showRecipeDetail(recipe),
          );
        },
      ),
    );
  }

  List<Recipe> _getCurrentRecipes(RecipeProvider recipeProvider) {
    switch (_selectedFilter) {
      case 'favorites':
        return recipeProvider.favoriteRecipes;
      case 'recent':
        return recipeProvider.recentRecipes;
      default:
        return recipeProvider.recipes;
    }
  }

  String _getEmptyMessage() {
    switch (_selectedFilter) {
      case 'favorites':
        return 'Aucune recette favorite\nAjoutez des recettes à vos favoris !';
      case 'recent':
        return 'Aucune recette récente\nDécouvrez de nouvelles recettes !';
      default:
        return 'Aucune recette trouvée\nEssayez une autre recherche';
    }
  }

  void _onSearchChanged(String query) {
    if (query.isNotEmpty) {
      context.read<RecipeProvider>().searchRecipes(query);
    } else {
      _loadFilteredRecipes();
    }
  }

  Future<void> _loadFilteredRecipes() async {
    final recipeProvider = context.read<RecipeProvider>();

    switch (_selectedFilter) {
      case 'goal':
        await recipeProvider.loadRecipesForGoal();
        break;
      case 'healthy':
        await recipeProvider.loadHealthyRecipes();
        break;
      case 'favorites':
        await recipeProvider.loadFavoriteRecipes();
        break;
      case 'recent':
        await recipeProvider.loadRecentRecipes();
        break;
    }
  }

  Future<void> _getRandomRecipe() async {
    final recipe = await context.read<RecipeProvider>().getRandomRecipe();
    if (recipe != null && mounted) {
      _showRecipeDetail(recipe);
    }
  }

  void _showRecipeDetail(Recipe recipe) {
    showDialog(
      context: context,
      builder: (context) => RecipeDetailDialog(recipe: recipe),
    );
  }

  String _getGoalText(String goal) {
    switch (goal) {
      case 'perte':
        return 'Perte de poids';
      case 'prise_masse':
        return 'Prise de masse';
      case 'maintien':
      default:
        return 'Maintien';
    }
  }
}