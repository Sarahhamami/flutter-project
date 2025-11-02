import 'package:flutter/material.dart';
import '../repositories/wellness_repository.dart';
import '../services/wellness_service.dart';

class WellnessHomeScreen extends StatefulWidget {
  @override
  _WellnessHomeScreenState createState() => _WellnessHomeScreenState();
}

class _WellnessHomeScreenState extends State<WellnessHomeScreen> {
  final WellnessRepository _wellnessRepository = WellnessRepository();
  final WellnessService _wellnessService = WellnessService();
  Map<String, dynamic> _stats = {
    'avgSleep': 7.2,
    'avgStress': 4.5,
    'avgEnergy': 6.8,
  };
  List<Map<String, dynamic>> _notifications = [];
  bool _loadingNotifications = true;

  // Custom colors
  final Color whiteColor = Colors.white;
  final Color lightGreenColor = Color(0xFF20c997);
  final Color blueColor = Color(0xFF0dcaf0);
  final Color grayColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _printDebugInfo();
  }

  void _printDebugInfo() {
    print('🔄 WellnessHomeScreen initialized');
    print('📊 Stats: $_stats');
  }

  Future<void> _loadNotifications() async {
    print('📥 Loading notifications...');
    try {
      final notifications = await _wellnessService.getPendingNotifications();
      setState(() {
        _notifications = notifications;
        _loadingNotifications = false;
      });
      print('✅ Notifications loaded: ${notifications.length} items');
    } catch (e) {
      print('❌ Error loading notifications: $e');
      setState(() {
        _loadingNotifications = false;
      });
    }
  }

  int get _unreadNotificationsCount {
    final count = _notifications.where((notification) => !notification['read']).length;
    print('🔔 Unread notifications: $count');
    return count;
  }

  void _viewAllNotifications() {
    print('👆 View All Notifications clicked');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('All Notifications'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _notifications.length,
            itemBuilder: (context, index) {
              final notification = _notifications[index];
              return ListTile(
                leading: Icon(
                  _getNotificationIcon(notification['type']),
                  color: _getNotificationColor(notification['type']),
                ),
                title: Text(notification['title']),
                subtitle: Text(notification['message']),
                trailing: Text(notification['time']),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              print('📌 Notifications dialog closed');
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsPanel() {
    print('🔔 Building notifications panel...');
    
    if (_loadingNotifications) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              CircularProgressIndicator(color: blueColor),
              SizedBox(height: 8),
              Text('Loading notifications...'),
            ],
          ),
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: blueColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.notifications_none, size: 40, color: grayColor),
            SizedBox(height: 8),
            Text(
              'No notifications',
              style: TextStyle(color: grayColor),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Notifications',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (_unreadNotificationsCount > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_unreadNotificationsCount new',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12),
          ..._notifications.take(3).map((notification) => Card(
            elevation: 2,
            color: whiteColor,
            margin: EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification['type']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getNotificationIcon(notification['type']),
                  color: _getNotificationColor(notification['type']),
                  size: 20,
                ),
              ),
              title: Text(
                notification['title'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: notification['read'] ? grayColor : Colors.black87,
                ),
              ),
              subtitle: Text(
                notification['message'],
                style: TextStyle(
                  fontSize: 12,
                  color: notification['read'] ? grayColor : Colors.black54,
                ),
              ),
              trailing: Text(
                notification['time'],
                style: TextStyle(fontSize: 11, color: grayColor),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
          )).toList(),
          if (_notifications.length > 3)
            Center(
              child: TextButton(
                onPressed: _viewAllNotifications,
                child: Text(
                  'View all notifications',
                  style: TextStyle(color: blueColor),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'reminder':
        return Colors.orange;
      case 'achievement':
        return Colors.green;
      case 'update':
        return blueColor;
      default:
        return grayColor;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'reminder':
        return Icons.notifications;
      case 'achievement':
        return Icons.emoji_events;
      case 'update':
        return Icons.new_releases;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 Building WellnessHomeScreen UI');
    
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
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: _viewAllNotifications,
              ),
              if (_unreadNotificationsCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '$_unreadNotificationsCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView( // ✅ CHANGEMENT IMPORTANT ICI
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick statistics
              _buildStatsCard(),
              SizedBox(height: 20),
              
              // Notifications panel
              _buildNotificationsPanel(),
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
              Column(
                children: [
                  _buildFeatureCard(
                    'Mood Journal',
                    Icons.emoji_emotions,
                    lightGreenColor,
                    () {
                      print('🎭 Mood Journal clicked');
                      Navigator.pushNamed(context, '/mood_tracker');
                    },
                  ),
                  _buildFeatureCard(
                    'Breathing Exercises',
                    Icons.self_improvement,
                    blueColor,
                    () {
                      print('🌬️ Breathing Exercises clicked');
                      Navigator.pushNamed(context, '/breathing');
                    },
                  ),
                  _buildFeatureCard(
                    'Guided Meditation',
                    Icons.mediation,
                    lightGreenColor,
                    () {
                      print('🧘 Meditation clicked');
                      Navigator.pushNamed(context, '/meditation');
                    },
                  ),
                  _buildFeatureCard(
                    'Sleep Tracker',
                    Icons.bedtime_rounded,
                    blueColor,
                    () {
                      print('😴 Sleep Tracker clicked');
                      Navigator.pushNamed(context, '/sleep_tracker');
                    },
                  ),
                  _buildFeatureCard(
                    'Menstrual Cycle',
                    Icons.cyclone_rounded,
                    lightGreenColor,
                    () {
                      print('♻️ Menstrual Cycle clicked');
                      Navigator.pushNamed(context, '/menstrual_cycle');
                    },
                  ),
                  _buildFeatureCard(
                    'Analytics',
                    Icons.analytics,
                    blueColor,
                    () {
                      print('📊 Analytics clicked');
                      Navigator.pushNamed(context, '/analytics');
                    },
                  ),
                  // Debug button
                  _buildDebugButton(),
                ],
              ),
            ],
          ),
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

  Widget _buildDebugButton() {
    return Card(
      elevation: 2,
      color: Colors.orange.withOpacity(0.1),
      margin: EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.bug_report, 
            color: Colors.orange,
            size: 24,
          ),
        ),
        title: Text(
          'Debug Info', 
          style: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          'Tap to see debug information in console',
          style: TextStyle(fontSize: 12),
        ),
        trailing: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.info,
            color: Colors.orange,
            size: 16,
          ),
        ),
        onTap: () {
          print('🐛 DEBUG INFORMATION:');
          print('📊 Stats: $_stats');
          print('🔔 Notifications count: ${_notifications.length}');
          print('🔔 Unread notifications: $_unreadNotificationsCount');
          print('🔄 Loading state: $_loadingNotifications');
          _wellnessRepository.printAllRecords();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Debug info printed to console!'),
              backgroundColor: Colors.orange,
            ),
          );
        },
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}