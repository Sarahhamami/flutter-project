import 'package:flutter/material.dart';

class WaterIntake {
  String id;
  DateTime date;
  int quantity; // en ml
  TimeOfDay time;
  String note; // optionnel

  WaterIntake({
    required this.date,
    required this.quantity,
    required this.time,
    this.note = '',
    String? id,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  // Constructeur depuis JSON
  factory WaterIntake.fromJson(Map<String, dynamic> json) {
    return WaterIntake(
      id: json['id'],
      date: DateTime.parse(json['date']),
      quantity: json['quantity'],
      time: TimeOfDay(
        hour: json['hour'],
        minute: json['minute'],
      ),
      note: json['note'] ?? '',
    );
  }

  // Conversion en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'quantity': quantity,
      'hour': time.hour,
      'minute': time.minute,
      'note': note,
    };
  }

  // Copie avec modifications
  WaterIntake copyWith({
    String? id,
    DateTime? date,
    int? quantity,
    TimeOfDay? time,
    String? note,
  }) {
    return WaterIntake(
      id: id ?? this.id,
      date: date ?? this.date,
      quantity: quantity ?? this.quantity,
      time: time ?? this.time,
      note: note ?? this.note,
    );
  }

  // Vérifier si c'est aujourd'hui
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  // Formater l'heure sans BuildContext
  String get formattedTime {
    final hourStr = time.hour.toString().padLeft(2, '0');
    final minuteStr = time.minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr';
  }

  @override
  String toString() {
    return '$quantity ml à $formattedTime';
  }
}

// Classe utilitaire pour TimeOfDay
extension TimeOfDayExtension on TimeOfDay {
  String format() {
    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr';
  }
}