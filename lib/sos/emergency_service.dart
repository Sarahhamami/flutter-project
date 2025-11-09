import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../db/database_helper.dart';

class EmergencyService {
  static final EmergencyService _instance = EmergencyService._internal();
  factory EmergencyService() => _instance;
  EmergencyService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Check and request location permissions
  Future<bool> _checkLocationPermissions() async {
    try {
      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      return true;
    } catch (e) {
      print('❌ Error checking permissions: $e');
      return false;
    }
  }

  /// Get current user position (robust: high-accuracy with fallback)
  Future<Position?> getCurrentLocation() async {
    try {
      final bool hasPermission = await _checkLocationPermissions();
      if (!hasPermission) {
        print('Location permission or service not available');
        return null;
      }

      // 1) Try to get a fresh, high-accuracy fix quickly
      try {
        final Position fresh = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          timeLimit: const Duration(seconds: 8),
        );
        print('Fresh position: ${fresh.latitude}, ${fresh.longitude} (acc: ${fresh.accuracy} m)');
        return fresh;
      } on TimeoutException catch (_) {
        print('High-accuracy fix timed out; falling back to last known position');
      } catch (e) {
        print('High-accuracy fix error; falling back. Details: $e');
      }

      // 2) Fallback to last known position
      final Position? last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        print('Last known position: ${last.latitude}, ${last.longitude} (acc: ${last.accuracy} m)');
        return last;
      }

      // 3) As a final attempt, request a low-power fix
      try {
        final Position coarse = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 6),
        );
        print('Coarse position: ${coarse.latitude}, ${coarse.longitude} (acc: ${coarse.accuracy} m)');
        return coarse;
      } catch (e) {
        print('Coarse fix also failed: $e');
      }

      return null;
    } catch (e) {
      print('Error retrieving position: $e');
      return null;
    }
  }

  /// Get address from GPS coordinates
  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      // For a complete implementation, you could use a reverse geocoding service
      // like Google Maps Geocoding API or OpenStreetMap Nominatim
      return 'Lat: $latitude, Lng: $longitude';
    } catch (e) {
      print('Error retrieving address: $e');
      return null;
    }
  }

  /// Check internet connectivity
  Future<bool> _hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return !connectivityResult.contains(ConnectivityResult.none);
    } catch (e) {
      print('Error checking connectivity: $e');
      return false;
    }
  }

  /// Send SMS emergency alert when offline
  Future<void> _sendOfflineSMSAlert({
    required String phoneNumber,
    required String message,
    double? latitude,
    double? longitude,
  }) async {
    try {
      String smsMessage = 'EMERGENCY ALERT: $message';
      if (latitude != null && longitude != null) {
        smsMessage += ' Location: https://maps.google.com/?q=$latitude,$longitude';
      }

      final Uri smsUri = Uri(scheme: 'sms', path: phoneNumber, queryParameters: {'body': smsMessage});
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        print('✅ SMS emergency alert sent to $phoneNumber');
      } else {
        print('❌ Unable to send SMS to $phoneNumber');
      }
    } catch (e) {
      print('❌ Error sending SMS: $e');
    }
  }

  /// Save alert to local history
  Future<void> _saveAlertToHistory(Map<String, dynamic> alertData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alertsJson = prefs.getStringList('alert_history') ?? [];

      final alertJson = jsonEncode({
        ...alertData,
        'timestamp': DateTime.now().toIso8601String(),
        'date': DateTime.now().toString().split(' ')[0],
        'time': DateTime.now().toString().split(' ')[1].substring(0, 8),
      });

      alertsJson.add(alertJson);
      await prefs.setStringList('alert_history', alertsJson);

      print('✅ Alert saved to history');
    } catch (e) {
      print('❌ Error saving alert to history: $e');
    }
  }

  /// Send emergency alert with offline support
  Future<Map<String, dynamic>> sendEmergencyAlert({
    required int userId,
    String? customMessage,
  }) async {
    try {
      print('🚨 Starting emergency alert for user $userId');

      // Check internet connectivity
      final hasInternet = await _hasInternetConnection();
      print('📶 Internet connection: ${hasInternet ? 'Available' : 'Not available'}');
      
      // Try to get current position
      print('📍 Attempting to retrieve position...');
      Position? position;
      String? address;
      
      try {
        bool hasLocationPermission = await _checkLocationPermissions();
        if (hasLocationPermission) {
          position = await getCurrentLocation();
          if (position != null) {
            print('✅ Position obtained: ${position.latitude}, ${position.longitude}');
            address = await getAddressFromCoordinates(
              position.latitude, 
              position.longitude
            );
          }
        }
      } catch (e) {
        print('⚠️ Location not available: $e');
        // Continue without location
      }

      // Get user's first emergency contact
      print('📞 Retrieving emergency contacts...');
      List<Map<String, dynamic>> emergencyContacts = 
          await _dbHelper.getEmergencyContactsByUser(userId);
      
      String? contactName;
      String? contactPhone;
      
      if (emergencyContacts.isNotEmpty) {
        contactName = emergencyContacts.first['full_name'];
        contactPhone = emergencyContacts.first['phone'];
        print('✅ Emergency contact found: $contactName ($contactPhone)');
      } else {
        print('⚠️ No emergency contacts configured');
      }

      // Create alert in database
      print('💾 Saving alert to database...');
      int alertId = await _dbHelper.createEmergencyAlert(
        userId: userId,
        latitude: position?.latitude,
        longitude: position?.longitude,
        locationAddress: address ?? 'Position not available',
        alertMessage: customMessage ?? 'Emergency Alert - Help Needed!',
        contactName: contactName,
        contactPhone: contactPhone,
        predictedService: 'Ambulance', // Default
      );

      print('✅ Emergency alert created with ID: $alertId');

      // Save alert to local history
      await _saveAlertToHistory({
        'message': customMessage ?? 'Emergency Alert - Help Needed!',
        'location': address ?? 'Position not available',
        'contact_name': contactName,
        'contact_phone': contactPhone,
        'predicted_service': 'Ambulance',
        'latitude': position?.latitude,
        'longitude': position?.longitude,
      });

      // Always send SMS alert (both online and offline)
      if (contactPhone != null && contactPhone.isNotEmpty) {
        print('📱 Sending SMS alert to emergency contact...');
        await _sendOfflineSMSAlert(
          phoneNumber: contactPhone,
          message: customMessage ?? 'Emergency Alert - Help Needed!',
          latitude: position?.latitude,
          longitude: position?.longitude,
        );

        // Also try to call if online
        if (hasInternet) {
          print('📞 Online mode: Also attempting to call $contactPhone...');
          await _callEmergencyContact(contactPhone);
        }
      }

      String message;
      if (!hasInternet) {
        message = 'Emergency alert sent via SMS (offline mode)!';
      } else {
        message = position != null
            ? 'Emergency alert sent successfully with location!'
            : 'Emergency alert sent successfully (without location)!';
      }

      final String? mapsUrl = position != null
          ? 'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}'
          : null;

      return {
        'success': true,
        'alertId': alertId,
        'message': message,
        'contactCalled': contactPhone != null && contactPhone.isNotEmpty,
        'hasLocation': position != null,
        'isOfflineMode': !hasInternet,
        'latitude': position?.latitude,
        'longitude': position?.longitude,
        'mapsUrl': mapsUrl,
      };
    } catch (e) {
      print('❌ Error sending emergency alert: $e');
      return {
        'success': false,
        'error': 'Technical error: ${e.toString()}',
        'errorType': 'technical_error'
      };
    }
  }

  /// Call an emergency contact
  Future<void> _callEmergencyContact(String phoneNumber) async {
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        print('Unable to call number: $phoneNumber');
      }
    } catch (e) {
      print('Error during call: $e');
    }
  }

  /// Get emergency alert history for a user
  Future<List<Map<String, dynamic>>> getEmergencyHistory(int userId) async {
    return await _dbHelper.getEmergencyAlertsByUser(userId);
  }

  /// Update alert status
  Future<bool> updateAlertStatus(int alertId, String status) async {
    try {
      await _dbHelper.updateEmergencyAlertStatus(
        alertId: alertId,
        status: status,
      );
      return true;
    } catch (e) {
      print('Error updating status: $e');
      return false;
    }
  }

  /// Add an emergency contact
  Future<bool> addEmergencyContact({
    required int userId,
    required String fullName,
    required String phone,
    String? relation,
    int priority = 1,
  }) async {
    try {
      await _dbHelper.createEmergencyContact(
        userId: userId,
        fullName: fullName,
        phone: phone,
        relation: relation,
        priority: priority,
      );
      return true;
    } catch (e) {
      print('Error adding emergency contact: $e');
      return false;
    }
  }

  /// Get user's emergency contacts
  Future<List<Map<String, dynamic>>> getEmergencyContacts(int userId) async {
    return await _dbHelper.getEmergencyContactsByUser(userId);
  }

  /// Test version of emergency alert (without geolocation)
  Future<Map<String, dynamic>> sendTestEmergencyAlert({
    required int userId,
    String? customMessage,
  }) async {
    try {
      print('🧪 Testing emergency alert for user $userId');
      
      // Get user's first emergency contact
      print('📞 Retrieving emergency contacts...');
      List<Map<String, dynamic>> emergencyContacts = 
          await _dbHelper.getEmergencyContactsByUser(userId);
      
      String? contactName;
      String? contactPhone;
      
      if (emergencyContacts.isNotEmpty) {
        contactName = emergencyContacts.first['full_name'];
        contactPhone = emergencyContacts.first['phone'];
        print('✅ Emergency contact found: $contactName ($contactPhone)');
      } else {
        print('⚠️ No emergency contacts configured');
      }

      // Create alert in database (without geolocation)
      print('💾 Saving alert to database...');
      int alertId = await _dbHelper.createEmergencyAlert(
        userId: userId,
        latitude: null, // No geolocation for test
        longitude: null,
        locationAddress: 'Position not available (test mode)',
        alertMessage: customMessage ?? 'Emergency Alert TEST - Help Needed!',
        contactName: contactName,
        contactPhone: contactPhone,
        predictedService: 'Ambulance',
      );

      print('✅ Emergency alert TEST created with ID: $alertId');

      return {
        'success': true,
        'alertId': alertId,
        'message': 'Emergency alert TEST sent successfully!',
        'contactCalled': false, // No automatic call in test mode
        'isTest': true,
      };
    } catch (e) {
      print('❌ Error during emergency alert test: $e');
      return {
        'success': false,
        'error': 'Technical error: ${e.toString()}',
        'errorType': 'technical_error'
      };
    }
  }
}
