import 'package:flutter/material.dart';

class OnboardingPage2 extends StatelessWidget {
  const OnboardingPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('assets/images/goals.png', height: 200),
        const SizedBox(height: 20),
        const Text(
          'Fixez vos objectifs',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          'Définissez vos objectifs quotidiens et hebdomadaires pour rester motivé.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
