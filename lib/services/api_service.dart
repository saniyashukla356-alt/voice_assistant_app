import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  ApiService({String? apiKey, String? model})
      : apiKey = (apiKey ?? dotenv.env['GEMINI_API_KEY'] ?? '').trim(),
        model = (model ?? dotenv.env['GEMINI_MODEL'] ?? 'gemini-1.5-flash').trim();

  final String apiKey;
  final String model;

  Future<String> getResponse(String prompt) async {
    if (apiKey.isEmpty) {
      return 'Error: API Key is empty. Check if your .env file exists and contains GEMINI_API_KEY.';
    }

    // Using v1beta as it is often more permissive for non-standard keys
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );

    try {
      debugPrint('ApiService: Sending request to $model (Key length: ${apiKey.length})');
      
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text": "SYSTEM: Your name is Vaani AI. You are a helpful voice assistant. "
                      "Current time is ${DateTime.now().toIso8601String()}. "
                      "\n\nUSER: $prompt"
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["candidates"][0]["content"]["parts"][0]["text"];
      } else {
        final errorBody = response.body;
        if (response.statusCode == 401) {
          return "Auth Error (401): Your API key is invalid or has expired. Please get a new key from Google AI Studio.";
        }
        return "API Error (${response.statusCode}): $errorBody";
      }
    } catch (e) {
      return "Exception: $e";
    }
  }
}
