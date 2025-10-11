import 'package:flutter/material.dart';
import 'package:flutter_application_1/Appointments/add_appointment_page.dart';
import 'package:flutter_application_1/Appointments/appointment_details_page.dart';
import 'package:flutter_application_1/repositories/appointment_repository.dart';


class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final _appointmentRepo = AppointmentRepository();
  List<Map<String, dynamic>> _appointments = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final data = await _appointmentRepo.getAllAppointments();
    setState(() {
      _appointments = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        backgroundColor: const Color(0xFF0dcaf0),
      ),
      body: _appointments.isEmpty
          ? const Center(child: Text("No appointments yet 🕒"))
          : ListView.builder(
              itemCount: _appointments.length,
              itemBuilder: (context, index) {
                final appt = _appointments[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  child: ListTile(
  title: Text("${appt['date_rdv']} at ${appt['heure_rdv']}"),
  subtitle: Text("Status: ${appt['statut']}"),
  trailing: const Icon(Icons.calendar_today, color: Colors.teal),
  onTap: () async {
    // Open details page when tapped
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AppointmentDetailsPage(appointment: appt),
      ),
    );
    // Refresh appointments list in case user cancelled it
    _loadAppointments();
  },
),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF20c997),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAppointmentPage()),
          );
          _loadAppointments(); // Refresh list after adding
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
