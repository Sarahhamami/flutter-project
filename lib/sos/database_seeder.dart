import '../db/database_helper.dart';

class DatabaseSeeder {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Fill database with sample data
  Future<void> seedDatabase() async {
    try {
      print('🌱 Starting database seeding...');
      
      // Get default user ID
      int userId = await _dbHelper.getDefaultUserId();
      print('👤 User ID: $userId');

      // Add emergency contacts
      await _seedEmergencyContacts(userId);
      
      // Add first aid guides
      await _seedFirstAidGuides();
      
      // Add sample medical record
      await _seedMedicalRecord(userId);
      
      // Add sample medications
      await _seedMedications(userId);

      print('✅ Database seeded successfully!');
    } catch (e) {
      print('❌ Error during database seeding: $e');
    }
  }

  /// Add sample emergency contacts
  Future<void> _seedEmergencyContacts(int userId) async {
    print('📞 Adding emergency contacts...');
    
    final contacts = [
      {
        'fullName': 'Mary Johnson',
        'phone': '+44123456789',
        'relation': 'Wife',
        'priority': 1,
      },
      {
        'fullName': 'Dr. John Smith',
        'phone': '+44987654321',
        'relation': 'Family Doctor',
        'priority': 2,
      },
      {
        'fullName': 'Sarah Wilson',
        'phone': '+44555666777',
        'relation': 'Sister',
        'priority': 3,
      },
      {
        'fullName': 'Fire Department',
        'phone': '999',
        'relation': 'Emergency Service',
        'priority': 4,
      },
      {
        'fullName': 'Emergency Medical Services',
        'phone': '999',
        'relation': 'Medical Emergency Service',
        'priority': 5,
      },
    ];

    for (var contact in contacts) {
      try {
        await _dbHelper.createEmergencyContact(
          userId: userId,
          fullName: contact['fullName'] as String,
          phone: contact['phone'] as String,
          relation: contact['relation'] as String,
          priority: contact['priority'] as int,
        );
        print('  ✅ Contact added: ${contact['fullName']}');
      } catch (e) {
        print('  ❌ Contact error ${contact['fullName']}: $e');
      }
    }
  }

  /// Add sample first aid guides
  Future<void> _seedFirstAidGuides() async {
    print('🩹 Adding first aid guides...');
    
    final guides = [
      {
        'title': 'What to do in case of fainting',
        'description': 'Guide to help a person who has fainted',
        'stepByStep': '''1. Check if the person is conscious
2. Call emergency services (999)
3. Place the person in recovery position
4. Monitor their breathing
5. Stay with them until help arrives''',
        'category': 'Malaise',
        'imageUrl': 'https://example.com/fainting.jpg',
      },
      {
        'title': 'First aid for burns',
        'description': 'How to treat a burn quickly',
        'stepByStep': '''1. Cool immediately with lukewarm water (15-20°C)
2. Rinse for 15-20 minutes
3. Remove jewelry and non-stuck clothing
4. Cover with clean cloth
5. Consult a doctor if necessary''',
        'category': 'Brûlure',
        'imageUrl': 'https://example.com/burn.jpg',
      },
      {
        'title': 'Managing a fracture',
        'description': 'What to do in case of suspected fracture',
        'stepByStep': '''1. Do not move the person
2. Immobilize the injured limb
3. Call emergency services (999)
4. Do not give anything to drink or eat
5. Monitor consciousness level''',
        'category': 'Fracture',
        'imageUrl': 'https://example.com/fracture.jpg',
      },
      {
        'title': 'Stop bleeding',
        'description': 'Techniques to stop bleeding',
        'stepByStep': '''1. Apply direct pressure on the wound
2. Elevate the limb if possible
3. Maintain pressure
4. Call emergency services if bleeding persists
5. Do not remove embedded objects''',
        'category': 'Saignement',
        'imageUrl': 'https://example.com/bleeding.jpg',
      },
      {
        'title': 'Cardiopulmonary Resuscitation (CPR)',
        'description': 'Basic CPR technique',
        'stepByStep': '''1. Check consciousness and breathing
2. Call emergency services (999)
3. Place hands in center of chest
4. Perform 30 compressions
5. Give 2 rescue breaths
6. Repeat until help arrives''',
        'category': 'Autre',
        'imageUrl': 'https://example.com/cpr.jpg',
      },
    ];

    for (var guide in guides) {
      try {
        await _dbHelper.createFirstAidGuide(
          title: guide['title'] as String,
          description: guide['description'] as String,
          stepByStep: guide['stepByStep'] as String,
          category: guide['category'] as String,
          imageUrl: guide['imageUrl'] as String,
        );
        print('  ✅ Guide added: ${guide['title']}');
      } catch (e) {
        print('  ❌ Guide error ${guide['title']}: $e');
      }
    }
  }

  /// Add sample medical record
  Future<void> _seedMedicalRecord(int userId) async {
    print('🏥 Adding medical record...');
    
    try {
      await _dbHelper.createUserMedicalRecord(
        userId: userId,
        bloodType: 'O+',
        chronicDiseases: 'Type 2 Diabetes, High Blood Pressure',
        allergies: 'Penicillin, Pollen, Peanuts',
        currentTreatments: 'Metformin 500mg, Amlodipine 5mg',
        doctorName: 'Dr. John Smith',
        doctorPhone: '+44987654321',
      );
      print('  ✅ Medical record added');
    } catch (e) {
      print('  ❌ Medical record error: $e');
    }
  }

  /// Add sample medications
  Future<void> _seedMedications(int userId) async {
    print('💊 Adding medications...');
    
    // First, get medical record ID
    final medicalRecord = await _dbHelper.getUserMedicalRecord(userId);
    if (medicalRecord == null) {
      print('  ❌ No medical record found');
      return;
    }
    
    int recordId = medicalRecord['record_id'];
    
    final medications = [
      {
        'name': 'Metformin',
        'dosage': '500mg',
        'frequency': 'Twice daily',
        'startDate': '2024-01-15',
        'endDate': null,
      },
      {
        'name': 'Amlodipine',
        'dosage': '5mg',
        'frequency': 'Once daily',
        'startDate': '2024-02-01',
        'endDate': null,
      },
      {
        'name': 'Paracetamol',
        'dosage': '1000mg',
        'frequency': 'As needed (max 3g/day)',
        'startDate': '2024-03-01',
        'endDate': '2024-03-15',
      },
    ];

    for (var medication in medications) {
      try {
        await _dbHelper.createMedication(
          recordId: recordId,
          name: medication['name'] as String,
          dosage: medication['dosage'] as String,
          frequency: medication['frequency'] as String,
          startDate: medication['startDate'] as String,
          endDate: medication['endDate'] as String?,
        );
        print('  ✅ Medication added: ${medication['name']}');
      } catch (e) {
        print('  ❌ Medication error ${medication['name']}: $e');
      }
    }
  }

  /// Clear database (for testing)
  Future<void> clearDatabase() async {
    try {
      print('🗑️ Clearing database...');
      
      final db = await _dbHelper.database;
      
      // Delete data from new tables
      await db.delete('EmergencyAlert');
      await db.delete('EmergencyContact');
      await db.delete('FirstAidGuide');
      await db.delete('Medication');
      await db.delete('UserMedicalRecord');
      
      print('✅ Database cleared');
    } catch (e) {
      print('❌ Error during clearing: $e');
    }
  }

  /// Show database statistics
  Future<void> showDatabaseStats() async {
    try {
      print('\n📊 DATABASE STATISTICS');
      print('======================');
      
      final db = await _dbHelper.database;
      
      // Count records in each table
      final tables = [
        'Utilisateur',
        'EmergencyContact',
        'EmergencyAlert',
        'FirstAidGuide',
        'UserMedicalRecord',
        'Medication',
      ];
      
      for (String table in tables) {
        try {
          final result = await db.rawQuery('SELECT COUNT(*) as count FROM $table');
          int count = result.first['count'] as int;
          print('📋 $table: $count record(s)');
        } catch (e) {
          print('❌ Table error $table: $e');
        }
      }
      
      print('======================\n');
    } catch (e) {
      print('❌ Error displaying statistics: $e');
    }
  }
}
