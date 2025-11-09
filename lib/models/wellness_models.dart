class Sleep {
  final int? id;
  final int userId;
  final DateTime date;
  final String bedTime;
  final String wakeUpTime;
  final double sleepDuration;
  final String sleepQuality;

  Sleep({
    this.id,
    required this.userId,
    required this.date,
    required this.bedTime,
    required this.wakeUpTime,
    required this.sleepDuration,
    required this.sleepQuality,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String(),
      'bedTime': bedTime,
      'wakeUpTime': wakeUpTime,
      'sleepDuration': sleepDuration,
      'sleepQuality': sleepQuality,
    };
  }

  factory Sleep.fromMap(Map<String, dynamic> map) {
    return Sleep(
      id: map['id'],
      userId: map['user_id'],
      date: DateTime.parse(map['date']),
      bedTime: map['bedTime'],
      wakeUpTime: map['wakeUpTime'],
      sleepDuration: map['sleepDuration'],
      sleepQuality: map['sleepQuality'],
    );
  }
}

class Mood {
  final int? id;
  final int userId;
  final DateTime date;
  final int stressLevel;
  final String mood;
  final int energyLevel;

  Mood({
    this.id,
    required this.userId,
    required this.date,
    required this.stressLevel,
    required this.mood,
    required this.energyLevel,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String(),
      'stressLevel': stressLevel,
      'mood': mood,
      'energyLevel': energyLevel,
    };
  }

  factory Mood.fromMap(Map<String, dynamic> map) {
    return Mood(
      id: map['id'],
      userId: map['user_id'],
      date: DateTime.parse(map['date']),
      stressLevel: map['stressLevel'],
      mood: map['mood'],
      energyLevel: map['energyLevel'],
    );
  }
}

class Cycle {
  final int? id;
  final int userId;
  final DateTime cycleStartDate;
  final DateTime cycleEndDate;
  final List<String> symptoms;

  Cycle({
    this.id,
    required this.userId,
    required this.cycleStartDate,
    required this.cycleEndDate,
    required this.symptoms,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'cycleStartDate': cycleStartDate.toIso8601String(),
      'cycleEndDate': cycleEndDate.toIso8601String(),
      'symptoms': symptoms.join(','),
    };
  }

  factory Cycle.fromMap(Map<String, dynamic> map) {
    return Cycle(
      id: map['id'],
      userId: map['user_id'],
      cycleStartDate: DateTime.parse(map['cycleStartDate']),
      cycleEndDate: DateTime.parse(map['cycleEndDate']),
      symptoms: map['symptoms'] != null ? (map['symptoms'] as String).split(',') : [],
    );
  }
}

class Recommendation {
  final int? id;
  final int userId;
  final DateTime date;
  final String type;
  final String message;

  Recommendation({
    this.id,
    required this.userId,
    required this.date,
    required this.type,
    required this.message,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String(),
      'type': type,
      'message': message,
    };
  }

  factory Recommendation.fromMap(Map<String, dynamic> map) {
    return Recommendation(
      id: map['id'],
      userId: map['user_id'],
      date: DateTime.parse(map['date']),
      type: map['type'],
      message: map['message'],
    );
  }
}

class LifestyleLog {
  final int? id;
  final int userId;
  final DateTime date;
  final String physicalActivity;
  final String? nutrition;
  final double screenTime;

  LifestyleLog({
    this.id,
    required this.userId,
    required this.date,
    required this.physicalActivity,
    this.nutrition,
    required this.screenTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String(),
      'physicalActivity': physicalActivity,
      'nutrition': nutrition,
      'screenTime': screenTime,
    };
  }

  factory LifestyleLog.fromMap(Map<String, dynamic> map) {
    return LifestyleLog(
      id: map['id'],
      userId: map['user_id'],
      date: DateTime.parse(map['date']),
      physicalActivity: map['physicalActivity'],
      nutrition: map['nutrition'],
      screenTime: map['screenTime'],
    );
  }
}