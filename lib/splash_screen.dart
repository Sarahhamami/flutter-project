import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_application_1/user/login_page.dart';
import 'package:flutter_application_1/home_page.dart';
import 'package:flutter_application_1/user/current_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/user_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _userRepo = UserRepository();

  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 5)); // splash delay

    final prefs = await SharedPreferences.getInstance();
    final rememberedEmail = prefs.getString('remembered_email');

    if (rememberedEmail != null) {
      final user = await _userRepo.getUserByEmail(rememberedEmail);
      if (user != null) {
        CurrentUser().setUser(user);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
        return;
      }
    }

    // if no user remembered → go to SignUp or Login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/splash.png',
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
