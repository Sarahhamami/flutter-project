import 'package:flutter/material.dart';
import 'package:flutter_application_1/custom_app_bar.dart';
import 'package:flutter_application_1/user/current_user.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = CurrentUser().getUser();
    final firstName = user?['prenom'] ?? 'Guest';

    return Scaffold(
      appBar: customAppBar(context),
      body: Center(
        child: Text(
          'Hello $firstName!',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
