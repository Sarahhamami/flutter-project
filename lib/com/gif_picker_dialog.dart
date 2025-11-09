import 'package:flutter/material.dart';
import '../services/gif_service.dart';

// Color palette
const Color kPrimary = Color(0xFF01BCE5);
const Color kAccent = Color(0xFF08CAC2);
const Color kDark = Color(0xFF52575A);
const Color kLightGrey = Color(0xFFF8F9FA);

class GifPickerDialog extends StatefulWidget {
  final Function(GifData) onGifSelected;

  const GifPickerDialog({
    super.key,
    required this.onGifSelected,
  });

  @override
  State<GifPickerDialog> createState() => _GifPickerDialogState();
}

class _GifPickerDialogState extends State<GifPickerDialog> {
  final GifService _gifService = GifService();
  final TextEditingController _searchController = TextEditingController();

  List<GifData> _gifs = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTrendingGifs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTrendingGifs() async {
    setState(() {
      _isLoading = true;
      _currentQuery = '';
    });

    try {
      final gifs = await _gifService.getTrendingGifs(limit: 30);
      setState(() {
        _gifs = gifs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load GIFs: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _searchGifs(String query) async {
    if (query.trim().isEmpty) {
      _loadTrendingGifs();
      return;
    }

    setState(() {
      _isSearching = true;
      _currentQuery = query;
    });

    try {
      final gifs = await _gifService.searchGifs(query, limit: 30);
      setState(() {
        _gifs = gifs;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to search GIFs: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.gif,
                    color: kPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Choose a GIF',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kDark,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: kDark.withOpacity(0.7)),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Search bar
            Container(
              decoration: BoxDecoration(
                color: kLightGrey,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: kPrimary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search GIFs...',
                  prefixIcon: Icon(Icons.search, color: kPrimary.withOpacity(0.7)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onSubmitted: _searchGifs,
              ),
            ),

            const SizedBox(height: 16),

            // Trending button
            if (_currentQuery.isNotEmpty)
              Container(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loadTrendingGifs,
                  icon: Icon(Icons.trending_up, color: kPrimary),
                  label: Text(
                    'Show Trending',
                    style: TextStyle(color: kPrimary),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary.withOpacity(0.1),
                    foregroundColor: kPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // GIF Grid
            Expanded(
              child: _isLoading || _isSearching
                  ? const Center(
                      child: CircularProgressIndicator(color: kPrimary),
                    )
                  : _gifs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.gif_box_outlined,
                                size: 48,
                                color: kDark.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No GIFs found',
                                style: TextStyle(
                                  color: kDark.withOpacity(0.7),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _gifs.length,
                          itemBuilder: (context, index) {
                            final gif = _gifs[index];
                            return GestureDetector(
                              onTap: () {
                                widget.onGifSelected(gif);
                                Navigator.pop(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: kPrimary.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: Image.network(
                                    gif.previewUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: kLightGrey,
                                        child: const Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: kPrimary,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: kLightGrey,
                                        child: const Icon(
                                          Icons.error_outline,
                                          color: Colors.red,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}