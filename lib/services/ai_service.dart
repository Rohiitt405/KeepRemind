import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

import '../models/ai_memory.dart';

class AiService {
  final _model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-3.5-flash',
  );

  static const _maxAttempts = 5;

  static const _retryDelays = [
    Duration(seconds: 2),
    Duration(seconds: 5),
    Duration(seconds: 10),
    Duration(seconds: 20),
    Duration(seconds: 40),
  ];

  Future<AiMemory?> generateMemory({
    required String url,
    required String platform,
    required String title,
    required String caption,
  }) async {
    final prompt =
        '''
You are helping users remember why they saved a social media link.

The link can come from:

- YouTube
- Instagram
- TikTok
- Facebook
- Threads
- Reddit
- LinkedIn
- Pinterest
- X (Twitter)
- Snapchat
- GitHub
- Medium
- Any website

Platform:
$platform

URL:
$url

Title:
$title

Caption:
$caption

Instructions:

1. If the title and caption contain enough information, use them.

2. If the metadata is incomplete, use the platform and URL to produce a generic but useful memory.

3. Never invent specific facts that are not supported by the metadata.

4. Memory must:
- be one sentence
- under 25 words
- concise
- easy to remember

5. Tags:
- 3 to 5 tags
- lowercase
- single words whenever possible
- no duplicates

Return ONLY valid JSON.

Example:

{
  "memory": "Flutter Riverpod tutorial for state management.",
  "tags": [
    "flutter",
    "riverpod",
    "tutorial"
  ]
}
''';

    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        final response = await _model.generateContent([Content.text(prompt)]);

        final text = response.text;

        debugPrint('AI response: ${text ?? "<null>"}');

        if (text == null || text.trim().isEmpty) {
          return null;
        }

        Map<String, dynamic>? parsed;

        try {
          parsed = jsonDecode(text);
        } catch (_) {
          final raw = text.trim();

          final start = raw.indexOf('{');
          final end = raw.lastIndexOf('}');

          if (start == -1 || end == -1) {
            return null;
          }

          final candidate = raw.substring(start, end + 1);

          try {
            parsed = jsonDecode(candidate);
          } catch (_) {
            try {
              parsed = jsonDecode(candidate.replaceAll("'", '"'));
            } catch (_) {
              return null;
            }
          }
        }

        if (parsed == null) {
          return null;
        }

        final memory =
            (parsed['memory'] ??
                    parsed['aiMemory'] ??
                    parsed['ai_memory'] ??
                    '')
                .toString();

        dynamic tagsValue =
            parsed['tags'] ??
            parsed['aiTags'] ??
            parsed['ai_tags'] ??
            parsed['ai-tags'];

        List<String> tags = [];

        if (tagsValue is List) {
          tags = tagsValue
              .map((e) => e.toString().trim().toLowerCase())
              .where((e) => e.isNotEmpty)
              .toSet()
              .toList();
        } else if (tagsValue is String) {
          tags = tagsValue
              .split(RegExp(r',|\n'))
              .map((e) => e.trim().toLowerCase())
              .where((e) => e.isNotEmpty)
              .toSet()
              .toList();
        }

        return AiMemory(memory: memory, tags: tags);
      } catch (e, stackTrace) {
        debugPrint('generateMemory attempt $attempt failed: $e');

        debugPrintStack(stackTrace: stackTrace);

        final message = e.toString().toLowerCase();

        final isTransient =
            message.contains('500') ||
            message.contains('internal') ||
            message.contains('high demand') ||
            message.contains('unavailable');

        if (!isTransient || attempt == _maxAttempts) {
          return null;
        }

        await Future.delayed(_retryDelays[attempt - 1]);
      }
    }

    return null;
  }
}
