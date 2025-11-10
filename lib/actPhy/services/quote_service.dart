import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class QuoteService {
  static final List<String> motivationalQuotes = [
    "💪 Keep pushing! Every rep brings you closer to your goals!",
    "🔥 You're stronger than you think! Keep going!",
    "🏋️‍♂️ Fitness is not about being better than someone else. It's about being better than you used to be!",
    "🌟 One hour of exercise is just 4% of your day. No excuses!",
    "🚀 The only bad workout is the one that didn't happen!",
    "💯 You didn't come this far to only come this far!",
    "🏃‍♂️ Sweat is just fat crying! Keep it up!",
    "🔥 Your body achieves what your mind believes!",
    "💪 The pain you feel today will be the strength you feel tomorrow!",
    "🌟 Fitness is not a destination, it's a way of life!"
  ];

  static void showRandomQuote() {
    final random = Random();
    final randomQuote = motivationalQuotes[random.nextInt(motivationalQuotes.length)];
    
    Fluttertoast.showToast(
      msg: randomQuote,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: const Color(0xFF20c997), // Teal color for mobile
      textColor: Colors.white,
      fontSize: 16.0,
      timeInSecForIosWeb: 0, // 0 means toast is displayed until closed
      webShowClose: true,
      webBgColor: "#20c997", // Teal color for web
      webPosition: "center",
    );
  }

  static void startQuoteTimer() {
    // Show first quote immediately
    showRandomQuote();
    
    // Then show a new quote every 30 seconds
    const thirtySeconds = Duration(seconds: 30);
    Timer.periodic(thirtySeconds, (timer) {
      showRandomQuote();
    });
  }
}
