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
      version: 3, // Updated to version 3 for ForumLike table
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add chat tables
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ChatConversation(
          conversation_id INTEGER PRIMARY KEY AUTOINCREMENT,
          user1_id INTEGER NOT NULL,
          user2_id INTEGER NOT NULL,
          last_message TEXT,
          last_message_time TEXT,
          FOREIGN KEY(user1_id) REFERENCES Utilisateur(user_id),
          FOREIGN KEY(user2_id) REFERENCES Utilisateur(user_id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS ChatMessage(
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
      print("✅ Chat tables added via upgrade");
    }

    // Add ForumLike table for version 3
    if (oldVersion < 3) {
      print("🔄 Database version 3 - adding ForumLike table");

      await db.execute('''
        CREATE TABLE IF NOT EXISTS ForumLike(
          like_id INTEGER PRIMARY KEY AUTOINCREMENT,
          topic_id INTEGER NOT NULL,
          user_id INTEGER NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY(topic_id) REFERENCES ForumTopic(topic_id),
          FOREIGN KEY(user_id) REFERENCES Utilisateur(user_id),
          UNIQUE(topic_id, user_id)
        )
      ''');
      print("✅ ForumLike table added via upgrade");
    }
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

    print("🎉 Database and tables created successfully!");

    // Create a default user for testing
    await _createDefaultUser(db);
  }

  Future<void> _createDefaultUser(Database db) async {
    try {
      // Test users data
      final testUsers = [
        {
          'nom': 'Default',
          'prenom': 'User',
          'email': 'default@healthtracker.com',
          'mot_de_passe': 'password123',
          'telephone': '+1234567890',
          'date_naissance': '1990-01-01',
          'sexe': 'Other',
          'adresse': 'Default Address',
          'role': 'patient',
          'specialite': null,
        },
        {
          'nom': 'Smith',
          'prenom': 'John',
          'email': 'john@test.com',
          'mot_de_passe': 'password123',
          'telephone': '+1987654321',
          'date_naissance': '1985-05-15',
          'sexe': 'Male',
          'adresse': 'Test Address 1',
          'role': 'patient',
          'specialite': null,
        },
        {
          'nom': 'Johnson',
          'prenom': 'Emma',
          'email': 'emma@test.com',
          'mot_de_passe': 'password123',
          'telephone': '+1555123456',
          'date_naissance': '1992-08-22',
          'sexe': 'Female',
          'adresse': 'Test Address 2',
          'role': 'doctor',
          'specialite': 'Cardiology',
        },
      ];

      for (var userData in testUsers) {
        // Check if user already exists
        final existingUser = await db.query(
          'Utilisateur',
          where: 'email = ?',
          whereArgs: [userData['email']],
        );

        if (existingUser.isEmpty) {
          await db.insert('Utilisateur', userData);
          print("✅ User created: ${userData['prenom']} ${userData['nom']} (${userData['email']})");
        } else {
          print("✅ User already exists: ${userData['email']}");
        }
      }
    } catch (e) {
      print("❌ Error creating test users: $e");
    }
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
    // For testing different users, change this return value
    // User 1: return 1 (Default User)
    // User 2: return 2 (John Smith)
    // User 3: return 3 (Emma Johnson)
    return 2; // Change this number to test as different users

    // Uncomment below to use actual database lookup
    /*
    final db = await database;
    final result = await db.query(
      'Utilisateur',
      where: 'email = ?',
      whereArgs: ['default@healthtracker.com'],
      columns: ['user_id'],
    );

    if (result.isNotEmpty) {
      return result.first['user_id'] as int;
    } else {
      // If no default user exists, create one and return its ID
      await _createDefaultUser(db);
      final newResult = await db.query(
        'Utilisateur',
        where: 'email = ?',
        whereArgs: ['default@healthtracker.com'],
        columns: ['user_id'],
      );
      return newResult.first['user_id'] as int;
    }
    */
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
  
}
