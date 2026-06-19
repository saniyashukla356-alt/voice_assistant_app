import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  ApiService({String? apiKey, String? model})
      : apiKey = apiKey ?? dotenv.env['GEMINI_API_KEY'] ?? '',
        model = model ?? dotenv.env['GEMINI_MODEL'] ?? 'gemini-1.5-flash';

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
          "system_instruction": {
            "parts": [
              {
                "text":
                    "Your name is Vaani. You are Vaani AI, a highly capable and friendly voice assistant. Whenever someone asks who you are or what your name is, always respond that you are Vaani AI. Keep your responses short, helpful, and optimized for text-to-speech. \n\n"
                    "If the user asks to set a reminder, extract the task and the time. "
                    "Respond with a JSON block in this format: {\"reminder\": {\"task\": \"...\", \"time\": \"ISO_8601_TIMESTAMP\"}}. "
                    "Current time: ${DateTime.now().toIso8601String()}. "
                    "Always confirm the reminder to the user in plain text as well."
              }
            ]
          },
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
