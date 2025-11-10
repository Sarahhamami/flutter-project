import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../db/database_helper.dart';

class EditActivityPage extends StatefulWidget {
  final Map<String, dynamic> activity;
  final VoidCallback onUpdate;

  const EditActivityPage({
    Key? key,
    required this.activity,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _EditActivityPageState createState() => _EditActivityPageState();
}

class _EditActivityPageState extends State<EditActivityPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dateController;
  late TextEditingController _durationController;
  late TextEditingController _distanceController;
  late TextEditingController _stepsController;
  late TextEditingController _caloriesController;
  String? _selectedActivityType;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  final List<String> _activityTypes = [
    'Walking/Running',
    'Cycling',
    'Swimming',
    'Weightlifting',
  ];

  @override
  void initState() {
    super.initState();
    _selectedActivityType = widget.activity['type_activite'];
    _dateController = TextEditingController(
      text: widget.activity['date_activite'] != null
          ? DateFormat('yyyy-MM-dd HH:mm').format(
              DateTime.parse(widget.activity['date_activite']).toLocal(),
            )
          : '',
    );
    _durationController = TextEditingController(
        text: widget.activity['duree']?.toString() ?? '');
    _distanceController = TextEditingController(
        text: widget.activity['distance']?.toString() ?? '');
    _stepsController = TextEditingController(
        text: widget.activity['pas']?.toString() ?? '');
    _caloriesController = TextEditingController(
        text: widget.activity['calories_brulees']?.toString() ?? '');
  }

  @override
  void dispose() {
    _dateController.dispose();
    _durationController.dispose();
    _distanceController.dispose();
    _stepsController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      
      if (time != null) {
        final DateTime dateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );
        setState(() {
          _dateController.text = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
        });
      }
    }
  }

  Future<void> _updateActivity() async {
    if (_formKey.currentState!.validate() && _selectedActivityType != null) {
      try {
        final updatedActivity = {
          'id_activite': widget.activity['id_activite'],
          'type_activite': _selectedActivityType,
          'date_activite': _dateController.text,
          'duree': int.tryParse(_durationController.text) ?? 0,
          'distance': double.tryParse(_distanceController.text) ?? 0.0,
          'pas': int.tryParse(_stepsController.text) ?? 0,
          'calories_brulees': int.tryParse(_caloriesController.text) ?? 0,
        };

        final db = await _databaseHelper.database;
        await db.update(
          'Activite_physique',
          updatedActivity,
          where: 'id_activite = ?',
          whereArgs: [widget.activity['id_activite']],
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Activity updated successfully')),
          );
          widget.onUpdate();
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update activity')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Activity'),
        backgroundColor: const Color(0xFF0dcaf0),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedActivityType,
                decoration: const InputDecoration(
                  labelText: 'Activity Type',
                  border: OutlineInputBorder(),
                ),
                items: _activityTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedActivityType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an activity type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date & Time',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDateTime(context),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select date and time';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter duration';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _distanceController,
                decoration: const InputDecoration(
                  labelText: 'Distance (km)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter distance';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stepsController,
                decoration: const InputDecoration(
                  labelText: 'Steps',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter steps';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(
                  labelText: 'Calories Burned',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter calories burned';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updateActivity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF20c997),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Update Activity',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
