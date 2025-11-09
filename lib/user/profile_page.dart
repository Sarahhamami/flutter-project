import 'package:flutter/material.dart';
import 'package:flutter_application_1/Appointments/appointments_page.dart';
import 'package:flutter_application_1/com/articles_display.dart';
import 'package:flutter_application_1/com/friends_list_page.dart';
import 'package:flutter_application_1/com/navbar.dart';
import 'package:flutter_application_1/custom_app_bar.dart';
import 'package:flutter_application_1/custom_bottom.dart';
import 'package:flutter_application_1/repositories/user_repository.dart';
import 'package:flutter_application_1/user/update_profile_page.dart';
import '../user/current_user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final user = CurrentUser().getUser();
    final userRepo = UserRepository();

    if (user == null) {
      return Scaffold(
        appBar: customAppBar(context),
        body: const Center(child: Text("No user found.")),
      );
      
    }
  int _selectedIndex = 3;
  void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;
  });

  switch (index) {
    case 0: // Articles / Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ArticlesDisplay()),
      );
      break;

    case 1: // Friends
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FriendsListPage()),
      );
      break;

    case 2: // Appointments
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AppointmentsPage()),
      );
      break;

    case 3: // Profile
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
      break;

    default:
      break;
  }
}
    return Scaffold(
      appBar: customAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🧑‍🦱 Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF20c997),
              child: Text(
                user['prenom']![0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),
            Text(
              "${user['prenom']} ${user['nom']}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // 📝 Info
            _buildInfoRow("Email", user['email']),
            _buildInfoRow("Phone", user['telephone'] ?? "-"),
            _buildInfoRow("Address", user['adresse'] ?? "-"),
            _buildInfoRow("Gender", user['sexe']),
            _buildInfoRow("Role", user['role']),

            const SizedBox(height: 30),

            // 🔄 Update Profile Button
              ElevatedButton.icon(
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text("Update Profile",
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0DCAF0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
              ),
              onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const UpdateProfilePage()),
  );
},
            ),

            const SizedBox(height: 15),

            // ❌ Delete Profile Button
           ElevatedButton.icon(
              icon: const Icon(Icons.delete_forever, color: Colors.white),
              label: const Text("Delete Account",
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C757D),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
              ),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Confirm Deletion"),
                    content: const Text(
                        "Are you sure you want to delete your account? This action cannot be undone."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await userRepo.deleteUser(user['user_id']);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Account deleted successfully")),
                  );

                  // Clear current user and navigate to login
                  CurrentUser().clear();
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ],
        ),
      ),
                bottomNavigationBar: BottomNavBar(currentIndex: 3),

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
