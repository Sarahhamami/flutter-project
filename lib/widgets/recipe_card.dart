import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import '../services/favorite_service.dart';
import '../themes/app_theme.dart';

class RecipeCard extends StatefulWidget {
  final Recipe recipe;
  final VoidCallback? onTap;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.onTap,
  });

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // Image
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      image: DecorationImage(
                        image: NetworkImage(widget.recipe.thumbnailUrl),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          // Fallback for broken images
                        },
                      ),
                    ),
                  ),

                  // Favorite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : AppColors.grey,
                          size: 20,
                        ),
                        onPressed: _toggleFavorite,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ),
                  ),

                  // Healthy badge
                  if (widget.recipe.isHealthy)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.eco,
                              color: Colors.white,
                              size: 12,
                            ),
                            SizedBox(width: 2),
                            Text(
                              'Healthy',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Recipe info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      widget.recipe.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Category and area
                    Text(
                      '${widget.recipe.category} • ${widget.recipe.area}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Calories and macros
                    Row(
                      children: [
                        // Calories
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.recipe.estimatedCalories.round()} cal',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                '${widget.recipe.estimatedProteins.round()}g protéines',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Prep time indicator (estimated)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _getPrepTimeIndicator(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
   
                            // YouTube button
                            if (widget.recipe.youtubeUrl != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.play_arrow, color: Colors.white, size: 16),
                                  onPressed: _openYouTube,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 28,
                                    minHeight: 28,
                                  ),
                                ),
                              ),
                            ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPrepTimeIndicator() {
    final ingredientCount = widget.recipe.ingredients.length;
    if (ingredientCount <= 5) return '< 30min';
    if (ingredientCount <= 10) return '30-60min';
    return '> 60min';
  }

  Future<void> _toggleFavorite() async {
    final success = await _favoriteService.toggleFavorite(widget.recipe);

    if (success && mounted) {
      setState(() => _isFavorite = !_isFavorite);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite
                ? 'Ajouté aux favoris'
                : 'Retiré des favoris',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

Future<void> _openYouTube() async {
  final urlString = widget.recipe.youtubeUrl;
  if (urlString == null || urlString.isEmpty) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune vidéo YouTube disponible')),
      );
    }
    return;
  }

  Uri? url = Uri.tryParse(urlString);

  if (url == null || (!url.isAbsolute && !urlString.contains('youtu'))) {
    // Fallback: construct YouTube URL if needed
    if (urlString.contains('v=')) {
      final videoId = urlString.split('v=').last.split('&').first;
      url = Uri.tryParse('https://www.youtube.com/watch?v=$videoId');
    } else if (urlString.contains('youtu.be/')) {
      final videoId = urlString.split('youtu.be/').last.split('?').first;
      url = Uri.tryParse('https://www.youtube.com/watch?v=$videoId');
    }
  }

  if (url != null) {
    // Direct launch without canLaunchUrl check to avoid Android package visibility issues
    try {
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
  } else if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('URL YouTube invalide')),
    );
  }
}
}