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
      version: 3, // Version augmentée à 3 pour toutes les tables
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
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

    // 4️⃣ Table Sleep (Suivi du sommeil)
    await db.execute('''
      CREATE TABLE Sleep(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        bedTime TEXT NOT NULL,
        wakeUpTime TEXT NOT NULL,
        sleepDuration REAL NOT NULL,
        sleepQuality TEXT NOT NULL,
        FOREIGN KEY(user_id) REFERENCES Utilisateur(user_id)
      )
    ''');
    print("✅ Table Sleep created");

    // 5️⃣ Table Mood (Suivi de l'humeur)
    await db.execute('''
      CREATE TABLE Mood(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        stressLevel INTEGER NOT NULL,
        mood TEXT NOT NULL,
        energyLevel INTEGER NOT NULL,
        FOREIGN KEY(user_id) REFERENCES Utilisateur(user_id)
      )
    ''');
    print("✅ Table Mood created");

    // 6️⃣ Table Cycle (Suivi menstruel)
    await db.execute('''
      CREATE TABLE Cycle(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        cycleStartDate TEXT NOT NULL,
        cycleEndDate TEXT NOT NULL,
        symptoms TEXT,
        FOREIGN KEY(user_id) REFERENCES Utilisateur(user_id)
      )
    ''');
    print("✅ Table Cycle created");

    // 7️⃣ Table Recommendation (Recommandations IA)
    await db.execute('''
      CREATE TABLE Recommendation(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        message TEXT NOT NULL,
        FOREIGN KEY(user_id) REFERENCES Utilisateur(user_id)
      )
    ''');
    print("✅ Table Recommendation created");

    // 8️⃣ Table LifestyleLog (Activités physiques)
    await db.execute('''
      CREATE TABLE LifestyleLog(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        physicalActivity TEXT NOT NULL,
        nutrition TEXT,
        screenTime REAL NOT NULL,
        FOREIGN KEY(user_id) REFERENCES Utilisateur(user_id)
      )
    ''');
    print("✅ Table LifestyleLog created");
  }
}