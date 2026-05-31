import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  ApiService({String? apiKey, String? model})
      : apiKey = apiKey ?? dotenv.env['GEMINI_API_KEY'] ?? '',
        model = model ?? dotenv.env['GEMINI_MODEL'] ?? 'gemini-2.5-flash';

  final String apiKey;
  final String model;

  Future<String> getResponse(String prompt) async {
    if (apiKey.isEmpty) {
      return 'Missing API key. Set GEMINI_API_KEY in .env.';
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data["candidates"][0]["content"]["parts"][0]["text"];
      } else {
        return "API Error: ${response.body}";
      }
    } catch (e) {
      return "Exception: $e";
    }
  }
}
