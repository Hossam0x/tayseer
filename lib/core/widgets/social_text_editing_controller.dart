import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/my_import.dart';

class SocialTextEditingController extends TextEditingController {
  SocialTextEditingController({String? text}) : super(text: text);

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    List<TextSpan> spans = [];
    RegExp exp = RegExp(r"([#@][\w\u0600-\u06FF]+)");

    text.splitMapJoin(
      exp,
      onMatch: (Match match) {
        final String word = match[0]!;
        final bool isHashtag = word.startsWith('#');
        final bool isMention = word.startsWith('@');

        TextStyle defaultStyle = style ?? const TextStyle();

        if (isHashtag) {
          defaultStyle = defaultStyle.copyWith(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          );
        } else if (isMention) {
          defaultStyle = defaultStyle.copyWith(
            color: AppColors
                .primary200, // Matching SocialTextParser AppColors.primary200 or Colors.blueAccent
            fontWeight: FontWeight.w900,
            fontSize:
                16.sp, // Or leave default size so it doesn't break metrics
          );
        }

        spans.add(TextSpan(text: word, style: defaultStyle));
        return word;
      },
      onNonMatch: (String nonMatch) {
        if (nonMatch.isNotEmpty) {
          spans.add(TextSpan(text: nonMatch, style: style));
        }
        return nonMatch;
      },
    );

    return TextSpan(style: style, children: spans);
  }
}
