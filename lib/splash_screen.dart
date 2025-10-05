import 'package:flutter/material.dart';
import 'package:flutter_application_1/com/articles_display.dart';
import 'dart:async';

import 'package:flutter_application_1/user/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // 🔹 Navigate to login page after 3 seconds
    Timer(const Duration(seconds: 7), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ArticlesDisplay()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/splash.png', // Replace with your splash image
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
