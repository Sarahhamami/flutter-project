import 'package:flutter/material.dart';
import '../../repositories/wellness_repository.dart';
import '../../models/wellness_models.dart';

class MoodTrackerScreen extends StatefulWidget {
  @override
  _MoodTrackerScreenState createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  final WellnessRepository _wellnessRepository = WellnessRepository();

  int _stressLevel = 5;
  int _energyLevel = 5;
  String _selectedMood = 'Neutral';
  final List<String> _moodOptions = [
    'Happy', 'Sad', 'Anxious', 'Neutral', 'Excited',
    'Tired', 'Stressed', 'Relaxed', 'Angry', 'Content'
  ];

  // Custom colors
  final Color whiteColor = Colors.white;
  final Color lightGreenColor = Color(0xFF20c997);
  final Color blueColor = Color(0xFF0dcaf0);
  final Color grayColor = Colors.grey;

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'Happy': return '😊';
      case 'Sad': return '😢';
      case 'Anxious': return '😰';
      case 'Neutral': return '😐';
      case 'Excited': return '🤩';
      case 'Tired': return '😴';
      case 'Stressed': return '😫';
      case 'Relaxed': return '😌';
      case 'Angry': return '😠';
      case 'Content': return '🙂';
      default: return '😐';
    }
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'Happy': return Colors.green;
      case 'Sad': return Colors.blue;
      case 'Anxious': return Colors.orange;
      case 'Neutral': return Colors.grey;
      case 'Excited': return Colors.purple;
      case 'Tired': return Colors.brown;
      case 'Stressed': return Colors.red;
      case 'Relaxed': return lightGreenColor;
      case 'Angry': return Colors.deepOrange;
      case 'Content': return Colors.teal;
      default: return blueColor;
    }
  }

  Future<void> _saveMoodRecord() async {
    try {
      final mood = Mood(
        userId: 1, // Temporary UserId
        date: DateTime.now(),
        stressLevel: _stressLevel,
        mood: _selectedMood,
        energyLevel: _energyLevel,
      );

      await _wellnessRepository.insertMood(mood);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mood record saved successfully!'),
          backgroundColor: lightGreenColor,
        ),
      );
      
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildMoodSelector() {
    return Card(
      elevation: 3,
      color: whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'How are you feeling?', 
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _moodOptions.map((mood) {
                final isSelected = _selectedMood == mood;
                final moodColor = _getMoodColor(mood);
                
                return ChoiceChip(
                  label: Text(
                    '${_getMoodEmoji(mood)} $mood',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedMood = mood;
                    });
                  },
                  backgroundColor: grayColor.withOpacity(0.1),
                  selectedColor: moodColor,
                  checkmarkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderSection(String title, int value, Function(int) onChanged, String minLabel, String maxLabel, Color color) {
    return Card(
      elevation: 3,
      color: whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$title: $value/10', 
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Slider(
              value: value.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              activeColor: color,
              inactiveColor: color.withOpacity(0.3),
              thumbColor: color,
              onChanged: (value) {
                onChanged(value.toInt());
              },
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  minLabel, 
                  style: TextStyle(
                    fontSize: 12, 
                    color: grayColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  maxLabel, 
                  style: TextStyle(
                    fontSize: 12, 
                    color: grayColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: Text(
          'Mood Tracker',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: blueColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMoodSelector(),
            SizedBox(height: 20),
            _buildSliderSection(
              'Stress Level', 
              _stressLevel, 
              (value) => setState(() => _stressLevel = value),
              'Calm',
              'Stressed',
              Colors.red,
            ),
            SizedBox(height: 20),
            _buildSliderSection(
              'Energy Level', 
              _energyLevel, 
              (value) => setState(() => _energyLevel = value),
              'Tired',
              'Energetic',
              lightGreenColor,
            ),
            SizedBox(height: 30),
            
            // Current summary
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: blueColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: blueColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_emotions_rounded,
                    color: blueColor,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Summary',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${_getMoodEmoji(_selectedMood)} $_selectedMood • Stress: $_stressLevel/10 • Energy: $_energyLevel/10',
                          style: TextStyle(
                            fontSize: 12,
                            color: grayColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 30),
            
            // Save button
            ElevatedButton(
              onPressed: _saveMoodRecord,
              style: ElevatedButton.styleFrom(
                backgroundColor: blueColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                minimumSize: Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_emotions_rounded, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Save Mood Record',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}