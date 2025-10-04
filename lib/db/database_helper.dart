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
        specialite TEXT
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

    await db.execute('''
  CREATE TABLE ForumTopic(
    topic_id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    created_by INTEGER NOT NULL,
    created_at TEXT NOT NULL,
    FOREIGN KEY(created_by) REFERENCES Utilisateur(user_id)
  )
''');
print("✅ Table ForumTopic created");

await db.execute('''
  CREATE TABLE ForumPost(
    post_id INTEGER PRIMARY KEY AUTOINCREMENT,
    topic_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    content TEXT NOT NULL,
    created_at TEXT NOT NULL,
    FOREIGN KEY(topic_id) REFERENCES ForumTopic(topic_id),
    FOREIGN KEY(user_id) REFERENCES Utilisateur(user_id)
  )
''');
print("✅ Table ForumPost created");
await db.execute('''
  CREATE TABLE Advice(
    advice_id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    doctor_id INTEGER NOT NULL,
    created_at TEXT NOT NULL,
    FOREIGN KEY(doctor_id) REFERENCES Utilisateur(user_id)
  )
''');
print("✅ Table Advice created");
await db.execute('''
  CREATE TABLE Sleep(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    date TEXT NOT NULL,
    bedTime TEXT,
    wakeUpTime TEXT,
    sleepDuration REAL,
    sleepQuality TEXT,
    FOREIGN KEY(user_id) REFERENCES Utilisateur(user_id)
  )
''');
print("✅ Table Sleep created");
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
await db.execute('''
  CREATE TABLE Mood(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    date TEXT NOT NULL,
    stressLevel INTEGER,
    mood TEXT,
    energyLevel INTEGER,
    FOREIGN KEY(user_id) REFERENCES Utilisateur(user_id)
  )
''');
print("✅ Table Mood created");
await db.execute('''
  CREATE TABLE Cycle(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    cycleStartDate TEXT NOT NULL,
    cycleEndDate TEXT,
    symptoms TEXT,
    FOREIGN KEY(user_id) REFERENCES Utilisateur(user_id)
  )
''');
print("✅ Table Cycle created");
await db.execute('''
  CREATE TABLE LifestyleLog(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    date TEXT NOT NULL,
    physicalActivity TEXT,
    nutrition TEXT,
    screenTime REAL,
    FOREIGN KEY(user_id) REFERENCES Utilisateur(user_id)
  )
''');
print("✅ Table LifestyleLog created");
await db.execute('''
  CREATE TABLE Activite_physique(
    id_activite INTEGER PRIMARY KEY AUTOINCREMENT,
    id_utilisateur INTEGER NOT NULL,
    type_activite TEXT NOT NULL,
    date_activite TEXT NOT NULL,
    duree INTEGER,
    distance REAL,
    pas INTEGER,
    calories_brulees REAL,
    source_donnees TEXT,
    FOREIGN KEY(id_utilisateur) REFERENCES Utilisateur(user_id)
  )
''');
print("✅ Table Activite_physique created");
await db.execute('''
  CREATE TABLE Objectif(
    id_objectif INTEGER PRIMARY KEY AUTOINCREMENT,
    id_utilisateur INTEGER NOT NULL,
    type_objectif TEXT NOT NULL,
    type_metrique TEXT NOT NULL,
    valeur_cible REAL NOT NULL,
    periode TEXT,
    date_debut TEXT,
    date_fin TEXT,
    etat TEXT,
    FOREIGN KEY(id_utilisateur) REFERENCES Utilisateur(user_id)
  )
''');
print("✅ Table Objectif created");
await db.execute('''
  CREATE TABLE Statistique(
    id_stat INTEGER PRIMARY KEY AUTOINCREMENT,
    id_utilisateur INTEGER NOT NULL,
    date TEXT NOT NULL,
    total_pas INTEGER,
    total_distance REAL,
    total_calories REAL,
    objectif_atteint INTEGER, -- 0 = false, 1 = true
    tendance_performance TEXT,
    FOREIGN KEY(id_utilisateur) REFERENCES Utilisateur(user_id)
  )
''');
print("✅ Table Statistique created");
await db.execute('''
  CREATE TABLE Performances(
    performance_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    date TEXT NOT NULL,
    score_performance REAL,
    tendance TEXT,
    FOREIGN KEY(user_id) REFERENCES Utilisateur(user_id)
  )
''');
print("✅ Table Performances created");
await db.execute('''
  CREATE TABLE NutritionProfil(
    nutrition_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    poids REAL,
    taille REAL,
    age INTEGER,
    objectif TEXT,
    calorie_objectif REAL,
    proteine_objectif REAL,
    glucide_objectif REAL,
    lipide_objectif REAL,
    eau_objectif REAL,
    pas_objectif INTEGER,
    FOREIGN KEY(user_id) REFERENCES Utilisateur(user_id)
  )
''');
print("✅ Table NutritionProfil created");
await db.execute('''
  CREATE TABLE Repas(
    repas_id INTEGER PRIMARY KEY AUTOINCREMENT,
    nutrition_id INTEGER NOT NULL,
    date_repas TEXT NOT NULL,
    type_repas TEXT NOT NULL,
    calories_totales REAL,
    FOREIGN KEY(nutrition_id) REFERENCES NutritionProfil(nutrition_id)
  )
''');
print("✅ Table Repas created");
await db.execute('''
  CREATE TABLE Aliment(
    aliment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    nom TEXT NOT NULL,
    calories REAL,
    proteines REAL,
    glucides REAL,
    lipides REAL
  )
''');
print("✅ Table Aliment created");
await db.execute('''
  CREATE TABLE Repas_Aliment(
    repas_id INTEGER NOT NULL,
    aliment_id INTEGER NOT NULL,
    quantite REAL,
    PRIMARY KEY(repas_id, aliment_id),
    FOREIGN KEY(repas_id) REFERENCES Repas(repas_id),
    FOREIGN KEY(aliment_id) REFERENCES Aliment(aliment_id)
  )
''');
print("✅ Table Repas_Aliment created");
await db.execute('''
  CREATE TABLE Hydratation(
    hydratation_id INTEGER PRIMARY KEY AUTOINCREMENT,
    nutrition_id INTEGER NOT NULL,
    date_jour TEXT NOT NULL,
    quantite_bue REAL,
    FOREIGN KEY(nutrition_id) REFERENCES NutritionProfil(nutrition_id)
  )
''');
print("✅ Table Hydratation created");
await db.execute('''
  CREATE TABLE ActivitePas(
    pas_id INTEGER PRIMARY KEY AUTOINCREMENT,
    nutrition_id INTEGER NOT NULL,
    date_jour TEXT NOT NULL,
    pas_faits INTEGER,
    FOREIGN KEY(nutrition_id) REFERENCES NutritionProfil(nutrition_id)
  )
''');
print("✅ Table ActivitePas created");
    print("🎉 Database and tables created successfully!");

  }
  
}
