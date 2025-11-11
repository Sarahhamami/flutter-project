import 'package:latlong2/latlong.dart' as latlong;

class RouteData {
  final latlong.LatLng startPoint;
  final latlong.LatLng endPoint;
  final double distanceKm;
  final int estimatedSteps;
  final double estimatedCalories;
  final List<latlong.LatLng> polylinePoints;
  final String? duration;

  RouteData({
    required this.startPoint,
    required this.endPoint,
    required this.distanceKm,
    required this.estimatedSteps,
    required this.estimatedCalories,
    required this.polylinePoints,
    this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'startPoint': {'lat': startPoint.latitude, 'lng': startPoint.longitude},
      'endPoint': {'lat': endPoint.latitude, 'lng': endPoint.longitude},
      'distanceKm': distanceKm,
      'estimatedSteps': estimatedSteps,
      'estimatedCalories': estimatedCalories,
      'polylinePoints': polylinePoints.map((point) => {'lat': point.latitude, 'lng': point.longitude}).toList(),
      'duration': duration,
    };
  }

  factory RouteData.fromJson(Map<String, dynamic> json) {
    return RouteData(
      startPoint: latlong.LatLng(json['startPoint']['lat'], json['startPoint']['lng']),
      endPoint: latlong.LatLng(json['endPoint']['lat'], json['endPoint']['lng']),
      distanceKm: json['distanceKm'],
      estimatedSteps: json['estimatedSteps'],
      estimatedCalories: json['estimatedCalories'],
      polylinePoints: (json['polylinePoints'] as List).map((point) => latlong.LatLng(point['lat'], point['lng'])).toList(),
      duration: json['duration'],
    );
  }
}