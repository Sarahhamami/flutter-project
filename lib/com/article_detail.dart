import 'package:flutter/material.dart';
import '../models/article.dart';
import 'package:url_launcher/url_launcher.dart';
import 'available_doctor.dart';

// Color palette
const Color kWhite = Colors.white;
const Color kPrimary = Color(0xFF01BCE5);
const Color kDark = Color(0xFF52575A);
const Color kAccent = Color(0xFF08CAC2);

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
      backgroundColor: kWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Modern cover image with enhanced overlays
              SizedBox(
                height: 380,
                child: Stack(
                  children: [
                    // Main image with gradient overlay
                    Positioned.fill(
                      child: Stack(
                        children: [
                          article.image.isNotEmpty && article.image.startsWith('http')
                              ? Image.network(article.image, fit: BoxFit.cover)
                              : article.image.isNotEmpty
                                  ? Image.asset(article.image, fit: BoxFit.cover)
                                  : Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            kPrimary.withOpacity(0.8),
                                            kAccent.withOpacity(0.6),
                                          ],
                                        ),
                                      ),
                                    ),
                          // Gradient overlay for better text readability
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.3),
                                  Colors.black.withOpacity(0.7),
                                ],
                                stops: const [0.0, 0.6, 1.0],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Modern back button with enhanced styling
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          color: kWhite.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: kDark.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => Navigator.of(context).pop(),
                            child: const Padding(
                              padding: EdgeInsets.all(12),
                              child: Icon(Icons.arrow_back_ios_new, color: kDark, size: 20),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Modern menu button with enhanced styling
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          color: kWhite.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: kDark.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {},
                            child: const Padding(
                              padding: EdgeInsets.all(12),
                              child: Icon(Icons.more_horiz, color: kDark, size: 20),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Modern source tag with gradient
                    Positioned(
                      left: 20,
                      bottom: 120,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              kPrimary.withOpacity(0.9),
                              kAccent.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: kPrimary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.article_outlined,
                              color: kWhite,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              article.sourceName.isNotEmpty ? article.sourceName : 'General',
                              style: TextStyle(
                                color: kWhite,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Enhanced title with better typography
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 24,
                      child: Text(
                        article.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: kWhite,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Modern content panel with enhanced styling
              Container(
                width: double.infinity,
                transform: Matrix4.translationValues(0, -50, 0),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kDark.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Modern author section with enhanced styling
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              kPrimary.withOpacity(0.05),
                              kAccent.withOpacity(0.03),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: kPrimary.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [kPrimary, kAccent],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: kPrimary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.transparent,
                                child: Text(
                                  article.sourceName.isNotEmpty ? article.sourceName[0].toUpperCase() : 'A',
                                  style: const TextStyle(
                                    color: kWhite,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    article.sourceName,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: kDark,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        color: kDark.withOpacity(0.6),
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatPublishedDate(article.publishedAt.isNotEmpty ? article.publishedAt : ''),
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: kDark.withOpacity(0.7),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Modern view count with enhanced styling
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: kPrimary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.visibility_outlined,
                                    size: 16,
                                    color: kPrimary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '188k',
                                    style: TextStyle(
                                      color: kPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Modern content section with enhanced typography
                      if (article.description.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: kWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: kPrimary.withOpacity(0.1),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: kDark.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: SelectableText(
                            article.description,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: kDark,
                              height: 1.6,
                              fontWeight: FontWeight.w400,
                            ),
                            toolbarOptions: const ToolbarOptions(copy: true, selectAll: true),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (article.content.isNotEmpty && article.content != article.description) ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: kWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: kPrimary.withOpacity(0.1),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: kDark.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: SelectableText(
                            article.content,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: kDark,
                              height: 1.6,
                              fontWeight: FontWeight.w400,
                            ),
                            toolbarOptions: const ToolbarOptions(copy: true, selectAll: true),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Clean, responsive action section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: kDark.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Engagement metrics - clean horizontal layout
                            Row(
                              children: [
                                // Likes metric
                                Expanded(
                                  child: _EngagementMetric(
                                    icon: Icons.thumb_up_outlined,
                                    count: '40.6k',
                                    label: 'Likes',
                                    onTap: () => _openUrl(context, article.url),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Comments metric
                                Expanded(
                                  child: _EngagementMetric(
                                    icon: Icons.comment_outlined,
                                    count: '10.2k',
                                    label: 'Comments',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const AvailableDoctorPage()),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Read original button - clean and simple
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimary,
                                  foregroundColor: kWhite,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                ),
                                onPressed: () => _openUrl(context, article.url),
                                icon: const Icon(Icons.open_in_new, size: 18),
                                label: const Text(
                                  'Read Original Article',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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

// Responsive engagement metric widget
class _EngagementMetric extends StatelessWidget {
  final IconData icon;
  final String count;
  final String label;
  final VoidCallback onTap;

  const _EngagementMetric({
    required this.icon,
    required this.count,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: kDark.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: kDark.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Icon(
                icon,
                color: kPrimary,
                size: 20,
              ),
              const SizedBox(height: 8),
              // Count - responsive text that adapts to number size
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  count,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: kDark,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              // Label
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: kDark.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
