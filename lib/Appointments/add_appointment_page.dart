import 'package:flutter/material.dart';
import '../repositories/appointment_repository.dart';
import '../repositories/user_repository.dart';
import '../user/current_user.dart';

class AddAppointmentPage extends StatefulWidget {
  const AddAppointmentPage({super.key});

  @override
  State<AddAppointmentPage> createState() => _AddAppointmentPageState();
}

class _AddAppointmentPageState extends State<AddAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _appointmentRepo = AppointmentRepository();
  final _userRepo = UserRepository();

  List<Map<String, dynamic>> _doctors = [];
  String? _selectedDoctorId;
  bool _isLoadingDoctors = true;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      final doctors = await _userRepo.getAllDoctors();
      setState(() {
        _doctors = doctors;
        _isLoadingDoctors = false;
      });
    } catch (e) {
      setState(() => _isLoadingDoctors = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading doctors: $e')),
      );
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = pickedDate.toIso8601String().split('T').first;
      });
    }
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _timeController.text =
            pickedTime.format(context); // formatted like "10:30 AM"
      });
    }
  }

  Future<void> _saveAppointment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDoctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a doctor 👨‍⚕️")),
      );
      return;
    }

    final user = CurrentUser().getUser();
    final appointment = {
      'patient_id': user?['user_id'],
      'medecin_id': int.parse(_selectedDoctorId!),
      'date_rdv': _dateController.text,
      'heure_rdv': _timeController.text,
      'statut': 'Scheduled',
    };

    await _appointmentRepo.insertAppointment(appointment);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Appointment added ✅')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Appointment'),
        backgroundColor: const Color(0xFF0dcaf0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _isLoadingDoctors
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedDoctorId,
                      decoration: const InputDecoration(
                        labelText: 'Select Doctor',
                        border: OutlineInputBorder(),
                      ),
                      items: _doctors.map((doc) {
                        return DropdownMenuItem<String>(
                          value: doc['user_id'].toString(),
                          child: Text(doc['nom'] ?? 'Unknown Doctor'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedDoctorId = value);
                      },
                      validator: (value) =>
                          value == null ? 'Please select a doctor' : null,
                    ),
                    const SizedBox(height: 20),

                    // 📅 Date picker
                    TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Select Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: _pickDate,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Choose a date' : null,
                    ),
                    const SizedBox(height: 15),

                    // ⏰ Time picker
                    TextFormField(
                      controller: _timeController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Select Time',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      onTap: _pickTime,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Choose a time' : null,
                    ),
                    const SizedBox(height: 30),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF20c997),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 50),
                      ),
                      onPressed: _saveAppointment,
                      child: const Text(
                        'Save Appointment',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
