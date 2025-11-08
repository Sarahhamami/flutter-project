class Article {
  final String id;
  final String title;
  final String description;
  final String content;
  final String url;
  final String image;
  final String publishedAt;
  final String lang;
  final String sourceName;
  final String sourceUrl;

  Article({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.url,
    required this.image,
    required this.publishedAt,
    required this.lang,
    required this.sourceName,
    required this.sourceUrl,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      url: json['url'] ?? '',
      image: json['image'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      lang: json['lang'] ?? '',
      sourceName: json['source']?['name'] ?? '',
      sourceUrl: json['source']?['url'] ?? '',
    );
  }
}

// User Model
class User {
  final int userId;
  final String nom;
  final String prenom;
  final String email;
  final String motDePasse;
  final String? telephone;
  final String? dateNaissance;
  final String? sexe;
  final String? adresse;
  final String role;
  final String? specialite;

  User({
    required this.userId,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.motDePasse,
    this.telephone,
    this.dateNaissance,
    this.sexe,
    this.adresse,
    required this.role,
    this.specialite,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['user_id'] ?? 0,
      nom: map['nom'] ?? '',
      prenom: map['prenom'] ?? '',
      email: map['email'] ?? '',
      motDePasse: map['mot_de_passe'] ?? '',
      telephone: map['telephone'],
      dateNaissance: map['date_naissance'],
      sexe: map['sexe'],
      adresse: map['adresse'],
      role: map['role'] ?? '',
      specialite: map['specialite'],
    );
  }

  String get fullName => '$prenom $nom';
}
