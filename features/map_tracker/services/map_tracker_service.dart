import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/route.dart';

class MapTrackerService {
  static const String _routesKey = 'tracked_routes';

  // Sauvegarder un parcours
  Future<bool> saveRoute(Route route) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final routes = await getAllRoutes();

      // Vérifier si le parcours existe déjà
      final existingIndex = routes.indexWhere((r) => r.id == route.id);
      if (existingIndex != -1) {
        routes[existingIndex] = route;
      } else {
        routes.add(route);
      }

      final routesJson = routes.map((r) => r.toJson()).toList();
      final success = await prefs.setString(_routesKey, jsonEncode(routesJson));
      return success;
    } catch (e) {
      print('Erreur lors de la sauvegarde du parcours: $e');
      return false;
    }
  }

  // Récupérer tous les parcours
  Future<List<Route>> getAllRoutes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final routesJson = prefs.getString(_routesKey);

      if (routesJson == null) return [];

      final routesData = jsonDecode(routesJson) as List;
      return routesData.map((data) => Route.fromJson(data)).toList();
    } catch (e) {
      print('Erreur lors de la récupération des parcours: $e');
      return [];
    }
  }

  // Récupérer les parcours du jour
  Future<List<Route>> getTodayRoutes() async {
    final allRoutes = await getAllRoutes();
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    return allRoutes.where((route) {
      final routeDate = DateTime(route.date.year, route.date.month, route.date.day);
      return routeDate.isAtSameMomentAs(startOfDay);
    }).toList();
  }

  // Supprimer un parcours
  Future<bool> deleteRoute(String routeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final routes = await getAllRoutes();

      routes.removeWhere((route) => route.id == routeId);

      final routesJson = routes.map((r) => r.toJson()).toList();
      final success = await prefs.setString(_routesKey, jsonEncode(routesJson));
      return success;
    } catch (e) {
      print('Erreur lors de la suppression du parcours: $e');
      return false;
    }
  }

  // Calculer le total des pas pour aujourd'hui
  Future<int> getTodayTotalSteps() async {
    final todayRoutes = await getTodayRoutes();
    return todayRoutes.fold(0, (total, route) => total + route.steps);
  }

  // Calculer la distance totale pour aujourd'hui
  Future<double> getTodayTotalDistance() async {
    final todayRoutes = await getTodayRoutes();
    return todayRoutes.fold(0.0, (total, route) => total + route.distance);
  }

  // Créer un nouveau parcours avec des points
  Route createRoute({
    required String name,
    required List<dynamic> points, // Liste de LatLng
    required Duration duration,
  }) {
    final latLngPoints = points.cast<LatLng>();
    final distance = Route.calculateDistance(latLngPoints);
    final steps = Route.convertDistanceToSteps(distance);
    final averageSpeed = Route.calculateAverageSpeed(distance, duration);

    return Route(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      date: DateTime.now(),
      points: latLngPoints,
      distance: distance,
      steps: steps,
      duration: duration,
      averageSpeed: averageSpeed,
    );
  }
}