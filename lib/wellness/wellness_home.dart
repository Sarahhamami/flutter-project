import 'package:flutter/material.dart';
import '../repositories/wellness_repository.dart';

class WellnessHomeScreen extends StatefulWidget {
  @override
  _WellnessHomeScreenState createState() => _WellnessHomeScreenState();
}

class _WellnessHomeScreenState extends State<WellnessHomeScreen> {
  final WellnessRepository _wellnessRepository = WellnessRepository();
  Map<String, dynamic> _stats = {
    'avgSleep': 7.2,
    'avgStress': 4.5,
    'avgEnergy': 6.8,
  };

  // Custom colors
  final Color whiteColor = Colors.white;
  final Color lightGreenColor = Color(0xFF20c997);
  final Color blueColor = Color(0xFF0dcaf0);
  final Color grayColor = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: Text(
          'Mental Wellness',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: blueColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick statistics
            _buildStatsCard(),
            SizedBox(height: 20),
            
            // Features title
            Text(
              'My Features',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            
            // Features
            Expanded(
              child: ListView(
                children: [
                  _buildFeatureCard(
                    'Mood Journal',
                    Icons.emoji_emotions,
                    lightGreenColor,
                    () => Navigator.pushNamed(context, '/mood_tracker'),
                  ),
                  _buildFeatureCard(
                    'Breathing Exercises',
                    Icons.self_improvement,
                    blueColor,
                    () => Navigator.pushNamed(context, '/breathing'),
                  ),
                  _buildFeatureCard(
                    'Guided Meditation',
                    Icons.mediation,
                    lightGreenColor,
                    () => Navigator.pushNamed(context, '/meditation'),
                  ),
                  _buildFeatureCard(
                    'Sleep Tracker',
                    Icons.bedtime_rounded,
                    blueColor,
                    () => Navigator.pushNamed(context, '/sleep_tracker'),
                  ),
                  _buildFeatureCard(
                    'Menstrual Cycle',
                    Icons.cyclone_rounded,
                    lightGreenColor,
                    () => Navigator.pushNamed(context, '/menstrual_cycle'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 4,
      color: whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Wellness This Week', 
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('😴', 'Sleep', '${(_stats['avgSleep'] as double).toStringAsFixed(1)}h'),
                _buildStatItem('😌', 'Stress', '${(_stats['avgStress'] as double).toStringAsFixed(1)}/10'),
                _buildStatItem('⚡', 'Energy', '${(_stats['avgEnergy'] as double).toStringAsFixed(1)}/10'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: TextStyle(fontSize: 28)),
        SizedBox(height: 8),
        Text(
          label, 
          style: TextStyle(
            fontSize: 12, 
            color: grayColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value, 
          style: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.bold,
            color: blueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      color: whiteColor,
      margin: EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon, 
            color: color,
            size: 24,
          ),
        ),
        title: Text(
          title, 
          style: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        trailing: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.arrow_forward_ios,
            color: color,
            size: 16,
          ),
        ),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}