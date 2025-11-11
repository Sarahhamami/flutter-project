import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:clipboard/clipboard.dart';
import '../models/recipe.dart';
import '../models/meal.dart';
import '../models/food_item.dart';
import '../providers/recipe_provider.dart';
import '../providers/dashboard_provider.dart';
import '../pages/add_meal_page.dart';
import '../services/favorite_service.dart';
import '../themes/app_theme.dart';

class RecipeDetailDialog extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailDialog({
    super.key,
    required this.recipe,
  });

  @override
  State<RecipeDetailDialog> createState() => _RecipeDetailDialogState();
}

class _RecipeDetailDialogState extends State<RecipeDetailDialog> {
  final FavoriteService _favoriteService = FavoriteService();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFav = await _favoriteService.isFavorite(widget.recipe.id);
    if (mounted) {
      setState(() => _isFavorite = isFav);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with image and actions
            _buildHeader(),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and badges
                    _buildTitleSection(),

                    const SizedBox(height: 16),

                    // Nutrition info
                    _buildNutritionInfo(),

                    const SizedBox(height: 16),

                    // Ingredients
                    _buildIngredientsSection(),

                    const SizedBox(height: 16),

                    // Instructions
                    _buildInstructionsSection(),

                    const SizedBox(height: 16),

                    // Shopping list
                    _buildShoppingListSection(),

                    const SizedBox(height: 16),

                    // Actions
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        // Recipe image
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            image: DecorationImage(
              image: NetworkImage(widget.recipe.thumbnailUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Gradient overlay
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),

        // Close button
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withOpacity(0.5),
            ),
          ),
        ),

        // Favorite button
        Positioned(
          top: 8,
          left: 8,
          child: IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: _toggleFavorite,
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withOpacity(0.5),
            ),
          ),
        ),

        // YouTube button
        if (widget.recipe.youtubeUrl != null)
          Positioned(
            bottom: 8,
            right: 8,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow, size: 16),
              label: const Text('YouTube'),
              onPressed: _openYouTube,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.recipe.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.recipe.category,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.recipe.area,
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (widget.recipe.isHealthy) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.eco, color: Colors.green, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'Healthy',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildNutritionInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations nutritionnelles (estimées)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNutrientItem(
                  '${widget.recipe.estimatedCalories.round()}',
                  'Calories',
                  'kcal',
                  AppColors.primary,
                ),
                _buildNutrientItem(
                  '${widget.recipe.estimatedProteins.round()}',
                  'Protéines',
                  'g',
                  Colors.blue,
                ),
                _buildNutrientItem(
                  '${widget.recipe.estimatedCarbs.round()}',
                  'Glucides',
                  'g',
                  Colors.orange,
                ),
                _buildNutrientItem(
                  '${widget.recipe.estimatedFats.round()}',
                  'Lipides',
                  'g',
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientItem(String value, String label, String unit, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: 12,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingrédients',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...widget.recipe.ingredients.map((ingredient) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              const Icon(Icons.fiber_manual_record, size: 8, color: AppColors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${ingredient.measure} ${ingredient.name}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildInstructionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Instructions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.recipe.instructions,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildShoppingListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Liste de courses',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copier'),
              onPressed: _copyShoppingList,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.recipe.shoppingList.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '• $item',
                style: const TextStyle(fontSize: 14),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Liste courses'),
            onPressed: _copyShoppingList,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.restaurant),
            label: const Text('Ajouter au repas'),
            onPressed: _addToMeal,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _toggleFavorite() async {
    final success = await _favoriteService.toggleFavorite(widget.recipe);

    if (success && mounted) {
      setState(() => _isFavorite = !_isFavorite);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite ? 'Ajouté aux favoris' : 'Retiré des favoris',
          ),
        ),
      );
    }
  }

  Future<void> _openYouTube() async {
    if (widget.recipe.youtubeUrl != null && widget.recipe.youtubeUrl!.isNotEmpty) {
      final url = Uri.parse(widget.recipe.youtubeUrl!);
      try {
        // Direct launch without canLaunchUrl check to avoid Android package visibility issues
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } catch (e) {
        // If external fails, try in-app web view
        try {
          await launchUrl(url, mode: LaunchMode.inAppWebView);
        } catch (e2) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Impossible d\'ouvrir YouTube')),
            );
          }
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucun lien YouTube disponible')),
        );
      }
    }
  }

  void _copyShoppingList() {
    // Copy shopping list to clipboard
    final shoppingList = widget.recipe.shoppingList.join('\n');
    FlutterClipboard.copy(shoppingList).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Liste de courses copiée')),
      );
    });
  }

  Future<void> _addToMeal() async {
    // Convert recipe to meal format and add directly
    if (mounted) {
      Navigator.of(context).pop(); // Close detail dialog

      try {
        // Convert recipe to meal format
        final foods = widget.recipe.ingredients.map((ingredient) {
          return FoodItem(
            fiber: 0,
            sugars: 0,
            sodium: 0,
            cholesterol: 0,
            id: DateTime.now().millisecondsSinceEpoch.toString() + ingredient.name,
            name: ingredient.name,
            category: 'recipe',
            calories: ingredient.estimateCalories(),
            proteins: 0,
            carbs: 0,
            fats: 0,
            quantity: 100,
          );
        }).toList();

        final meal = Meal(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: 'lunch', // Default to lunch
          date: DateTime.now(),
          foods: foods.cast<FoodItem>(),
        );

        // Add to dashboard
        final success = await context.read<DashboardProvider>().addMeal(meal);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Recette "${widget.recipe.name}" ajoutée avec succès !'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('Failed to add meal');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'ajout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}