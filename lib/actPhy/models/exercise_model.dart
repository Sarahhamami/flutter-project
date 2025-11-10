class Exercise {
  final String id;
  final String name;
  final String bodyPart;
  final String equipment;
  final String gifUrl;
  final String target;
  final String instructions;

  Exercise({
    required this.id,
    required this.name,
    required this.bodyPart,
    required this.equipment,
    required this.gifUrl,
    required this.target,
    required this.instructions,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      bodyPart: json['bodyPart'] ?? '',
      equipment: json['equipment'] ?? '',
      gifUrl: json['image'] ?? json['gifUrl'] ?? '', // Try 'image' first, then 'gifUrl'
      target: json['target'] ?? '',
      instructions: (json['instructions'] is List)
          ? (json['instructions'] as List).join(" ")
          : json['instructions']?.toString() ?? '',
    );
  }
}
