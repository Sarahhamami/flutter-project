import 'package:flutter/material.dart';
import '../models/article.dart';
import 'package:url_launcher/url_launcher.dart';
import 'available_doctor.dart';

// Robust URL launcher helper: normalizes URL and shows a SnackBar on failure.
Future<void> _openUrl(BuildContext context, String url) async {
  if (url.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No URL available')));
    return;
  }

  var finalUrl = url.trim();
  if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
    finalUrl = 'https://$finalUrl';
  }

  final uri = Uri.tryParse(finalUrl);
  if (uri == null) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid URL')));
    return;
  }

  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open the link')));
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error opening link: $e')));
  }
}

class ArticleDetail extends StatelessWidget {
  final Article article;
  const ArticleDetail({super.key, required this.article});

  String _formatPublishedDate(String raw) {
    if (raw.isEmpty) return '';
    // Try parsing common ISO-like formats (yyyy-MM-dd or full ISO)
    DateTime? dt;
    try {
      dt = DateTime.tryParse(raw);
    } catch (_) {
      dt = null;
    }

    if (dt == null) {
      // Try to extract yyyy-MM-dd manually
      final match = RegExp(r"(\d{4}-\d{2}-\d{2})").firstMatch(raw);
      if (match != null) dt = DateTime.tryParse(match.group(0)!);
    }

    if (dt == null) return raw; // fallback to raw string

    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';

    // For older dates show '2 May 2025' style
    final months = <String>['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Cover image with overlays
              SizedBox(
                height: 340,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: article.image.isNotEmpty && article.image.startsWith('http')
                          ? Image.network(article.image, fit: BoxFit.cover)
                          : article.image.isNotEmpty
                              ? Image.asset(article.image, fit: BoxFit.cover)
                              : Container(color: Colors.grey.shade200),
                    ),
                    // Top left back button
                    Positioned(
                      top: 12,
                      left: 12,
                      child: ClipOval(
                        child: Material(
                          color: Colors.white.withOpacity(0.85),
                          child: InkWell(
                            splashColor: Colors.black12,
                            onTap: () => Navigator.of(context).pop(),
                            child: const SizedBox(width: 44, height: 44, child: Icon(Icons.arrow_back, color: Colors.black)),
                          ),
                        ),
                      ),
                    ),
                    // Top right menu
                    Positioned(
                      top: 12,
                      right: 12,
                      child: ClipOval(
                        child: Material(
                          color: Colors.white.withOpacity(0.85),
                          child: InkWell(
                            onTap: () {},
                            child: const SizedBox(width: 44, height: 44, child: Icon(Icons.more_vert, color: Colors.black)),
                          ),
                        ),
                      ),
                    ),
                    // Tag pill
                    Positioned(
                      left: 16,
                      bottom: 110,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(article.sourceName.isNotEmpty ? article.sourceName : 'General', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black87)),
                      ),
                    ),
                    // Title overlay near bottom
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 24,
                      child: Text(
                        article.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              // White rounded content panel overlapping the image
              Container(
                width: double.infinity,
                transform: Matrix4.translationValues(0, -40, 0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Author chip and meta
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              article.sourceName.isNotEmpty ? article.sourceName[0] : 'A',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(article.sourceName, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(
                                  _formatPublishedDate(article.publishedAt.isNotEmpty ? article.publishedAt : ''),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          // view count placeholder
                          Row(
                            children: [
                              const Icon(Icons.remove_red_eye_outlined, size: 18, color: Colors.black45),
                              const SizedBox(width: 6),
                              Text('188k', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Full description/content
                      if (article.description.isNotEmpty) ...[
                        SelectableText(article.description, style: Theme.of(context).textTheme.bodyMedium, toolbarOptions: const ToolbarOptions(copy: true, selectAll: true)),
                        const SizedBox(height: 12),
                      ],
                      if (article.content.isNotEmpty && article.content != article.description) ...[
                        SelectableText(article.content, style: Theme.of(context).textTheme.bodyMedium, toolbarOptions: const ToolbarOptions(copy: true, selectAll: true)),
                        const SizedBox(height: 12),
                      ],

                      const SizedBox(height: 8),

                      // Action pills (centered)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF01BCE5),
                                  shape: const StadiumBorder(),
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                ),
                                onPressed: () => _openUrl(context, article.url),
                                icon: const Icon(Icons.thumb_up, size: 18),
                                label: const Text('40,6k'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF01BCE5),
                                  shape: const StadiumBorder(),
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const AvailableDoctorPage()),
                                  );
                                },
                                icon: const Icon(Icons.comment, size: 18),
                                label: const Text('10,2k'),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Row with Read original and Find Doctor (full-width)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _openUrl(context, article.url),
                              child: const Text('Read original'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AvailableDoctorPage(),
                                  ),
                                );
                              },
                              child: const Text('Find Doctor'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
