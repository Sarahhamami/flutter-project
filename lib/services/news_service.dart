import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class NewsService {
  final String apiUrl =
      'https://gnews.io/api/v4/search?q=health&lang=eng&token=439b59c93580f861707cfc471e89c477';

  Future<List<Article>> fetchNews() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List articles = data['articles'] ?? []; // ✅ correct key

      return articles.map((json) => Article.fromJson(json)).toList();
    } else {
      print('❌ Failed to load news: ${response.statusCode}');
      print(response.body);
      throw Exception('Failed to load news');
    }
  }
}
