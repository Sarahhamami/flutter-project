import 'package:flutter/material.dart';
import 'package:flutter_application_1/sos/analytics_page.dart';
import 'package:flutter_application_1/sos/emergency_contacts_page.dart';
import 'package:flutter_application_1/sos/medication_page.dart';
import 'package:flutter_application_1/sos/user_medical_record_page.dart';
import 'package:flutter_application_1/user/current_user.dart';
import '../user/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

PreferredSizeWidget customAppBar(BuildContext context) {
  final user = CurrentUser().getUser();
  final firstName = user?['prenom'] ?? 'Guest';

  return AppBar(
    backgroundColor: const Color(0xFF0dcaf0),
    title: const Text('Health Tracker'),
    actions: [
      PopupMenuButton<String>(
        onSelected: (value) async { // ✅ make the callback async
            if (value == 'Emergency Contacts') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EmergencyContactsPage()),
            );
          } 
           else if (value == 'Analytics') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AnalyticsPage()),
            );
          } else if (value == 'Medication') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MedicationPage()),
            );
          } else if (value == 'Medical Records') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UserMedicalRecordPage()),
            );
          }
          else if (value == 'Logout') {
            // ✅ clear remembered user
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('remembered_email');

            // ✅ clear current user info
            CurrentUser().clear();

            // ✅ navigate to login page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'Emergency Contacts', child: Text('Emergency Contacts')),
          PopupMenuItem(value: 'Medical Records', child: Text('Medical Records')),
          PopupMenuItem(value: 'Medication', child: Text('Medication')),
          PopupMenuItem(value: 'Analytics', child: Text('Analytics')),
          PopupMenuItem(value: 'Logout', child: Text('Logout')),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: Text(
              firstName.isNotEmpty ? firstName[0] : 'G',
              style: const TextStyle(
                color: Color(0xFF20c997),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
