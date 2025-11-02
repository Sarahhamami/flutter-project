import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _db;
  bool _isWeb = false;

  DatabaseHelper._internal() {
    // Détecter si on est sur le web de manière plus fiable
    try {
      _isWeb = !(identical(0, 0.0));
    } catch (e) {
      _isWeb = true;
    }
  }

  Future<Database> get database async {
    if (_isWeb) {
      // Sur le web, retourner une base de données factice
      return _getMockDatabase();
    }
    
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    String path = join(dbPath, 'app.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
    );
  }

  Future<Database> _getMockDatabase() async {
    // Retourner une base de données factice pour le web
    return await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (db, version) async {
        // Ne rien créer sur le web
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    if (_isWeb) return;

    // User Table
    await db.execute('''
      CREATE TABLE User(
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        phone TEXT,
        birth_date TEXT,
        gender TEXT,
        address TEXT,
        role TEXT NOT NULL,
        specialty TEXT,
        is_verified INTEGER NOT NULL DEFAULT 0
      )
    ''');
    print("✅ User table created");

    // Sleep Table
    await db.execute('''
      CREATE TABLE Sleep(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        bedTime TEXT NOT NULL,
        wakeUpTime TEXT NOT NULL,
        sleepDuration REAL NOT NULL,
        sleepQuality TEXT NOT NULL,
        FOREIGN KEY(user_id) REFERENCES User(user_id)
      )
    ''');
    print("✅ Sleep table created");

    // Mood Table
    await db.execute('''
      CREATE TABLE Mood(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        stressLevel INTEGER NOT NULL,
        mood TEXT NOT NULL,
        energyLevel INTEGER NOT NULL,
        FOREIGN KEY(user_id) REFERENCES User(user_id)
      )
    ''');
    print("✅ Mood table created");

    // Cycle Table
    await db.execute('''
      CREATE TABLE Cycle(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        cycleStartDate TEXT NOT NULL,
        cycleEndDate TEXT NOT NULL,
        symptoms TEXT,
        FOREIGN KEY(user_id) REFERENCES User(user_id)
      )
    ''');
    print("✅ Cycle table created");
  }

  bool get isWeb => _isWeb;
}