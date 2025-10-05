import 'package:flutter/material.dart';
import 'package:flutter_application_1/user/current_user.dart';
import '../user/login_page.dart';
import '../user/profile_page.dart';

PreferredSizeWidget customAppBar(BuildContext context) {
  final user = CurrentUser().getUser();
  final firstName = user?['prenom'] ?? 'Guest';

  return AppBar(
    backgroundColor: const Color(0xFF20c997),
    title: Text('Welcome $firstName'),
    actions: [
      PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'Profile') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
          } else if (value == 'Logout') {
            CurrentUser().clear();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'Profile', child: Text('Profile')),
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
                  color: Color(0xFF20c997), fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    ],
  );
}
