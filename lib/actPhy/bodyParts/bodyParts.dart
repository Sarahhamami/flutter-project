import 'package:flutter/material.dart';
import 'package:body_part_selector/body_part_selector.dart';
import 'package:flutter_application_1/actPhy/activité/gym.dart';

enum BodyPart {
  head('Head'),
  neck('Neck'),
  leftShoulder('Left Shoulder'),
  rightShoulder('Right Shoulder'),
  leftArm('Left Arm'),
  rightArm('Right Arm'),
  leftForearm('Left Forearm'),
  rightForearm('Right Forearm'),
  leftHand('Left Hand'),
  rightHand('Right Hand'),
  chest('Chest'),
  abdomen('Abdomen'),
  back('Back'),
  lowerBack('Lower Back'),
  leftThigh('Left Thigh'),
  rightThigh('Right Thigh'),
  leftLeg('Left Leg'),
  rightLeg('Right Leg'),
  leftFoot('Left Foot'),
  rightFoot('Right Foot');

  final String displayName;
  const BodyPart(this.displayName);
}

enum Equipment {
  barbell('Barbell', Icons.fitness_center),
  dumbbell('Dumbbell', Icons.fitness_center),
  machine('Machine', Icons.settings),
  bodyweight('Bodyweight', Icons.accessibility),
  kettlebell('Kettlebell', Icons.fitness_center),
  resistanceBand('Resistance Band', Icons.linear_scale),
  battleRope('Battle Rope', Icons.waves),
  medicineBall('Medicine Ball', Icons.sports_baseball),
  bosuBall('BOSU Ball', Icons.circle_outlined),
  powerSled('Power Sled', Icons.directions_run),
  smithMachine('Smith Machine', Icons.settings_applications),
  stabilityBall('Stability Ball', Icons.radio_button_unchecked),
  trapBar('Trap Bar', Icons.fitness_center),
  stepper('Stepper', Icons.stairs),
  wheelRoller('Wheel Roller', Icons.settings_ethernet),
  towel('Towel', Icons.clean_hands),
  landmine('Landmine', Icons.agriculture),
  cable('Cable', Icons.cable);

  final String displayName;
  final IconData icon;
  
  const Equipment(this.displayName, this.icon);
}

class BodyPartsPage extends StatefulWidget {
  const BodyPartsPage({Key? key}) : super(key: key);

  @override
  State<BodyPartsPage> createState() => _BodyPartsPageState();
}

class _BodyPartsPageState extends State<BodyPartsPage> {
  final Set<BodyPart> _selectedParts = {};
  BodyParts _bodyParts = const BodyParts();

  void _onBodyPartSelected(BodyPart part) {
    setState(() {
      if (_selectedParts.contains(part)) {
        _selectedParts.remove(part);
      } else {
        _selectedParts.add(part);
      }
    });
  }
  
  List<String> _getSelectedParts(BodyParts bodyParts) {
    final selected = <String>[];
    if (bodyParts.head) selected.add('head');
    if (bodyParts.neck) selected.add('neck');
    if (bodyParts.leftShoulder) selected.add('shoulder_left');
    if (bodyParts.rightShoulder) selected.add('shoulder_right');
    if (bodyParts.leftUpperArm) selected.add('arm_left');
    if (bodyParts.rightUpperArm) selected.add('arm_right');
    if (bodyParts.leftLowerArm) selected.add('forearm_left');
    if (bodyParts.rightLowerArm) selected.add('forearm_right');
    if (bodyParts.leftHand) selected.add('hand_left');
    if (bodyParts.rightHand) selected.add('hand_right');
    if (bodyParts.upperBody) selected.add('chest');
    if (bodyParts.lowerBody) selected.add('stomach');
    if (bodyParts.upperBody) selected.add('upper_back');
    if (bodyParts.upperBody) selected.add('spine_middle');
    if (bodyParts.lowerBody) selected.add('lower_back');
    if (bodyParts.leftUpperLeg) selected.add('hip_left');
    if (bodyParts.leftUpperLeg) selected.add('thigh_left');
    if (bodyParts.rightUpperLeg) selected.add('hip_right');
    if (bodyParts.rightUpperLeg) selected.add('thigh_right');
    if (bodyParts.leftLowerLeg) selected.add('shin_left');
    if (bodyParts.rightLowerLeg) selected.add('shin_right');
    if (bodyParts.leftFoot) selected.add('foot_left');
    if (bodyParts.rightFoot) selected.add('foot_right');
    return selected;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Body Parts',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF20c997),
                const Color(0xFF20c997).withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          if (_selectedParts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EquipmentSelectionPage(
                      selectedParts: _selectedParts.toList(), // pass the arguments here
                    ),
                  ),
                );
              },

            ),
        ],
      ),
           body: Column(
        children: [
          Expanded(
            child: Center(
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: const Color(0xFF20c997),
                    secondary: const Color(0xFF20c997),
                  ),
                ),
                child: BodyPartSelectorTurnable(
                  bodyParts: _bodyParts,
                  onSelectionUpdated: (updatedParts) {
                    setState(() {
                      // Get the list of selected parts before and after update
                      final previousSelected = _getSelectedParts(_bodyParts);
                      _bodyParts = updatedParts;
                      final currentSelected = _getSelectedParts(updatedParts);
                      
                      // Find which part was just selected
                      if (currentSelected.length > previousSelected.length) {
                        String? newPart;
                        try {
                          newPart = currentSelected.firstWhere(
                            (part) => !previousSelected.contains(part),
                          );
                        } catch (e) {
                          newPart = null;
                        }
                        
                        if (newPart != null && newPart.isNotEmpty) {
                          final partMap = {
                            'head': BodyPart.head,
                            'neck': BodyPart.neck,
                            'shoulder_left': BodyPart.leftShoulder,
                            'shoulder_right': BodyPart.rightShoulder,
                            'arm_left': BodyPart.leftArm,
                            'arm_right': BodyPart.rightArm,
                            'forearm_left': BodyPart.leftForearm,
                            'forearm_right': BodyPart.rightForearm,
                            'hand_left': BodyPart.leftHand,
                            'hand_right': BodyPart.rightHand,
                            'chest': BodyPart.chest,
                            'stomach': BodyPart.abdomen,
                            'upper_back': BodyPart.back,
                            'spine_middle': BodyPart.back,
                            'lower_back': BodyPart.lowerBack,
                            'hip_left': BodyPart.leftThigh,
                            'thigh_left': BodyPart.leftThigh,
                            'hip_right': BodyPart.rightThigh,
                            'thigh_right': BodyPart.rightThigh,
                            'shin_left': BodyPart.leftLeg,
                            'shin_right': BodyPart.rightLeg,
                            'foot_left': BodyPart.leftFoot,
                            'foot_right': BodyPart.rightFoot,
                          };
                          
                          final mappedPart = partMap[newPart];
                          if (mappedPart != null) {
                            _onBodyPartSelected(mappedPart);
                          }
                        }
                      }
                    });
                  },
                  labelData: const RotationStageLabelData(
                    front: 'Front',
                    left: 'Left',
                    right: 'Right',
                    back: 'Back',
                  ),
                ),
              ),
            ),
          ),
          if (_selectedParts.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selected Body Parts:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedParts
                        .map((part) => Chip(
                              label: Text(
                                part.displayName,
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: const Color(0xFF20c997),
                              deleteIcon: const Icon(Icons.close, size: 18, color: Colors.white),
                              onDeleted: () {
                                setState(() {
                                  _selectedParts.remove(part);
                                });
                              },
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EquipmentSelectionPage(
                              selectedParts: _selectedParts.toList(),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF20c997),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Select Equipment',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class EquipmentSelectionPage extends StatefulWidget {
  final List<BodyPart> selectedParts;

  const EquipmentSelectionPage({
    Key? key,
    required this.selectedParts,
  }) : super(key: key);

  @override
  State<EquipmentSelectionPage> createState() => _EquipmentSelectionPageState();
}

class _EquipmentSelectionPageState extends State<EquipmentSelectionPage> {
  final Set<Equipment> _selectedEquipment = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Equipment',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF20c997),
                const Color(0xFF0dcaf0),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              const Color(0xFFf0f9f7).withOpacity(0.8),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Body Parts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (widget.selectedParts.isEmpty)
                      Text(
                        'No body parts selected',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.selectedParts.map((part) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF20c997).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF20c997).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              part.displayName,
                              style: const TextStyle(
                                color: Color(0xFF0a7a5f),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Available Equipment',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Select one or more equipment types',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 12,
              children: Equipment.values.map((equipment) {
                final isSelected = _selectedEquipment.contains(equipment);
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          equipment.icon,
                          size: 18,
                          color: isSelected ? Colors.white : const Color(0xFF20c997),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          equipment.displayName,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[800],
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedEquipment.add(equipment);
                        } else {
                          _selectedEquipment.remove(equipment);
                        }
                      });
                    },
                    backgroundColor: Colors.grey[100],
                    selectedColor: const Color(0xFF20c997),
                    checkmarkColor: Colors.white,
                    showCheckmark: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF20c997)
                            : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    elevation: isSelected ? 2 : 0,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: _selectedEquipment.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(bottom: 20, right: 20),
              child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GymExercisesPage(
                    selectedBodyParts: widget.selectedParts.toSet(), // pass directly
                    selectedEquipment: _selectedEquipment,          // pass directly
                  ),
                ),
              );
            },

                backgroundColor: const Color(0xFF0dcaf0),
                icon: const Icon(Icons.check),
                label: const Text('Done'),
              ),
            )
          : null,
    );
  }
}
