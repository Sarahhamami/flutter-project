import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import '../../db/database_helper.dart';

class BadgesPage extends StatefulWidget {
  const BadgesPage({Key? key}) : super(key: key);

  @override
  _BadgesPageState createState() => _BadgesPageState();
}

class Badge {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final int target;
  final Color color;
  final String category;
  int current;
  bool isUnlocked;
  DateTime? unlockedAt;
  final Future<Map<String, dynamic>> Function(Database) checkCondition;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.target,
    required this.color,
    required this.category,
    required this.current,
    required this.isUnlocked,
    this.unlockedAt,
    required this.checkCondition,
  });
}

class _BadgesPageState extends State<BadgesPage> with TickerProviderStateMixin {
  late List<Badge> badges = [];
  List<Badge> filteredBadges = [];
  Set<String> selectedCategories = {};
  bool isLoading = true;
  late ConfettiController _confettiController;
  late AnimationController _lottieController;
  Badge? newlyUnlockedBadge;

  // Define all available badge categories
  final List<String> badgeCategories = [
    'steps',
    'calories',
    'strength',
    'swimming',
    'cycling',
    'consistency',
    'all_rounder',
    'marathon',
    'speed',
    'target'
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _loadBadges();
    // Select all categories by default
    selectedCategories = Set.from(badgeCategories);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _lottieController.dispose();
    super.dispose();
  }

  Future<void> _loadBadges() async {
    final db = await DatabaseHelper().database;
    
    // Define all badges with their conditions
    final allBadges = [
      Badge(
        id: 'step_starter',
        name: 'Step Starter',
        description: 'Take 1,000+ steps in a single session',
        icon: FontAwesomeIcons.shoePrints,
        target: 1000,
        color: Colors.blue,
        category: 'steps',
        current: 0,
        isUnlocked: false,
        checkCondition: _checkStepStarter,
      ),
      Badge(
        id: 'calorie_crusher',
        name: 'Calorie Crusher',
        description: 'Burn 100+ calories in one activity',
        icon: FontAwesomeIcons.fire,
        target: 10,
        color: Colors.orange,
        category: 'calories',
        current: 0,
        isUnlocked: false,
        checkCondition: _checkCalorieCrusher,
      ),
      Badge(
        id: 'strength_builder',
        name: 'Strength Builder',
        description: 'Complete 3+ weightlifting sessions',
        icon: FontAwesomeIcons.dumbbell,
        target: 3,
        color: Colors.purple,
        category: 'strength',
        current: 0,
        isUnlocked: false,
        checkCondition: _checkStrengthBuilder,
      ),
      Badge(
        id: 'swim_star',
        name: 'Swim Star',
        description: 'Swim 10+ laps in one session',
        icon: FontAwesomeIcons.personSwimming,
        target: 10,
        color: Colors.blueAccent,
        category: 'swimming',
        current: 0,
        isUnlocked: false,
        checkCondition: _checkSwimStar,
      ),
      Badge(
        id: 'road_rider',
        name: 'Road Rider',
        description: 'Cycle 10+ km in one session',
        icon: FontAwesomeIcons.bicycle,
        target: 10,
        color: Colors.green,
        category: 'cycling',
        current: 0,
        isUnlocked: false,
        checkCondition: _checkRoadRider,
      ),
      Badge(
        id: 'consistency_king',
        name: 'Consistency King',
        description: 'Train 3 consecutive days',
        icon: FontAwesomeIcons.calendarCheck,
        target: 3,
        color: Colors.amber,
        category: 'consistency',
        current: 0,
        isUnlocked: false,
        checkCondition: _checkConsistencyKing,
      ),
      Badge(
        id: 'all_rounder',
        name: 'All-Rounder',
        description: 'Perform 4+ different activity types',
        icon: FontAwesomeIcons.star,
        target: 4,
        color: Colors.teal,
        category: 'strength',
        current: 0,
        isUnlocked: false,
        checkCondition: _checkAllRounder,
      ),
      Badge(
        id: 'marathon_mindset',
        name: 'Marathon Mindset',
        description: 'Log 10+ total activities',
        icon: FontAwesomeIcons.medal,
        target: 10,
        color: Colors.indigo,
        category: 'consistency',
        current: 0,
        isUnlocked: false,
        checkCondition: _checkMarathonMindset,
      ),
      Badge(
        id: 'speed_demon',
        name: 'Speed Demon',
        description: 'Achieve average speed ≥ 10 km/h',
        icon: FontAwesomeIcons.gaugeHigh,
        target: 10,
        color: Colors.red,
        category: 'speed',
        current: 0,
        isUnlocked: false,
        checkCondition: _checkSpeedDemon,
      ),
      Badge(
        id: 'target_smasher',
        name: 'Target Smasher',
        description: 'Complete a session over 30 minutes',
        icon: FontAwesomeIcons.clock,
        target: 30,
        color: Colors.pink,
        category: 'speed',
        current: 0,
        isUnlocked: false,
        checkCondition: _checkTargetSmasher,
      ),
    ];

    // Check each badge's condition
    for (var badge in allBadges) {
      try {
        final result = await badge.checkCondition(db);
        if (result.isNotEmpty) {
          final isUnlocked = result['is_unlocked'] == 1;
          final current = result['current'] is int ? result['current'] : 0;
          final unlockedAt = result['unlocked_at'] != null 
              ? DateTime.tryParse(result['unlocked_at'].toString()) 
              : null;
          
          if (isUnlocked && unlockedAt == null) {
            // Newly unlocked badge
            _showBadgeUnlockedDialog(badge);
          }
          
          setState(() {
            badge.isUnlocked = isUnlocked;
            badge.current = current;
            badge.unlockedAt = unlockedAt;
          });
        }
      } catch (e) {
        print('Error checking badge ${badge.id}: $e');
      }
    }

    setState(() {
      badges = allBadges;
      isLoading = false;
    });
  }

  // Badge condition check methods
  Future<Map<String, dynamic>> _checkStepStarter(Database db) async {
    try {
      final result = await db.rawQuery('''
        SELECT 
          CASE WHEN MAX(pas) >= 1000 THEN 1 ELSE 0 END as is_unlocked,
          COALESCE(MAX(pas), 0) as current,
          1000 as target,
          (SELECT date_activite FROM Activite_physique 
           WHERE pas >= 1000 ORDER BY date_activite DESC LIMIT 1) as unlocked_at
        FROM Activite_physique
        WHERE type_activite IN ('Walking', 'Walking/Running')
      ''');
      return result.isNotEmpty ? result.first : {'is_unlocked': 0, 'current': 0, 'target': 1000, 'unlocked_at': null};
    } catch (e) {
      debugPrint('Error in _checkStepStarter: $e');
      return {'is_unlocked': 0, 'current': 0, 'target': 1000, 'unlocked_at': null};
    }
  }

  Future<Map<String, dynamic>> _checkCalorieCrusher(Database db) async {
    try {
      final result = await db.rawQuery('''
        SELECT 
          CASE WHEN EXISTS (
            SELECT 1 FROM Activite_physique 
            WHERE calories_brulees >= 100
          ) THEN 1 ELSE 0 END as is_unlocked,
          (SELECT COUNT(*) FROM (
            SELECT 1 FROM Activite_physique 
            WHERE calories_brulees >= 100
            GROUP BY date(date_activite)
          )) as current,
          100 as target,
          (SELECT date_activite FROM Activite_physique 
           WHERE calories_brulees >= 100 
           ORDER BY date_activite DESC LIMIT 1) as unlocked_at
        FROM Activite_physique
        WHERE calories_brulees IS NOT NULL
        LIMIT 1
      ''');
      
      debugPrint('Calorie Crusher Query Result: $result');
      return result.isNotEmpty ? result.first : {'is_unlocked': 0, 'current': 0, 'target': 100, 'unlocked_at': null};
    } catch (e) {
      debugPrint('Error in _checkCalorieCrusher: $e');
      return {'is_unlocked': 0, 'current': 0, 'target': 100, 'unlocked_at': null};
    }
  }

  Future<Map<String, dynamic>> _checkStrengthBuilder(Database db) async {
    try {
      final result = await db.rawQuery('''
        SELECT 
          COUNT(*) as current,
          CASE WHEN COUNT(*) >= 3 THEN 1 ELSE 0 END as is_unlocked,
          3 as target,
          (SELECT date_activite FROM Activite_physique 
           WHERE type_activite = 'Weightlifting' 
           ORDER BY date_activite DESC LIMIT 1) as unlocked_at
        FROM Activite_physique
        WHERE type_activite = 'Weightlifting'
      ''');
      return result.isNotEmpty ? result.first : {'is_unlocked': 0, 'current': 0, 'target': 3, 'unlocked_at': null};
    } catch (e) {
      debugPrint('Error in _checkStrengthBuilder: $e');
      return {'is_unlocked': 0, 'current': 0, 'target': 3, 'unlocked_at': null};
    }
  }

  Future<Map<String, dynamic>> _checkSwimStar(Database db) async {
    try {
      final result = await db.rawQuery('''
        SELECT 
          CASE WHEN MAX(laps) >= 10 THEN 1 ELSE 0 END as is_unlocked,
          COALESCE(MAX(laps), 0) as current,
          10 as target,
          (SELECT date_activite FROM Activite_physique 
           WHERE laps >= 10 AND type_activite = 'Swimming' 
           ORDER BY date_activite DESC LIMIT 1) as unlocked_at
        FROM Activite_physique
        WHERE type_activite = 'Swimming'
      ''');
      return result.isNotEmpty ? result.first : {'is_unlocked': 0, 'current': 0, 'target': 10, 'unlocked_at': null};
    } catch (e) {
      debugPrint('Error in _checkSwimStar: $e');
      return {'is_unlocked': 0, 'current': 0, 'target': 10, 'unlocked_at': null};
    }
  }

  Future<Map<String, dynamic>> _checkRoadRider(Database db) async {
    try {
      final result = await db.rawQuery('''
        SELECT 
          CASE WHEN EXISTS (
            SELECT 1 FROM Activite_physique 
            WHERE distance >= 10 AND type_activite = 'Cycling'
          ) THEN 1 ELSE 0 END as is_unlocked,
          (SELECT COUNT(*) FROM (
            SELECT 1 FROM Activite_physique 
            WHERE distance >= 10 AND type_activite = 'Cycling'
            GROUP BY date(date_activite)
          )) as current,
          1 as target,
          (SELECT date_activite FROM Activite_physique 
           WHERE distance >= 10 AND type_activite = 'Cycling' 
           ORDER BY date_activite DESC LIMIT 1) as unlocked_at
        FROM Activite_physique
        WHERE type_activite = 'Cycling'
        LIMIT 1
      ''');
      return result.isNotEmpty ? result.first : {'is_unlocked': 0, 'current': 0, 'target': 1, 'unlocked_at': null};
    } catch (e) {
      debugPrint('Error in _checkRoadRider: $e');
      return {'is_unlocked': 0, 'current': 0, 'target': 1, 'unlocked_at': null};
    }
  }

  Future<Map<String, dynamic>> _checkConsistencyKing(Database db) async {
    try {
      final result = await db.rawQuery('''
        WITH dates AS (
          SELECT DISTINCT date(date_activite) as activity_date
          FROM Activite_physique
          WHERE date_activite >= date('now', '-30 days')
        ),
        ranked_dates AS (
          SELECT 
            activity_date,
            julianday(activity_date) - julianday('now', '-30 days') - 
            ROW_NUMBER() OVER (ORDER BY activity_date) as grp
          FROM dates
        ),
        grouped_dates AS (
          SELECT 
            activity_date,
            COUNT(*) OVER (PARTITION BY grp) as consecutive_days
          FROM ranked_dates
        )
        SELECT 
          MAX(consecutive_days) as current,
          CASE WHEN MAX(consecutive_days) >= 3 THEN 1 ELSE 0 END as is_unlocked,
          3 as target,
          (SELECT activity_date FROM grouped_dates 
           WHERE consecutive_days >= 3 
           ORDER BY activity_date DESC LIMIT 1) as unlocked_at
        FROM grouped_dates
        WHERE consecutive_days >= 3
        LIMIT 1
      ''');
      return result.isNotEmpty ? result.first : {'is_unlocked': 0, 'current': 0, 'target': 3, 'unlocked_at': null};
    } catch (e) {
      debugPrint('Error in _checkConsistencyKing: $e');
      return {'is_unlocked': 0, 'current': 0, 'target': 3, 'unlocked_at': null};
    }
  }

  Future<Map<String, dynamic>> _checkAllRounder(Database db) async {
    try {
      final result = await db.rawQuery('''
        SELECT 
          COUNT(DISTINCT type_activite) as current,
          CASE WHEN COUNT(DISTINCT type_activite) >= 4 THEN 1 ELSE 0 END as is_unlocked,
          4 as target,
          (SELECT date_activite FROM Activite_physique 
           GROUP BY type_activite 
           ORDER BY date_activite DESC 
           LIMIT 1) as unlocked_at
        FROM Activite_physique
      ''');
      return result.isNotEmpty ? result.first : {'is_unlocked': 0, 'current': 0, 'target': 4, 'unlocked_at': null};
    } catch (e) {
      debugPrint('Error in _checkAllRounder: $e');
      return {'is_unlocked': 0, 'current': 0, 'target': 4, 'unlocked_at': null};
    }
  }

  Future<Map<String, dynamic>> _checkMarathonMindset(Database db) async {
    try {
      final result = await db.rawQuery('''
        SELECT 
          COUNT(*) as current,
          CASE WHEN COUNT(*) >= 10 THEN 1 ELSE 0 END as is_unlocked,
          10 as target,
          (SELECT date_activite FROM Activite_physique 
           ORDER BY date_activite DESC 
           LIMIT 1) as unlocked_at
        FROM Activite_physique
      ''');
      return result.isNotEmpty ? result.first : {'is_unlocked': 0, 'current': 0, 'target': 10, 'unlocked_at': null};
    } catch (e) {
      debugPrint('Error in _checkMarathonMindset: $e');
      return {'is_unlocked': 0, 'current': 0, 'target': 10, 'unlocked_at': null};
    }
  }

  Future<Map<String, dynamic>> _checkSpeedDemon(Database db) async {
    try {
      final result = await db.rawQuery('''
        SELECT 
          CASE WHEN MAX(avg_speed) >= 10.0 THEN 1 ELSE 0 END as is_unlocked,
          COALESCE(MAX(avg_speed), 0) as current,
          10.0 as target,
          (SELECT date_activite FROM Activite_physique 
           WHERE avg_speed >= 10.0 
           ORDER BY date_activite DESC LIMIT 1) as unlocked_at
        FROM Activite_physique
      ''');
      return result.isNotEmpty ? result.first : {'is_unlocked': 0, 'current': 0, 'target': 10.0, 'unlocked_at': null};
    } catch (e) {
      debugPrint('Error in _checkSpeedDemon: $e');
      return {'is_unlocked': 0, 'current': 0, 'target': 10.0, 'unlocked_at': null};
    }
  }

  Future<Map<String, dynamic>> _checkTargetSmasher(Database db) async {
    try {
      final result = await db.rawQuery('''
        SELECT 
          CASE WHEN MAX(duree) >= 30 THEN 1 ELSE 0 END as is_unlocked,
          COALESCE(MAX(duree), 0) as current,
          30 as target,
          (SELECT date_activite FROM Activite_physique 
           WHERE duree >= 30 
           ORDER BY date_activite DESC LIMIT 1) as unlocked_at
        FROM Activite_physique
      ''');
      return result.isNotEmpty ? result.first : {'is_unlocked': 0, 'current': 0, 'target': 30, 'unlocked_at': null};
    } catch (e) {
      debugPrint('Error in _checkTargetSmasher: $e');
      return {'is_unlocked': 0, 'current': 0, 'target': 30, 'unlocked_at': null};
    }
  }

  void _showBadgeUnlockedDialog(Badge badge) {
    _confettiController.play();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 10,
          title: const Text(
            '🎉 Achievement Unlocked!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.amber,
              fontSize: 24,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      badge.color.withOpacity(0.7),
                      badge.color,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: badge.color.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  badge.icon,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 20),
              
              Text(
                badge.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 10),
              
              Text(
                badge.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 20),
              
              Lottie.asset(
                'assets/lottie/confetti.json',
                width: 200,
                height: 150,
                fit: BoxFit.cover,
                controller: _lottieController,
                onLoaded: (composition) {
                  _confettiController.duration = composition.duration;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _confettiController.stop();
              },
              child: const Text(
                'AWESOME!',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  // Filter badges based on selected categories
  List<Badge> _filterBadges() {
    if (selectedCategories.isEmpty) return [];
    return badges.where((badge) => selectedCategories.contains(badge.category)).toList();
  }

  // Toggle category selection
  void _toggleCategory(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }
      filteredBadges = _filterBadges();
    });
  }

  // Show badge details in a modal bottom sheet
  void _showBadgeDetails(Badge badge) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              
              // Badge icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: badge.isUnlocked 
                    ? badge.color.withOpacity(0.1) 
                    : Colors.grey[200],
                  border: Border.all(
                    color: badge.isUnlocked ? badge.color : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Icon(
                  badge.icon,
                  size: 60,
                  color: badge.isUnlocked ? badge.color : Colors.grey[400],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Badge name
              Text(
                badge.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 10),
              
              // Badge status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: badge.isUnlocked 
                    ? Colors.green.withOpacity(0.1) 
                    : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge.isUnlocked ? 'UNLOCKED' : 'LOCKED',
                  style: TextStyle(
                    color: badge.isUnlocked ? Colors.green : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Badge description
              Text(
                badge.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 20),
              
              // Progress indicator for badges with targets > 1
              if (badge.target > 1) ...[
                LinearProgressIndicator(
                  value: (badge.current / badge.target).clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    badge.isUnlocked ? badge.color : Colors.grey[400]!,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${badge.current} / ${badge.target} completed',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
              ],
              
              // Unlock date if available
              if (badge.unlockedAt != null) ...[
                Text(
                  'Unlocked on ${DateFormat('MMM d, y').format(badge.unlockedAt!)}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              
              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: badge.color,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'GOT IT',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeCard(Badge badge) {
    // Add floating animation controller for unlocked badges
    final AnimationController _floatController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    final Animation<double> _floatAnimation = Tween<double>(
      begin: 0,
      end: 8,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    // Dispose the controller when the widget is disposed
    _floatController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        _floatController.dispose();
      }
    });

    return GestureDetector(
      onTap: () => _showBadgeDetails(badge),
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          return Transform.translate(
            offset: badge.isUnlocked ? Offset(0, _floatAnimation.value - 4) : Offset.zero,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  if (badge.isUnlocked)
                    BoxShadow(
                      color: badge.color.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Icon with glow effect for unlocked badges
                        badge.isUnlocked
                            ? Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: badge.color.withOpacity(0.5),
                                      blurRadius: 10,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  badge.icon,
                                  size: 32,
                                  color: badge.color,
                                ),
                              )
                            : Icon(
                                badge.icon,
                                size: 32,
                                color: Colors.grey[400],
                              ),
                        const SizedBox(height: 6),
                        Text(
                          badge.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: badge.isUnlocked ? Colors.black87 : Colors.grey[600],
                            fontSize: 12,
                            height: 3,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (badge.target > 1) ...[
                          const SizedBox(height: 4),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 4,
                                child: LinearProgressIndicator(
                                  value: (badge.current / badge.target).clamp(0.0, 1.0),
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    badge.isUnlocked ? badge.color : Colors.grey[400]!,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${badge.current >= badge.target ? badge.target : badge.current}/${badge.target}',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const Spacer(),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: badge.isUnlocked ? badge.color.withOpacity(0.1) : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: badge.isUnlocked ? badge.color.withOpacity(0.3) : Colors.grey[300]!,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            badge.isUnlocked ? 'UNLOCKED' : 'LOCKED',
                            style: TextStyle(
                              color: badge.isUnlocked ? badge.color : Colors.grey[600],
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (badge.isUnlocked)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Shimmer.fromColors(
                          baseColor: Colors.white.withOpacity(0.1),
                          highlightColor: Colors.white.withOpacity(0.3),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              gradient: RadialGradient(
                                radius: 0.7,
                                colors: [
                                  badge.color.withOpacity(0.1),
                                  badge.color.withOpacity(0.05),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Badges',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: Theme.of(context).brightness == Brightness.light 
                ? Colors.black87 
                : Colors.white,
            shadows: [
              Shadow(
                offset: const Offset(0, 2),
                blurRadius: 4.0,
                color: Colors.black.withOpacity(0.1),
              ),
            ],
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          // Add a filter button in the app bar
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options in a dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Filter Badges'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Select categories to show:'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: badgeCategories.map((category) {
                            final isSelected = selectedCategories.contains(category);
                            return FilterChip(
                              label: Text(
                                category.replaceAll('_', ' ').toUpperCase(),
                                style: TextStyle(
                                  color: isSelected ? Colors.white : null,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: Theme.of(context).primaryColor,
                              checkmarkColor: Colors.white,
                              onSelected: (_) => _toggleCategory(category),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CLOSE'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : badges.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/lottie/empty.json',
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'No badges yet!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Complete activities to earn badges',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadBadges,
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Filter chips for quick filtering
                    Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          // All filter
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: const Text('ALL'),
                              selected: selectedCategories.length == badgeCategories.length,
                              onSelected: (_) {
                                setState(() {
                                  if (selectedCategories.length == badgeCategories.length) {
                                    selectedCategories.clear();
                                  } else {
                                    selectedCategories = Set.from(badgeCategories);
                                  }
                                  filteredBadges = _filterBadges();
                                });
                              },
                            ),
                          ),
                          // Category filters
                          ...badgeCategories.map((category) {
                            final isSelected = selectedCategories.contains(category);
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FilterChip(
                                label: Text(
                                  category.replaceAll('_', ' ').toUpperCase(),
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : null,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (_) => _toggleCategory(category),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    // Main badges grid
                    Expanded(
                      child: filteredBadges.isEmpty
                          ? const Center(
                              child: Text('No badges match the selected filters'),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.all(16.0),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.85,
                                crossAxisSpacing: 16.0,
                                mainAxisSpacing: 16.0,
                              ),
                              itemCount: filteredBadges.length,
                              itemBuilder: (context, index) {
                                return _buildBadgeCard(filteredBadges[index]);
                              },
                            ),
                    ),
                    
                    // Confetti effect
                    Align(
                      alignment: Alignment.topCenter,
                      child: ConfettiWidget(
                        confettiController: _confettiController,
                        blastDirectionality: BlastDirectionality.explosive,
                        shouldLoop: false,
                        colors: const [
                          Colors.green,
                          Colors.blue,
                          Colors.pink,
                          Colors.orange,
                          Colors.purple,
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}