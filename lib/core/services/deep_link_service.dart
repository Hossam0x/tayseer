import 'package:share_plus/share_plus.dart';
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/my_import.dart';

class DeepLinkService {
  static const _baseUrl = 'https://tayser-app.net';

  // ─────────────────────────────────────────────
  // Outgoing — بناء وإرسال الرابط
  // ─────────────────────────────────────────────

  static String buildProfileLink(String personId) {
    return '$_baseUrl/marriage/profile/$personId';
  }

  /// ✅ بيبني رابط يفتح التطبيق مباشرة بدون ما يروح للمتصفح
  /// لو assetlinks.json مش شغال، الرابط ده هو الـ fallback الموثوق
  static String buildCustomSchemeLink(String personId) {
    return 'tayseer://marriage?profileId=$personId';
  }

  static void shareProfile({
    required String personId,
    required String userName,
    required BuildContext context,
  }) {
    final httpsLink = buildProfileLink(personId);

    SharePlus.instance.share(
      ShareParams(
        text: '${context.tr('share_profile_text').replaceAll('{name}', userName)}\n$httpsLink',
        // subject: context.tr('share_profile_subject').replaceAll('{name}', userName),
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

  // ─────────────────────────────────────────────
  // ✅ Handle deep link مع check على نوع المستخدم
  // ─────────────────────────────────────────────

  static void handleMarriageProfileLink({
    required BuildContext context,
    required String personId,
  }) {
    // ✅ مستشار — مش مسموحله بصفحة الزواج
    if (selectedUserType == UserTypeEnum.asConsultant) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                context.tr('cannot_do_this_action'),
                textAlign: TextAlign.center,
                style: Styles.textStyle18Bold,
              ),
              content: Text(
                'هذه الميزة متاحة فقط لمستخدمي تطبيق تيسير.\nيرجى تسجيل الدخول بحساب مستخدم للوصول إلى ملفات الزواج.',
                textAlign: TextAlign.center,
                style: Styles.textStyle14,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.pushNamed(AppRouter.kRegisrationView);
                  },
                  child: Text(context.tr('login')),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.tr('cancel')),
                ),
              ],
            ),
          );
        }
      });
      return;
    }

    // ✅ guest — محتاج يسجل دخول
    if (kIsUserGuest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                context.tr('guest_login_first'),
                textAlign: TextAlign.center,
                style: Styles.textStyle18Bold,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.pushNamed(AppRouter.kRegisrationView);
                  },
                  child: Text(context.tr('login')),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.tr('cancel')),
                ),
              ],
            ),
          );
        }
      });
      return;
    }

    // ✅ مستخدم عادي — افتح الصفحة
    if (context.mounted) {
      context.pushNamed(
        AppRouter.kMarriageView,
        arguments: {'personId': personId},
      );
    }
  }
}
