import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'env.dart';

/// REST-API client for Gemini text models. Powers:
/// - The feedback judge (JSON-mode call after each session).
/// - The cross-session summary writer.
/// - The STT half of the fallback voice path (audio → text → text-mode chat).
abstract class GeminiTextService {
  /// One-shot generation. If [jsonMode] is true, the model is forced to
  /// return a parseable JSON blob (caller still has to `jsonDecode`).
  Future<String> generate({
    required String prompt,
    String? systemInstruction,
    bool jsonMode = false,
  });

  /// Streaming generation. Chunks arrive as the model emits them — useful
  /// for the feedback screen's progressive reveal.
  Stream<String> generateStream({
    required String prompt,
    String? systemInstruction,
  });
}

/// Mock that returns canned JSON-shaped strings after a short delay.
/// Lets the feedback screen exercise its streaming UI without an API key.
class MockGeminiTextService implements GeminiTextService {
  @override
  Future<String> generate({
    required String prompt,
    String? systemInstruction,
    bool jsonMode = false,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (jsonMode) {
      return jsonEncode({
        'score': 78,
        'fillerCount': 4,
        'strongestMoment':
            "You handled the 'why us' question with a specific, well-researched answer.",
        'areasForImprovement': [
          'Ask three follow-up questions to show curiosity.',
          'Cut filler words ("um", "like") on technical answers.',
        ],
        'recommendedNextPersonaId': 'hiring_manager',
        'recommendedNextRationale':
            'You did well with screening — try a hiring manager next to go deeper.',
        'skillScores': {
          'Communication': 0.82,
          'Confidence': 0.7,
          'Active Listening': 0.6,
          'Follow-up': 0.55,
        },
      });
    }
    return 'Practiced phone screen with Sarah at Acme. Strong on '
        "'why us'; needs follow-up questions and tighter pacing.";
  }

  @override
  Stream<String> generateStream({
    required String prompt,
    String? systemInstruction,
  }) async* {
    final chunks = [
      'You came across as ',
      'genuinely curious and ',
      'well-prepared. The ',
      'opening was strong; the ',
      'middle had some pacing ',
      'issues worth working on.',
    ];
    for (final c in chunks) {
      await Future<void>.delayed(const Duration(milliseconds: 220));
      yield c;
    }
  }
}

/// Real impl: hits the Gemini REST API directly from the browser. API key
/// is embedded via dotenv — acceptable risk for a hackathon demo since the
/// key is scoped to a single project with a low budget cap.
class RealGeminiTextService implements GeminiTextService {
  RealGeminiTextService({required this.apiKey, http.Client? client})
      : _client = client ?? http.Client();

  final String apiKey;
  final http.Client _client;

  static const _base =
      'https://generativelanguage.googleapis.com/v1beta/models';

  @override
  Future<String> generate({
    required String prompt,
    String? systemInstruction,
    bool jsonMode = false,
  }) async {
    final url = Uri.parse('$_base/$geminiTextModel:generateContent?key=$apiKey');
    final body = <String, dynamic>{
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': prompt}
          ],
        },
      ],
      if (systemInstruction != null)
        'system_instruction': {
          'parts': [
            {'text': systemInstruction}
          ],
        },
      if (jsonMode)
        'generation_config': {'response_mime_type': 'application/json'},
    };
    final res = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      throw Exception('Gemini error ${res.statusCode}: ${res.body}');
    }
    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    final parts = (decoded['candidates'] as List).first['content']['parts']
        as List;
    return parts.map((p) => p['text'] as String? ?? '').join();
  }

  @override
  Stream<String> generateStream({
    required String prompt,
    String? systemInstruction,
  }) async* {
    final url = Uri.parse(
      '$_base/$geminiTextModel:streamGenerateContent?key=$apiKey&alt=sse',
    );
    final req = http.Request('POST', url)
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': prompt}
            ],
          },
        ],
        if (systemInstruction != null)
          'system_instruction': {
            'parts': [
              {'text': systemInstruction}
            ],
          },
      });

    final res = await _client.send(req);
    if (res.statusCode != 200) {
      final body = await res.stream.bytesToString();
      throw Exception('Gemini stream error ${res.statusCode}: $body');
    }

    final lines = res.stream.transform(utf8.decoder).transform(const LineSplitter());
    await for (final line in lines) {
      if (!line.startsWith('data:')) continue;
      final payload = line.substring(5).trim();
      if (payload.isEmpty || payload == '[DONE]') continue;
      try {
        final decoded = jsonDecode(payload) as Map<String, dynamic>;
        final candidates = decoded['candidates'] as List?;
        if (candidates == null || candidates.isEmpty) continue;
        final parts = (candidates.first['content']?['parts'] as List?) ?? [];
        for (final p in parts) {
          final text = p['text'] as String?;
          if (text != null && text.isNotEmpty) yield text;
        }
      } catch (_) {
        // SSE frame split mid-JSON; skip and let the next frame pick up.
      }
    }
  }
}

final geminiTextServiceProvider = Provider<GeminiTextService>((ref) {
  if (useMocks) return MockGeminiTextService();
  final key = geminiApiKey;
  if (key == null) return MockGeminiTextService();
  return RealGeminiTextService(apiKey: key);
});
