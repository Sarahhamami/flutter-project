import 'package:flutter/material.dart';
import 'package:flutter_application_1/Appointments/add_appointment_page.dart';
import 'package:flutter_application_1/Appointments/appointment_details_page.dart';
import 'package:flutter_application_1/repositories/appointment_repository.dart';
import 'package:flutter_application_1/user/current_user.dart';
import 'package:intl/intl.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final _appointmentRepo = AppointmentRepository();
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _filteredAppointments = [];

  final TextEditingController _searchController = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _updateStatus(int id, String newStatus) async {
    await _appointmentRepo.updateAppointmentStatus(id, newStatus);
    _loadAppointments();
  }

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final user = CurrentUser().getUser();
    final role = user?['role']; // e.g. 'Patient' or 'Doctor'
    final id = user?['user_id'];
    print("Role: $role, user_id: $id");

    List<Map<String, dynamic>> data = [];

    if (role == 'Doctor') {
      data = await _appointmentRepo.getAppointmentsByDoctor(id);
    } else {
      data = await _appointmentRepo.getAppointmentsByPatient(id);
    }

    setState(() {
      _appointments = data;
      _filteredAppointments = data;
    });

    print("Loaded appointments for $role $id: $data");
  }

  // 🔍 Search by name depending on role
  void _searchAppointments(String query) {
    final user = CurrentUser().getUser();
    final isDoctor = user?['role'] == 'Doctor';
    final lowerQuery = query.toLowerCase();

    setState(() {
      _filteredAppointments = _appointments.where((appt) {
        if (isDoctor) {
          // Doctor searches by patient name
          final patientName =
              "${appt['patient_prenom']} ${appt['patient_nom']}".toLowerCase();
          return patientName.contains(lowerQuery);
        } else {
          // Patient searches by doctor name
          final doctorName =
              "${appt['medecin_prenom']} ${appt['medecin_nom']}".toLowerCase();
          return doctorName.contains(lowerQuery);
        }
      }).toList();
    });
  }

  // 📅 Filter by date
  void _filterByDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _filteredAppointments = _appointments.where((appt) {
        final apptDate = DateTime.parse(appt['date_rdv']);
        return apptDate.year == date.year &&
            apptDate.month == date.month &&
            apptDate.day == date.day;
      }).toList();
    });
  }

  // ♻️ Clear date filter
  void _clearFilter() {
    setState(() {
      _selectedDate = null;
      _filteredAppointments = _appointments;
    });
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF20c997);
    const blue = Color(0xFF0dcaf0);
    final gray = Colors.grey.shade300;

    final user = CurrentUser().getUser();
    final isDoctor = user?['role'] == 'Doctor';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        backgroundColor: blue,
      ),
      body: Column(
        children: [
          // 🔍 Search bar + Filter
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Search bar
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _searchAppointments,
                    decoration: InputDecoration(
                      hintText: isDoctor
                          ? 'Search by patient name...'
                          : 'Search by doctor name...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: gray.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Filter button
                IconButton(
                  icon: Icon(Icons.filter_alt,
                      color: _selectedDate != null ? green : Colors.grey),
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      _filterByDate(picked);
                    }
                  },
                ),

                // Clear button if filter active
                if (_selectedDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.redAccent),
                    onPressed: _clearFilter,
                  ),
              ],
            ),
          ),

          // 📋 Appointment list
          Expanded(
            child: _filteredAppointments.isEmpty
                ? const Center(child: Text("No appointments found 🕒"))
                : ListView.builder(
                    itemCount: _filteredAppointments.length,
                    itemBuilder: (context, index) {
                      final appt = _filteredAppointments[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 12),
                        child: ListTile(
                          title: Text(
                            isDoctor
                                ? "${appt['patient_prenom']} ${appt['patient_nom']}"
                                : "Dr. ${appt['medecin_prenom']} ${appt['medecin_nom']}",
                            style:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "${appt['date_rdv']} • ${appt['heure_rdv']}\nStatus: ${appt['statut']}",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: isDoctor
                              ? PopupMenuButton<String>(
                                  icon: const Icon(Icons.edit,
                                      color: Color(0xFF0dcaf0)),
                                  onSelected: (value) => _updateStatus(
                                      appt['appointment_id'], value),
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                        value: 'Scheduled',
                                        child: Text('Scheduled')),
                                    PopupMenuItem(
                                        value: 'Confirmed',
                                        child: Text('Confirmed')),
                                
                                    PopupMenuItem(
                                        value: 'Cancelled',
                                        child: Text('Cancelled')),
                                  ],
                                )
                              : const Icon(Icons.calendar_today,
                                  color: Color(0xFF20c997)),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AppointmentDetailsPage(appointment: appt),
                              ),
                            );
                            _loadAppointments();
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      // Remove Add button for doctors
      floatingActionButton: isDoctor
          ? null
          : FloatingActionButton(
              backgroundColor: green,
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddAppointmentPage()),
                );
                _loadAppointments();
              },
              child: const Icon(Icons.add),
            ),
    );
  }
}
