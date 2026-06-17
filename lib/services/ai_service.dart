import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import '../models/ai_memory.dart';

class AiService {
  final _model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-3.5-flash',
  );

  Future<AiMemory?> generateMemory({
    required String title,
    required String caption,
  }) async {
    try {
      final prompt = ''' You help users remember why they saved short-form videos.

      Titel: $title
      Caption: $caption

      Return ONLY valid JSON: 

      {
        "memory" : "single sentence under 20 words",
        "tags" : ["tag1", "tag2", "tag3"]
      }
      ''';

      final response = await _model.generateContent([Content.text(prompt)]);

      final text = response.text;

      if (text == null || text.trim().isEmpty) {
        return null;
      }

      Map<String, dynamic>? parsed;

      // First try direct decode
      try {
        parsed = jsonDecode(text) as Map<String, dynamic>?;
      } catch (_) {
        // Try to extract JSON object from surrounding text
        final raw = text.trim();
        final start = raw.indexOf('{');
        final end = raw.lastIndexOf('}');
        if (start != -1 && end != -1 && end > start) {
          final candidate = raw.substring(start, end + 1);
          try {
            parsed = jsonDecode(candidate) as Map<String, dynamic>?;
          } catch (_) {
            // As a last resort, replace single quotes with double quotes
            try {
              parsed = jsonDecode(candidate.replaceAll("'", '"')) as Map<String, dynamic>?;
            } catch (e) {
              debugPrint('AI JSON parse failed: $e');
              debugPrint('AI raw response: $raw');
              return null;
            }
          }
        } else {
          debugPrint('AI response did not contain JSON object: $raw');
          return null;
        }
      }

      if (parsed == null) return null;

      // Support multiple possible key names the model might return
      final memoryValue = parsed['memory'] ?? parsed['aiMemory'] ?? parsed['ai_memory'] ?? '';

      dynamic tagsValue = parsed['tags'] ?? parsed['aiTags'] ?? parsed['ai_tags'] ?? parsed['ai-tags'];

      List<String> tags = [];
      if (tagsValue is List) {
        tags = tagsValue.map((e) => e.toString()).toList();
      } else if (tagsValue is String) {
        tags = tagsValue
            .split(RegExp(r',|\n'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }

      return AiMemory(
        memory: memoryValue.toString(),
        tags: tags,
      );
    } catch (e) {
      debugPrint('generateMemory error: $e');
      return null;
    }
  }
}