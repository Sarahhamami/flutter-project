import 'package:flutter/material.dart';

class OnboardingPage3 extends StatelessWidget {
  const OnboardingPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('assets/images/stats.png', height: 200),
        const SizedBox(height: 20),
        const Text(
          'Visualisez vos progrès',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          'Analysez vos statistiques avec des graphiques simples et motivants.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
