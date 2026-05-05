import 'package:dio/dio.dart';

/// Service for translating post content using Google Translate (unofficial endpoint).
/// No API key required — same approach used by many open-source apps.
class PostTranslationService {
  static final PostTranslationService _instance =
      PostTranslationService._internal();
  factory PostTranslationService() => _instance;
  PostTranslationService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // Cache: key = "$text|$targetLang", value = translated text
  final Map<String, String> _cache = {};

  /// Translates [text] to [targetLang] (e.g. 'ar', 'en').
  /// Returns the original text if translation fails.
  Future<String> translate(String text, String targetLang) async {
    if (text.trim().isEmpty) return text;

    final cacheKey = '$text|$targetLang';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!;

    try {
      final response = await _dio.get(
        'https://translate.googleapis.com/translate_a/single',
        queryParameters: {
          'client': 'gtx',
          'sl': 'auto',
          'tl': targetLang,
          'dt': 't',
          'q': text,
        },
      );

      final data = response.data;
      if (data is List && data.isNotEmpty && data[0] is List) {
        final buffer = StringBuffer();
        for (final part in data[0]) {
          if (part is List && part.isNotEmpty && part[0] is String) {
            buffer.write(part[0]);
          }
        }
        final result = buffer.toString();
        if (result.isNotEmpty) {
          _cache[cacheKey] = result;
          return result;
        }
      }
    } catch (_) {
      // Silently fall through and return original text
    }

    return text;
  }
}
