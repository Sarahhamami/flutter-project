import 'package:flutter/material.dart';
import '../../repositories/wellness_repository.dart';
import '../../models/wellness_models.dart';

class SleepTrackerScreen extends StatefulWidget {
  @override
  _SleepTrackerScreenState createState() => _SleepTrackerScreenState();
}

class _SleepTrackerScreenState extends State<SleepTrackerScreen> {
  final WellnessRepository _wellnessRepository = WellnessRepository();
  
  TimeOfDay _bedTime = TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _wakeUpTime = TimeOfDay(hour: 7, minute: 0);
  String _sleepQuality = 'Average';
  final List<String> _qualityOptions = ['Good', 'Average', 'Poor'];

  // Custom colors
  final Color whiteColor = Colors.white;
  final Color lightGreenColor = Color(0xFF20c997);
  final Color blueColor = Color(0xFF0dcaf0);
  final Color grayColor = Colors.grey;

  Future<void> _selectBedTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _bedTime,
    );
    if (picked != null) {
      setState(() {
        _bedTime = picked;
      });
    }
  }

  Future<void> _selectWakeUpTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _wakeUpTime,
    );
    if (picked != null) {
      setState(() {
        _wakeUpTime = picked;
      });
    }
  }

  double _calculateSleepDuration() {
    final bedDateTime = DateTime(2023, 1, 1, _bedTime.hour, _bedTime.minute);
    final wakeDateTime = DateTime(2023, 1, 1, _wakeUpTime.hour, _wakeUpTime.minute);
    
    Duration duration;
    if (wakeDateTime.isAfter(bedDateTime)) {
      duration = wakeDateTime.difference(bedDateTime);
    } else {
      duration = wakeDateTime.add(Duration(days: 1)).difference(bedDateTime);
    }
    
    return duration.inHours.toDouble();
  }

  Future<void> _saveSleepRecord() async {
    try {
      final sleep = Sleep(
        userId: 1, // Temporary UserId
        date: DateTime.now(),
        bedTime: '${_bedTime.hour}:${_bedTime.minute}', // Convert to String
        wakeUpTime: '${_wakeUpTime.hour}:${_wakeUpTime.minute}', // Convert to String
        sleepDuration: _calculateSleepDuration(),
        sleepQuality: _sleepQuality,
      );

      await _wellnessRepository.insertSleep(sleep);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sleep record saved successfully!'),
          backgroundColor: lightGreenColor,
        ),
      );
      
      // Return to previous screen after delay
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

  @override
  Widget build(BuildContext context) {
    final duration = _calculateSleepDuration();
    
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: Text(
          'Sleep Tracker',
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
          children: [
            // Sleep schedule card
            Card(
              elevation: 3,
              color: whiteColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildTimeTile(
                      Icons.bedtime_rounded,
                      'Bedtime',
                      '${_bedTime.format(context)}',
                      _selectBedTime,
                      lightGreenColor,
                    ),
                    Divider(color: grayColor.withOpacity(0.3)),
                    _buildTimeTile(
                      Icons.wb_sunny_rounded,
                      'Wake-up Time',
                      '${_wakeUpTime.format(context)}',
                      _selectWakeUpTime,
                      blueColor,
                    ),
                    Divider(color: grayColor.withOpacity(0.3)),
                    _buildTimeTile(
                      Icons.timer_rounded,
                      'Sleep Duration',
                      '${duration.toStringAsFixed(1)} hours',
                      null,
                      Colors.amber,
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Sleep quality card
            Card(
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
                    Text(
                      'Sleep Quality:', 
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: grayColor.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButton<String>(
                          value: _sleepQuality,
                          isExpanded: true,
                          underline: SizedBox(),
                          icon: Icon(Icons.arrow_drop_down, color: blueColor),
                          items: _qualityOptions.map((String quality) {
                            Color itemColor;
                            switch (quality) {
                              case 'Good':
                                itemColor = lightGreenColor;
                                break;
                              case 'Average':
                                itemColor = Colors.amber;
                                break;
                              case 'Poor':
                                itemColor = Colors.red;
                                break;
                              default:
                                itemColor = blueColor;
                            }
                            
                            return DropdownMenuItem<String>(
                              value: quality,
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: itemColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    quality,
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _sleepQuality = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 30),
            
            // Save button
            ElevatedButton(
              onPressed: _saveSleepRecord,
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
                  Icon(Icons.save_rounded, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Save Sleep Record',
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

  Widget _buildTimeTile(IconData icon, String title, String subtitle, VoidCallback? onTap, Color color) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon, 
          color: color,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: grayColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      trailing: onTap != null 
          ? Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: blueColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.edit_rounded,
                color: blueColor,
                size: 18,
              ),
            )
          : null,
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(vertical: 4),
    );
  }
}