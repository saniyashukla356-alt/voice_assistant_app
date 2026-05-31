import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String apiKey = "YOUR_GEMINI_API_KEY_HERE";

  Future<String> getResponse(String prompt) async {
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey",
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