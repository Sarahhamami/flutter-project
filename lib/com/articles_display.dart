import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/news_service.dart';
import 'article_detail.dart';
import 'forum_page.dart';

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
      case 2: // Bookmark
        // Add bookmark functionality here if needed
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
      backgroundColor: kWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('HealthTracker News',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: kDark,
                          )),
                      const SizedBox(height: 6),
                      Text('Welcome back, Jeniffer',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: kDark,
                          )),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage('assets/images/splash.png'),
                  ),
                ],
              ),

                      const SizedBox(height: 0),

              // Tabs
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
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

                        // Header for vertical section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Just For You',
                                style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: kDark)),
                            TextButton(
                              onPressed: () {},
                              child: const Text('See More',
                                  style: TextStyle(color: kPrimary)),
                            )
                          ],
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
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 8,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.local_hospital), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black38,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: _onItemTapped,
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPrimary.withOpacity(0.12)),
      ),
      child: Text(text,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: kDark)),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? kPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? kWhite : kDark,
            fontWeight: FontWeight.w600,
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
      height: 220, // fix card height to match the carousel slot
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: kDark.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: image.startsWith('http')
                ? Image.network(image,
                    width: 300, height: 120, fit: BoxFit.cover)
                : Image.asset(image,
                    width: 300, height: 120, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
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
                const SizedBox(height: 8),
        // Truncate long titles to a single line with ellipsis
        Text(title,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.w700, color: kDark)),
              ],
            ),
          )
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
      height: 100,
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: kDark.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(12)),
            child: image.startsWith('http')
                ? Image.network(image,
                    width: 120, height: 100, fit: BoxFit.cover)
                : Image.asset(image,
                    width: 120, height: 100, fit: BoxFit.cover),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600, color: kDark)),
                  const SizedBox(height: 6),
                  Text(subtitle,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
