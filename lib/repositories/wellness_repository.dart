import 'package:sqflite/sqflite.dart';
import '../db/database_helper.dart';
import '../models/wellness_models.dart';

class WellnessRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final List<Sleep> _sleepRecords = [];
  final List<Mood> _moodRecords = [];
  final List<Cycle> _cycleRecords = [];

  // Sleep methods - Version améliorée
  Future<int> insertSleep(Sleep sleep) async {
    try {
      if (_databaseHelper.isWeb) {
        // Fallback pour le web - stockage en mémoire
        final newSleep = Sleep(
          id: _sleepRecords.length + 1,
          userId: sleep.userId,
          date: sleep.date,
          bedTime: sleep.bedTime,
          wakeUpTime: sleep.wakeUpTime,
          sleepDuration: sleep.sleepDuration,
          sleepQuality: sleep.sleepQuality,
        );
        _sleepRecords.add(newSleep);
        print('📝 Sleep record saved in memory (Web mode) - ID: ${newSleep.id}');
        return newSleep.id!;
      } else {
        // Mode mobile - vraie base de données
        final db = await _databaseHelper.database;
        final id = await db.insert('Sleep', sleep.toMap());
        print('✅ Sleep record saved in database (Mobile mode) - ID: $id');
        return id;
      }
    } catch (e) {
      print('❌ Error saving sleep record: Using memory fallback');
      // Fallback en mémoire en cas d'erreur
      final newSleep = Sleep(
        id: _sleepRecords.length + 1,
        userId: sleep.userId,
        date: sleep.date,
        bedTime: sleep.bedTime,
        wakeUpTime: sleep.wakeUpTime,
        sleepDuration: sleep.sleepDuration,
        sleepQuality: sleep.sleepQuality,
      );
      _sleepRecords.add(newSleep);
      return newSleep.id!;
    }
  }

  Future<List<Sleep>> getSleepByUserId(int userId) async {
    try {
      if (_databaseHelper.isWeb) {
        // Retourner les données en mémoire pour le web
        return _sleepRecords.where((record) => record.userId == userId).toList();
      } else {
        final db = await _databaseHelper.database;
        final List<Map<String, dynamic>> maps = await db.query(
          'Sleep',
          where: 'user_id = ?',
          whereArgs: [userId],
          orderBy: 'date DESC',
        );
        return List.generate(maps.length, (i) => Sleep.fromMap(maps[i]));
      }
    } catch (e) {
      print('❌ Error fetching sleep records: Using memory data');
      return _sleepRecords.where((record) => record.userId == userId).toList();
    }
  }

  // Mood methods - Version améliorée
  Future<int> insertMood(Mood mood) async {
    try {
      if (_databaseHelper.isWeb) {
        final newMood = Mood(
          id: _moodRecords.length + 1,
          userId: mood.userId,
          date: mood.date,
          stressLevel: mood.stressLevel,
          mood: mood.mood,
          energyLevel: mood.energyLevel,
        );
        _moodRecords.add(newMood);
        print('📝 Mood record saved in memory (Web mode) - ID: ${newMood.id}');
        return newMood.id!;
      } else {
        final db = await _databaseHelper.database;
        final id = await db.insert('Mood', mood.toMap());
        print('✅ Mood record saved in database (Mobile mode) - ID: $id');
        return id;
      }
    } catch (e) {
      print('❌ Error saving mood record: Using memory fallback');
      final newMood = Mood(
        id: _moodRecords.length + 1,
        userId: mood.userId,
        date: mood.date,
        stressLevel: mood.stressLevel,
        mood: mood.mood,
        energyLevel: mood.energyLevel,
      );
      _moodRecords.add(newMood);
      return newMood.id!;
    }
  }

  Future<List<Mood>> getMoodByUserId(int userId) async {
    try {
      if (_databaseHelper.isWeb) {
        return _moodRecords.where((record) => record.userId == userId).toList();
      } else {
        final db = await _databaseHelper.database;
        final List<Map<String, dynamic>> maps = await db.query(
          'Mood',
          where: 'user_id = ?',
          whereArgs: [userId],
          orderBy: 'date DESC',
        );
        return List.generate(maps.length, (i) => Mood.fromMap(maps[i]));
      }
    } catch (e) {
      print('❌ Error fetching mood records: Using memory data');
      return _moodRecords.where((record) => record.userId == userId).toList();
    }
  }

  // Cycle methods - Version améliorée
  Future<int> insertCycle(Cycle cycle) async {
    try {
      if (_databaseHelper.isWeb) {
        final newCycle = Cycle(
          id: _cycleRecords.length + 1,
          userId: cycle.userId,
          cycleStartDate: cycle.cycleStartDate,
          cycleEndDate: cycle.cycleEndDate,
          symptoms: cycle.symptoms,
        );
        _cycleRecords.add(newCycle);
        print('📝 Cycle record saved in memory (Web mode) - ID: ${newCycle.id}');
        return newCycle.id!;
      } else {
        final db = await _databaseHelper.database;
        final id = await db.insert('Cycle', cycle.toMap());
        print('✅ Cycle record saved in database (Mobile mode) - ID: $id');
        return id;
      }
    } catch (e) {
      print('❌ Error saving cycle record: Using memory fallback');
      final newCycle = Cycle(
        id: _cycleRecords.length + 1,
        userId: cycle.userId,
        cycleStartDate: cycle.cycleStartDate,
        cycleEndDate: cycle.cycleEndDate,
        symptoms: cycle.symptoms,
      );
      _cycleRecords.add(newCycle);
      return newCycle.id!;
    }
  }

  Future<List<Cycle>> getCycleByUserId(int userId) async {
    try {
      if (_databaseHelper.isWeb) {
        return _cycleRecords.where((record) => record.userId == userId).toList();
      } else {
        final db = await _databaseHelper.database;
        final List<Map<String, dynamic>> maps = await db.query(
          'Cycle',
          where: 'user_id = ?',
          whereArgs: [userId],
          orderBy: 'cycleStartDate DESC',
        );
        return List.generate(maps.length, (i) => Cycle.fromMap(maps[i]));
      }
    } catch (e) {
      print('❌ Error fetching cycle records: Using memory data');
      return _cycleRecords.where((record) => record.userId == userId).toList();
    }
  }

  // Statistics method - Version améliorée
  Future<Map<String, dynamic>> getWellnessStats(int userId) async {
    try {
      List<Sleep> sleepRecords;
      List<Mood> moodRecords;

      if (_databaseHelper.isWeb) {
        sleepRecords = _sleepRecords.where((record) => record.userId == userId).toList();
        moodRecords = _moodRecords.where((record) => record.userId == userId).toList();
      } else {
        final db = await _databaseHelper.database;
        
        final sleepMaps = await db.query(
          'Sleep',
          where: 'user_id = ?',
          whereArgs: [userId],
        );
        sleepRecords = List.generate(sleepMaps.length, (i) => Sleep.fromMap(sleepMaps[i]));
        
        final moodMaps = await db.query(
          'Mood',
          where: 'user_id = ?',
          whereArgs: [userId],
        );
        moodRecords = List.generate(moodMaps.length, (i) => Mood.fromMap(moodMaps[i]));
      }

      // Calculer les moyennes
      double avgSleep = sleepRecords.isNotEmpty 
          ? sleepRecords.map((e) => e.sleepDuration).reduce((a, b) => a + b) / sleepRecords.length
          : 7.0;

      double avgStress = moodRecords.isNotEmpty
          ? moodRecords.map((e) => e.stressLevel.toDouble()).reduce((a, b) => a + b) / moodRecords.length
          : 5.0;

      double avgEnergy = moodRecords.isNotEmpty
          ? moodRecords.map((e) => e.energyLevel.toDouble()).reduce((a, b) => a + b) / moodRecords.length
          : 6.0;

      return {
        'avgSleep': avgSleep,
        'avgStress': avgStress,
        'avgEnergy': avgEnergy,
      };
    } catch (e) {
      print('❌ Error calculating stats: Using default values');
      return {
        'avgSleep': 7.2,
        'avgStress': 4.5,
        'avgEnergy': 6.8,
      };
    }
  }

  // Méthodes pour debug
  void printAllRecords() {
    print('📊 Current records in memory:');
    print('Sleep records: ${_sleepRecords.length}');
    _sleepRecords.forEach((record) {
      print('😴 Sleep: ${record.date} - ${record.sleepDuration}h - ${record.sleepQuality}');
    });
    
    print('Mood records: ${_moodRecords.length}');
    _moodRecords.forEach((record) {
      print('🎭 Mood: ${record.date} - ${record.mood} - Stress: ${record.stressLevel}');
    });
    
    print('Cycle records: ${_cycleRecords.length}');
    _cycleRecords.forEach((record) {
      print('♻️ Cycle: ${record.cycleStartDate} to ${record.cycleEndDate} - Symptoms: ${record.symptoms.join(", ")}');
    });
  }

  // Vider la mémoire (pour les tests)
  void clearMemoryStorage() {
    _sleepRecords.clear();
    _moodRecords.clear();
    _cycleRecords.clear();
    print('🧹 Memory storage cleared');
  }
}