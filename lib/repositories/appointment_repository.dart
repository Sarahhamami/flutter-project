import 'package:flutter_application_1/db/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class AppointmentRepository {
  Future<Database> get _db async => await DatabaseHelper().database;

  Future<void> insertAppointment(Map<String, dynamic> appointment) async {
    final db = await _db;
    await db.insert('RendezVous', appointment);
  }

  Future<List<Map<String, dynamic>>> getAllAppointments() async {
  final db = await _db;

  final result = await db.rawQuery('''
    SELECT r.appointment_id, r.patient_id, r.medecin_id, r.date_rdv, r.heure_rdv, r.statut,
           p.nom AS patient_nom, p.prenom AS patient_prenom,
           m.nom AS medecin_nom, m.prenom AS medecin_prenom
    FROM RendezVous r
    JOIN Utilisateur p ON r.patient_id = p.user_id
    JOIN Utilisateur m ON r.medecin_id = m.user_id
    ORDER BY r.date_rdv DESC
  ''');

  return result;
}
  Future<int> deleteAppointment(int id) async {
    final db = await _db;
  return await db.delete(
    'RendezVous', // your table name
    where: 'appointment_id = ?',
    whereArgs: [id],
  );
}
}
