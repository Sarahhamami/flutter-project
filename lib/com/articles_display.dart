import 'package:flutter/material.dart';

// Palette requested by user:
// white, #01BCE5 (primary), #52575A (dark), #08CAC2 (accent)
const Color kWhite = Colors.white;
const Color kPrimary = Color(0xFF01BCE5);
const Color kDark = Color(0xFF52575A);
const Color kAccent = Color(0xFF08CAC2);

class ArticlesDisplay extends StatelessWidget {
  const ArticlesDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = [
      {
        'title': 'Minimal: Things You Should Know',
        'image': 'assets/images/splash.png',
        'tags': ['Life Improvement', 'Knowledge']
      },
      {
        'title': 'Healthy Habits To Start Today',
        'image': 'assets/images/splash.png',
        'tags': ['Wellness', 'Fitness']
      },
      {
        'title': 'Designing Your Routine',
        'image': 'assets/images/splash.png',
        'tags': ['Productivity', 'Design']
      },
    ];

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HealthTracker News',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: kDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Welcome back, Jeniffer',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: kDark,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage('assets/images/splash.png'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

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
                    _TabButton(label: 'Feeds', selected: true),
                    _TabButton(label: 'Popular'),
                    _TabButton(label: 'Following'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Featured card
              Expanded(
                child: ListView(
                  children: [
                    // Category carousel: horizontally scrollable cards
                    SizedBox(
                      height: 220,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        padding: const EdgeInsets.only(right: 12),
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, idx) {
                          final item = categories[idx];
                          return _CategoryCard(
                            title: item['title'] as String,
                            image: item['image'] as String,
                            tags: (item['tags'] as List<dynamic>).cast<String>(),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Just For You header
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Just For You', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: kDark)),
                        TextButton(
                          onPressed: () {},
                          child: const Text('See More', style: TextStyle(color: kPrimary)),
                        )
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Vertical stacked list (non-scrollable) - one per line
                    Column(
                      children: List.generate(5, (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _VerticalArticleCard(
                          title: 'Elon Musk on How to learn and adapt more Faster',
                          subtitle: 'How To Be Better • 4 Min',
                          image: 'assets/images/splash.png',
                        ),
                      )),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black38,
        showSelectedLabels: false,
        showUnselectedLabels: false,
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
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: kDark),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  const _TabButton({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _SmallArticleCard extends StatelessWidget {
  final int index;
  const _SmallArticleCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: kDark.withOpacity(0.06), blurRadius: 8, offset: const Offset(0,4))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            child: Image.asset('assets/images/splash.png', width: 110, height: 120, fit: BoxFit.cover),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Elon Musk on How to learn and adapt more Faster', maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('How To Be Better • 4 Min', style: Theme.of(context).textTheme.bodySmall),
                ], 
                
                ) ,
              ),
            ),
          

        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String image;
  final List<String> tags;
  const _CategoryCard({required this.title, required this.image, required this.tags});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: kDark.withOpacity(0.06), blurRadius: 10, offset: const Offset(0,4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(image, width: 300, height: 120, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: tags.take(2).map((t) => Padding(padding: const EdgeInsets.only(right: 8), child: _Tag(text: t))).toList(),
                ),
                const SizedBox(height: 10),
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: kDark)),
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
  const _VerticalArticleCard({required this.title, required this.subtitle, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: kDark.withOpacity(0.04), blurRadius: 8, offset: const Offset(0,4))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            child: Image.asset(image, width: 120, height: 100, fit: BoxFit.cover),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: kDark)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
