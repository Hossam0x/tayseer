import 'package:flutter/gestures.dart';
import 'package:tayseer/core/functions/url_launcher.dart';
import 'package:tayseer/my_import.dart';

class AgreementText extends StatelessWidget {
  const AgreementText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: context.tr('by_continuing_you_agree'),
            style: Styles.textStyle14.copyWith(color: Colors.grey[600]),
          ),
          const TextSpan(text: ' '),
          TextSpan(
            text: context.tr('privacy_policy'),
            style: Styles.textStyle14.copyWith(
              color: AppColors.kprimaryColor,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.kprimaryColor,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                ApplaunchUrl(
                  Uri.parse('https://m.tayser-app.com/privacy-policy-2/'),
                );
              },
          ),
          const TextSpan(text: ' '),
          TextSpan(
            text: context.tr('terms_belong_to_us'),
            style: Styles.textStyle14.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
