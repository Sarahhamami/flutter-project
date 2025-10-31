import 'package:sqflite/sqflite.dart';
import '../db/database_helper.dart';

class UserRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'Utilisateur',
      user,
      conflictAlgorithm: ConflictAlgorithm.abort, // prevent overwriting
    );
  }

  // 🔍 Check if a user with the same email exists
  Future<bool> userExists(String email) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'Utilisateur',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  // 🔎 Get a specific user by email (for login)
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'Utilisateur',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  // ❌ Delete a user (if needed)
  Future<int> deleteUser(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'Utilisateur',
      where: 'user_id = ?',
      whereArgs: [id],
    );
  }
  Future<void> updateUserVerification(String email, int verified) async {
  final db = await DatabaseHelper().database;
  await db.update(
    'Utilisateur',
    {'is_verified': verified},
    where: 'email = ?',
    whereArgs: [email],
  );

}
Future<void> updatePassword(String email, String newHashedPassword) async {
    final db = await _dbHelper.database;
    await db.update(
      'Utilisateur',
      {'mot_de_passe': newHashedPassword},
      where: 'email = ?',
      whereArgs: [email],
    );
  }
  Future<List<Map<String, dynamic>>> getAllDoctors() async {
  final db = await _dbHelper.database;
  final result = await db.query(
    'Utilisateur',
    where: 'role = ?',
    whereArgs: ['Doctor'],
  );
  return result;
}
Future<void> updateUser(int id, Map<String, dynamic> updatedFields) async {
  final db = await _dbHelper.database;
  await db.update(
    'Utilisateur',
    updatedFields,
    where: 'user_id = ?',
    whereArgs: [id],
  );
}

}
