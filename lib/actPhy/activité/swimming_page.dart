import 'package:flutter/material.dart';
import 'dart:async';

class SwimmingPage extends StatefulWidget {
  const SwimmingPage({super.key});

  @override
  State<SwimmingPage> createState() => _SwimmingPageState();
}

class _SwimmingPageState extends State<SwimmingPage> {
  bool _isRunning = false;
  bool _sessionStarted = false;
  int _totalSeconds = 0;
  int _currentRoundSeconds = 0;
  int _roundCount = 0;
  Timer? _timer;
  List<int> _roundTimes = [];

  void _startSession() {
    setState(() {
      _sessionStarted = true;
      _isRunning = true;
    });
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _totalSeconds++;
        _currentRoundSeconds++;
      });
    });
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
    });
    _timer?.cancel();
  }

  void _nextRound() {
    if (_sessionStarted) {
      setState(() {
        _roundCount++;
        _roundTimes.add(_currentRoundSeconds);
        _currentRoundSeconds = 0;
      });
    }
  }

  void _resetSession() {
    setState(() {
      _isRunning = false;
      _sessionStarted = false;
      _totalSeconds = 0;
      _currentRoundSeconds = 0;
      _roundCount = 0;
      _roundTimes.clear();
    });
    _timer?.cancel();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  double _getAverageRoundTime() {
    if (_roundTimes.isEmpty) return 0;
    int total = _roundTimes.reduce((a, b) => a + b);
    return total / _roundTimes.length;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF20c997),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Swimming Session',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF20c997).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.pool,
                    size: 80,
                    color: Color(0xFF20c997),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'Track your swimming rounds and see your total time',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                if (!_sessionStarted)
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: const Color(0xFF20c997).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.waves,
                              size: 60,
                              color: Color(0xFF20c997),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Ready to swim?',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Start your session and track each round',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildActionButton(
                        icon: Icons.play_arrow,
                        label: 'Start Session',
                        color: const Color(0xFF20c997),
                        onPressed: _startSession,
                      ),
                    ],
                  )
                else ...[
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF20c997).withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Current Round',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatTime(_currentRoundSeconds),
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF20c997),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 2,
                              height: 60,
                              color: Colors.grey[300],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Total Time',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatTime(_totalSeconds),
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isRunning) ...[
                        _buildActionButton(
                          icon: Icons.pause,
                          label: 'Pause',
                          color: Colors.orange,
                          onPressed: _pauseTimer,
                        ),
                        const SizedBox(width: 15),
                        _buildActionButton(
                          icon: Icons.flag,
                          label: 'Next Round',
                          color: const Color(0xFF0dcaf0),
                          onPressed: _nextRound,
                        ),
                      ],
                      if (!_isRunning) ...[
                        _buildActionButton(
                          icon: Icons.play_arrow,
                          label: 'Resume',
                          color: const Color(0xFF20c997),
                          onPressed: _startTimer,
                        ),
                        const SizedBox(width: 15),
                        _buildActionButton(
                          icon: Icons.stop,
                          label: 'Finish',
                          color: Colors.red,
                          onPressed: _showSummaryDialog,
                        ),
                      ],
                    ],
                  ),
                  if (!_isRunning)
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: TextButton.icon(
                        onPressed: _resetSession,
                        icon: const Icon(Icons.refresh, color: Colors.grey),
                        label: const Text(
                          'Reset',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0dcaf0).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              'Rounds',
                              _roundCount.toString(),
                              Icons.repeat,
                            ),
                            if (_roundTimes.isNotEmpty)
                              _buildStatItem(
                                'Avg Round',
                                _formatTime(_getAverageRoundTime().round()),
                                Icons.speed,
                              ),
                          ],
                        ),
                        if (_roundTimes.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 10),
                          const Text(
                            'Round History',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 150,
                            child: ListView.builder(
                              itemCount: _roundTimes.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  dense: true,
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFF20c997),
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    'Round ${index + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  trailing: Text(
                                    _formatTime(_roundTimes[index]),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF20c997),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 4,
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF0dcaf0), size: 30),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0dcaf0),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showSummaryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.emoji_events, color: Color(0xFF20c997)),
            SizedBox(width: 10),
            Text('Swimming Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryRow('Total Time', _formatTime(_totalSeconds)),
            _buildSummaryRow('Total Rounds', _roundCount.toString()),
            if (_roundTimes.isNotEmpty)
              _buildSummaryRow(
                'Avg Round Time',
                _formatTime(_getAverageRoundTime().round()),
              ),
            _buildSummaryRow(
              'Calories Burned',
              '${(_totalSeconds * 0.15).toStringAsFixed(0)} kcal',
            ),
            const SizedBox(height: 10),
            const Text(
              '🏊 Outstanding swimming session! Keep pushing!',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetSession();
            },
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF20c997)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF20c997),
            ),
          ),
        ],
      ),
    );
  }
}
