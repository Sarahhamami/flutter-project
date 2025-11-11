import 'package:latlong2/latlong.dart';

class Route {
  final String id;
  final String name;
  final DateTime date;
  final List<LatLng> points;
  final double distance; // en km
  final int steps; // nombre de pas calculés
  final Duration duration;
  final double averageSpeed; // km/h

  Route({
    required this.id,
    required this.name,
    required this.date,
    required this.points,
    required this.distance,
    required this.steps,
    required this.duration,
    required this.averageSpeed,
  });

  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(
      id: json['id'],
      name: json['name'],
      date: DateTime.parse(json['date']),
      points: (json['points'] as List).map((point) =>
        LatLng(point['lat'], point['lng'])).toList(),
      distance: json['distance'],
      steps: json['steps'],
      duration: Duration(seconds: json['durationSeconds']),
      averageSpeed: json['averageSpeed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'points': points.map((point) => {
        'lat': point.latitude,
        'lng': point.longitude,
      }).toList(),
      'distance': distance,
      'steps': steps,
      'durationSeconds': duration.inSeconds,
      'averageSpeed': averageSpeed,
    };
  }

  // Calculer la distance totale en km
  static double calculateDistance(List<LatLng> points) {
    if (points.length < 2) return 0.0;

    const Distance distance = Distance();
    double totalDistance = 0.0;

    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += distance.as(
        LengthUnit.Kilometer,
        points[i],
        points[i + 1],
      );
    }

    return totalDistance;
  }

  // Convertir la distance en pas (approximation : 1 km = 1300 pas)
  static int convertDistanceToSteps(double distanceKm) {
    const double stepsPerKm = 1300; // Approximation moyenne
    return (distanceKm * stepsPerKm).round();
  }

  // Calculer la vitesse moyenne
  static double calculateAverageSpeed(double distanceKm, Duration duration) {
    if (duration.inSeconds == 0) return 0.0;
    return distanceKm / (duration.inHours);
  }
}