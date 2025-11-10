import 'package:flutter/material.dart';
import 'package:flutter_application_1/actPhy/bodyParts/bodyParts.dart';
import 'walking_page.dart';
import 'cycling_page.dart';
import 'swimming_page.dart';
import 'weightlifting_page.dart';

class ActivityCategoriesPage extends StatelessWidget {
  const ActivityCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF20c997),
        elevation: 0,
        title: const Text(
          'Choose Your Activity',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GridView.count(
                crossAxisCount: constraints.maxWidth > 600 ? 2 : 1,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: constraints.maxWidth > 600 ? 1.2 : 2.5,
                children: [
                  _buildActivityCard(
                    context: context,
                    icon: Icons.directions_walk,
                    title: 'Walking',
                    description: 'Track your walking sessions',
                    color: const Color(0xFF20c997),
                    onTap: () => _navigateWithTransition(
                      context,
                      const WalkingPage(),
                    ),
                  ),
                  _buildActivityCard(
                    context: context,
                    icon: Icons.directions_bike,
                    title: 'Cycling',
                    description: 'Track cycling laps and duration',
                    color: const Color(0xFF0dcaf0),
                    onTap: () => _navigateWithTransition(
                      context,
                      const CyclingPage(),
                    ),
                  ),
                  _buildActivityCard(
                    context: context,
                    icon: Icons.pool,
                    title: 'Swimming',
                    description: 'Track swimming rounds',
                    color: const Color(0xFFF36B56),
                    onTap: () => _navigateWithTransition(
                      context,
                      const SwimmingPage(),
                    ),
                  ),
               
                  _buildActivityCard(
                    context: context,
                    icon: Icons.sports_gymnastics,
                    title: 'Gym',
                    description: 'Choose body parts to train',
                    color: const Color(0xFFfd7e14),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => BodyPartsPage()), // Replace with your actual widget class
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Hero(
      tag: title,
      child: Card(
        elevation: 4,
        shadowColor: color.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [color.withOpacity(0.1), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: color,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateWithTransition(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }
}
