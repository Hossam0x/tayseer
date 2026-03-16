import 'package:share_plus/share_plus.dart';

class DeepLinkService {
  static const _baseUrl = 'https://tayseer.app';

  // ─────────────────────────────────────────────
  // Outgoing — بناء وإرسال الرابط
  // ─────────────────────────────────────────────

  static String buildProfileLink(String personId) {
    return '$_baseUrl/marriage/profile/$personId';
  }

  static void shareProfile({
    required String personId,
    required String userName,
  }) {
    final link = buildProfileLink(personId);

    // share_plus v12: API الجديد
    SharePlus.instance.share(
      ShareParams(
        text: 'شاهد ملف $userName الشخصي على تيسير 💍\n$link',
        subject: 'ملف $userName على تيسير',
      ),
    );
  }
}