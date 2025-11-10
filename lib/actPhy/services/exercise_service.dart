import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/exercise_model.dart';

class ExerciseService {
  static const String _baseUrl = 'https://gym-fit.p.rapidapi.com/v1/exercises/search';
  static const Map<String, String> _headers = {
    'x-rapidapi-key': '1b6f89246dmsh75f820709407d5bp18eda4jsnfc8d51e9fc05',
    'x-rapidapi-host': 'gym-fit.p.rapidapi.com',
  };

  Future<List<Exercise>> fetchExercises({
    String bodyPart = '',
    String equipment = '',
    int number = 10,
    int offset = 0,
  }) async {
    // Build query parameters, only include equipment if it's not empty
    final Map<String, String> queryParams = {
      'number': number.toString(),
      'offset': offset.toString(),
    };
    
    if (bodyPart.isNotEmpty) {
      queryParams['bodyPart'] = bodyPart;
    }
    
    if (equipment.isNotEmpty) {
      queryParams['equipment'] = equipment;
    }
    
    final Uri uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);

    print('🔗 API Request URL: $uri');
    print('📋 Headers: $_headers');

    final response = await http.get(uri, headers: _headers);

    print('📊 Response Status: ${response.statusCode}');
    print('📄 Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> exercisesJson = data is List ? data : data['results'] ?? [];
      print('✅ Found ${exercisesJson.length} exercises');
      return exercisesJson.map((json) => Exercise.fromJson(json)).toList();
    } else {
      print('❌ API Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load exercises: ${response.statusCode} - ${response.body}');
    }
  }
}
