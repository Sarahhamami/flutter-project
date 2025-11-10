import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:flutter/services.dart';

class CyclingPage extends StatefulWidget {
  const CyclingPage({super.key});

  @override
  State<CyclingPage> createState() => _CyclingPageState();
}

class _CyclingPageState extends State<CyclingPage> with SingleTickerProviderStateMixin {
  bool _isTracking = false;
  int _distance = 0; // in meters
  double _speed = 0.0; // in km/h
  int _calories = 0;
  Duration _duration = Duration.zero;
  Timer? _timer;

  // Map related variables
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  LatLng? _destinationPosition;
  bool _isSelectingDestination = false;
  final List<LatLng> _routePoints = [];
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  bool _isMapReady = false;

  // Location related
  StreamSubscription<Position>? _positionStream;
  late LocationSettings _locationSettings;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    // Initialize location settings
    _locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );
    
    // Request location permission and get initial location
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationPermission();
    });
  }

  @override
  void didUpdateWidget(CyclingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isMapReady && _currentPosition != null) {
      _moveToCurrentPosition();
    }
  }

  void _moveToCurrentPosition() {
    if (_isMapReady && _currentPosition != null) {
      _mapController.move(_currentPosition!, 15.0);
    } else {
      // If the map isn't ready yet, wait a bit and try again
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _currentPosition != null) {
          _moveToCurrentPosition();
        }
      });
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _confettiController.dispose();
    _animationController.dispose();
    _timer?.cancel();
    _isMapReady = false;
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enable location services and try again'),
            duration: Duration(seconds: 5),
          ),
        );
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permissions are denied'),
                duration: Duration(seconds: 5),
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are permanently denied. Please enable them in app settings.'),
              duration: Duration(seconds: 5),
            ),
          );
        }
        return;
      }

      // If we reach here, permissions are granted and we can get the location
      await _getCurrentLocation();
    } catch (e) {
      print('Error in _requestLocationPermission: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error requesting location permission. Please try again.'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      // First, get the current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Getting location timed out. Please try again.'),
                duration: Duration(seconds: 5),
              ),
            );
          }
          throw TimeoutException('Location request timed out');
        },
      );

      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
        
        // Start tracking after getting the initial position
        _startLocationTracking();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location found!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } on TimeoutException catch (e) {
      print('Location timeout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location request timed out. Please try again.'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print('Error getting location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error getting location. Please check your GPS and try again.'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _startLocationTracking() {
    _positionStream = Geolocator.getPositionStream(locationSettings: _locationSettings).listen(
      (Position position) {
        if (mounted) {
          setState(() {
            _currentPosition = LatLng(position.latitude, position.longitude);
            _updateRoute();
            _updateStats(position.speed);
          });
        }
      },
      onError: (e) {
        print('Error in location stream: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error tracking location. Please try again.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      },
    );
  }

  void _updateRoute() {
    if (_currentPosition != null) {
      _routePoints.add(_currentPosition!);
      if (_routePoints.length > 100) {
        _routePoints.removeAt(0);
      }
    }
  }

  void _updateStats(double speed) {
    setState(() {
      // Convert speed from m/s to km/h
      _speed = speed * 3.6;
      
      // Update distance (in meters)
      if (_routePoints.length > 1) {
        double totalDistance = 0;
        for (int i = 1; i < _routePoints.length; i++) {
          totalDistance += const Distance().as(
            LengthUnit.Meter,
            _routePoints[i - 1],
            _routePoints[i],
          );
        }
        _distance = totalDistance.round();
      }
      
      // Update calories (rough estimate: 0.05 cal per meter)
      _calories = (_distance * 0.05).round();
      
      _duration = _duration + const Duration(seconds: 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cycling Tracker'),
        centerTitle: true,
      ),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Map
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentPosition ?? const LatLng(0, 0),
                    initialZoom: 15.0,
                    onTap: (tapPosition, point) {
                      if (_isTracking) {
                        setState(() {
                          _destinationPosition = point;
                          _isSelectingDestination = false;
                        });
                      }
                    },
                    onMapReady: () {
                      setState(() {
                        _isMapReady = true;
                      });
                      if (_currentPosition != null) {
                        _moveToCurrentPosition();
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    // Route line
                    if (_routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            color: Colors.blue.withOpacity(0.7),
                            strokeWidth: 5.0,
                          ),
                        ],
                      ),
                    // Current position marker
                    if (_currentPosition != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _currentPosition!,
                            width: 60,
                            height: 60,
                            child: Container(
                              child: lottie.Lottie.asset(
                                'assets/lottie/cycling.json', // Changed to cycling animation
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    // Destination marker
                    if (_destinationPosition != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _destinationPosition!,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                // Stats overlay
                Positioned(
                  top: 20,
                  left: 10,
                  right: 10,
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn(Icons.directions_bike, '${(_distance / 1000).toStringAsFixed(2)} km', 'Distance'),
                          _buildStatColumn(Icons.speed, '${_speed.toStringAsFixed(1)} km/h', 'Speed'),
                          _buildStatColumn(Icons.timer, _formatDuration(_duration), 'Time'),
                          _buildStatColumn(Icons.local_fire_department, '$_calories', 'Calories'),
                        ],
                      ),
                    ),
                  ),
                ),
                // Bottom controls
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton.extended(
                        onPressed: _toggleTracking,
                        backgroundColor: _isTracking ? Colors.red : Colors.green,
                        icon: Icon(_isTracking ? Icons.stop : Icons.directions_bike),
                        label: Text(_isTracking ? 'STOP' : 'START'),
                      ),
                      const SizedBox(width: 20),
                      FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            _isSelectingDestination = !_isSelectingDestination;
                            if (_isSelectingDestination) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Tap on the map to set destination'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          });
                        },
                        backgroundColor: _isSelectingDestination ? Colors.blue : Colors.grey,
                        child: const Icon(Icons.place),
                      ),
                    ],
                  ),
                ),
                // Confetti
                ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: true,
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildStatColumn(IconData icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 30, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  void _toggleTracking() {
    setState(() {
      _isTracking = !_isTracking;
      if (_isTracking) {
        _startTimer();
      } else {
        _stopTimer();
        _showSummaryDialog();
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _duration = _duration + const Duration(seconds: 1);
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _showSummaryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cycling Summary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSummaryRow('Distance', '${(_distance / 1000).toStringAsFixed(2)} km'),
            _buildSummaryRow('Average Speed', '${_speed.toStringAsFixed(1)} km/h'),
            _buildSummaryRow('Duration', _formatDuration(_duration)),
            _buildSummaryRow('Calories', '$_calories cal'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}