import 'package:sqflite/sqflite.dart';
import '../db/database_helper.dart';
import '../models/wellness_models.dart';

class WellnessRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Sleep methods
  Future<int> insertSleep(Sleep sleep) async {
    final db = await _databaseHelper.database;
    return await db.insert('Sleep', sleep.toMap());
  }

  Future<List<Sleep>> getSleepByUserId(int userId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Sleep',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Sleep.fromMap(maps[i]));
  }

  // Mood methods
  Future<int> insertMood(Mood mood) async {
    final db = await _databaseHelper.database;
    return await db.insert('Mood', mood.toMap());
  }

  Future<List<Mood>> getMoodByUserId(int userId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Mood',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Mood.fromMap(maps[i]));
  }

  // Cycle methods
  Future<int> insertCycle(Cycle cycle) async {
    final db = await _databaseHelper.database;
    return await db.insert('Cycle', cycle.toMap());
  }

  Future<List<Cycle>> getCycleByUserId(int userId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Cycle',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'cycleStartDate DESC',
    );
    return List.generate(maps.length, (i) => Cycle.fromMap(maps[i]));
  }

  // Recommendation methods
  Future<int> insertRecommendation(Recommendation recommendation) async {
    final db = await _databaseHelper.database;
    return await db.insert('Recommendation', recommendation.toMap());
  }

  Future<List<Recommendation>> getRecommendationsByUserId(int userId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Recommendation',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Recommendation.fromMap(maps[i]));
  }

  // LifestyleLog methods
  Future<int> insertLifestyleLog(LifestyleLog log) async {
    final db = await _databaseHelper.database;
    return await db.insert('LifestyleLog', log.toMap());
  }

  Future<List<LifestyleLog>> getLifestyleLogsByUserId(int userId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'LifestyleLog',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => LifestyleLog.fromMap(maps[i]));
  }
}