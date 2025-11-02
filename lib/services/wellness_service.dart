class WellnessService {
  // Breathing exercises - Enhanced with categories and popularity
  Future<List<Map<String, dynamic>>> getBreathingExercises() async {
    await Future.delayed(Duration(milliseconds: 500));
    return [
      {
        'id': 1,
        'title': 'Box Breathing',
        'duration': 5,
        'description': 'Inhale 4s, hold 4s, exhale 4s, pause 4s',
        'type': 'Stress Relief',
        'popularity': 4.8,
        'steps': [
          'Inhale deeply through your nose for 4 seconds',
          'Hold your breath for 4 seconds',
          'Exhale slowly through your mouth for 4 seconds',
          'Remain without breathing for 4 seconds',
          'Repeat the cycle for 5 minutes'
        ]
      },
      {
        'id': 2,
        'title': 'Deep Breathing',
        'duration': 10,
        'description': 'Abdominal breathing to relax',
        'type': 'Relaxation',
        'popularity': 4.5,
        'steps': [
          'Sit comfortably or lie down',
          'Place one hand on your stomach',
          'Inhale slowly through your nose while expanding your stomach',
          'Exhale through your mouth while contracting your stomach',
          'Focus on the movement of your hand'
        ]
      },
      {
        'id': 3,
        'title': 'Alternate Nostril Breathing',
        'duration': 7,
        'description': 'Nadi Shodhana to balance energy',
        'type': 'Energy',
        'popularity': 4.2,
        'steps': [
          'Sit in meditation position',
          'Close your right nostril with your right thumb',
          'Inhale through your left nostril',
          'Close your left nostril with your right ring finger',
          'Exhale through your right nostril',
          'Repeat alternating'
        ]
      },
      {
        'id': 4,
        'title': '4-7-8 Breathing',
        'duration': 8,
        'description': 'Calming technique for better sleep',
        'type': 'Sleep',
        'popularity': 4.7,
        'steps': [
          'Inhale through your nose for 4 seconds',
          'Hold your breath for 7 seconds',
          'Exhale through your mouth for 8 seconds',
          'Repeat 4 times'
        ]
      }
    ];
  }

  // Guided meditations - Enhanced with categories
  Future<List<Map<String, dynamic>>> getMeditationSessions() async {
    await Future.delayed(Duration(milliseconds: 500));
    return [
      {
        'id': 1,
        'title': 'Morning Meditation',
        'duration': 10,
        'type': 'Energy',
        'popularity': 4.6,
        'description': 'Start your day with energy and clarity'
      },
      {
        'id': 2,
        'title': 'Deep Relaxation',
        'duration': 15,
        'type': 'Relaxation',
        'popularity': 4.9,
        'description': 'Release tensions and find inner peace'
      },
      {
        'id': 3,
        'title': 'Peaceful Sleep',
        'duration': 20,
        'type': 'Sleep',
        'popularity': 4.8,
        'description': 'Prepare for a restful night of sleep'
      },
      {
        'id': 4,
        'title': 'Anti-Stress',
        'duration': 12,
        'type': 'Stress Relief',
        'popularity': 4.7,
        'description': 'Reduce anxiety and daily stress'
      },
      {
        'id': 5,
        'title': 'Focus & Concentration',
        'duration': 8,
        'type': 'Focus',
        'popularity': 4.4,
        'description': 'Improve your focus and mental clarity'
      }
    ];
  }

  // Get analytics data
  Future<Map<String, dynamic>> getAnalyticsData(int userId) async {
    await Future.delayed(Duration(milliseconds: 300));
    return {
      'sleepTrend': [7.2, 6.8, 7.5, 7.1, 6.9, 7.3, 7.0],
      'moodTrend': [7, 6, 8, 7, 9, 8, 7],
      'stressTrend': [4, 5, 3, 4, 2, 3, 4],
      'energyTrend': [6, 5, 7, 6, 8, 7, 6],
      'weeklyGoals': {
        'sleep': {'target': 49, 'achieved': 42, 'unit': 'hours'},
        'meditation': {'target': 7, 'achieved': 5, 'unit': 'sessions'},
        'exercise': {'target': 5, 'achieved': 3, 'unit': 'days'},
      },
      'insights': [
        'Your sleep quality improved by 15% this week',
        'You meditated 5 times this week - great consistency!',
        'Try to go to bed 30 minutes earlier for better rest'
      ]
    };
  }

  // Get notifications
  Future<List<Map<String, dynamic>>> getPendingNotifications() async {
    await Future.delayed(Duration(milliseconds: 200));
    return [
      {
        'id': 1,
        'title': 'Time for Meditation',
        'message': 'Your daily meditation session is due',
        'type': 'reminder',
        'time': '09:00 AM',
        'read': false
      },
      {
        'id': 2,
        'title': 'Sleep Reminder',
        'message': 'Remember to log your sleep from last night',
        'type': 'reminder',
        'time': '08:00 AM',
        'read': true
      },
      {
        'id': 3,
        'title': 'Weekly Progress',
        'message': 'You achieved 85% of your wellness goals this week!',
        'type': 'achievement',
        'time': 'Yesterday',
        'read': false
      },
      {
        'id': 4,
        'title': 'New Exercise Available',
        'message': 'Check out the new 4-7-8 breathing technique for better sleep',
        'type': 'update',
        'time': '2 days ago',
        'read': true
      }
    ];
  }
}