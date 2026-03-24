import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tayseer/core/utils/extensions/extensions.dart';
import 'package:tayseer/core/utils/router/app_router.dart';

class SocialTextParser extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextStyle? hashtagStyle;
  final Function(String)? onMentionTap;

  // 1. المتغيرات الجديدة للتحكم في قص النص
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final bool removeDirectionality;
  final bool parseMentions; // للتحكم في تفعيل المنشن
  const SocialTextParser({
    super.key,
    required this.text,
    this.style,
    this.hashtagStyle,
    this.onMentionTap,
    // 2. إضافتها في الكونستركتور
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.textDirection,
    this.removeDirectionality = false,
    this.parseMentions = true,
  });

  @override
  Widget build(BuildContext context) {
    // تحديد الاتجاه بناءً على النص
    final bool isArabic = _isArabicText(text);

    return SizedBox(
      width: double.infinity,
      child: RichText(
        textAlign: removeDirectionality
            ? TextAlign.start
            : textAlign ?? (isArabic ? TextAlign.right : TextAlign.left),
        textDirection: removeDirectionality
            ? null
            : textDirection ??
                  (isArabic ? TextDirection.rtl : TextDirection.ltr),
        maxLines: maxLines,
        overflow: overflow ?? TextOverflow.clip,
        text: TextSpan(
          style: style ?? const TextStyle(color: Colors.black),
          children: _parseText(text, context),
        ),
      ),
    );
  }

  /// فحص إذا كان النص يبدأ بحرف عربي
  bool _isArabicText(String text) {
    if (text.trim().isEmpty) return true;

    // البحث عن أول حرف (عربي أو إنجليزي) وتجاهل الإيموجي والرموز والأرقام في البداية
    // ملاحظة: الأرقام والرموز لا يتم التقاطها بواسطة التعبير النمطي أدناه وبالتالي يتم تجاهلها
    final RegExp letterRegex = RegExp(r'[a-zA-Z\u0600-\u06FF]');
    final Match? match = letterRegex.firstMatch(text);

    if (match != null) {
      // التحقق مما إذا كان الحرف الذي تم إيجاده عربياً
      return RegExp(r'^[\u0600-\u06FF]').hasMatch(match.group(0)!);
    }

    // إذا لم يتم العثور على أي حروف (مثلاً النص عبارة عن إيموجي أو أرقام فقط)، نعتبره عربي
    return true;
  }

  List<TextSpan> _parseText(String text, BuildContext context) {
    List<TextSpan> spans = [];
    RegExp exp = RegExp(r"([#@][\w\u0600-\u06FF]+)");

    text.splitMapJoin(
      exp,
      onMatch: (Match match) {
        final String word = match[0]!;
        final bool isHashtag = word.startsWith('#');
        final bool isMention = word.startsWith('@');

        // إذا كانت الكلمة منشن وخاصية parseMentions معطلة، أضفها كنص عادي
        if (isMention && !parseMentions) {
          spans.add(TextSpan(text: word));
          return word;
        }

        spans.add(
          TextSpan(
            text: word,
            style:
                hashtagStyle ??
                const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                if (isHashtag) {
                  context.pushNamed(
                    AppRouter.kAdvisorSearchView,
                    arguments: {'query': word},
                  );
                } else if (isMention && parseMentions) {
                  // المنشن
                  print('Mention clicked: $word');
                  if (onMentionTap != null) {
                    onMentionTap!(word);
                  }
                }
              },
          ),
        );
        return word;
      },
      onNonMatch: (String nonMatch) {
        if (nonMatch.isNotEmpty) {
          spans.add(TextSpan(text: nonMatch));
        }
        return nonMatch;
      },
    );

    return spans;
  }
}
