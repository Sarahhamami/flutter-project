import 'package:flutter_application_1/user/current_user.dart';
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
      version: 1, // Updated to version 3 for ForumLike table
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

// Chat tables
await db.execute('''
  CREATE TABLE ChatConversation(
    conversation_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user1_id INTEGER NOT NULL,
    user2_id INTEGER NOT NULL,
    last_message TEXT,
    last_message_time TEXT,
    FOREIGN KEY(user1_id) REFERENCES Utilisateur(user_id),
    FOREIGN KEY(user2_id) REFERENCES Utilisateur(user_id)
  )
''');
print("✅ Table ChatConversation created");

await db.execute('''
  CREATE TABLE ChatMessage(
    message_id INTEGER PRIMARY KEY AUTOINCREMENT,
    conversation_id INTEGER NOT NULL,
    sender_id INTEGER NOT NULL,
    receiver_id INTEGER NOT NULL,
    content TEXT NOT NULL,
    is_read INTEGER DEFAULT 0,
    created_at TEXT NOT NULL,
    FOREIGN KEY(conversation_id) REFERENCES ChatConversation(conversation_id),
    FOREIGN KEY(sender_id) REFERENCES Utilisateur(user_id),
    FOREIGN KEY(receiver_id) REFERENCES Utilisateur(user_id)
  )
''');
print("✅ Table ChatMessage created");
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
    exercise_name TEXT,   -- for weightlifting
    sets INTEGER,         -- for weightlifting
    reps INTEGER,         -- for weightlifting
    weight REAL,          -- for weightlifting
    stroke_type TEXT,     -- for swimming
    laps INTEGER,         -- for swimming
    avg_speed REAL,       -- for cycling
    max_speed REAL,       -- for cycling
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

await db.execute('''
  CREATE TABLE ForumLike(
    like_id INTEGER PRIMARY KEY AUTOINCREMENT,
    topic_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    created_at TEXT NOT NULL,
    FOREIGN KEY(topic_id) REFERENCES ForumTopic(topic_id),
    FOREIGN KEY(user_id) REFERENCES Utilisateur(user_id),
    UNIQUE(topic_id, user_id)
  )
''');
print("✅ Table ForumLike created");
   await db.execute('''
      CREATE TABLE EmergencyContact(
        contact_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        full_name TEXT NOT NULL,
        phone TEXT NOT NULL,
        relation TEXT,
        priority INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        FOREIGN KEY(user_id) REFERENCES Utilisateur(user_id)
      )
    ''');
    print("✅ Table EmergencyContact created");

    // Emergency Alert Table
    await db.execute('''
      CREATE TABLE EmergencyAlert(
        alert_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        latitude REAL,
        longitude REAL,
        location_address TEXT NOT NULL,
        alert_message TEXT NOT NULL,
        contact_name TEXT,
        contact_phone TEXT,
        predicted_service TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'active',
        created_at TEXT NOT NULL,
        FOREIGN KEY(user_id) REFERENCES Utilisateur(user_id)
      )
    ''');
    print("✅ Table EmergencyAlert created");

    // First Aid Guide Table
    await db.execute('''
      CREATE TABLE FirstAidGuide(
        guide_id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        step_by_step TEXT NOT NULL,
        category TEXT NOT NULL,
        image_url TEXT,
        created_at TEXT NOT NULL
      )
    ''');
    print("✅ Table FirstAidGuide created");

    // User Medical Record Table
    await db.execute('''
      CREATE TABLE UserMedicalRecord(
        record_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        blood_type TEXT NOT NULL,
        chronic_diseases TEXT NOT NULL,
        allergies TEXT NOT NULL,
        current_treatments TEXT NOT NULL,
        doctor_name TEXT NOT NULL,
        doctor_phone TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY(user_id) REFERENCES Utilisateur(user_id)
      )
    ''');
    print("✅ Table UserMedicalRecord created");

    // Medication Table
    await db.execute('''
      CREATE TABLE Medication(
        medication_id INTEGER PRIMARY KEY AUTOINCREMENT,
        record_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        dosage TEXT NOT NULL,
        frequency TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY(record_id) REFERENCES UserMedicalRecord(record_id)
      )
    ''');
    print("✅ Table Medication created");

    // Task Table
    await db.execute('''
      CREATE TABLE Task(
        task_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        priority TEXT NOT NULL DEFAULT 'medium',
        status TEXT NOT NULL DEFAULT 'pending',
        due_date TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY(user_id) REFERENCES Utilisateur(user_id)
      )
    ''');
    print("✅ Table Task created");

    print("🎉 Database and tables created successfully!");

    // Create a default user for testing
  }

 
  // Forum Topic Operations
  Future<int> createForumTopic({
    required String title,
    required String description,
    required int createdBy,
  }) async {
    final db = await database;
    return await db.insert(
      'ForumTopic',
      {
        'title': title,
        'description': description,
        'created_by': createdBy,
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<List<Map<String, dynamic>>> getAllForumTopics() async {
    final db = await database;
    final currentUserId = await getDefaultUserId();
    return await db.rawQuery('''
      SELECT ft.*,
              u.user_id, u.nom, u.prenom, u.email, u.mot_de_passe, u.telephone,
              u.date_naissance, u.sexe, u.adresse, u.role, u.specialite,
              COALESCE(comment_counts.comment_count, 0) as comment_count,
              first_comments.first_comment,
              first_comments.first_comment_author,
              COALESCE(like_counts.like_count, 0) as like_count,
              CASE WHEN user_likes.like_id IS NOT NULL THEN 1 ELSE 0 END as is_liked_by_current_user
       FROM ForumTopic ft
       LEFT JOIN Utilisateur u ON ft.created_by = u.user_id
       LEFT JOIN (
         SELECT topic_id, COUNT(*) as comment_count
         FROM ForumPost
         GROUP BY topic_id
       ) comment_counts ON ft.topic_id = comment_counts.topic_id
       LEFT JOIN (
         SELECT fp.topic_id,
                fp.content as first_comment,
                COALESCE(u.prenom || ' ' || u.nom, 'Unknown User') as first_comment_author
         FROM ForumPost fp
         LEFT JOIN Utilisateur u ON fp.user_id = u.user_id
         WHERE fp.created_at = (
           SELECT MIN(created_at) FROM ForumPost WHERE topic_id = fp.topic_id
         )
       ) first_comments ON ft.topic_id = first_comments.topic_id
       LEFT JOIN (
         SELECT topic_id, COUNT(*) as like_count
         FROM ForumLike
         GROUP BY topic_id
       ) like_counts ON ft.topic_id = like_counts.topic_id
       LEFT JOIN ForumLike user_likes ON ft.topic_id = user_likes.topic_id AND user_likes.user_id = ?
       ORDER BY ft.created_at DESC
    ''', [currentUserId]);
  }

  Future<List<Map<String, dynamic>>> getForumTopicsByUser(int userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT ft.*, u.nom, u.prenom, u.email
      FROM ForumTopic ft
      JOIN Utilisateur u ON ft.created_by = u.user_id
      WHERE ft.created_by = ?
      ORDER BY ft.created_at DESC
    ''', [userId]);
  }

  Future<Map<String, dynamic>?> getForumTopicById(int topicId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT ft.*, u.nom, u.prenom, u.email
      FROM ForumTopic ft
      JOIN Utilisateur u ON ft.created_by = u.user_id
      WHERE ft.topic_id = ?
    ''', [topicId]);
    
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateForumTopic({
    required int topicId,
    required String title,
    required String description,
  }) async {
    final db = await database;
    return await db.update(
      'ForumTopic',
      {
        'title': title,
        'description': description,
      },
      where: 'topic_id = ?',
      whereArgs: [topicId],
    );
  }

  Future<int> deleteForumTopic(int topicId) async {
    final db = await database;
    // First delete all posts in this topic
    await db.delete(
      'ForumPost',
      where: 'topic_id = ?',
      whereArgs: [topicId],
    );
    // Then delete the topic
    return await db.delete(
      'ForumTopic',
      where: 'topic_id = ?',
      whereArgs: [topicId],
    );
  }

  // Forum Post Operations
  Future<int> createForumPost({
    required int topicId,
    required int userId,
    required String content,
  }) async {
    final db = await database;
    return await db.insert(
      'ForumPost',
      {
        'topic_id': topicId,
        'user_id': userId,
        'content': content,
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<List<Map<String, dynamic>>> getForumPostsByTopic(int topicId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT fp.*, u.nom, u.prenom, u.email
      FROM ForumPost fp
      JOIN Utilisateur u ON fp.user_id = u.user_id
      WHERE fp.topic_id = ?
      ORDER BY fp.created_at ASC
    ''', [topicId]);
  }

  Future<List<Map<String, dynamic>>> getForumPostsByUser(int userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT fp.*, u.nom, u.prenom, u.email, ft.title as topic_title
      FROM ForumPost fp
      JOIN Utilisateur u ON fp.user_id = u.user_id
      JOIN ForumTopic ft ON fp.topic_id = ft.topic_id
      WHERE fp.user_id = ?
      ORDER BY fp.created_at DESC
    ''', [userId]);
  }

  Future<int> updateForumPost({
    required int postId,
    required String content,
  }) async {
    final db = await database;
    return await db.update(
      'ForumPost',
      {
        'content': content,
      },
      where: 'post_id = ?',
      whereArgs: [postId],
    );
  }

  Future<int> deleteForumPost(int postId) async {
    final db = await database;
    return await db.delete(
      'ForumPost',
      where: 'post_id = ?',
      whereArgs: [postId],
    );
  }

  // Get forum statistics
  Future<Map<String, int>> getForumStats() async {
    final db = await database;

    final topicCount = await db.rawQuery('SELECT COUNT(*) as count FROM ForumTopic');
    final postCount = await db.rawQuery('SELECT COUNT(*) as count FROM ForumPost');
    final userCount = await db.rawQuery('SELECT COUNT(DISTINCT created_by) as count FROM ForumTopic');

    return {
      'topics': topicCount.first['count'] as int,
      'posts': postCount.first['count'] as int,
      'users': userCount.first['count'] as int,
    };
  }

  // Forum Like Operations
  Future<int> addForumLike({
    required int topicId,
    required int userId,
  }) async {
    final db = await database;
    try {
      return await db.insert(
        'ForumLike',
        {
          'topic_id': topicId,
          'user_id': userId,
          'created_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Handle unique constraint violation (user already liked this topic)
      return 0;
    }
  }

  Future<int> removeForumLike({
    required int topicId,
    required int userId,
  }) async {
    final db = await database;
    return await db.delete(
      'ForumLike',
      where: 'topic_id = ? AND user_id = ?',
      whereArgs: [topicId, userId],
    );
  }

  Future<bool> hasUserLikedTopic({
    required int topicId,
    required int userId,
  }) async {
    final db = await database;
    final result = await db.query(
      'ForumLike',
      where: 'topic_id = ? AND user_id = ?',
      whereArgs: [topicId, userId],
    );
    return result.isNotEmpty;
  }

  Future<int> getTopicLikeCount(int topicId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ForumLike WHERE topic_id = ?',
      [topicId],
    );
    return result.first['count'] as int? ?? 0;
  }

  // Get default user ID for testing - CHANGE THIS TO SWITCH USERS
  Future<int> getDefaultUserId() async {
   final user = CurrentUser().getUser();
    final userId = user?['user_id'];
   if (userId != null) {
    return userId as int;
  } else {
    throw Exception("No user_id found in CurrentUser");
  }  
  }

  // Clear any existing sample topics (optional - for clean start)
  Future<void> clearSampleTopics() async {
    try {
      final db = await database;
      
      // Delete topics with common sample titles
      final sampleTitles = [
        'Welcome to Health Forum!',
        'Best practices for maintaining a healthy lifestyle',
        'Mental health awareness and support',
      ];
      
      for (final title in sampleTitles) {
        await db.delete(
          'ForumTopic',
          where: 'title = ?',
          whereArgs: [title],
        );
      }
      
      print("✅ Sample topics cleared");
    } catch (e) {
      print("❌ Error clearing sample topics: $e");
    }
  }

  // User Operations - Get all users for friends list
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query(
      'Utilisateur',
      columns: ['user_id', 'nom', 'prenom', 'email', 'role'],
      orderBy: 'nom, prenom ASC',
    );
  }

  // Get user by ID
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await database;
    final result = await db.query(
      'Utilisateur',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    
    return result.isNotEmpty ? result.first : null;
  }

  // Get user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      'Utilisateur',
      where: 'email = ?',
      whereArgs: [email],
    );
    
    return result.isNotEmpty ? result.first : null;
  }

  // Search users by name
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final db = await database;
    return await db.query(
      'Utilisateur',
      columns: ['user_id', 'nom', 'prenom', 'email', 'role'],
      where: 'nom LIKE ? OR prenom LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'nom, prenom ASC',
    );
  }

  // ==================== CHAT OPERATIONS ====================
  
  // Get or create a conversation between two users
  Future<int> getOrCreateConversation(int user1Id, int user2Id) async {
    final db = await database;
    
    // Check if conversation already exists
    final existing = await db.query(
      'ChatConversation',
      where: '(user1_id = ? AND user2_id = ?) OR (user1_id = ? AND user2_id = ?)',
      whereArgs: [user1Id, user2Id, user2Id, user1Id],
    );
    
    if (existing.isNotEmpty) {
      return existing.first['conversation_id'] as int;
    }
    
    // Create new conversation
    final id = await db.insert(
      'ChatConversation',
      {
        'user1_id': user1Id,
        'user2_id': user2Id,
        'last_message': '',
        'last_message_time': DateTime.now().toIso8601String(),
      },
    );
    
    return id as int;
  }

  // Save a chat message
  Future<int> saveMessage(int conversationId, int senderId, int receiverId, String content) async {
    final db = await database;
    
    final messageId = await db.insert(
      'ChatMessage',
      {
        'conversation_id': conversationId,
        'sender_id': senderId,
        'receiver_id': receiverId,
        'content': content,
        'is_read': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
    );
    
    // Update conversation last message
    await db.update(
      'ChatConversation',
      {
        'last_message': content,
        'last_message_time': DateTime.now().toIso8601String(),
      },
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
    );
    
    return messageId as int;
  }

  // Get messages for a conversation
  Future<List<Map<String, dynamic>>> getConversationMessages(int conversationId) async {
    final db = await database;
    return await db.query(
      'ChatMessage',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'created_at ASC',
    );
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(int conversationId, int currentUserId) async {
    final db = await database;
    await db.update(
      'ChatMessage',
      {'is_read': 1},
      where: 'conversation_id = ? AND receiver_id = ?',
      whereArgs: [conversationId, currentUserId],
    );
  }

  // Get unread message count for a user
  Future<int> getUnreadCount(int conversationId, int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ChatMessage WHERE conversation_id = ? AND receiver_id = ? AND is_read = 0',
      [conversationId, userId],
    );
    
    return result.first['count'] as int? ?? 0;
  }

  // Get last message for a conversation
  Future<Map<String, dynamic>?> getLastMessage(int conversationId) async {
    final db = await database;
    final result = await db.query(
      'ChatMessage',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    
    return result.isNotEmpty ? result.first : null;
  }
  Future<int> createEmergencyContact({
    required int userId,
    required String fullName,
    required String phone,
    String? relation,
    int priority = 1,
  }) async {
    final db = await database;
    return await db.insert('EmergencyContact', {
      'user_id': userId,
      'full_name': fullName,
      'phone': phone,
      'relation': relation,
      'priority': priority,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getEmergencyContactsByUser(int userId) async {
    final db = await database;
    return await db.query(
      'EmergencyContact',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'priority ASC',
    );
  }

  Future<int> deleteEmergencyContact(int contactId) async {
    final db = await database;
    return await db.delete(
      'EmergencyContact',
      where: 'contact_id = ?',
      whereArgs: [contactId],
    );
  }

  // Emergency Alert Operations
  Future<int> createEmergencyAlert({
    required int userId,
    double? latitude,
    double? longitude,
    required String locationAddress,
    required String alertMessage,
    String? contactName,
    String? contactPhone,
    required String predictedService,
  }) async {
    final db = await database;
    return await db.insert('EmergencyAlert', {
      'user_id': userId,
      'latitude': latitude,
      'longitude': longitude,
      'location_address': locationAddress,
      'alert_message': alertMessage,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'predicted_service': predictedService,
      'status': 'active',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getEmergencyAlertsByUser(int userId) async {
    final db = await database;
    return await db.query(
      'EmergencyAlert',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  Future<int> updateEmergencyAlertStatus({
    required int alertId,
    required String status,
  }) async {
    final db = await database;
    return await db.update(
      'EmergencyAlert',
      {'status': status},
      where: 'alert_id = ?',
      whereArgs: [alertId],
    );
  }

  // First Aid Guide Operations
  Future<int> createFirstAidGuide({
    required String title,
    required String description,
    required String stepByStep,
    required String category,
    required String imageUrl,
  }) async {
    final db = await database;
    return await db.insert('FirstAidGuide', {
      'title': title,
      'description': description,
      'step_by_step': stepByStep,
      'category': category,
      'image_url': imageUrl,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getAllFirstAidGuides() async {
    final db = await database;
    return await db.query('FirstAidGuide', orderBy: 'created_at DESC');
  }

  Future<Map<String, dynamic>?> getFirstAidGuideById(int guideId) async {
    final db = await database;
    final result = await db.query(
      'FirstAidGuide',
      where: 'guide_id = ?',
      whereArgs: [guideId],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateFirstAidGuide({
    required int guideId,
    String? title,
    String? description,
    String? stepByStep,
    String? category,
    String? imageUrl,
  }) async {
    final db = await database;
    Map<String, dynamic> updateData = {};

    if (title != null) updateData['title'] = title;
    if (description != null) updateData['description'] = description;
    if (stepByStep != null) updateData['step_by_step'] = stepByStep;
    if (category != null) updateData['category'] = category;
    if (imageUrl != null) updateData['image_url'] = imageUrl;

    return await db.update(
      'FirstAidGuide',
      updateData,
      where: 'guide_id = ?',
      whereArgs: [guideId],
    );
  }

  Future<int> deleteFirstAidGuide(int guideId) async {
    final db = await database;
    return await db.delete(
      'FirstAidGuide',
      where: 'guide_id = ?',
      whereArgs: [guideId],
    );
  }

  // User Medical Record Operations
  Future<int> createUserMedicalRecord({
    required int userId,
    required String bloodType,
    required String chronicDiseases,
    required String allergies,
    required String currentTreatments,
    required String doctorName,
    required String doctorPhone,
  }) async {
    final db = await database;
    return await db.insert('UserMedicalRecord', {
      'user_id': userId,
      'blood_type': bloodType,
      'chronic_diseases': chronicDiseases,
      'allergies': allergies,
      'current_treatments': currentTreatments,
      'doctor_name': doctorName,
      'doctor_phone': doctorPhone,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>?> getUserMedicalRecord(int userId) async {
    final db = await database;
    final result = await db.query(
      'UserMedicalRecord',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateUserMedicalRecord({
    required int recordId,
    String? bloodType,
    String? chronicDiseases,
    String? allergies,
    String? currentTreatments,
    String? doctorName,
    String? doctorPhone,
  }) async {
    final db = await database;
    Map<String, dynamic> updateData = {};

    if (bloodType != null) updateData['blood_type'] = bloodType;
    if (chronicDiseases != null) updateData['chronic_diseases'] = chronicDiseases;
    if (allergies != null) updateData['allergies'] = allergies;
    if (currentTreatments != null) updateData['current_treatments'] = currentTreatments;
    if (doctorName != null) updateData['doctor_name'] = doctorName;
    if (doctorPhone != null) updateData['doctor_phone'] = doctorPhone;

    return await db.update(
      'UserMedicalRecord',
      updateData,
      where: 'record_id = ?',
      whereArgs: [recordId],
    );
  }

  Future<int> deleteUserMedicalRecord(int recordId) async {
    final db = await database;
    // First delete all medications associated with this record
    await db.delete(
      'Medication',
      where: 'record_id = ?',
      whereArgs: [recordId],
    );
    // Then delete the record
    return await db.delete(
      'UserMedicalRecord',
      where: 'record_id = ?',
      whereArgs: [recordId],
    );
  }

  // Medication Operations
  Future<int> createMedication({
    required int recordId,
    required String name,
    required String dosage,
    required String frequency,
    required String startDate,
    String? endDate,
  }) async {
    final db = await database;
    return await db.insert('Medication', {
      'record_id': recordId,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'start_date': startDate,
      'end_date': endDate,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getMedicationsByUser(int userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT m.*, umr.user_id
      FROM Medication m
      JOIN UserMedicalRecord umr ON m.record_id = umr.record_id
      WHERE umr.user_id = ?
      ORDER BY m.created_at DESC
    ''', [userId]);
  }

  Future<Map<String, dynamic>?> getMedicationById(int medicationId) async {
    final db = await database;
    final result = await db.query(
      'Medication',
      where: 'medication_id = ?',
      whereArgs: [medicationId],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateMedication({
    required int medicationId,
    String? name,
    String? dosage,
    String? frequency,
    String? startDate,
    String? endDate,
  }) async {
    final db = await database;
    Map<String, dynamic> updateData = {};

    if (name != null) updateData['name'] = name;
    if (dosage != null) updateData['dosage'] = dosage;
    if (frequency != null) updateData['frequency'] = frequency;
    if (startDate != null) updateData['start_date'] = startDate;
    if (endDate != null) updateData['end_date'] = endDate;

    return await db.update(
      'Medication',
      updateData,
      where: 'medication_id = ?',
      whereArgs: [medicationId],
    );
  }

  Future<int> deleteMedication(int medicationId) async {
    final db = await database;
    return await db.delete(
      'Medication',
      where: 'medication_id = ?',
      whereArgs: [medicationId],
    );
  }

  // Delete all operations for testing
  Future<void> deleteAllEmergencyAlerts() async {
    final db = await database;
    await db.delete('EmergencyAlert');
  }

  Future<void> deleteAllEmergencyContacts() async {
    final db = await database;
    await db.delete('EmergencyContact');
  }

  Future<void> deleteAllFirstAidGuides() async {
    final db = await database;
    await db.delete('FirstAidGuide');
  }

  Future<void> deleteAllUserMedicalRecords() async {
    final db = await database;
    await db.delete('UserMedicalRecord');
  }

  Future<void> deleteAllMedications() async {
    final db = await database;
    await db.delete('Medication');
  }

  // ========================================
  // TASK CRUD OPERATIONS
  // ========================================

  // Create a new task
  Future<int> createTask({
    required int userId,
    required String title,
    String? description,
    String priority = 'medium',
    String status = 'pending',
    String? dueDate,
  }) async {
    final db = await database;
    return await db.insert('Task', {
      'user_id': userId,
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'due_date': dueDate,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Get all tasks for a user
  Future<List<Map<String, dynamic>>> getTasksByUser(int userId) async {
    final db = await database;
    return await db.query(
      'Task',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  // Get task by ID
  Future<Map<String, dynamic>?> getTaskById(int taskId) async {
    final db = await database;
    final result = await db.query(
      'Task',
      where: 'task_id = ?',
      whereArgs: [taskId],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Update a task
  Future<int> updateTask({
    required int taskId,
    String? title,
    String? description,
    String? priority,
    String? status,
    String? dueDate,
  }) async {
    final db = await database;
    Map<String, dynamic> updateData = {
      'updated_at': DateTime.now().toIso8601String(),
    };
    
    if (title != null) updateData['title'] = title;
    if (description != null) updateData['description'] = description;
    if (priority != null) updateData['priority'] = priority;
    if (status != null) updateData['status'] = status;
    if (dueDate != null) updateData['due_date'] = dueDate;

    return await db.update(
      'Task',
      updateData,
      where: 'task_id = ?',
      whereArgs: [taskId],
    );
  }

  // Delete a task
  Future<int> deleteTask(int taskId) async {
    final db = await database;
    return await db.delete(
      'Task',
      where: 'task_id = ?',
      whereArgs: [taskId],
    );
  }

  // Get tasks by status
  Future<List<Map<String, dynamic>>> getTasksByStatus(int userId, String status) async {
    final db = await database;
    return await db.query(
      'Task',
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, status],
      orderBy: 'created_at DESC',
    );
  }

  // Get tasks by priority
  Future<List<Map<String, dynamic>>> getTasksByPriority(int userId, String priority) async {
    final db = await database;
    return await db.query(
      'Task',
      where: 'user_id = ? AND priority = ?',
      whereArgs: [userId, priority],
      orderBy: 'created_at DESC',
    );
  }

  // Get overdue tasks
  Future<List<Map<String, dynamic>>> getOverdueTasks(int userId) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    return await db.query(
      'Task',
      where: 'user_id = ? AND due_date < ? AND status != ?',
      whereArgs: [userId, now, 'completed'],
      orderBy: 'due_date ASC',
    );
  }

  // Get task statistics
  Future<Map<String, int>> getTaskStats(int userId) async {
    final db = await database;
    
    final totalTasks = await db.rawQuery(
      'SELECT COUNT(*) as count FROM Task WHERE user_id = ?',
      [userId]
    );
    
    final pendingTasks = await db.rawQuery(
      'SELECT COUNT(*) as count FROM Task WHERE user_id = ? AND status = ?',
      [userId, 'pending']
    );
    
    final completedTasks = await db.rawQuery(
      'SELECT COUNT(*) as count FROM Task WHERE user_id = ? AND status = ?',
      [userId, 'completed']
    );
    
    final overdueTasks = await db.rawQuery(
      'SELECT COUNT(*) as count FROM Task WHERE user_id = ? AND due_date < ? AND status != ?',
      [userId, DateTime.now().toIso8601String(), 'completed']
    );

    return {
      'total': totalTasks.first['count'] as int,
      'pending': pendingTasks.first['count'] as int,
      'completed': completedTasks.first['count'] as int,
      'overdue': overdueTasks.first['count'] as int,
    };
  }

  // Delete all tasks for testing
  Future<void> deleteAllTasks() async {
    final db = await database;
    await db.delete('Task');
  }
}