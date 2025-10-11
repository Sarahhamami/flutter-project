import 'package:flutter/material.dart';
import '../../services/wellness_service.dart';

class MeditationScreen extends StatefulWidget {
  @override
  _MeditationScreenState createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  final WellnessService _wellnessService = WellnessService();
  List<Map<String, dynamic>> _sessions = [];
  bool _isLoading = true;

  // Custom colors
  final Color whiteColor = Colors.white;
  final Color lightGreenColor = Color(0xFF20c997);
  final Color blueColor = Color(0xFF0dcaf0);
  final Color grayColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final sessions = await _wellnessService.getMeditationSessions();
    setState(() {
      _sessions = sessions;
      _isLoading = false;
    });
  }

  void _startMeditation(Map<String, dynamic> session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(session['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session['description'] ?? 'Guided meditation session',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Type: ${session['type']}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: blueColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Duration: ${session['duration']} minutes',
              style: TextStyle(color: grayColor),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Start meditation session here
            },
            child: Text('Start Meditation'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: Text(
          'Guided Meditation',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: blueColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: blueColor),
                  SizedBox(height: 16),
                  Text(
                    'Loading meditation sessions...',
                    style: TextStyle(color: grayColor),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: _sessions.length,
              itemBuilder: (context, index) {
                final session = _sessions[index];
                return Card(
                  elevation: 3,
                  color: whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => _startMeditation(session),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.self_improvement_rounded,
                            size: 40,
                            color: lightGreenColor,
                          ),
                          SizedBox(height: 12),
                          Text(
                            session['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            session['type'],
                            style: TextStyle(
                              color: grayColor,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 12),
                          Chip(
                            label: Text(
                              '${session['duration']} min',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                            backgroundColor: blueColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}