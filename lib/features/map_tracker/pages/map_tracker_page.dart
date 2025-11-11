import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import '../../../providers/activity_provider.dart';
import '../models/route_data.dart';
import '../services/map_service.dart';
import '../services/steps_converter.dart';
import '../widgets/map_widget.dart';
import '../widgets/route_selector.dart';
import '../widgets/distance_calculator.dart';
import '../../../app_colors.dart';

class MapTrackerPage extends StatefulWidget {
  const MapTrackerPage({Key? key}) : super(key: key);

  @override
  State<MapTrackerPage> createState() => _MapTrackerPageState();
}

class _MapTrackerPageState extends State<MapTrackerPage> {
  bool _isMapsAvailable = true;
  bool _isLoading = true;
  String? _errorMessage;
  latlong.LatLng? _startPoint;
  latlong.LatLng? _endPoint;
  RouteData? _routeData;
  List<Marker> _markers = [];
  List<Polyline> _polylines = [];
  String _instruction = 'Appuyez pour définir le point de départ';

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    setState(() => _isLoading = true);

    try {
      // Initialize location services
      await _initializeLocation();
      // Add a small delay to ensure map is properly initialized
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _isMapsAvailable = true;
        _isLoading = false;
      });
    } catch (e) {
      print('Map initialization error: $e');
      setState(() {
        _isMapsAvailable = false;
        _isLoading = false;
        _errorMessage = 'Erreur lors du chargement de la carte. Veuillez réessayer.';
      });
    }
  }

  Future<void> _initializeLocation() async {
    latlong.LatLng? currentLocation = await MapService.getCurrentLocation();
    if (currentLocation != null) {
      // Optionally center map on current location
    }
  }

  void _onLocationSelected(latlong.LatLng position) {
    setState(() {
      if (_startPoint == null) {
        _startPoint = position;
        _instruction = 'Maintenant choisissez le point d\'arrivée';
        _updateMarkers();
      } else if (_endPoint == null) {
        _endPoint = position;
        _calculateRoute();
      }
    });
  }

  void _calculateRoute() {
    if (_startPoint != null && _endPoint != null) {
      _routeData = MapService.createRoute(_startPoint!, _endPoint!);
      _updateMarkers();
      _updatePolylines();
      setState(() {});
    }
  }

  void _updateMarkers() {
    _markers = [];

    if (_startPoint != null) {
      _markers.add(
        Marker(
          point: _startPoint!,
          child: const Icon(
            Icons.location_on,
            color: Colors.green,
            size: 40,
          ),
        ),
      );
    }

    if (_endPoint != null) {
      _markers.add(
        Marker(
          point: _endPoint!,
          child: const Icon(
            Icons.location_on,
            color: Colors.blue,
            size: 40,
          ),
        ),
      );
    }
  }

  void _updatePolylines() {
    if (_routeData != null) {
      _polylines = [
        Polyline(
          points: _routeData!.polylinePoints,
          color: AppColors.primary,
          strokeWidth: 5.0,
        ),
      ];
    }
  }

  void _clearRoute() {
    setState(() {
      _startPoint = null;
      _endPoint = null;
      _routeData = null;
      _markers = [];
      _polylines = [];
      _instruction = 'Appuyez pour définir le point de départ';
    });
  }

  Future<void> _addStepsToActivity() async {
    if (_routeData != null) {
      final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
      final success = await activityProvider.addStepsFromRoute(
        _routeData!.estimatedSteps,
        _routeData!.distanceKm,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_routeData!.estimatedSteps} pas ajoutés à votre activité du jour !',
            ),
            backgroundColor: AppColors.primary,
          ),
        );

        // Clear route and navigate back with success result
        _clearRoute();
        Navigator.of(context).pop(true); // Return true to indicate steps were added
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'ajout des pas'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tracker Parcours'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isMapsAvailable) {
      return _buildManualMode();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracker Parcours'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Map
            SizedBox.expand(
              child: MapWidget(
                onLocationSelected: _onLocationSelected,
                markers: _markers,
                polylines: _polylines,
              ),
            ),

            // Controls overlay
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    RouteSelector(
                      startPoint: _startPoint,
                      endPoint: _endPoint,
                      onClearRoute: _clearRoute,
                      instruction: _instruction,
                    ),
                    if (_routeData != null) ...[
                      const SizedBox(height: 16),
                      DistanceCalculator(
                        routeData: _routeData,
                        onAddToSteps: _addStepsToActivity,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Current location button (additional overlay if needed)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () async {
                  latlong.LatLng? currentLocation = await MapService.getCurrentLocation();
                  if (currentLocation != null) {
                    // Center map on current location
                    // This would require passing controller to MapWidget
                  }
                },
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.my_location),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualMode() {
    final TextEditingController _distanceController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracker Parcours - Mode Manuel'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Carte non disponible',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'La carte Google Maps n\'est pas configurée. Utilisez le mode manuel pour saisir votre distance.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _distanceController,
              decoration: InputDecoration(
                labelText: 'Distance parcourue (km)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixText: 'km',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final distanceText = _distanceController.text;
                if (distanceText.isNotEmpty) {
                  final distance = double.tryParse(distanceText);
                  if (distance != null && distance > 0) {
                    final steps = (distance * 1312).round();
                    final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
                    await activityProvider.addStepsFromRoute(steps, distance);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$steps pas ajoutés à votre activité !'),
                        backgroundColor: AppColors.primary,
                      ),
                    );

                    Navigator.of(context).pop(true); // Return true to indicate steps were added
                  }
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Ajouter les pas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // TODO: Open Google Maps API setup guide
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Guide de configuration Google Maps à venir'),
                  ),
                );
              },
              child: const Text('Comment configurer Google Maps ?'),
            ),
          ],
        ),
      ),
    );
  }
}