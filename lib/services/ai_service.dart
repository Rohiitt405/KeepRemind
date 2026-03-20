import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';

class AiService {
  Future<List<String>> generateTakeaways(String title, String caption) async {
    if(title.isEmpty && caption.isEmpty) {
      return [];
    }

    final prompt = ''' You are helping a user understand the key points form a short video (reel or youtube short).

    Vide title: $title
    Vide description: $caption

    extract 3 to 5 short, clear, actionable key takeaways from this content.
    Reply Only with a JSON array of string. No explanation, no markdown, no extra text.

    Example format: ["Takeaway one", "Takeaway two", "Takeaway three"]
    ''';

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.geminiApiKey}?key=${AppConstants.geminiApiKey}'),
        headers: {'Content-Type' : 'application/json'},
        body: jsonEncode({
          "contents" : [
            {
              "parts": [
                {"text" : prompt}
              ]
            }
          ]
        })
      );

      if(response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final text = json['candidates'][0]['content']['parts'][0]['text'] as String;
        final cleaned = text
          .trim()
          .replaceAll('```', '')
          .replaceAll('```', '')
          .trim();
        
        final List<dynamic> decoded = jsonDecode(cleaned);
        return decoded.map((e) => e.toString()).toList();

      } else {
        print('Gemini error: ${response.statusCode} ${response.body}');
        return [];
      }

    } catch (e) {
      print('AI service error: $e');
      return [];
    }
  }
}