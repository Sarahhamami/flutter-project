import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';
import '../theme/colors.dart';
import '../db/database_helper.dart';
import 'emergency_service.dart';

class FallDetectionPage extends StatefulWidget {
  const FallDetectionPage({super.key});

  @override
  State<FallDetectionPage> createState() => _FallDetectionPageState();
}

class _FallDetectionPageState extends State<FallDetectionPage> with WidgetsBindingObserver {
  final EmergencyService _emergencyService = EmergencyService();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Accelerometer data
  double _x = 0.0, _y = 0.0, _z = 0.0;
  double _totalAcceleration = 0.0;

  // Fall detection parameters
  static const double fallThreshold = 2.5; // Sudden acceleration change
  static const double impactThreshold = 15.0; // High impact acceleration
  static const int confirmationTime = 10; // Seconds to wait for user response

  // Simulation mode for PC testing
  static const bool _isSimulationMode = true; // Set to false for real device

  // Detection state
  bool _isMonitoring = false;
  bool _fallDetected = false;
  bool _countdownActive = false;
  int _countdownSeconds = confirmationTime;
  Timer? _countdownTimer;

  // Historical data for fall detection
  final List<double> _accelerationHistory = [];
  static const int HISTORY_SIZE = 10;

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startMonitoring();
    if (_isSimulationMode) {
      _startSimulation();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Restart monitoring when app comes back to foreground
      if (!_isMonitoring) {
        _startMonitoring();
      }
    } else if (state == AppLifecycleState.paused) {
      // Stop monitoring when app goes to background
      _stopMonitoring();
    }
  }

  void _startMonitoring() {
    if (_isMonitoring) return;

    setState(() => _isMonitoring = true);

    _accelerometerSubscription = accelerometerEvents.listen(
      (AccelerometerEvent event) {
        if (!mounted) return;

        setState(() {
          _x = event.x;
          _y = event.y;
          _z = event.z;
          _totalAcceleration = sqrt(_x * _x + _y * _y + _z * _z);
        });

        _checkForFall(_totalAcceleration);
      },
      onError: (error) {
        print('Accelerometer error: $error');
      },
    );
  }

  void _stopMonitoring() {
    _accelerometerSubscription?.cancel();
    _countdownTimer?.cancel();
    _simulationTimer?.cancel();
    setState(() {
      _isMonitoring = false;
      _fallDetected = false;
      _countdownActive = false;
    });
  }

  Timer? _simulationTimer;

  void _startSimulation() {
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted || !_isMonitoring) {
        timer.cancel();
        return;
      }

      // Generate simulated accelerometer data
      final random = Random();
      final x = (random.nextDouble() - 0.5) * 20; // -10 to 10 m/s²
      final y = (random.nextDouble() - 0.5) * 20;
      final z = 9.8 + (random.nextDouble() - 0.5) * 4; // Around gravity with variation

      setState(() {
        _x = x;
        _y = y;
        _z = z;
        _totalAcceleration = sqrt(_x * _x + _y * _y + _z * _z);
      });

      _checkForFall(_totalAcceleration);
    });
  }

  void _checkForFall(double currentAcceleration) {
    // Add to history
    _accelerationHistory.add(currentAcceleration);
    if (_accelerationHistory.length > HISTORY_SIZE) {
      _accelerationHistory.removeAt(0);
    }

    // Need at least 2 readings for comparison
    if (_accelerationHistory.length < 2) return;

    // Calculate acceleration change
    final previousAcceleration = _accelerationHistory[_accelerationHistory.length - 2];
    final accelerationChange = (currentAcceleration - previousAcceleration).abs();

    // Check for fall pattern:
    // 1. Sudden decrease in acceleration (free fall)
    // 2. Followed by high impact
    if (!_fallDetected && !_countdownActive) {
      if (accelerationChange > fallThreshold && currentAcceleration < 5.0) {
        // Possible free fall detected
        _detectPotentialFall();
      } else if (currentAcceleration > impactThreshold) {
        // High impact detected
        _detectPotentialFall();
      }
    }
  }

  void _detectPotentialFall() {
    if (_fallDetected || _countdownActive) return;

    setState(() {
      _fallDetected = true;
      _countdownActive = true;
      _countdownSeconds = confirmationTime;
    });

    // Start countdown
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _countdownSeconds--;
      });

      if (_countdownSeconds <= 0) {
        timer.cancel();
        _triggerEmergencyAlert();
      }
    });

    // Show confirmation dialog
    _showFallConfirmationDialog();
  }

  void _showFallConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Fall Detected!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'We detected a possible fall. Are you okay?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Emergency alert in: $_countdownSeconds seconds',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _countdownSeconds / confirmationTime,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _countdownTimer?.cancel();
                    _resetFallDetection();
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  child: const Text('I\'M OK'),
                ),
                TextButton(
                  onPressed: () {
                    _countdownTimer?.cancel();
                    _triggerEmergencyAlert();
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  child: const Text('NEED HELP'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _resetFallDetection() {
    setState(() {
      _fallDetected = false;
      _countdownActive = false;
    });
  }

  Future<void> _triggerEmergencyAlert() async {
    try {
      // First, get the closest emergency contact (highest priority)
      final contacts = await _dbHelper.getEmergencyContactsByUser(1); // Default user
      String? closestContactName;
      String? closestContactPhone;

      if (contacts.isNotEmpty) {
        // Sort by priority (1 is highest) and get the first one
        contacts.sort((a, b) => (a['priority'] as int).compareTo(b['priority'] as int));
        closestContactName = contacts.first['full_name'] as String?;
        closestContactPhone = contacts.first['phone'] as String?;
      }

      print('🧪 TEST MODE: Simulating emergency alert...');
      print('📞 Closest contact: $closestContactName ($closestContactPhone)');

      if (closestContactPhone == null || closestContactPhone.isEmpty) {
        print('❌ No emergency contact found!');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No emergency contact configured!'),
              backgroundColor: Colors.red,
            ),
          );
        }
        _resetFallDetection();
        return;
      }

      // Simulate SMS sending (don't actually send for testing)
      print('📱 SIMULATION: SMS would be sent to $closestContactPhone');
      print('💬 Message: "EMERGENCY ALERT: Fall detected by accelerometer"');

      // Show detailed test results
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('SMS Test Results'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('✅ Emergency contact found:'),
                Text('   Name: $closestContactName'),
                Text('   Phone: $closestContactPhone'),
                const SizedBox(height: 16),
                const Text('📱 SMS Simulation:'),
                const Text('   Status: Would be sent'),
                const Text('   Message: "EMERGENCY ALERT: Fall detected by accelerometer"'),
                const Text('   Location: Would include GPS coordinates'),
                const SizedBox(height: 16),
                const Text('🔄 Next steps:'),
                const Text('   1. SMS app would open'),
                const Text('   2. Message pre-filled'),
                const Text('   3. User taps send'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Uncomment to test real SMS
                  _showRealSmsDialog(closestContactName!, closestContactPhone!);
                },
                child: const Text('Test Real SMS'),
              ),
            ],
          ),
        );
      }

      // For real SMS sending, uncomment this:
      /*
      final result = await _emergencyService.sendEmergencyAlert(
        userId: 1, // Default user
        customMessage: 'AUTOMATIC ALERT: Fall detected by accelerometer',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Emergency alert sent'),
            backgroundColor: result['success'] == true ? Colors.green : Colors.red,
          ),
        );
      }
      */

    } catch (e) {
      print('❌ Error in test mode: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error in test mode: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    _resetFallDetection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fall Detection'),
        backgroundColor: AppColors.lightGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isMonitoring ? Icons.stop : Icons.play_arrow),
            onPressed: _isMonitoring ? _stopMonitoring : _startMonitoring,
            tooltip: _isMonitoring ? 'Stop monitoring' : 'Start monitoring',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Status indicator
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _isMonitoring ? Colors.green.shade50 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isMonitoring ? Colors.green : Colors.grey,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _isMonitoring ? Icons.sensors : Icons.sensors_off,
                    size: 48,
                    color: _isMonitoring ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isMonitoring ? 'Monitoring Active' : 'Monitoring Stopped',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _isMonitoring ? Colors.green : Colors.grey,
                    ),
                  ),
                  if (_fallDetected) ...[
                    const SizedBox(height: 16),
                    const Icon(
                      Icons.warning,
                      color: Colors.red,
                      size: 32,
                    ),
                    const Text(
                      'FALL DETECTED!',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Accelerometer data
            if (_isMonitoring) ...[
              const Text(
                'Accelerometer Data',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildDataRow('X-axis', _x, 'm/s²'),
                    _buildDataRow('Y-axis', _y, 'm/s²'),
                    _buildDataRow('Z-axis', _z, 'm/s²'),
                    const Divider(),
                    _buildDataRow('Total', _totalAcceleration, 'm/s²', isTotal: true),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Information cards
            Expanded(
              child: ListView(
                children: [
                  _buildInfoCard(
                    'How it works',
                    'The app monitors your phone\'s accelerometer for sudden movements that may indicate a fall. If a potential fall is detected, you\'ll be asked to confirm if you need help.',
                    Icons.info_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    'When to use',
                    'Keep this feature active when you\'re alone or in situations where you might need immediate assistance. Make sure your emergency contacts are set up.',
                    Icons.accessibility,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    'Important notes',
                    '• This feature is not a substitute for professional medical monitoring\n• False positives may occur during sports or rough activities\n• Keep your phone charged and accessible',
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, double value, String unit, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${value.toStringAsFixed(2)} $unit',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.lightGreen : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon, {Color? color}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color ?? AppColors.lightGreen),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _accelerometerSubscription?.cancel();
    _countdownTimer?.cancel();
    _simulationTimer?.cancel();
    super.dispose();
  }

  void _showRealSmsDialog(String contactName, String contactPhone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Real SMS Test'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Send real SMS to $contactName?'),
            Text('Phone: $contactPhone'),
            const SizedBox(height: 16),
            const Text(
              '⚠️ This will actually send an SMS!',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _sendRealSms(contactName, contactPhone);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Send SMS'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendRealSms(String contactName, String contactPhone) async {
    try {
      final result = await _emergencyService.sendEmergencyAlert(
        userId: 1,
        customMessage: 'TEST SMS: Fall detection system test',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Real SMS sent to $contactName'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending real SMS: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}