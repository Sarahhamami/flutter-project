import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPoint {
  final LatLng coordinates;
  final String? address;
  final String type; // 'start' or 'end'

  LocationPoint({
    required this.coordinates,
    this.address,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'coordinates': {'lat': coordinates.latitude, 'lng': coordinates.longitude},
      'address': address,
      'type': type,
    };
  }

  factory LocationPoint.fromJson(Map<String, dynamic> json) {
    return LocationPoint(
      coordinates: LatLng(json['coordinates']['lat'], json['coordinates']['lng']),
      address: json['address'],
      type: json['type'],
    );
  }
}