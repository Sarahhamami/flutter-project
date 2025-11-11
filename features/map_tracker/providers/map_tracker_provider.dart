import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/route.dart';
import '../services/map_tracker_service.dart';

class MapTrackerProvider extends ChangeNotifier {
  final MapTrackerService _service = MapTrackerService();

  List<Route> _routes = [];
  List<Route> _todayRoutes = [];
  bool _isLoading = false;
  bool _isTracking = false;
  List<LatLng> _currentRoutePoints = [];
  DateTime? _trackingStartTime;
  Position? _currentPosition;

  // Getters
  List<Route> get routes => _routes;
  List<Route> get todayRoutes => _todayRoutes;
  bool get isLoading => _isLoading;
  bool get isTracking => _isTracking;
  List<LatLng> get currentRoutePoints => _currentRoutePoints;
  Position? get currentPosition => _currentPosition;

  int get todayTotalSteps => _todayRoutes.fold(0, (sum, route) => sum + route.steps);
  double get todayTotalDistance => _todayRoutes.fold(0.0, (sum, route) => sum + route.distance);

  // Initialisation
  Future<void> initialize() async {
    await loadRoutes();
    await loadTodayRoutes();
  }

  // Charger tous les parcours
  Future<void> loadRoutes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _routes = await _service.getAllRoutes();
    } catch (e) {
      print('Erreur lors du chargement des parcours: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger les parcours du jour
  Future<void> loadTodayRoutes() async {
    try {
      _todayRoutes = await _service.getTodayRoutes();
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement des parcours du jour: $e');
    }
  }

  // Démarrer le suivi GPS
  Future<bool> startTracking() async {
    try {
      // Vérifier les permissions
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

      // Obtenir la position actuelle
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _isTracking = true;
      _currentRoutePoints = [LatLng(_currentPosition!.latitude, _currentPosition!.longitude)];
      _trackingStartTime = DateTime.now();

      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur lors du démarrage du suivi: $e');
      return false;
    }
  }

  // Arrêter le suivi GPS
  Future<void> stopTracking() async {
    _isTracking = false;
    notifyListeners();
  }

  // Ajouter un point au parcours actuel
  void addRoutePoint(LatLng point) {
    if (_isTracking) {
      _currentRoutePoints.add(point);
      notifyListeners();
    }
  }

  // Sauvegarder le parcours actuel
  Future<bool> saveCurrentRoute(String name) async {
    if (!_isTracking || _currentRoutePoints.length < 2 || _trackingStartTime == null) {
      return false;
    }

    try {
      final duration = DateTime.now().difference(_trackingStartTime!);
      final route = _service.createRoute(
        name: name,
        points: _currentRoutePoints,
        duration: duration,
      );

      final success = await _service.saveRoute(route);
      if (success) {
        await loadRoutes();
        await loadTodayRoutes();
        _resetTracking();
      }
      return success;
    } catch (e) {
      print('Erreur lors de la sauvegarde du parcours: $e');
      return false;
    }
  }

  // Supprimer un parcours
  Future<bool> deleteRoute(String routeId) async {
    try {
      final success = await _service.deleteRoute(routeId);
      if (success) {
        await loadRoutes();
        await loadTodayRoutes();
      }
      return success;
    } catch (e) {
      print('Erreur lors de la suppression du parcours: $e');
      return false;
    }
  }

  // Réinitialiser le suivi
  void _resetTracking() {
    _isTracking = false;
    _currentRoutePoints = [];
    _trackingStartTime = null;
    _currentPosition = null;
    notifyListeners();
  }

  // Obtenir la position actuelle
  Future<Position?> getCurrentPosition() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      notifyListeners();
      return _currentPosition;
    } catch (e) {
      print('Erreur lors de l\'obtention de la position: $e');
      return null;
    }
  }

  // Calculer la distance du parcours actuel
  double get currentRouteDistance {
    return Route.calculateDistance(_currentRoutePoints);
  }

  // Calculer les pas du parcours actuel
  int get currentRouteSteps {
    return Route.convertDistanceToSteps(currentRouteDistance);
  }

  // Durée du suivi actuel
  Duration get currentTrackingDuration {
    if (_trackingStartTime == null) return Duration.zero;
    return DateTime.now().difference(_trackingStartTime!);
  }
}