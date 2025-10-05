import 'package:flutter/material.dart';
import 'package:flutter_application_1/custom_app_bar.dart';
import '../user/current_user.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = CurrentUser().getUser();

    if (user == null) {
      return Scaffold(
        appBar: customAppBar(context),
        body: const Center(child: Text("No user found.")),
      );
    }

    return Scaffold(
      appBar: customAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF20c997),
              child: Text(
                user['prenom']![0].toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "${user['prenom']} ${user['nom']}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildInfoRow("Email", user['email']),
            _buildInfoRow("Phone", user['telephone'] ?? "-"),
            _buildInfoRow("Address", user['adresse'] ?? "-"),
            _buildInfoRow("Gender", user['sexe']),
            _buildInfoRow("Role", user['role']),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
