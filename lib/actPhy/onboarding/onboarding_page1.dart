import 'package:flutter/material.dart';

class OnboardingPage1 extends StatelessWidget {
  const OnboardingPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('assets/images/activity_tracking.png', height: 200),
        const SizedBox(height: 20),
        const Text(
          'Suivi de vos activités',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          'Enregistrez vos pas, distance, et calories brûlées manuellement ou via Google Fit.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
