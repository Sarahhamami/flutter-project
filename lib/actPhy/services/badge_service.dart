// lib/actPhy/services/badge_service.dart
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BadgeService {
  static final BadgeService _instance = BadgeService._internal();
  static Database? _database;

  factory BadgeService() => _instance;

  BadgeService._internal();
Future<void> initialize() async {
  await database; // This will initialize the database if not already initialized
}
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'fitness_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS badges(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        icon_code_point INTEGER NOT NULL,
        icon_font_family TEXT,
        icon_package TEXT,
        target INTEGER NOT NULL,
        current INTEGER NOT NULL,
        color_value INTEGER NOT NULL,
        is_unlocked INTEGER DEFAULT 0,
        unlocked_at TEXT,
        category TEXT NOT NULL
      )
    ''');

    // Default badges
    final defaultBadges = [
      // Step-related
      _createBadgeMap(
        id: 'step_starter',
        name: 'Step Starter',
        description: 'Take 1,000 steps in a single session',
        icon: FontAwesomeIcons.shoePrints,
        target: 1000,
        color: Colors.blue,
        category: 'steps',
      ),
      // Calorie-related
      _createBadgeMap(
        id: 'calorie_crusher',
        name: 'Calorie Crusher',
        description: 'Burn 100 calories or more in one activity',
        icon: FontAwesomeIcons.fire,
        target: 100,
        color: Colors.orange,
        category: 'calories',
      ),
      // Strength-related
      _createBadgeMap(
        id: 'strength_builder',
        name: 'Strength Builder',
        description: 'Complete 3+ weightlifting sessions',
        icon: FontAwesomeIcons.dumbbell,
        target: 3,
        color: Colors.purple,
        category: 'strength',
      ),
      // Swimming
      _createBadgeMap(
        id: 'swim_star',
        name: 'Swim Star',
        description: 'Swim 10+ laps total',
        icon: FontAwesomeIcons.personSwimming,
        target: 10,
        color: Colors.blueAccent,
        category: 'swimming',
      ),
      // Cycling
      _createBadgeMap(
        id: 'road_rider',
        name: 'Road Rider',
        description: 'Cycle more than 10 km',
        icon: FontAwesomeIcons.bicycle,
        target: 10,
        color: Colors.green,
        category: 'cycling',
      ),
      // Consistency
      _createBadgeMap(
        id: 'consistency_king',
        name: 'Consistency King',
        description: 'Train 3 consecutive days',
        icon: FontAwesomeIcons.calendarCheck,
        target: 3,
        color: Colors.amber,
        category: 'consistency',
      ),
      // All-rounder
      _createBadgeMap(
        id: 'all_rounder',
        name: 'All-Rounder',
        description: 'Perform 4 different activity types',
        icon: FontAwesomeIcons.star,
        target: 4,
        color: Colors.teal,
        category: 'variety',
      ),
      // Marathon
      _createBadgeMap(
        id: 'marathon_mindset',
        name: 'Marathon Mindset',
        description: 'Log 10 total activities',
        icon: FontAwesomeIcons.medal,
        target: 10,
        color: Colors.indigo,
        category: 'endurance',
      ),
      // Speed
      _createBadgeMap(
        id: 'speed_demon',
        name: 'Speed Demon',
        description: 'Achieve average speed ≥ 10 km/h',
        icon: FontAwesomeIcons.gaugeHigh,
        target: 10,
        color: Colors.red,
        category: 'speed',
      ),
      // Duration
      _createBadgeMap(
        id: 'target_smasher',
        name: 'Target Smasher',
        description: 'Complete a session over 30 minutes',
        icon: FontAwesomeIcons.clock,
        target: 30,
        color: Colors.pink,
        category: 'duration',
      ),
    ];

    final batch = db.batch();
    for (var badge in defaultBadges) {
      batch.insert(
        'badges',
        badge,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }

  Map<String, dynamic> _createBadgeMap({
    required String id,
    required String name,
    required String description,
    required IconData icon,
    required int target,
    required Color color,
    required String category,
  }) {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_code_point': icon.codePoint,
      'icon_font_family': icon.fontFamily,
      'icon_package': icon.fontPackage,
      'target': target,
      'current': 0,
      'color_value': color.value,
      'is_unlocked': 0,
      'unlocked_at': null,
      'category': category,
    };
  }

  Future<void> updateBadgeProgress(String badgeId, int newProgress) async {
    final db = await database;
    await db.transaction((txn) async {
      final badge = await txn.query(
        'badges',
        where: 'id = ?',
        whereArgs: [badgeId],
      );

      if (badge.isNotEmpty) {
        final currentProgress = badge.first['current'] as int;
        final target = badge.first['target'] as int;
        final isUnlocked = badge.first['is_unlocked'] == 1;
        final updatedProgress = currentProgress + newProgress;
        final shouldUnlock = updatedProgress >= target && !isUnlocked;

        await txn.update(
          'badges',
          {
            'current': updatedProgress,
            'is_unlocked': isUnlocked || shouldUnlock ? 1 : 0,
            if (shouldUnlock) 'unlocked_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [badgeId],
        );

        if (shouldUnlock) {
          // Trigger any additional logic for newly unlocked badges
        }
      }
    });
  }
// Add this to badge_service.dart
Future<void> updateAllBadges() async {
  final db = await database;
  final activities = await db.query('Activite_physique');
  
  print('Updating all badges based on ${activities.length} activities');
  
  // Process each activity to update badge progress
  for (var activity in activities) {
    await updateFromActivity(activity);
  }
  
  print('Finished updating all badges');
}
  Future<List<Map<String, dynamic>>> getBadgesByCategory(String category) async {
    final db = await database;
    return await db.query(
      'badges',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'is_unlocked DESC, name ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllBadges() async {
    final db = await database;
    return await db.query(
      'badges',
      orderBy: 'is_unlocked DESC, name ASC',
    );
  }

  Future<void> resetBadges() async {
    final db = await database;
    await db.update(
      'badges',
      {'current': 0, 'is_unlocked': 0, 'unlocked_at': null},
    );
  }

  Future<void> updateFromActivity(Map<String, dynamic> activity) async {
    final db = await database;
    final userId = activity['id_utilisateur'];
    final activityType = activity['type_activite']?.toString().toLowerCase() ?? '';
    
    print('Updating badges for activity: $activity');
    
    // 1. Step Starter - Check for walking activity with >= 1000 steps
    if ((activityType.contains('walking') || activityType.contains('running')) && 
        (activity['pas'] != null && (activity['pas'] as num) > 0)) {
      final steps = activity['pas'] as int;
      print('Updating step_starter with steps: $steps');
      await updateBadgeProgress('step_starter', steps);
    }

    // 2. Calorie Crusher - Check for any activity with >= 100 calories
    if (activity['calories_brulees'] != null && (activity['calories_brulees'] as num) > 0) {
      final calories = activity['calories_brulees'] as num;
      print('Updating calorie_crusher with calories: $calories');
      await updateBadgeProgress('calorie_crusher', calories.toInt());
    }

    // 3. Strength Builder - Count weightlifting activities (case-insensitive)
    if (activityType.contains('weightlifting')) {
      final weightliftingCount = await db.rawQuery('''
        SELECT COUNT(*) as count 
        FROM Activite_physique 
        WHERE id_utilisateur = ? AND LOWER(type_activite) LIKE '%weightlifting%'
      ''', [userId]);
      
      if (weightliftingCount.isNotEmpty) {
        final count = weightliftingCount.first['count'] as int;
        print('Updating strength_builder with count: $count');
        await updateBadgeProgress('strength_builder', count);
      }
    }

    // 4. Swim Star - Check for swimming activity with >= 10 laps
    if (activityType.contains('swimming') && activity['laps'] != null) {
      final laps = activity['laps'] as int;
      print('Updating swim_star with laps: $laps');
      await updateBadgeProgress('swim_star', laps);
    }

    // 5. Road Rider - Check for cycling activity with >= 10km distance
    if (activityType.contains('cycling') && activity['distance'] != null) {
      final distance = activity['distance'] as num;
      print('Updating road_rider with distance: $distance');
      await updateBadgeProgress('road_rider', distance.toInt());
    }

    // 6. Consistency King - Check for 3 consecutive days of activities
    final consecutiveDays = await db.rawQuery('''
      WITH RECURSIVE dates(date) AS (
        SELECT date('now', '-30 days')
        UNION ALL
        SELECT date(date, '+1 day')
        FROM dates
        WHERE date < date('now')
      ),
      activity_dates AS (
        SELECT DISTINCT date(date_activite) as activity_date
        FROM Activite_physique
        WHERE id_utilisateur = ?
      ),
      grouped_dates AS (
        SELECT date,
               date(date, '-' || ROW_NUMBER() OVER (ORDER BY date) || ' day') as grp
        FROM dates
        JOIN activity_dates ON dates.date = activity_dates.activity_date
      )
      SELECT COUNT(*) as consecutive_count
      FROM (
        SELECT grp, COUNT(*) as cnt
        FROM grouped_dates
        GROUP BY grp
        ORDER BY cnt DESC
        LIMIT 1
      ) t
    ''', [userId]);
    
    if (consecutiveDays.isNotEmpty) {
      final count = consecutiveDays.first['consecutive_count'] as int;
      print('Updating consistency_king with consecutive days: $count');
      await updateBadgeProgress('consistency_king', count);
    }

    // 7. All-Rounder - Count distinct activity types (case-insensitive)
    final activityTypes = await db.rawQuery('''
      SELECT COUNT(DISTINCT LOWER(TRIM(type_activite))) as count 
      FROM Activite_physique 
      WHERE id_utilisateur = ?
    ''', [userId]);
    
    if (activityTypes.isNotEmpty) {
      final count = activityTypes.first['count'] as int;
      print('Updating all_rounder with activity types: $count');
      await updateBadgeProgress('all_rounder', count);
    }

    // 8. Marathon Mindset - Count total activities
    final totalActivities = await db.rawQuery('''
      SELECT COUNT(*) as count 
      FROM Activite_physique 
      WHERE id_utilisateur = ?
    ''', [userId]);
    
    if (totalActivities.isNotEmpty) {
      final count = totalActivities.first['count'] as int;
      print('Updating marathon_mindset with total activities: $count');
      await updateBadgeProgress('marathon_mindset', count);
    }

    // 9. Speed Demon - Check for max speed >= 10 km/h
    if (activity['avg_speed'] != null || activity['max_speed'] != null) {
      final maxSpeed = await db.rawQuery('''
        SELECT COALESCE(GREATEST(MAX(COALESCE(avg_speed, 0)), MAX(COALESCE(max_speed, 0))), 0) as max_speed
        FROM Activite_physique 
        WHERE id_utilisateur = ? AND (avg_speed IS NOT NULL OR max_speed IS NOT NULL)
      ''', [userId]);
      
      if (maxSpeed.isNotEmpty) {
        final speed = (maxSpeed.first['max_speed'] as num).toDouble();
        print('Updating speed_demon with max speed: $speed');
        await updateBadgeProgress('speed_demon', speed.toInt());
      }
    }

    // 10. Target Smasher - Check for duration > 30 minutes
    if (activity['duree'] != null) {
      final maxDuration = await db.rawQuery('''
        SELECT COALESCE(MAX(duree), 0) as max_duration
        FROM Activite_physique 
        WHERE id_utilisateur = ? AND duree IS NOT NULL
      ''', [userId]);
      
      if (maxDuration.isNotEmpty) {
        final duration = (maxDuration.first['max_duration'] as num).toInt();
        print('Updating target_smasher with max duration: $duration');
        await updateBadgeProgress('target_smasher', duration);
      }
    }
    
    print('Finished updating badges');
  }

  Future<Map<String, dynamic>?> getBadge(String id) async {
    final db = await database;
    final results = await db.query(
      'badges',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> getUnlockedBadgesCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM badges WHERE is_unlocked = 1',
    );
    return result.first['count'] as int;
  }

  Future<int> getTotalBadgesCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM badges');
    return result.first['count'] as int;
  }
}