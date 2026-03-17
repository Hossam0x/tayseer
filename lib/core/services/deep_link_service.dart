import 'package:share_plus/share_plus.dart';

class DeepLinkService {
  static const _baseUrl = 'https://tayser-app.net';

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

    SharePlus.instance.share(
      ShareParams(
        text: 'شاهد ملف $userName الشخصي على تيسير 💍\n$link',
        subject: 'ملف $userName على تيسير',
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Incoming — التحقق من الرابط
  // ─────────────────────────────────────────────

  /// استخراج personId من أي نوع رابط
  static String? extractPersonId(Uri uri) {
    final segments = uri.pathSegments;

    // https://tayser-app.net/marriage/profile/{personId}
    if (segments.length >= 3 &&
        segments[0] == 'marriage' &&
        segments[1] == 'profile') {
      return segments[2];
    }

    // tayseer://marriage?profileId={personId}
    if (uri.scheme == 'tayseer' && uri.host == 'marriage') {
      return uri.queryParameters['profileId'];
    }

    return null;
  }

  /// التحقق إن الرابط هو profile link
  static bool isProfileLink(Uri uri) {
    return extractPersonId(uri) != null;
  }
}
