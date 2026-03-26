import 'package:flutter/gestures.dart';
import 'package:tayseer/core/models/comment_model.dart';
import 'package:tayseer/my_import.dart';

class SocialTextParser extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextStyle? hashtagStyle;

  // 1. المتغيرات الجديدة للتحكم في قص النص
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final bool removeDirectionality;
  final bool parseMentions; // للتحكم في تفعيل المنشن

  final Map<String, MentionModel?>?
  mentions; // خريطة المنشنات (username -> userId)
  const SocialTextParser({
    super.key,
    required this.text,
    this.style,
    this.hashtagStyle,
    // 2. إضافتها في الكونستركتور
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.textDirection,
    this.removeDirectionality = false,
    this.parseMentions = true,
    this.mentions,
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

        // إذا كانت الكلمة منشن (وخاصية parseMentions معطلة أو غير موجودة في الـ mentions)، أضفها كنص عادي
        if (isMention &&
            (!parseMentions || mentions == null || mentions![word] == null)) {
          spans.add(TextSpan(text: word));
          return word;
        }

        String displayText = word;
        TextStyle defaultStyle =
            hashtagStyle ??
            const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold);

        if (isMention) {
          final mention = mentions![word]!;
          if (mention.name.isNotEmpty) {
            displayText = mention.name;
          }
          defaultStyle = TextStyle(
            color: AppColors.primary200,
            fontWeight: FontWeight.w900,
            fontSize: 16.sp,
          );
        }

        spans.add(
          TextSpan(
            text: displayText,
            style: defaultStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                if (isHashtag) {
                  context.pushNamed(
                    AppRouter.kAdvisorSearchView,
                    arguments: {'query': word},
                  );
                } else if (isMention) {
                  final mention = mentions![word]!;

                  if (mention.userType == "Advisor") {
                    context.pushNamed(
                      AppRouter.kUserProfileView,
                      arguments: {'advisorId': mention.id},
                    );
                  } else {
                    context.pushNamed(
                      AppRouter.kUserPublicProfileView,
                      arguments: mention.id,
                    );
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
