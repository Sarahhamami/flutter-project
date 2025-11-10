import 'package:flutter/material.dart';
import 'package:flutter_application_1/actPhy/activit%C3%A9/accueilAP.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  final List<Map<String, String>> onboardingData = [
    {
      'animation': 'assets/lottie/activity.json',
      'title': 'Track your activity',
      'description':
          'Track your steps, distance, and calories burned manually or via Google Fit.'
    },
    {
      'animation': 'assets/lottie/goals.json',
      'title': 'Set your goals',
      'description':
          'Set your daily and weekly goals to stay motivated.'
    },
    {
      'animation': 'assets/lottie/stats.json',
      'title': 'Analyse your progress',
      'description':
          'View your statistics and track your performance over time.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 🔹 PageView with Lottie animations
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (index) {
                    setState(() => isLastPage = index == onboardingData.length - 1);
                  },
                  itemCount: onboardingData.length,
                  itemBuilder: (context, index) {
                    final page = onboardingData[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(page['animation']!, height: 250),
                        const SizedBox(height: 30),
                        Text(
                          page['title']!,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          page['description']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // 🔹 Dots indicator
              SmoothPageIndicator(
                controller: _controller,
                count: onboardingData.length,
                effect: const ExpandingDotsEffect(
                  activeDotColor: Colors.blue,
                  dotHeight: 10,
                  dotWidth: 10,
                  spacing: 8,
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => AccueilAP()),
                        );
                      },

                    child: const Text(
                      'Skip',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (isLastPage) {
                        Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => AccueilAP()),
                            );

                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(isLastPage ? 'Get started' : 'Next'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
