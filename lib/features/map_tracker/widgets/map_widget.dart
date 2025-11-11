import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/map_service.dart';

class MapWidget extends StatefulWidget {
  final Function(latlong.LatLng)? onLocationSelected;
  final latlong.LatLng? initialLocation;
  final List<Marker> markers;
  final List<Polyline> polylines;

  const MapWidget({
    Key? key,
    this.onLocationSelected,
    this.initialLocation,
    this.markers = const [],
    this.polylines = const [],
  }) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late MapController _mapController;
  latlong.LatLng? _currentLocation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      latlong.LatLng? location = await MapService.getCurrentLocation();
      if (location != null) {
        setState(() {
          _currentLocation = location;
        });
        // Move map after controller is initialized
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _mapController != null) {
            _mapController.move(location, 15);
          }
        });
      } else {
        // Default location if geolocation fails
        setState(() {
          _currentLocation = const latlong.LatLng(48.8566, 2.3522); // Paris
        });
      }
    } catch (e) {
      print('Error initializing location: $e');
      setState(() {
        _currentLocation = const latlong.LatLng(48.8566, 2.3522); // Paris
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onTap(latlong.LatLng position) {
    widget.onLocationSelected?.call(position);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Ensure we have a valid location before showing the map
    final targetLocation = widget.initialLocation ?? _currentLocation ?? const latlong.LatLng(48.8566, 2.3522);

    return Container(
      color: Colors.grey[200],
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: targetLocation,
          zoom: 15.0,
          onTap: (_, position) => _onTap(position),
          // Simplified options
          maxZoom: 18.0,
          minZoom: 3.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.flutter_application_1',
          ),
          MarkerLayer(markers: widget.markers),
          PolylineLayer(polylines: widget.polylines),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}