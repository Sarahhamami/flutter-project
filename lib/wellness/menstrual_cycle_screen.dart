import 'package:flutter/material.dart';
import '../../repositories/wellness_repository.dart';
import '../../models/wellness_models.dart';

class MenstrualCycleScreen extends StatefulWidget {
  @override
  _MenstrualCycleScreenState createState() => _MenstrualCycleScreenState();
}

class _MenstrualCycleScreenState extends State<MenstrualCycleScreen> {
  final WellnessRepository _wellnessRepository = WellnessRepository();
  
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(Duration(days: 5));
  final List<String> _symptoms = [
    'Cramps', 'Headache', 'Mood swings', 'Fatigue', 
    'Back pain', 'Bloating', 'Breast tenderness'
  ];
  final List<String> _selectedSymptoms = [];

  // Custom colors
  final Color whiteColor = Colors.white;
  final Color lightGreenColor = Color(0xFF20c997);
  final Color blueColor = Color(0xFF0dcaf0);
  final Color grayColor = Colors.grey;

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _saveCycleRecord() async {
    try {
      final cycle = Cycle(
        userId: 1, // Temporary UserId
        cycleStartDate: _startDate,
        cycleEndDate: _endDate,
        symptoms: _selectedSymptoms,
      );

      await _wellnessRepository.insertCycle(cycle);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cycle record saved successfully!'),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildDateTile(IconData icon, String title, String subtitle, VoidCallback onTap, Color color) {
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
      trailing: Container(
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
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(vertical: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cycleLength = _endDate.difference(_startDate).inDays + 1;
    
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: Text(
          'Menstrual Cycle Tracker',
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
            // Cycle dates card
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
                    _buildDateTile(
                      Icons.calendar_today_rounded,
                      'Cycle Start Date',
                      _formatDate(_startDate),
                      _selectStartDate,
                      lightGreenColor,
                    ),
                    Divider(color: grayColor.withOpacity(0.3)),
                    _buildDateTile(
                      Icons.calendar_today_rounded,
                      'Cycle End Date',
                      _formatDate(_endDate),
                      _selectEndDate,
                      blueColor,
                    ),
                    Divider(color: grayColor.withOpacity(0.3)),
                    ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.timeline_rounded, 
                          color: Colors.amber,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'Cycle Duration',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: grayColor,
                        ),
                      ),
                      subtitle: Text(
                        '$cycleLength days',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 4),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Symptoms card
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
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: lightGreenColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Symptoms:', 
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Select experienced symptoms:',
                      style: TextStyle(
                        fontSize: 14,
                        color: grayColor,
                      ),
                    ),
                    SizedBox(height: 15),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _symptoms.map((symptom) {
                        final isSelected = _selectedSymptoms.contains(symptom);
                        return ChoiceChip(
                          label: Text(
                            symptom,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedSymptoms.add(symptom);
                              } else {
                                _selectedSymptoms.remove(symptom);
                              }
                            });
                          },
                          backgroundColor: grayColor.withOpacity(0.1),
                          selectedColor: lightGreenColor,
                          checkmarkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    // Selected symptoms display
                    if (_selectedSymptoms.isNotEmpty) ...[
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: blueColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: lightGreenColor,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Selected Symptoms:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    _selectedSymptoms.join(', '),
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
                    ],
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 30),
            
            // Cycle summary
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
                    Icons.cyclone_rounded,
                    color: blueColor,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cycle Summary',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'From ${_formatDate(_startDate)} to ${_formatDate(_endDate)} • $cycleLength days • ${_selectedSymptoms.length} symptom(s)',
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
              onPressed: _saveCycleRecord,
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
                    'Save Cycle Record',
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