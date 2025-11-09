import 'package:flutter/material.dart';
import 'package:flutter_application_1/custom_app_bar.dart';
import '../repositories/appointment_repository.dart';
import '../user/current_user.dart';

class AppointmentDetailsPage extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final AppointmentRepository _appointmentRepo = AppointmentRepository();

  AppointmentDetailsPage({super.key, required this.appointment});

  Future<void> _deleteAppointment(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _appointmentRepo.deleteAppointment(appointment['appointment_id']);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment cancelled ❌')),
      );
      Navigator.pop(context, true); // go back to list
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = CurrentUser().getUser();
    final isDoctor = user?['role'] == 'Doctor';

    return Scaffold(
      appBar: customAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Appointment Information',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 25),

                // ✅ Show names depending on role
                if (isDoctor)
                  Text(
                    'Patient: ${appointment['patient_nom']} ${appointment['patient_prenom']}',
                    style: const TextStyle(fontSize: 16),
                  )
                else
                  Text(
                    'Doctor: Dr. ${appointment['medecin_nom']} ${appointment['medecin_prenom']}',
                    style: const TextStyle(fontSize: 16),
                  ),

                Text('Date: ${appointment['date_rdv']}', style: const TextStyle(fontSize: 16)),
                Text('Time: ${appointment['heure_rdv']}', style: const TextStyle(fontSize: 16)),
                Text('Status: ${appointment['statut']}', style: const TextStyle(fontSize: 16)),

                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                    ),
                    onPressed: () => _deleteAppointment(context),
                    icon: const Icon(Icons.cancel, color: Colors.white),
                    label: const Text('Cancel Appointment', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
