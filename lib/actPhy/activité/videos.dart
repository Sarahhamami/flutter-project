import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'mockvideos.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class VideosScreen extends StatefulWidget {
  const VideosScreen({Key? key}) : super(key: key);

  @override
  _VideosScreenState createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = ['All', 'Yoga', 'HIIT', 'Running', 'Cycling', 'Swimming'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, String>> _getFilteredVideos(String category) {
    if (category == 'All') return fitnessVideos;
    return fitnessVideos.where((video) {
      final title = video['title']!.toLowerCase();
      return title.contains(category.toLowerCase());
    }).toList();
  }

  Future<void> _launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // If direct launch fails, try to handle YouTube links specially
        if (url.contains('youtube.com') || url.contains('youtu.be')) {
          final videoId = RegExp(
            r'(?:youtube\.com/(?:[^/]+/.+/|(?:v|e(?:mbed)?)/|.*[?&]v=)|youtu\.be/)([^"&?\/ ]{11})',
          ).firstMatch(url)?.group(1) ?? '';
          
          if (videoId.isNotEmpty) {
            final youtubeAppUrl = 'vnd.youtube:$videoId';
            final youtubeWebUrl = 'https://www.youtube.com/watch?v=$videoId';
            
            try {
              await launchUrl(
                Uri.parse(youtubeAppUrl),
                mode: LaunchMode.externalApplication,
              );
            } catch (_) {
              // If YouTube app is not installed, open in browser
              await launchUrl(
                Uri.parse(youtubeWebUrl),
                mode: LaunchMode.externalApplication,
              );
            }
          }
        } else {
          // For non-YouTube URLs, try to open in browser
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        }
      }
    } catch (e) {
      debugPrint('Could not launch $url: $e');
      // As a last resort, try to launch with the string method
      try {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        debugPrint('Failed to launch URL: $e');
        // Show an error message to the user
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open the link: $url')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Videos', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          indicatorWeight: 3.0,
          tabs: _categories.map((category) => Tab(text: category)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _categories.map((category) {
          final videos = _getFilteredVideos(category);
          return _buildVideoGrid(videos);
        }).toList(),
      ),
    );
  }

  Widget _buildVideoGrid(List<Map<String, String>> videos) {
    return videos.isEmpty
        ? const Center(child: Text('No videos found in this category'))
        : GridView.builder(
            padding: const EdgeInsets.all(12.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
            ),
            itemCount: videos.length,
            itemBuilder: (context, index) => _VideoCard(
              title: videos[index]['title']!,
              channel: videos[index]['channel']!,
              thumbnail: videos[index]['thumbnail']!,
              onTap: () => _launchURL(videos[index]['url']!),
            ),
          );
  }
}

class _VideoCard extends StatelessWidget {
  final String title;
  final String channel;
  final String thumbnail;
  final VoidCallback onTap;

  const _VideoCard({
    Key? key,
    required this.title,
    required this.channel,
    required this.thumbnail,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with play button overlay
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
                    child: CachedNetworkImage(
                      imageUrl: thumbnail,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                  const Center(
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      radius: 24,
                      child: Icon(Icons.play_arrow, color: Colors.white, size: 32),
                    ),
                  ),
                ],
              ),
            ),
            // Video info
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    channel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
