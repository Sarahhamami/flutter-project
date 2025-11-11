import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latlong;
import '../models/route_data.dart';

class MapService {
  static const double EARTH_RADIUS = 6371.0; // Earth's radius in kilometers

  // Request location permission and get current position
  static Future<latlong.LatLng?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return latlong.LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  // Calculate distance between two points using Haversine formula
  static double calculateDistance(latlong.LatLng start, latlong.LatLng end) {
    double lat1Rad = start.latitude * (math.pi / 180);
    double lat2Rad = end.latitude * (math.pi / 180);
    double deltaLatRad = (end.latitude - start.latitude) * (math.pi / 180);
    double deltaLngRad = (end.longitude - start.longitude) * (math.pi / 180);

    double a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
               math.cos(lat1Rad) * math.cos(lat2Rad) *
               math.sin(deltaLngRad / 2) * math.sin(deltaLngRad / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return EARTH_RADIUS * c;
  }

  // Create a simple route with straight line (for demo purposes)
  // In a real app, you'd use routing service
  static RouteData createRoute(latlong.LatLng start, latlong.LatLng end) {
    double distance = calculateDistance(start, end);

    // Create polyline points (simple straight line for demo)
    List<latlong.LatLng> polylinePoints = [start, end];

    // For more accurate routing, you would use Google Directions API
    // This is a simplified version for demonstration

    int estimatedSteps = (distance * 1312).round();
    double estimatedCalories = estimatedSteps * 0.04;

    return RouteData(
      startPoint: start,
      endPoint: end,
      distanceKm: distance,
      estimatedSteps: estimatedSteps,
      estimatedCalories: estimatedCalories,
      polylinePoints: polylinePoints,
      duration: _estimateDuration(distance),
    );
  }

  // Estimate walking duration (rough estimate: 5 km/h average walking speed)
  static String _estimateDuration(double distanceKm) {
    double hours = distanceKm / 5.0; // 5 km/h average walking speed
    int totalMinutes = (hours * 60).round();

    if (totalMinutes < 60) {
      return '$totalMinutes min';
    } else {
      int hoursPart = totalMinutes ~/ 60;
      int minutesPart = totalMinutes % 60;
      return '${hoursPart}h ${minutesPart}min';
    }
  }

  // Check if location services are available
  static Future<bool> isLocationServiceAvailable() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check location permissions
  static Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  // Request location permissions
  static Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }
}