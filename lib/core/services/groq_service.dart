import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GroqService {
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';

  final Dio _dio;

  GroqService(this._dio);

  /// يرسل prompt لـ Groq ويرجع النص الناتج باللغة العربية دائماً
  Future<String> generateText(String prompt) async {
    final apiKey = dotenv.env['GROQ_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Missing GROQ_API_KEY in .env');
    }

    final response = await _dio.post(
      _baseUrl,
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'model': _model,
        'messages': [
          {
            'role': 'system',
            'content':
                'أنت مساعد ذكي. '
                'قاعدة صارمة جداً: يجب أن تكتب ردك باللغة العربية فقط بدون استثناء. '
                'ممنوع تماماً استخدام أي لغة أخرى مثل الإنجليزية أو الصينية أو اليابانية أو الكورية أو غيرها. '
                'لا تكتب أي تفكير أو شرح أو مقدمة. '
                'اكتب النتيجة النهائية فقط باللغة العربية.',
          },
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.7,
        'max_tokens': 1024,
      },
    );

    final raw = response.data['choices'][0]['message']['content'] as String;
    return _cleanOutput(raw);
  }

  /// يزيل أي thinking tags من الـ output
  String _cleanOutput(String text) {
    return text
        .replaceAll(RegExp(r'<think>.*?</think>', dotAll: true), '')
        .replaceAll(RegExp(r'<thinking>.*?</thinking>', dotAll: true), '')
        .trim();
  }
}
