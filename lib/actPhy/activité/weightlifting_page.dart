import 'package:flutter/material.dart';
import 'dart:async';

class WeightliftingPage extends StatefulWidget {
  const WeightliftingPage({super.key});

  @override
  State<WeightliftingPage> createState() => _WeightliftingPageState();
}

class _WeightliftingPageState extends State<WeightliftingPage> {
  String? _selectedBodyPart;
  String? _selectedExercise;
  bool _isWorkoutActive = false;
  bool _isResting = false;
  int _setSeconds = 0;
  int _restSeconds = 60;
  int _completedSets = 0;
  Timer? _timer;

  final Map<String, List<Map<String, String>>> _exercises = {
    'Chest': [
      {
        'name': 'Bench Press',
        'description': 'Lie on bench, lower bar to chest, press up'
      },
      {'name': 'Push-ups', 'description': 'Classic bodyweight chest exercise'},
      {
        'name': 'Dumbbell Flyes',
        'description': 'Lie flat, open arms wide with dumbbells'
      },
      {'name': 'Incline Press', 'description': 'Bench press on inclined bench'},
    ],
    'Back': [
      {
        'name': 'Pull-ups',
        'description': 'Hang from bar, pull body up until chin over bar'
      },
      {'name': 'Deadlifts', 'description': 'Lift barbell from ground to hips'},
      {
        'name': 'Bent-Over Rows',
        'description': 'Bend forward, pull weight to torso'
      },
      {'name': 'Lat Pulldown', 'description': 'Pull bar down to chest level'},
    ],
    'Arms': [
      {
        'name': 'Bicep Curls',
        'description': 'Curl dumbbells up to shoulders'
      },
      {
        'name': 'Tricep Dips',
        'description': 'Lower body between parallel bars'
      },
      {'name': 'Hammer Curls', 'description': 'Curl with neutral grip'},
      {
        'name': 'Overhead Extension',
        'description': 'Extend weight overhead for triceps'
      },
    ],
    'Legs': [
      {'name': 'Squats', 'description': 'Lower body by bending knees'},
      {'name': 'Lunges', 'description': 'Step forward, lower back knee'},
      {'name': 'Leg Press', 'description': 'Push weight away with legs'},
      {
        'name': 'Leg Curls',
        'description': 'Curl weight up with hamstrings'
      },
    ],
    'Shoulders': [
      {
        'name': 'Overhead Press',
        'description': 'Press weight from shoulders overhead'
      },
      {
        'name': 'Lateral Raises',
        'description': 'Raise arms to sides with dumbbells'
      },
      {
        'name': 'Front Raises',
        'description': 'Raise arms forward with weights'
      },
      {
        'name': 'Shrugs',
        'description': 'Lift shoulders up towards ears with weight'
      },
    ],
    'Abs': [
      {'name': 'Crunches', 'description': 'Lift shoulders off ground'},
      {'name': 'Planks', 'description': 'Hold body straight in push-up position'},
      {'name': 'Russian Twists', 'description': 'Rotate torso side to side'},
      {'name': 'Leg Raises', 'description': 'Lift legs up while lying down'},
    ],
  };

  void _startSet() {
    setState(() {
      _isWorkoutActive = true;
      _isResting = false;
      _setSeconds = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _setSeconds++;
      });
    });
  }

  void _completeSet() {
    _timer?.cancel();
    setState(() {
      _completedSets++;
      _isWorkoutActive = false;
      _isResting = true;
      _restSeconds = 60;
    });
    _startRestTimer();
  }

  void _startRestTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_restSeconds > 0) {
          _restSeconds--;
        } else {
          _timer?.cancel();
          _isResting = false;
        }
      });
    });
  }

  void _skipRest() {
    _timer?.cancel();
    setState(() {
      _isResting = false;
      _restSeconds = 60;
    });
  }

  void _finishWorkout() {
    _timer?.cancel();
    _showWorkoutSummary();
  }

  void _resetWorkout() {
    _timer?.cancel();
    setState(() {
      _selectedExercise = null;
      _isWorkoutActive = false;
      _isResting = false;
      _setSeconds = 0;
      _restSeconds = 60;
      _completedSets = 0;
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
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
        backgroundColor: const Color(0xFF0dcaf0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Weightlifting Session',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _selectedBodyPart == null
            ? _buildBodyPartSelection()
            : _selectedExercise == null
                ? _buildExerciseSelection()
                : _buildWorkoutScreen(),
      ),
    );
  }

  Widget _buildBodyPartSelection() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0dcaf0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.fitness_center,
                size: 80,
                color: Color(0xFF0dcaf0),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Choose Body Part',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Select which muscle group you want to train',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildBodyPartCard('Chest', Icons.favorite, Colors.red),
                _buildBodyPartCard('Back', Icons.square, const Color(0xFF20c997)),
                _buildBodyPartCard('Arms', Icons.flash_on, Colors.orange),
                _buildBodyPartCard('Legs', Icons.directions_run, Colors.blue),
                _buildBodyPartCard(
                    'Shoulders', Icons.accessibility_new, Colors.purple),
                _buildBodyPartCard('Abs', Icons.grid_3x3, Colors.teal),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyPartCard(String bodyPart, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedBodyPart = bodyPart;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.2), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: color),
              const SizedBox(height: 12),
              Text(
                bodyPart,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseSelection() {
    final exercises = _exercises[_selectedBodyPart] ?? [];
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0dcaf0).withOpacity(0.1),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedBodyPart = null;
                  });
                },
              ),
              const SizedBox(width: 10),
              Text(
                '$_selectedBodyPart Exercises',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF0dcaf0),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    exercise['name']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      exercise['description']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF0dcaf0),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedExercise = exercise['name'];
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutScreen() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _resetWorkout,
                ),
                Expanded(
                  child: Text(
                    _selectedExercise!,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF0dcaf0).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _isResting ? 'Rest Time' : 'Set Duration',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isResting
                        ? _formatTime(_restSeconds)
                        : _formatTime(_setSeconds),
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: _isResting ? Colors.orange : const Color(0xFF0dcaf0),
                      letterSpacing: 2,
                    ),
                  ),
                  if (_isResting)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        '💪 Take a breather!',
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF20c997).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn('Completed Sets', '$_completedSets'),
                  Container(width: 2, height: 40, color: Colors.grey[300]),
                  _buildStatColumn('Body Part', _selectedBodyPart!),
                ],
              ),
            ),
            const SizedBox(height: 40),
            if (_isResting) ...[
              _buildActionButton(
                icon: Icons.skip_next,
                label: 'Skip Rest',
                color: Colors.orange,
                onPressed: _skipRest,
              ),
              const SizedBox(height: 15),
              _buildActionButton(
                icon: Icons.check_circle,
                label: 'Finish Workout',
                color: const Color(0xFF20c997),
                onPressed: _finishWorkout,
              ),
            ] else if (_isWorkoutActive) ...[
              _buildActionButton(
                icon: Icons.check,
                label: 'Complete Set',
                color: const Color(0xFF20c997),
                onPressed: _completeSet,
              ),
            ] else ...[
              _buildActionButton(
                icon: Icons.play_arrow,
                label: 'Start Set',
                color: const Color(0xFF0dcaf0),
                onPressed: _startSet,
              ),
              if (_completedSets > 0) ...[
                const SizedBox(height: 15),
                _buildActionButton(
                  icon: Icons.flag,
                  label: 'Finish Workout',
                  color: Colors.red,
                  onPressed: _finishWorkout,
                ),
              ],
            ],
          ],
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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF20c997),
          ),
        ),
        const SizedBox(height: 4),
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

  void _showWorkoutSummary() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.emoji_events, color: Color(0xFF0dcaf0)),
            SizedBox(width: 10),
            Text('Workout Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryRow('Exercise', _selectedExercise!),
            _buildSummaryRow('Body Part', _selectedBodyPart!),
            _buildSummaryRow('Sets Completed', '$_completedSets'),
            _buildSummaryRow(
              'Est. Calories',
              '${(_completedSets * 15).toString()} kcal',
            ),
            const SizedBox(height: 10),
            const Text(
              '💪 Excellent workout! Keep building that strength!',
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
              _resetWorkout();
            },
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF0dcaf0)),
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
              color: Color(0xFF0dcaf0),
            ),
          ),
        ],
      ),
    );
  }
}
