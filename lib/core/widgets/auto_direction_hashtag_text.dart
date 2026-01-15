import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AutoDirectionHashtagText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextStyle? hashtagStyle;
  final Function(String)? onHashtagTap;

  // 1. المتغيرات الجديدة للتحكم في قص النص
  final int? maxLines;
  final TextOverflow? overflow;

  const AutoDirectionHashtagText({
    super.key,
    required this.text,
    this.style,
    this.hashtagStyle,
    this.onHashtagTap,
    // 2. إضافتها في الكونستركتور
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    // تحديد الاتجاه بناءً على النص
    final bool isArabic = _isArabicText(text);

    return SizedBox(
      width: double.infinity,
      child: RichText(
        textAlign: isArabic ? TextAlign.right : TextAlign.left,
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        maxLines: maxLines,
        overflow: overflow ?? TextOverflow.clip,
        text: TextSpan(
          style: style ?? const TextStyle(color: Colors.black),
          children: _parseText(text),
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

  List<TextSpan> _parseText(String text) {
    List<TextSpan> spans = [];
    RegExp exp = RegExp(r"([#][\w\u0600-\u06FF]+)");

    text.splitMapJoin(
      exp,
      onMatch: (Match match) {
        final String hashtag = match[0]!;
        spans.add(
          TextSpan(
            text: hashtag,
            style:
                hashtagStyle ??
                const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                if (onHashtagTap != null) {
                  onHashtagTap!(hashtag);
                }
              },
          ),
        );
        return hashtag;
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
