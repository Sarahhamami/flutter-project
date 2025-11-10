import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import '../../db/database_helper.dart';

class NewActivityPage extends StatefulWidget {
  final int userId;

  const NewActivityPage({Key? key, this.userId = 1}) : super(key: key);

  @override
  _NewActivityPageState createState() => _NewActivityPageState();
}

class _NewActivityPageState extends State<NewActivityPage> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  
  // Form controllers
  final _dateController = TextEditingController();
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _distanceController = TextEditingController();
  final _stepsController = TextEditingController();
  final _avgSpeedController = TextEditingController();
  final _maxSpeedController = TextEditingController();
  final _strokeTypeController = TextEditingController();
  final _lapsController = TextEditingController();
  final _exerciseNameController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();

  // Form values
  String? _activityType;
  String? _sourceData;
  DateTime _selectedDate = DateTime.now();
  
  final List<Map<String, dynamic>> _activityTypes = [
    {
      'name': 'Walking/Running',
      'icon': Icons.directions_walk,
      'color': Colors.blue,
      'gradient': [Colors.blue, Colors.blue.shade300],
    },
    {
      'name': 'Cycling',
      'icon': Icons.directions_bike,
      'color': Colors.green,
      'gradient': [Colors.green, Colors.green.shade300],
    },
    {
      'name': 'Swimming',
      'icon': Icons.pool,
      'color': Colors.lightBlue,
      'gradient': [Colors.lightBlue, Colors.lightBlue.shade300],
    },
    {
      'name': 'Weightlifting',
      'icon': Icons.fitness_center,
      'color': Colors.orange,
      'gradient': [Colors.orange, Colors.orange.shade300],
    },
  ];

  final List<Map<String, dynamic>> _sourceOptions = [
    {'name': 'Manual', 'icon': Icons.touch_app},
    {'name': 'Smartwatch', 'icon': Icons.watch},
    {'name': 'App', 'icon': Icons.phone_android},
  ];

  final List<String> _strokeTypes = [
    'Freestyle',
    'Backstroke',
    'Breaststroke',
    'Butterfly'
  ];

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
    _checkDatabase();
  }

  Future<void> _checkDatabase() async {
    try {
      final db = await _databaseHelper.database;
      final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
      print('📋 Database tables:');
      print(tables);
      
      // Check if Activite_physique table exists and has data
      try {
        final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM Activite_physique')
        );
        print('📊 Activite_physique table has $count rows');
        
        // Show first 5 rows if any
        if (count != null && count > 0) {
          final rows = await db.query('Activite_physique', limit: 5);
          print('📝 First ${rows.length} activities:');
          for (var row in rows) {
            print(row);
          }
        }
      } catch (e) {
        print('❌ Error querying Activite_physique table: $e');
      }
    } catch (e) {
      print('❌ Error accessing database: $e');
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    _distanceController.dispose();
    _stepsController.dispose();
    _avgSpeedController.dispose();
    _maxSpeedController.dispose();
    _strokeTypeController.dispose();
    _lapsController.dispose();
    _exerciseNameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Widget _buildActivitySpecificFields() {
    if (_activityType == null) return Container();

    switch (_activityType) {
      case 'Walking/Running':
        return Column(
          children: [
            TextFormField(
              controller: _distanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Distance (km)',
                border: OutlineInputBorder(),
              ),
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
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Steps',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter number of steps';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ],
        );

      case 'Cycling':
        return Column(
          children: [
            TextFormField(
              controller: _distanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Distance (km)',
                border: OutlineInputBorder(),
              ),
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
              controller: _avgSpeedController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Average Speed (km/h)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter average speed';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _maxSpeedController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Max Speed (km/h)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter max speed';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ],
        );

      case 'Swimming':
        return Column(
          children: [
            TextFormField(
              controller: _distanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Distance (meters)',
                border: OutlineInputBorder(),
              ),
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
            DropdownButtonFormField<String>(
              value: _strokeTypeController.text.isEmpty ? null : _strokeTypeController.text,
              decoration: const InputDecoration(
                labelText: 'Stroke Type',
                border: OutlineInputBorder(),
              ),
              items: _strokeTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _strokeTypeController.text = value;
                }
              },
              validator: (value) => value == null ? 'Please select a stroke type' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lapsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Number of Laps',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter number of laps';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ],
        );

      case 'Weightlifting':
        return Column(
          children: [
            TextFormField(
              controller: _exerciseNameController,
              decoration: const InputDecoration(
                labelText: 'Exercise Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter exercise name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _setsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Number of Sets',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter number of sets';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _repsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Reps per Set',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter number of reps';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter weight';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ],
        );

      default:
        return Container();
    }
  }

  Future<void> _saveActivity() async {
    if (!_formKey.currentState!.validate()) {
      print('❌ Form validation failed');
      return;
    }

    try {
      print('🔄 Attempting to save activity...');
      final db = await _databaseHelper.database;
      
      // Log all form values
      print('📋 Form values:');
      print('- User ID: ${widget.userId}');
      print('- Activity Type: $_activityType');
      print('- Date: ${_dateController.text}');
      print('- Duration: ${_durationController.text}');
      print('- Calories: ${_caloriesController.text}');
      print('- Source: $_sourceData');
      
      Map<String, dynamic> activityData = {
        'id_utilisateur': widget.userId,
        'type_activite': _activityType,
        'date_activite': _dateController.text,
        'duree': int.tryParse(_durationController.text) ?? 0,
        'calories_brulees': _caloriesController.text.isNotEmpty 
            ? double.tryParse(_caloriesController.text) 
            : null,
        'source_donnees': _sourceData,
      };

      // Add activity-specific fields
      print('🔍 Activity-specific fields:');
      switch (_activityType) {
        case 'Walking/Running':
          activityData['distance'] = double.tryParse(_distanceController.text);
          activityData['pas'] = int.tryParse(_stepsController.text);
          print('- Distance: ${activityData['distance']}');
          print('- Steps: ${activityData['pas']}');
          break;
          
        case 'Cycling':
          activityData['distance'] = double.tryParse(_distanceController.text);
          activityData['avg_speed'] = double.tryParse(_avgSpeedController.text);
          activityData['max_speed'] = double.tryParse(_maxSpeedController.text);
          print('- Distance: ${activityData['distance']}');
          print('- Avg Speed: ${activityData['avg_speed']}');
          print('- Max Speed: ${activityData['max_speed']}');
          break;
          
        case 'Swimming':
          activityData['distance'] = double.tryParse(_distanceController.text);
          activityData['stroke_type'] = _strokeTypeController.text;
          activityData['laps'] = int.tryParse(_lapsController.text);
          print('- Distance: ${activityData['distance']}');
          print('- Stroke Type: ${activityData['stroke_type']}');
          print('- Laps: ${activityData['laps']}');
          break;
          
        case 'Weightlifting':
          activityData['exercise_name'] = _exerciseNameController.text;
          activityData['sets'] = int.tryParse(_setsController.text);
          activityData['reps'] = int.tryParse(_repsController.text);
          activityData['weight'] = double.tryParse(_weightController.text);
          print('- Exercise: ${activityData['exercise_name']}');
          print('- Sets: ${activityData['sets']}');
          print('- Reps: ${activityData['reps']}');
          print('- Weight: ${activityData['weight']}');
          break;
      }

      print('💾 Inserting into database...');
      try {
        final id = await db.insert('Activite_physique', activityData);
        print('✅ Activity saved with ID: $id');
        
        // Verify the data was inserted
        final List<Map> result = await db.query('Activite_physique');
        print('📊 Current activities in database:');
        print(result);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Activity saved successfully!')),
          );
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } catch (e) {
        print('❌ Error inserting into database: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Database error: $e')),
          );
        }
      }
    } catch (e) {
      print('❌ Unexpected error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving activity: $e')),
        );
      }
    }
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? icon,
    int? maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: label,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: icon != null ? Icon(icon, color: Colors.blue) : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildActivityTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activity Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: _activityTypes.map((activity) {
            final isSelected = _activityType == activity['name'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _activityType = activity['name'];
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: isSelected 
                        ? (activity['gradient'] as List<Color>)
                        : [Colors.grey.shade200, Colors.grey.shade300],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      activity['icon'],
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      activity['name'],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade800,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (_activityType == null)
          const Padding(
            padding: EdgeInsets.only(top: 4.0, left: 8.0),
            child: Text(
              'Please select an activity type',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Activity',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              // Activity Type Selector
              _buildActivityTypeSelector(),
              const SizedBox(height: 24),

              // Date Picker
              _buildFormField(
                label: 'Date',
                controller: _dateController,
                readOnly: true,
                onTap: () => _selectDate(context),
                icon: Icons.calendar_today,
                validator: (value) => value?.isEmpty ?? true ? 'Please select a date' : null,
              ),
              const SizedBox(height: 16),

              // Duration
              _buildFormField(
                label: 'Duration (minutes)',
                controller: _durationController,
                keyboardType: TextInputType.number,
                icon: Icons.timer,
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

              // Calories (optional)
              _buildFormField(
                label: 'Calories Burned (optional)',
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                icon: Icons.local_fire_department,
              ),
              const SizedBox(height: 16),

              // Source of Data
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Source of Data',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _sourceOptions.map((source) {
                      final isSelected = _sourceData == source['name'];
                      return ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              source['icon'],
                              size: 18,
                              color: isSelected ? Colors.white : Colors.blue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              source['name'],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        selected: isSelected,
                        selectedColor: Colors.blue,
                        backgroundColor: Colors.blue.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? Colors.blue : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _sourceData = selected ? source['name'] : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  if (_sourceData == null && _formKey.currentState?.validate() == true)
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0, left: 8.0),
                      child: Text(
                        'Please select a data source',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Activity-specific fields
              if (_activityType != null) ...[
                Container(
                  margin: const EdgeInsets.only(top: 16, bottom: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade100, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _activityTypes.firstWhere(
                          (a) => a['name'] == _activityType,
                          orElse: () => _activityTypes[0],
                        )['icon'],
                        color: Colors.blue,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_activityType} Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildActivitySpecificFields(),
              ],
              const SizedBox(height: 32),

              // Save Button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _saveActivity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save Activity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}