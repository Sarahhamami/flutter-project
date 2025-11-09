import 'package:flutter/material.dart';
import 'package:flutter_application_1/Appointments/appointments_page.dart';
import 'package:flutter_application_1/com/tasks.dart';
import 'package:flutter_application_1/custom_app_bar.dart';
import 'package:flutter_application_1/custom_bottom.dart';
import 'package:flutter_application_1/db/database_helper.dart';
import 'package:flutter_application_1/sos/emergency_contacts_page.dart';
import 'package:flutter_application_1/sos/emergency_service.dart';
import 'package:flutter_application_1/user/current_user.dart';
import 'package:flutter_application_1/user/profile_page.dart';
import '../models/article.dart';
import '../services/news_service.dart';
import 'article_detail.dart';
import 'forum_page.dart';
import 'friends_list_page.dart';
import 'navbar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/colors.dart';

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
  final EmergencyService _emergencyService = EmergencyService();

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

  switch (index) {
    case 0: // Articles / Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ArticlesDisplay()),
      );
      break;

    case 1: // Friends
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FriendsListPage()),
      );
      break;

    case 2: // Appointments
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AppointmentsPage()),
      );
      break;

    case 3: 
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
      break;
       case 4: // Tasks
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TasksPage()),
        );
       
        break;
      case 5: 
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EmergencyContactsPage()),
        );
     
        break;
      case 6: // SOS Button
        _handleSOSButton();
      
        break;
    default:
      break;
  }
}
 Future<void> _handleSOSButton() async {
    // Afficher une boîte de dialogue de confirmation
    bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: AppColors.blue, size: 30),
              SizedBox(width: 10),
              Text('EMERGENCY ALERT', style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'Are you sure you want to send an emergency alert?\n\nYour location will be shared with your emergency contacts.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('SEND ALERT'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.blue),
                SizedBox(height: 20),
                Text('Sending emergency alert...'),
              ],
            ),
          );
        },
      );

      try {
        // Obtenir l'ID de l'utilisateur par défaut (vous pouvez modifier cela selon votre logique d'authentification)
        final dbHelper = DatabaseHelper();
        int userId = await dbHelper.getDefaultUserId();

        // Envoyer l'alerte d'urgence
        Map<String, dynamic> result = await _emergencyService.sendEmergencyAlert(userId: userId);

        // Fermer le dialogue de chargement
        Navigator.of(context).pop();

        // Afficher le résultat
        showDialog(
          context: context,
          builder: (BuildContext context) {
            bool success = result['success'] as bool;
            String message = success 
                ? (result['message'] as String)
                : (result['error'] as String);
            
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(
                    success ? Icons.check_circle : Icons.error,
                    color: success ? AppColors.lightGreen : AppColors.blue,
                    size: 30,
                  ),
                  SizedBox(width: 10),
                  Text(
                    success ? 'Alert Sent!' : 'Error',
                    style: TextStyle(
                      color: success ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(fontSize: 16),
                  ),
                  if (success) ...[
                    SizedBox(height: 10),
                    if (result['contactCalled'] == true) ...[
                      Row(
                        children: [
                          Icon(Icons.phone, color: Colors.green, size: 16),
                          SizedBox(width: 8),
                        Text(
                          'Automatic call made',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        ],
                      ),
                      SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        Icon(
                          result['hasLocation'] == true ? Icons.location_on : Icons.location_off,
                          color: result['hasLocation'] == true ? Colors.green : Colors.orange,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          result['hasLocation'] == true 
                              ? 'Location included'
                              : 'Location not available',
                          style: TextStyle(
                            color: result['hasLocation'] == true ? Colors.green : Colors.orange,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (result['hasLocation'] == true) ...[
                      SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final double lat = (result['latitude'] as num).toDouble();
                            final double lng = (result['longitude'] as num).toDouble();
                            // Prefer turn-by-turn navigation to nearest hospital
                            // 1) Android navigation intent
                            final navUri = Uri.parse('google.navigation:q=hospital&mode=d');
                            // 2) Fallback: web directions with origin = current location, destination = hospital
                            final webDir = Uri.parse('https://www.google.com/maps/dir/?api=1&origin=$lat,$lng&destination=hospital&travelmode=driving');
                            // 3) Last resort: generic nearby search
                            final webSearch = Uri.parse('https://www.google.com/maps/search/nearest+hospital/@$lat,$lng,15z');

                            if (await canLaunchUrl(navUri)) {
                              await launchUrl(navUri, mode: LaunchMode.externalApplication);
                            } else if (await canLaunchUrl(webDir)) {
                              await launchUrl(webDir, mode: LaunchMode.externalApplication);
                            } else if (await canLaunchUrl(webSearch)) {
                              await launchUrl(webSearch, mode: LaunchMode.externalApplication);
                            }
                          },
                          icon: Icon(Icons.local_hospital),
                          label: Text('Navigate to nearest hospital'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                  if (!success && result['errorType'] == 'location_permission') ...[
                    SizedBox(height: 10),
                    Text(
                      '💡 Solution: Go to Settings > Apps > Your App > Permissions > Location',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: success ? Colors.green : Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        // Fermer le dialogue de chargement en cas d'erreur
        Navigator.of(context).pop();
        
        // Afficher l'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending alert: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
  // Reserve a small buffer for system inset; the BottomNavigationBar will be wrapped in a SafeArea
  final double listBottomPadding = MediaQuery.of(context).padding.bottom + 8.0;
  final user = CurrentUser().getUser();
    final firstName = user?['prenom'] ?? 'Guest';
    return Scaffold(
      appBar: customAppBar(context),
      bottomNavigationBar: BottomNavBar(currentIndex: 0), //navigation bar
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
                            'Welcome back, $firstName',
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
