import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/map_tracker_provider.dart';
import '../models/route.dart';
import '../../themes/app_theme.dart';

class MapTrackerPage extends StatefulWidget {
  const MapTrackerPage({super.key});

  @override
  State<MapTrackerPage> createState() => _MapTrackerPageState();
}

class _MapTrackerPageState extends State<MapTrackerPage> {
  final MapController _mapController = MapController();
  bool _showRouteList = false;
  LatLng? _startPoint;
  LatLng? _endPoint;
  List<LatLng> _routePoints = [];
  double _distanceKm = 0.0;
  int _stepsCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapTrackerProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracker Parcours'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.darkGrey,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showRouteList ? Icons.map : Icons.list),
            onPressed: () {
              setState(() => _showRouteList = !_showRouteList);
            },
          ),
        ],
      ),
      body: Consumer<MapTrackerProvider>(
        builder: (context, provider, child) {
          if (_showRouteList) {
            return _buildRouteListView(provider);
          } else {
            return _buildMapView(provider);
          }
        },
      ),
    );
  }

  Widget _buildMapView(MapTrackerProvider provider) {
    return Stack(
      children: [
        // Carte OpenStreetMap
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: const LatLng(48.8566, 2.3522), // Paris par défaut
            zoom: 13.0,
            onTap: _onMapTap,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.flutter_application_1',
            ),
            // Marqueurs pour les points de départ et arrivée
            MarkerLayer(
              markers: [
                if (_startPoint != null)
                  Marker(
                    point: _startPoint!,
                    builder: (ctx) => const Icon(
                      Icons.location_on,
                      color: Colors.green,
                      size: 40,
                    ),
                  ),
                if (_endPoint != null)
                  Marker(
                    point: _endPoint!,
                    builder: (ctx) => const Icon(
                      Icons.flag,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
              ],
            ),
            // Ligne entre les points
            if (_startPoint != null && _endPoint != null)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [_startPoint!, _endPoint!],
                    strokeWidth: 4.0,
                    color: Colors.blue,
                  ),
                ],
              ),
          ],
        ),

        // Informations sur la carte
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Card(
            color: Colors.white.withOpacity(0.9),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Text(
                    'Sélectionnez Départ et Arrivée',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _startPoint == null
                        ? 'Tapez sur la carte pour définir le point de départ'
                        : _endPoint == null
                            ? 'Tapez sur la carte pour définir l\'arrivée'
                            : 'Distance: ${_distanceKm.toStringAsFixed(2)} km • ${_stepsCount} pas',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Contrôles
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: _buildControls(),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Résultats
            if (_startPoint != null && _endPoint != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${_distanceKm.toStringAsFixed(2)} km',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const Text('Distance', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '$_stepsCount',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const Text('Pas', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Boutons de contrôle
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _resetPoints,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _centerOnParis,
                    icon: const Icon(Icons.location_city),
                    label: const Text('Paris'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteListView(MapTrackerProvider provider) {
    return Column(
      children: [
        // Statistiques du jour
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  '${provider.todayTotalDistance.toStringAsFixed(2)} km',
                  'Distance totale',
                  Icons.straighten,
                ),
                _buildStatItem(
                  '${provider.todayTotalSteps}',
                  'Pas totaux',
                  Icons.directions_walk,
                ),
                _buildStatItem(
                  '${provider.todayRoutes.length}',
                  'Parcours',
                  Icons.route,
                ),
              ],
            ),
          ),
        ),

        // Liste des parcours
        Expanded(
          child: provider.todayRoutes.isEmpty
              ? const Center(
                  child: Text('Aucun parcours enregistré aujourd\'hui'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.todayRoutes.length,
                  itemBuilder: (context, index) {
                    final route = provider.todayRoutes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.route,
                            color: Colors.blue,
                          ),
                        ),
                        title: Text(route.name),
                        subtitle: Text(
                          '${route.distance.toStringAsFixed(2)} km • ${route.steps} pas • ${_formatDuration(route.duration)}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteRouteDialog(route),
                        ),
                        onTap: () => _showRouteDetails(route),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGrey,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }

  // Gestion des taps sur la carte
  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      if (_startPoint == null) {
        _startPoint = point;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Point de départ défini')),
        );
      } else if (_endPoint == null) {
        _endPoint = point;
        _calculateDistanceAndSteps();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Point d\'arrivée défini - Distance calculée')),
        );
      } else {
        // Reset si les deux points sont déjà définis
        _resetPoints();
        _startPoint = point;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nouveau point de départ défini')),
        );
      }
    });
  }

  // Calcul de la distance et conversion en pas
  void _calculateDistanceAndSteps() {
    if (_startPoint != null && _endPoint != null) {
      _distanceKm = _calculateDistance(_startPoint!, _endPoint!);
      _stepsCount = (_distanceKm * 1300).round(); // 1 km = 1300 pas
    }
  }

  // Calcul de distance avec formule de Haversine simplifiée
  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371; // Rayon de la Terre en km

    final double latDistance = (end.latitude - start.latitude) * pi / 180;
    final double lngDistance = (end.longitude - start.longitude) * pi / 180;

    final double a = sin(latDistance / 2) * sin(latDistance / 2) +
        cos(start.latitude * pi / 180) * cos(end.latitude * pi / 180) *
        sin(lngDistance / 2) * sin(lngDistance / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  // Reset des points
  void _resetPoints() {
    setState(() {
      _startPoint = null;
      _endPoint = null;
      _distanceKm = 0.0;
      _stepsCount = 0;
    });
  }

  // Centrer sur Paris
  void _centerOnParis() {
    _mapController.move(const LatLng(48.8566, 2.3522), 13.0);
  }

  void _showDeleteRouteDialog(Route route) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le parcours'),
        content: Text('Voulez-vous supprimer "${route.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await context.read<MapTrackerProvider>().deleteRoute(route.id);
              Navigator.of(context).pop();
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Parcours supprimé')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showRouteDetails(Route route) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(route.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Distance: ${route.distance.toStringAsFixed(2)} km'),
            Text('Pas: ${route.steps}'),
            Text('Durée: ${_formatDuration(route.duration)}'),
            Text('Vitesse moyenne: ${route.averageSpeed.toStringAsFixed(1)} km/h'),
            Text('Date: ${_formatDate(route.date)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else {
      return '${minutes}m ${seconds}s';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
