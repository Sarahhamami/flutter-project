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
