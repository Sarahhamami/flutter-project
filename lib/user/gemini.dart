import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String apiKey = 'AIzaSyAgcQVlaZP7K4SzOczOECtTPkLXnbRKjGQ';
  static const String geminiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey";

  static Future<String> generateStrongPassword() async {
    try {
      final prompt =
          "Generate a strong, random password with uppercase, lowercase, numbers, and symbols. Length: 12-16 characters, and just give me the password, don't say anything else.";

      final body = {
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      };

      final response = await http.post(
        Uri.parse(geminiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List;
        final parts = candidates[0]['content']['parts'] as List;
        return parts[0]['text'] as String;
      } else {
        print('Failed to generate password: ${response.body}');
        return "ErrorGeneratingPassword123!";
      }
    } catch (e) {
      print(e);
      return "ErrorGeneratingPassword123!";
    }
  }
}
