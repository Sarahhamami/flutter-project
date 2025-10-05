import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _db;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    String path = join(dbPath, 'app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    // 1️⃣ Table Utilisateur
    await db.execute('''
      CREATE TABLE Utilisateur(
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        prenom TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        mot_de_passe TEXT NOT NULL,
        telephone TEXT,
        date_naissance TEXT,
        sexe TEXT,
        adresse TEXT,
        role TEXT NOT NULL,
        specialite TEXT,
        is_verified INTEGER NOT NULL DEFAULT 0
      )
    ''');
    print("✅ Table Utilisateur created");

    // 2️⃣ Table RendezVous
    await db.execute('''
      CREATE TABLE RendezVous(
        appointment_id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id INTEGER NOT NULL,
        medecin_id INTEGER NOT NULL,
        date_rdv TEXT NOT NULL,
        heure_rdv TEXT NOT NULL,
        statut TEXT NOT NULL,
        FOREIGN KEY(patient_id) REFERENCES Utilisateur(user_id),
        FOREIGN KEY(medecin_id) REFERENCES Utilisateur(user_id)
      )
    ''');
    print("✅ Table RendezVous created");

    // 3️⃣ Table Disponibilite
    await db.execute('''
      CREATE TABLE Disponibilite(
        availability_id INTEGER PRIMARY KEY AUTOINCREMENT,
        medecin_id INTEGER NOT NULL,
        jour TEXT NOT NULL,
        heure_debut TEXT NOT NULL,
        heure_fin TEXT NOT NULL,
        FOREIGN KEY(medecin_id) REFERENCES Utilisateur(user_id)
      )
    ''');
    print("✅ Table Disponibilite created");

  }
  
}
