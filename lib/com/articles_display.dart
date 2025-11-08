import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/news_service.dart';
import 'article_detail.dart';
import 'forum_page.dart';
import 'friends_list_page.dart';
import 'navbar.dart';

// Palette
const Color kWhite = Colors.white;
const Color kPrimary = Color(0xFF01BCE5);
const Color kDark = Color(0xFF52575A);
const Color kAccent = Color(0xFF08CAC2);

class ArticlesDisplay extends StatefulWidget {
  const ArticlesDisplay({super.key});

  @override
  State<ArticlesDisplay> createState() => _ArticlesDisplayState();
}

class _ArticlesDisplayState extends State<ArticlesDisplay> {
  final NewsService _newsService = NewsService();
  late Future<List<Article>> _futureNews;
  late PageController _pageController;
  int _currentCarouselPage = 0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _futureNews = _newsService.fetchNews();
    _pageController = PageController(viewportFraction: 0.92);
    _pageController.addListener(() {
      final p = (_pageController.page ?? 0).round();
      if (p != _currentCarouselPage) {
        setState(() {
          _currentCarouselPage = p;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Handle navigation for different tabs
    switch (index) {
      case 0: // Home - already showing
        break;
      case 1: // Search
        // Add search functionality here if needed
        break;
      case 2: // Chat
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FriendsListPage()),
        );
        // Reset to home tab after navigation
        setState(() {
          _selectedIndex = 0;
        });
        break;
      case 3: // Forum
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ForumPage()),
        );
        // Reset to home tab after navigation
        setState(() {
          _selectedIndex = 0;
        });
        break;
      case 4: // Profile
        // Add profile functionality here if needed
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
  // Reserve a small buffer for system inset; the BottomNavigationBar will be wrapped in a SafeArea
  final double listBottomPadding = MediaQuery.of(context).padding.bottom + 8.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light grey background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modern Header with Gradient
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      kPrimary.withOpacity(0.1),
                      kAccent.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: kPrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'HealthTracker News',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: kPrimary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Welcome back, Jeniffer',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: kDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Stay updated with the latest health news',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: kDark.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kPrimary.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage('assets/images/splash.png'),
                      ),
                    ),
                  ],
                ),
              ),

                      const SizedBox(height: 0),

              // Modern Tabs with Glass Effect
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: kDark.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _TabButton(
                      label: 'Feeds', 
                      selected: true,
                      onTap: () {},
                    ),
                    _TabButton(
                      label: 'Forum',
                      selected: false,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ForumPage()),
                        );
                      },
                    ),
                    _TabButton(
                      label: 'Following',
                      selected: false,
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // FutureBuilder for API data
              Expanded(
                child: FutureBuilder<List<Article>>(
                  future: _futureNews,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(color: kPrimary));
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text('Erreur : ${snapshot.error}',
                              style: const TextStyle(color: Colors.red)));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('Aucun article trouvé',
                              style: TextStyle(color: kDark)));
                    }

                    final articles = snapshot.data!;
                    //atticle horizantal there's the error here 
                    return ListView(
                      padding: EdgeInsets.only(bottom: listBottomPadding),
                      children: [
                        // Horizontal featured carousel (first 5 articles)
                        SizedBox(
                          height: 240,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 220,
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount:
                                      articles.length > 5 ? 5 : articles.length,
                                  padEnds: false,
                                  itemBuilder: (context, idx) {
                                    final item = articles[idx];
                                    return Center(
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(16),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => ArticleDetail(
                                                    article: Article(
                                                      id: item.id,
                                                      title: item.title,
                                                      description: item.description,
                                                      content: item.content,
                                                      url: item.url,
                                                      image: item.image,
                                                      publishedAt: item.publishedAt,
                                                      lang: item.lang,
                                                      sourceName: item.sourceName,
                                                      sourceUrl: item.sourceUrl,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                            child: _CategoryCard(
                                              title: item.title,
                                              image: item.image.isNotEmpty
                                                  ? item.image
                                                  : 'assets/images/splash.png',
                                              tags: [item.sourceName, 'Santé'],
                                            ),
                                          ),
                                        );
                                  },
                                ),
                              ),
                              const SizedBox(height: 0),
                              // Dots indicator
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                    (articles.length > 5 ? 5 : articles.length),
                                    (i) => AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 6),
                                          width: _currentCarouselPage == i ? 12 : 8,
                                          height: _currentCarouselPage == i ? 12 : 8,
                                          decoration: BoxDecoration(
                                            color: _currentCarouselPage == i
                                                ? kPrimary
                                                : kPrimary.withOpacity(0.35),
                                            shape: BoxShape.circle,
                                          ),
                                        )),
                              )
                            ],
                          ),
                        ),

                        const SizedBox(height: 0),

                        // Modern Section Header
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                kPrimary.withOpacity(0.05),
                                kAccent.withOpacity(0.03),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: kPrimary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.auto_awesome,
                                      color: kPrimary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Just For You',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: kDark,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: kPrimary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: TextButton(
                                  onPressed: () {},
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'See More',
                                        style: TextStyle(
                                          color: kPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: kPrimary,
                                        size: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 0),

                        // Vertical articles (list)
                        Column(
                          children: List.generate(articles.length, (i) {
                            final article = articles[i];
                            return Padding(
              padding:
                const EdgeInsets.only(bottom: 0.0),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ArticleDetail(
                                        article: Article(
                                          id: article.id,
                                          title: article.title,
                                          description: article.description,
                                          content: article.content,
                                          url: article.url,
                                          image: article.image,
                                          publishedAt: article.publishedAt,
                                          lang: article.lang,
                                          sourceName: article.sourceName,
                                          sourceUrl: article.sourceUrl,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: _VerticalArticleCard(
                                  title: article.title,
                                  subtitle:
                                      '${article.sourceName} • ${article.publishedAt.substring(0, 10)}',
                                  image: article.image.isNotEmpty
                                      ? article.image
                                      : 'assets/images/splash.png',
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 0),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kPrimary.withOpacity(0.1),
            kAccent.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPrimary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(
              color: kPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  const _TabButton({required this.label, this.selected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected 
              ? LinearGradient(
                  colors: [kPrimary, kAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          boxShadow: selected ? [
            BoxShadow(
              color: kPrimary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? kWhite : kDark,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String image;
  final List<String> tags;
  const _CategoryCard(
      {required this.title, required this.image, required this.tags});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 240,
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kDark.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: kPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: image.startsWith('http')
                    ? Image.network(image,
                        width: 300, height: 130, fit: BoxFit.cover)
                    : Image.asset(image,
                        width: 300, height: 130, fit: BoxFit.cover),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: kDark.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.bookmark_border,
                    color: kPrimary,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: tags
                        .take(2)
                        .map((t) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _Tag(text: t)))
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700, 
                            color: kDark,
                            height: 1.3,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalArticleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;
  const _VerticalArticleCard(
      {required this.title, required this.subtitle, required this.image});


@override
Widget build(BuildContext context) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: kWhite,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: kDark.withOpacity(0.06),
          blurRadius: 15,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: kPrimary.withOpacity(0.03),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 🖼 Left image
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: kDark.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(2, 0),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            child: image.startsWith('http')
                ? Image.network(image, fit: BoxFit.cover)
                : Image.asset(image, fit: BoxFit.cover),
          ),
        ),

        // 📰 Text content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: kDark,
                        height: 1.3,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: kPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          subtitle.split(' • ')[0],
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: kPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.access_time, color: kDark.withOpacity(0.5), size: 12),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        subtitle.split(' • ')[1],
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: kDark.withOpacity(0.6),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ➡️ Right arrow (fixed size)
        SizedBox(
          width: 32, // limit space to prevent overflow
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: kPrimary,
                size: 14,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

}
