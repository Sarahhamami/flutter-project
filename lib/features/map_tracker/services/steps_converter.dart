class StepsConverter {
  static const double STEPS_PER_KM = 1312.0; // Average steps per kilometer
  static const double CALORIES_PER_STEP = 0.04; // Average calories burned per step

  static int convertKmToSteps(double distanceKm) {
    if (distanceKm <= 0) return 0;
    return (distanceKm * STEPS_PER_KM).round();
  }

  static double estimateCaloriesBurned(int steps) {
    if (steps <= 0) return 0.0;
    return steps * CALORIES_PER_STEP;
  }

  static double convertStepsToKm(int steps) {
    if (steps <= 0) return 0.0;
    return steps / STEPS_PER_KM;
  }

  static String formatDistance(double distanceKm) {
    if (distanceKm < 1.0) {
      return '${(distanceKm * 1000).round()} m';
    } else {
      return '${distanceKm.toStringAsFixed(2)} km';
    }
  }

  static String formatSteps(int steps) {
    if (steps >= 1000) {
      return '${(steps / 1000).toStringAsFixed(1)}k';
    }
    return steps.toString();
  }

  static String formatCalories(double calories) {
    return calories.toStringAsFixed(0);
  }
}