import 'package:flutter/gestures.dart';
import 'package:tayseer/core/functions/url_launcher.dart';
import 'package:tayseer/my_import.dart';

class AgreementText extends StatelessWidget {
  /// لو [onWhiteBackground] = false → النصوص بيضاء (على خلفية ملونة)
  final bool onWhiteBackground;

  const AgreementText({super.key, this.onWhiteBackground = true});

  static const _privacyUrl = 'https://m.tayser-app.com/privacy-policy-2/';
  static const _termsUrl = 'https://m.tayser-app.com/terms-of-use/';

  @override
  Widget build(BuildContext context) {
    final baseColor = onWhiteBackground
        ? Colors.grey[600]!
        : Colors.white.withOpacity(0.75);
    final linkColor = onWhiteBackground
        ? AppColors.kprimaryTextColor
        : Colors.white;

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: context.tr('by_continuing_you_agree'),
            style: Styles.textStyle12.copyWith(color: baseColor),
          ),
          const TextSpan(text: ' '),
          TextSpan(
            text: context.tr('terms_of_use'),
            style: Styles.textStyle12.copyWith(
              color: linkColor,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              decorationColor: linkColor,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                ApplaunchUrl(Uri.parse(_termsUrl));
              },
          ),
          TextSpan(
            text: ' ${context.tr('and')} ',
            style: Styles.textStyle12.copyWith(color: baseColor),
          ),
          TextSpan(
            text: context.tr('privacy_policy'),
            style: Styles.textStyle12.copyWith(
              color: linkColor,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              decorationColor: linkColor,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                ApplaunchUrl(Uri.parse(_privacyUrl));
              },
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
