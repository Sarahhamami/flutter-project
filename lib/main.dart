//import 'dart:io';


import 'package:flutter/material.dart';
import 'package:flutter_application_1/splash_screen.dart';
//import 'package:path/path.dart';
//import 'package:sqflite/sqflite.dart';
import 'db/database_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyBGthroSSE5T9jlnGVR1URxtpITqDXtBwU',
        appId: '1:110912732201:android:c5b44afc8c1a10a30bb038',
        messagingSenderId: '110912732201',
        projectId: 'healthtracker-d3a5c',
        databaseURL: 'https://healthtracker-d3a5c-default-rtdb.firebaseio.com',
        storageBucket: 'healthtracker-d3a5c.firebasestorage.app',
      ),
    );
    print("✅ Firebase initialized successfully");
  } catch (e) {
    print("⚠️ Firebase initialization error: $e");
    print("Please check your Firebase configuration");
  }
  // 🔹 Delete old database for a fresh start (optional, dev only)
/*final dbPath = join(await getDatabasesPath(), 'app.db');
  if (await File(dbPath).exists()) {
    await deleteDatabase(dbPath);
    print("🗑️ Old database deleted for fresh start");
  }*/

  // 🔹 Initialize database
  final db = await DatabaseHelper().database;
  print("✅ Database initialized at: ${db.path}");

  // 🔹 Fetch all tables and log their structure
  final tables = await db.rawQuery(
    "SELECT name FROM sqlite_master WHERE type='table';",
  );

  print("\n📋 DATABASE CONTENT OVERVIEW");
  print("----------------------------------------");

  for (var table in tables) {
    final tableName = table['name'];
    if (tableName == 'android_metadata' || tableName == 'sqlite_sequence') continue;

    print("\n🔸 Table: $tableName");

    // Columns
    final columns = await db.rawQuery("PRAGMA table_info($tableName);");
    final colNames = columns.map((c) => c['name']).toList();
    print("   Columns: $colNames");

    // Rows (should be empty)
    final rows = await db.query(tableName as String);
    if (rows.isEmpty) {
      print("   (no rows)");
    } else {
      for (var row in rows) {
        print("   ➜ $row");
      }
    }
  }

  print("\n✅ End of database log.\n");

  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
