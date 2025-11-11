import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/favorite_service.dart';
import '../widgets/recipe_card.dart';
import '../widgets/recipe_detail_dialog.dart';
import '../themes/app_theme.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> with SingleTickerProviderStateMixin {
  final FavoriteService _favoriteService = FavoriteService();

  List<Recipe> _favorites = [];
  List<Recipe> _filteredFavorites = [];
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'all'; // 'all', 'healthy', 'recent'

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedFilter = ['all', 'healthy', 'recent'][_tabController.index];
        _filterFavorites();
      });
    }
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);

    try {
      _favorites = await _favoriteService.getFavoriteRecipes();
      _filterFavorites();
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterFavorites() {
    switch (_selectedFilter) {
      case 'healthy':
        _filteredFavorites = _favorites.where((recipe) => recipe.isHealthy).toList();
        break;
      case 'recent':
        // Get recent favorites (would need to implement this in FavoriteService)
        _filteredFavorites = _favorites.take(10).toList(); // Simplified
        break;
      default:
        _filteredFavorites = _favorites;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes recettes favorites'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Toutes'),
            Tab(text: 'Healthy'),
            Tab(text: 'Récentes'),
          ],
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.7),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
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
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFavorites,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_filteredFavorites.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: _filteredFavorites.length,
        itemBuilder: (context, index) {
          final recipe = _filteredFavorites[index];
          return RecipeCard(
            recipe: recipe,
            onTap: () => _showRecipeDetails(recipe),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    String title;
    String message;
    IconData icon;

    switch (_selectedFilter) {
      case 'healthy':
        title = 'Aucune recette healthy';
        message = 'Vous n\'avez pas encore de recettes healthy en favoris.';
        icon = Icons.eco;
        break;
      case 'recent':
        title = 'Aucune recette récente';
        message = 'Vous n\'avez pas ajouté de nouvelles recettes récemment.';
        icon = Icons.access_time;
        break;
      default:
        title = 'Aucun favori';
        message = 'Vous n\'avez pas encore ajouté de recettes à vos favoris.\n\nParcourez les recettes et appuyez sur ♥ pour les ajouter !';
        icon = Icons.favorite_border;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (_selectedFilter == 'all' && _favorites.isEmpty)
              ElevatedButton.icon(
                icon: const Icon(Icons.restaurant_menu),
                label: const Text('Découvrir des recettes'),
                onPressed: () => Navigator.of(context).pushNamed('/recipes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showRecipeDetails(Recipe recipe) {
    showDialog(
      context: context,
      builder: (context) => RecipeDetailDialog(recipe: recipe),
    ).then((_) {
      // Refresh favorites after dialog closes (in case recipe was removed from favorites)
      _loadFavorites();
    });
  }
}