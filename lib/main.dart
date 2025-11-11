import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:firebase_core/firebase_core.dart';

// 🔹 Local imports
import 'package:flutter_application_1/splash_screen.dart';
import 'package:flutter_application_1/actPhy/services/badge_service.dart';
import 'package:flutter_application_1/actPhy/services/quote_service.dart';
import 'package:flutter_application_1/db/database_helper.dart';
import 'package:flutter_application_1/services/nutrition_database_service.dart';
import 'package:flutter_application_1/providers/dashboard_provider.dart';
import 'package:flutter_application_1/providers/hydration_provider.dart';
import 'package:flutter_application_1/providers/activity_provider.dart';
import 'package:flutter_application_1/providers/recipe_provider.dart';
import 'package:flutter_application_1/themes/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Initialize local badge database
  await BadgeService().database;

  // 🔹 Initialize Firebase
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
  }

  // 🔹 Initialize main database
  final db = await DatabaseHelper().database;
  print("✅ Database initialized at: ${db.path}");

  // 🔹 Log database structure
  final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table';");
  print("\n📋 DATABASE CONTENT OVERVIEW");
  print("----------------------------------------");
  for (var table in tables) {
    final name = table['name'];
    if (name == 'android_metadata' || name == 'sqlite_sequence') continue;
    final columns = await db.rawQuery("PRAGMA table_info($name);");
    final colNames = columns.map((c) => c['name']).toList();
    print("\n🔸 Table: $name");
    print("   Columns: $colNames");

    final rows = await db.query(name as String);
    if (rows.isEmpty) {
      print("   (no rows)");
    } else {
      for (var row in rows) {
        print("   ➜ $row");
      }
    }
  }
  print("\n✅ End of database log.\n");

  // 🔹 Start quote service
  WidgetsBinding.instance.addPostFrameCallback((_) {
    QuoteService.startQuoteTimer();
  });

  // 🔹 Initialize nutrition database
  await NutritionDatabaseService.init();
  print("✅ Nutrition Database Service initialized");

  runApp(const UnifiedApp());
}

class UnifiedApp extends StatelessWidget {
  const UnifiedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => HydrationProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
      ],
      child: MaterialApp(
        title: 'Health Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
