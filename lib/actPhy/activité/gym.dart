import 'package:flutter/material.dart';
import '../models/exercise_model.dart';
import '../repositories/exercise_repository.dart';
import '../bodyParts/bodyParts.dart';

class GymExercisesPage extends StatefulWidget {
  final Set<BodyPart> selectedBodyParts;
  final Set<Equipment> selectedEquipment;
  
  const GymExercisesPage({
    Key? key,
    required this.selectedBodyParts,
    required this.selectedEquipment,
  }) : super(key: key);

  @override
  State<GymExercisesPage> createState() => _GymExercisesPageState();
}

class _GymExercisesPageState extends State<GymExercisesPage> {
  final ExerciseRepository _repository = ExerciseRepository();
  List<Exercise> _exercises = [];
  bool _isLoading = false;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  // Map body parts to API body part names
  final Map<BodyPart, String> _bodyPartMapping = {
    // Head and Neck
    BodyPart.head: 'neck',
    BodyPart.neck: 'neck',
    
    // Shoulders (both left and right map to 'Shoulders')
    BodyPart.leftShoulder: 'Shoulders',
    BodyPart.rightShoulder: 'Shoulders',
    
    // Arms (all arm parts map to 'Arms')
    BodyPart.leftArm: 'Arms',
    BodyPart.rightArm: 'Arms',
    BodyPart.leftForearm: 'Arms',
    BodyPart.rightForearm: 'Arms',
    BodyPart.leftHand: 'Arms',
    BodyPart.rightHand: 'Arms',
    
    // Core
    BodyPart.chest: 'Chest',
    BodyPart.abdomen: 'Core',
    BodyPart.back: 'Back',
    BodyPart.lowerBack: 'Back',
    
    // Legs (all leg parts map to 'Legs')
    BodyPart.leftThigh: 'Legs',
    BodyPart.rightThigh: 'Legs',
    BodyPart.leftLeg: 'Legs',
    BodyPart.rightLeg: 'Legs',
    BodyPart.leftFoot: 'Legs',
    BodyPart.rightFoot: 'Legs',
  };

  // Map equipment to API names
  final Map<Equipment, String> _equipmentMapping = {
    Equipment.barbell: 'Barbell',
    Equipment.dumbbell: 'Dumbbell',
    Equipment.machine: 'Machine',
    Equipment.bodyweight: 'Bodyweight',
    Equipment.kettlebell: 'Kettlebell',
    Equipment.resistanceBand: 'ResistanceBand',
    Equipment.battleRope: 'BattleRope',
    Equipment.medicineBall: 'MedicineBall',
    Equipment.bosuBall: 'BosuBall',
    Equipment.powerSled: 'PowerSled',
    Equipment.smithMachine: 'SmithMachine',
    Equipment.stabilityBall: 'StabilityBall',
    Equipment.trapBar: 'TrapBar',
    Equipment.stepper: 'Stepper',
    Equipment.wheelRoller: 'WheelRoller',
    Equipment.towel: 'Towel',
    Equipment.landmine: 'Landmine',
    Equipment.cable: 'Cable',
  };

  Future<void> _loadExercises() async {
    if (widget.selectedBodyParts.isEmpty) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      List<Exercise> allExercises = [];
      
      // Get unique API body parts
      final apiBodyParts = widget.selectedBodyParts
          .map((part) => _bodyPartMapping[part] ?? '')
          .where((part) => part.isNotEmpty)
          .toSet();

      // Get unique API equipment
      final apiEquipment = widget.selectedEquipment
          .map((e) => _equipmentMapping[e] ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
      
      // If equipment is selected, fetch exercises for each body part + equipment combination
      if (apiEquipment.isNotEmpty) {
        for (final bodyPart in apiBodyParts) {
          for (final equipment in apiEquipment) {
            final exercises = await _repository.getExercises(
              bodyPart: bodyPart,
              equipment: equipment,
            );
            allExercises.addAll(exercises);
          }
        }
      } else {
        // Fallback: fetch exercises for body parts only
        for (final bodyPart in apiBodyParts) {
          final exercises = await _repository.getExercises(bodyPart: bodyPart);
          allExercises.addAll(exercises);
        }
      }

      // Remove duplicates based on exercise ID and filter valid exercises
      final uniqueExercises = <String, Exercise>{};
      for (var exercise in allExercises) {
        final hasValidImage = exercise.gifUrl.isNotEmpty && 
               !exercise.gifUrl.contains('image_coming_soon') &&
               (exercise.gifUrl.startsWith('http') || exercise.gifUrl.startsWith('https'));
        
        if (hasValidImage) {
          uniqueExercises[exercise.id] = exercise;
        }
      }

      if (mounted) {
        setState(() {
          _exercises = uniqueExercises.values.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load exercises: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          _buildSelectedBodyParts(),
          _buildExercisesList(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF2DD8A3),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Gym Exercises',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2DD8A3),
                Color(0xFF0FA67A),
                Color(0xFF3F51B5),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              const Center(
                child: Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: Colors.white24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedBodyParts() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2DD8A3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.my_location,
                    color: Color(0xFF2DD8A3),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Target Body Parts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      if (widget.selectedEquipment.isNotEmpty)
                        const Text(
                          'Selected Equipment',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF718096),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.selectedBodyParts.map((part) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2DD8A3), Color(0xFF0FA67A)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getBodyPartName(part),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
            if (widget.selectedEquipment.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.selectedEquipment.map((equipment) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF2196F3)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getEquipmentName(equipment),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExercisesList() {
    if (_isLoading) {
      return SliverToBoxAdapter(
        child: Container(
          height: 400,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2DD8A3)),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading exercises...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadExercises,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_exercises.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            children: [
              Icon(
                Icons.search_off,
                color: Colors.grey,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'No exercises found for the selected body parts',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return _buildExerciseCard(_exercises[index], index);
          },
          childCount: _exercises.length,
        ),
      ),
    );
  }

  Widget _buildExerciseCard(Exercise exercise, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _showExerciseDetails(exercise),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Exercise Image
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF2DD8A3),
                              Color(0xFF0FA67A),
                            ],
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: exercise.gifUrl.isNotEmpty
                              ? Image.network(
                                  exercise.gifUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(
                                        Icons.fitness_center,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.fitness_center,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    // Exercise Info
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Text(
                                exercise.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3748),
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2DD8A3).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                exercise.bodyPart.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2DD8A3),
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (exercise.equipment.isNotEmpty)
                              Flexible(
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.build,
                                      size: 12,
                                      color: Color(0xFF718096),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        exercise.equipment,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF718096),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showExerciseDetails(Exercise exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExerciseDetailsModal(exercise: exercise),
    );
  }

  String _getBodyPartName(BodyPart part) {
    switch (part) {
      case BodyPart.head:
        return 'Head';
      case BodyPart.neck:
        return 'Neck';
      case BodyPart.leftShoulder:
      case BodyPart.rightShoulder:
        return 'Shoulders';
      case BodyPart.leftArm:
      case BodyPart.rightArm:
        return 'Upper Arms';
      case BodyPart.leftForearm:
      case BodyPart.rightForearm:
        return 'Forearms';
      case BodyPart.leftHand:
      case BodyPart.rightHand:
        return 'Hands';
      case BodyPart.chest:
        return 'Chest';
      case BodyPart.abdomen:
        return 'Waist';
      case BodyPart.back:
      case BodyPart.lowerBack:
        return 'Back';
      case BodyPart.leftThigh:
      case BodyPart.rightThigh:
        return 'Upper Legs';
      case BodyPart.leftLeg:
      case BodyPart.rightLeg:
      case BodyPart.leftFoot:
      case BodyPart.rightFoot:
        return 'Lower Legs';
      default:
        return part.toString().split('.').last;
    }
  }

  String _getEquipmentName(Equipment equipment) {
    switch (equipment) {
      case Equipment.barbell:
        return 'Barbell';
      case Equipment.dumbbell:
        return 'Dumbbell';
      case Equipment.machine:
        return 'Machine';
      case Equipment.bodyweight:
        return 'Bodyweight';
      case Equipment.kettlebell:
        return 'Kettlebell';
      case Equipment.resistanceBand:
        return 'Resistance Band';
      case Equipment.battleRope:
        return 'Battle Rope';
      case Equipment.medicineBall:
        return 'Medicine Ball';
      case Equipment.bosuBall:
        return 'Bosu Ball';
      case Equipment.powerSled:
        return 'Power Sled';
      case Equipment.smithMachine:
        return 'Smith Machine';
      case Equipment.stabilityBall:
        return 'Stability Ball';
      case Equipment.trapBar:
        return 'Trap Bar';
      case Equipment.stepper:
        return 'Stepper';
      case Equipment.wheelRoller:
        return 'Wheel Roller';
      case Equipment.towel:
        return 'Towel';
      case Equipment.landmine:
        return 'Landmine';
      case Equipment.cable:
        return 'Cable';
    }
  }
}

class ExerciseDetailsModal extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailsModal({Key? key, required this.exercise}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Exercise Image
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2DD8A3), Color(0xFF0FA67A)],
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: exercise.gifUrl.isNotEmpty
                              ? Image.network(
                                  exercise.gifUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(
                                        Icons.fitness_center,
                                        size: 60,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.fitness_center,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Exercise Name
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Exercise Details
                      _buildDetailRow('Body Part', exercise.bodyPart),
                      _buildDetailRow('Target', exercise.target),
                      _buildDetailRow('Equipment', exercise.equipment),
                      const SizedBox(height: 20),
                      // Instructions
                      if (exercise.instructions.isNotEmpty) ...[
                        const Text(
                          'Instructions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          exercise.instructions,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4A5568),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2DD8A3),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4A5568),
              ),
            ),
          ),
        ],
      ),
    );
  }
}