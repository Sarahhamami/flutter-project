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
Future<List<Map<String, dynamic>>> getAppointmentsByPatient(int patientId) async {
  final db = await _db;
  return await db.rawQuery('''
    SELECT r.appointment_id, r.patient_id, r.medecin_id, r.date_rdv, r.heure_rdv, r.statut,
           m.nom AS medecin_nom, m.prenom AS medecin_prenom
    FROM RendezVous r
    JOIN Utilisateur m ON r.medecin_id = m.user_id
    WHERE r.patient_id = ?
    ORDER BY r.date_rdv DESC
  ''', [patientId]);
}

Future<List<Map<String, dynamic>>> getAppointmentsByDoctor(int doctorId) async {
  final db = await _db;
  return await db.rawQuery('''
    SELECT r.appointment_id, r.patient_id, r.medecin_id, r.date_rdv, r.heure_rdv, r.statut,
           p.nom AS patient_nom, p.prenom AS patient_prenom
    FROM RendezVous r
    JOIN Utilisateur p ON r.patient_id = p.user_id
    WHERE r.medecin_id = ?
    ORDER BY r.date_rdv DESC
  ''', [doctorId]);
}

Future<int> updateAppointmentStatus(int appointmentId, String newStatus) async {
  final db = await _db;
  return await db.update(
    'RendezVous',
    {'statut': newStatus},
    where: 'appointment_id = ?',
    whereArgs: [appointmentId],
  );
}
Future<bool> isDoctorAvailable(int doctorId, String date, String time) async {
  final db = await _db;

  // 1️⃣ Convert "2:13 PM" or "10:45 AM" to 24-hour hours and minutes
  final selectedDateTime = _parseDateTime(date, time);

  // 2️⃣ Check doctor working hours (09:00–17:00)
  final startWork = DateTime.parse("$date 09:00:00");
  final endWork = DateTime.parse("$date 17:00:00");
  if (selectedDateTime.isBefore(startWork) || selectedDateTime.isAfter(endWork)) {
    return false; // outside working hours
  }

  // 3️⃣ Get existing appointments for that doctor on the same day
  final existingAppointments = await db.query(
    'RendezVous',
    where: 'medecin_id = ? AND date_rdv = ?',
    whereArgs: [doctorId, date],
  );

  // 4️⃣ Check for at least 1 hour gap
for (var appt in existingAppointments) {
  final existingTime = _parseDateTime(date, appt['heure_rdv'] as String); // cast here
  final diff = selectedDateTime.difference(existingTime).inMinutes;
  if (diff.abs() < 60) return false; // less than 1 hour apart
}

  return true; // available
}

// Helper to parse "2:13 PM" into DateTime
DateTime _parseDateTime(String date, String time) {
  final parts = time.split(RegExp(r'[: ]')); // e.g., ["2", "13", "PM"]
  int hour = int.parse(parts[0]);
  final minute = int.parse(parts[1]);
  final period = parts[2].toUpperCase();

  if (period == 'PM' && hour != 12) hour += 12;
  if (period == 'AM' && hour == 12) hour = 0;

  return DateTime.parse("$date ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00");
}

}