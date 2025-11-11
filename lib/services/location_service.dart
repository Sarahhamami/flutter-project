import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static Future<bool> requestLocationPermission() async {
    // Check current permission status
    var status = await Permission.location.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      // Request permission
      status = await Permission.location.request();
      if (status.isGranted) {
        return true;
      }
    }

    if (status.isPermanentlyDenied) {
      // Open app settings
      await openAppSettings();
      return false;
    }

    return false;
  }

  static Future<Position?> getCurrentPosition() async {
    try {
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }

  static Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );
  }
}