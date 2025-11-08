import 'dart:convert';
import 'package:http/http.dart' as http;

class GifData {
  final String id;
  final String url;
  final String previewUrl;
  final int width;
  final int height;

  GifData({
    required this.id,
    required this.url,
    required this.previewUrl,
    required this.width,
    required this.height,
  });

  factory GifData.fromJson(Map<String, dynamic> json) {
    final images = json['images'];
    final fixedHeight = images['fixed_height'];
    final previewGif = images['preview_gif'];

    return GifData(
      id: json['id'],
      url: fixedHeight['url'],
      previewUrl: previewGif['url'],
      width: int.parse(fixedHeight['width'].toString()),
      height: int.parse(fixedHeight['height'].toString()),
    );
  }
}

class GifService {
  static const String _apiKey = 'PE1aD7rkBpy8USY6nZJt19P8FJESbDDL'; 
  static const String _baseUrl = 'https://api.giphy.com/v1/gifs';

  // Search for GIFs
  Future<List<GifData>> searchGifs(String query, {int limit = 20, int offset = 0}) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/search?api_key=$_apiKey&q=$query&limit=$limit&offset=$offset&rating=g&lang=en'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final gifs = data['data'] as List;
        return gifs.map((gif) => GifData.fromJson(gif)).toList();
      } else {
        throw Exception('Failed to load GIFs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching GIFs: $e');
    }
  }

  // Get trending GIFs
  Future<List<GifData>> getTrendingGifs({int limit = 20, int offset = 0}) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/trending?api_key=$_apiKey&limit=$limit&offset=$offset&rating=g'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final gifs = data['data'] as List;
        return gifs.map((gif) => GifData.fromJson(gif)).toList();
      } else {
        throw Exception('Failed to load trending GIFs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading trending GIFs: $e');
    }
  }

  // Get GIF by ID
  Future<GifData?> getGifById(String id) async {
    try {
      final url = Uri.parse('$_baseUrl/$id?api_key=$_apiKey');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final gif = data['data'];
        return GifData.fromJson(gif);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}