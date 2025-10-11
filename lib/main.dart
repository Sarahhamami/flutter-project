import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';

// Import your real screens
import 'wellness/wellness_home.dart';
import 'wellness/sleep_tracker_screen.dart';
import 'wellness/mood_tracker_screen.dart';
import 'wellness/breathing_exercises_screen.dart';
import 'wellness/meditation_screen.dart';
import 'wellness/menstrual_cycle_screen.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      title: 'Health Application',
      theme: ThemeData(
        primaryColor: Color(0xFF0dcaf0),
        colorScheme: ColorScheme.light(
          primary: Color(0xFF0dcaf0),
          secondary: Color(0xFF20c997),
        ),
      ),
      home: const HomeScreen(),
      routes: {
        '/wellness': (context) => WellnessHomeScreen(),
        '/sleep_tracker': (context) => SleepTrackerScreen(),
        '/mood_tracker': (context) => MoodTrackerScreen(),
        '/breathing': (context) => BreathingExercisesScreen(),
        '/meditation': (context) => MeditationScreen(),
        '/menstrual_cycle': (context) => MenstrualCycleScreen(),
      },
    );
  }
}

// Main home page
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'My Health App',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF0dcaf0),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon and title
            Icon(
              Icons.health_and_safety,
              size: 80,
              color: Color(0xFF20c997),
            ),
            SizedBox(height: 20),
            Text(
              'Welcome to Your\nComplete Health Application',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Track your health, nutrition, medical appointments and mental wellness',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 40),
            
            // Wellness module access button
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/wellness');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0dcaf0),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Access Wellness Module',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            
            // Features
            Row(
              children: [
                _buildFeatureItem(Icons.favorite, 'Health'),
                _buildFeatureItem(Icons.restaurant, 'Nutrition'),
                _buildFeatureItem(Icons.medical_services, 'Appointments'),
                _buildFeatureItem(Icons.self_improvement, 'Wellness'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Color(0xFF0dcaf0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              icon,
              color: Color(0xFF0dcaf0),
              size: 24,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}