import 'package:flutter/material.dart';
import '../../services/wellness_service.dart';

class BreathingExercisesScreen extends StatefulWidget {
  @override
  _BreathingExercisesScreenState createState() => _BreathingExercisesScreenState();
}

class _BreathingExercisesScreenState extends State<BreathingExercisesScreen> {
  final WellnessService _wellnessService = WellnessService();
  List<Map<String, dynamic>> _exercises = [];
  bool _isLoading = true;

  // Custom colors
  final Color whiteColor = Colors.white;
  final Color lightGreenColor = Color(0xFF20c997);
  final Color blueColor = Color(0xFF0dcaf0);
  final Color grayColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final exercises = await _wellnessService.getBreathingExercises();
    setState(() {
      _exercises = exercises;
      _isLoading = false;
    });
  }

  void _startExercise(Map<String, dynamic> exercise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(exercise['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise['description'],
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Steps:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...exercise['steps'].map<Widget>((step) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text('• $step'),
            )).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Start the exercise timer here
            },
            child: Text('Start ${exercise['duration']}min'),
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
          'Breathing Exercises',
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
                    'Loading breathing exercises...',
                    style: TextStyle(color: grayColor),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _exercises.length,
              itemBuilder: (context, index) {
                final exercise = _exercises[index];
                return Card(
                  elevation: 3,
                  color: whiteColor,
                  margin: EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: lightGreenColor.withOpacity(0.1),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: lightGreenColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      exercise['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      exercise['description'],
                      style: TextStyle(color: grayColor),
                    ),
                    trailing: Chip(
                      label: Text(
                        '${exercise['duration']} min',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: blueColor,
                    ),
                    onTap: () => _startExercise(exercise),
                    contentPadding: EdgeInsets.all(16),
                  ),
                );
              },
            ),
    );
  }
}