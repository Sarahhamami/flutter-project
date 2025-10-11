class WellnessService {
  // Breathing exercises
  Future<List<Map<String, dynamic>>> getBreathingExercises() async {
    await Future.delayed(Duration(milliseconds: 500));
    return [
      {
        'id': 1,
        'title': 'Box Breathing',
        'duration': 5,
        'description': 'Inhale 4s, hold 4s, exhale 4s, pause 4s',
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
        'steps': [
          'Sit in meditation position',
          'Close your right nostril with your right thumb',
          'Inhale through your left nostril',
          'Close your left nostril with your right ring finger',
          'Exhale through your right nostril',
          'Repeat alternating'
        ]
      }
    ];
  }

  // Guided meditations
  Future<List<Map<String, dynamic>>> getMeditationSessions() async {
    await Future.delayed(Duration(milliseconds: 500));
    return [
      {
        'id': 1,
        'title': 'Morning Meditation',
        'duration': 10,
        'type': 'Energy',
        'description': 'Start your day with energy and clarity'
      },
      {
        'id': 2,
        'title': 'Deep Relaxation',
        'duration': 15,
        'type': 'Relaxation',
        'description': 'Release tensions and find inner peace'
      },
      {
        'id': 3,
        'title': 'Peaceful Sleep',
        'duration': 20,
        'type': 'Sleep',
        'description': 'Prepare for a restful night of sleep'
      },
      {
        'id': 4,
        'title': 'Anti-Stress',
        'duration': 12,
        'type': 'Stress Relief',
        'description': 'Reduce anxiety and daily stress'
      }
    ];
  }
}