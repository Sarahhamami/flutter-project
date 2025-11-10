import 'package:flutter/material.dart';
import 'package:flutter_application_1/Appointments/appointments_page.dart';
import 'package:flutter_application_1/actPhy/onboarding/onboarding_screen.dart';
import 'package:flutter_application_1/com/articles_display.dart';
import 'package:flutter_application_1/com/friends_list_page.dart';
import 'package:flutter_application_1/db/database_helper.dart';
import 'package:flutter_application_1/sos/admin_menu_page.dart';
import 'package:flutter_application_1/sos/emergency_service.dart';
import 'package:flutter_application_1/sos/first_aid_chatbot_page.dart';
import 'package:flutter_application_1/user/profile_page.dart';
import 'package:flutter_application_1/wellness/analytics_screen.dart';
import 'package:flutter_application_1/wellness/breathing_exercises_screen.dart';
import 'package:flutter_application_1/wellness/meditation_screen.dart';
import 'package:flutter_application_1/wellness/menstrual_cycle_screen.dart';
import 'package:flutter_application_1/wellness/mood_tracker_screen.dart';
import 'package:flutter_application_1/wellness/sleep_tracker_screen.dart';
import 'package:flutter_application_1/wellness/wellness_home.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final EmergencyService _emergencyService = EmergencyService();

   BottomNavBar({Key? key, this.currentIndex = 0}) : super(key: key);

  Future<void> _handleSOSButton(BuildContext context) async {
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
              const SizedBox(width: 10),
              Text(
                'EMERGENCY ALERT',
                style: TextStyle(
                  color: AppColors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to send an emergency alert?\n\nYour location will be shared with your emergency contacts.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
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
              child: const Text('SEND ALERT'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(color: AppColors.blue),
            SizedBox(height: 20),
            Text('Sending emergency alert...'),
          ],
        ),
      ),
    );

    try {
      final dbHelper = DatabaseHelper();
      int userId = await dbHelper.getDefaultUserId();

      Map<String, dynamic> result =
          await _emergencyService.sendEmergencyAlert(userId: userId);

      Navigator.of(context).pop(); // close loading

      bool success = result['success'] as bool;
      String message = success
          ? (result['message'] as String)
          : (result['error'] as String);

      // Show result dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: success ? Colors.green : Colors.red,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Text(
                  success ? 'Alert Sent!' : 'Error',
                  style: TextStyle(
                    color: success ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message, style: const TextStyle(fontSize: 16)),
                  if (success) ...[
                    const SizedBox(height: 10),
                    if (result['contactCalled'] == true)
                      Row(
                        children: const [
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
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          result['hasLocation'] == true
                              ? Icons.location_on
                              : Icons.location_off,
                          color: result['hasLocation'] == true
                              ? Colors.green
                              : Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          result['hasLocation'] == true
                              ? 'Location included'
                              : 'Location not available',
                          style: TextStyle(
                            color: result['hasLocation'] == true
                                ? Colors.green
                                : Colors.orange,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (result['hasLocation'] == true) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final double lat =
                                (result['latitude'] as num).toDouble();
                            final double lng =
                                (result['longitude'] as num).toDouble();

                            final navUri =
                                Uri.parse('google.navigation:q=hospital&mode=d');
                            final webDir = Uri.parse(
                                'https://www.google.com/maps/dir/?api=1&origin=$lat,$lng&destination=hospital&travelmode=driving');
                            final webSearch = Uri.parse(
                                'https://www.google.com/maps/search/nearest+hospital/@$lat,$lng,15z');

                            if (await canLaunchUrl(navUri)) {
                              await launchUrl(navUri,
                                  mode: LaunchMode.externalApplication);
                            } else if (await canLaunchUrl(webDir)) {
                              await launchUrl(webDir,
                                  mode: LaunchMode.externalApplication);
                            } else if (await canLaunchUrl(webSearch)) {
                              await launchUrl(webSearch,
                                  mode: LaunchMode.externalApplication);
                            }
                          },
                          icon: const Icon(Icons.local_hospital),
                          label: const Text('Navigate to nearest hospital'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                  if (!success &&
                      result['errorType'] == 'location_permission') ...[
                    const SizedBox(height: 10),
                    const Text(
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
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      Navigator.of(context).pop(); // close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending alert: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF0dcaf0),
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ArticlesDisplay()));
            break;
          case 1:
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const FriendsListPage()));
            break;
          case 2:
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AppointmentsPage()));
            break;
          case 3:
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()));
            break;
          case 4:
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const FirstAidChatbotPage()));
                
            break;
             case 5:
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const AdminMenuPage()));
                
            break;
          case 6:
            _handleSOSButton(context);
            break;
            case 7:
            showMenu(
              context: context,
              position: RelativeRect.fromLTRB(100, 500, 40, 100), // adjust to position near your navbar item
              items: [
                PopupMenuItem(
                  child: Text("Wellness"),
                  onTap: () {
                    Future.delayed(Duration.zero, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => WellnessHomeScreen()));
                    });
                  },
                ),
                PopupMenuItem(
                  child: Text("Menstrual Cycle"),
                  onTap: () {
                    Future.delayed(Duration.zero, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => MenstrualCycleScreen()));
                    });
                  },
                ),
                PopupMenuItem(
                  child: Text("Meditation"),
                  onTap: () {
                    Future.delayed(Duration.zero, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => MeditationScreen()));
                    });
                  },
                ),
                 PopupMenuItem(
                  child: Text("Mood Tracker"),
                  onTap: () {
                    Future.delayed(Duration.zero, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => MoodTrackerScreen()));
                    });
                  },
                ),
                 PopupMenuItem(
                  child: Text("Sleep Tracker"),
                  onTap: () {
                    Future.delayed(Duration.zero, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => SleepTrackerScreen()));
                    });
                  },
                ),
                 PopupMenuItem(
                  child: Text("Analytics"),
                  onTap: () {
                    Future.delayed(Duration.zero, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => AnalyticsScreen()));
                    });
                  },
                ),
                 PopupMenuItem(
                  child: Text("Breathing Exercises"),
                  onTap: () {
                    Future.delayed(Duration.zero, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => BreathingExercisesScreen()));
                    });
                  },
                ),
              ],
            );
            break;
             case 8:
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
                
            break;

        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Friends'),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today), label: 'Appointments'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(
            icon: Icon(Icons.chat), label: 'ChatBot'),
       BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings), label: 'Pannel'),
        BottomNavigationBarItem(
          icon: Icon(Icons.emergency, color: Colors.grey),
          label: 'SOS',
          
        ),  BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety), label: 'Wellness'),
            BottomNavigationBarItem(
            icon: Icon(Icons.sports_gymnastics), label: 'Fitness'),
      ],
    );
  }
}
