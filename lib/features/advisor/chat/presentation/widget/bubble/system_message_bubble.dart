import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tayseer/core/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

/// Widget لعرض رسائل النظام في الشات
/// - عربي: الـ bubble على اليمين
/// - إنجليزي: الـ bubble على اليسار
/// - الـ URLs قابلة للضغط وبلون مختلف
class SystemMessageBubble extends StatefulWidget {
  final String content;

  const SystemMessageBubble({super.key, required this.content});

  @override
  State<SystemMessageBubble> createState() => _SystemMessageBubbleState();
}

class _SystemMessageBubbleState extends State<SystemMessageBubble> {
  // ✅ نحفظ الـ recognizers عشان نعمل dispose صح
  final List<TapGestureRecognizer> _recognizers = [];

  bool _isArabicText(String text) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text);
  }

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

List<InlineSpan> _buildSpans(String text, double fontSize) {
  for (final r in _recognizers) r.dispose();
  _recognizers.clear();

  // ✅ regex للـ URLs والـ emails معاً
  final urlRegex = RegExp(
    r'https?://[^\s]+|[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}',
    caseSensitive: false,
  );

  final spans = <InlineSpan>[];
  int lastEnd = 0;

  for (final match in urlRegex.allMatches(text)) {
    if (match.start > lastEnd) {
      spans.add(TextSpan(
        text: text.substring(lastEnd, match.start),
        style: TextStyle(
          fontSize: fontSize,
          color: AppColors.kRedColor,
          fontWeight: FontWeight.w500,
        ),
      ));
    }

    final matched = match.group(0)!;
    // ✅ حدد نوع الـ match
    final isEmail = matched.contains('@') && !matched.startsWith('http');
    final recognizer = TapGestureRecognizer()
      ..onTap = () => _launchUrl(isEmail ? 'mailto:$matched' : matched);
    _recognizers.add(recognizer);

    spans.add(TextSpan(
      text: matched,
      style: TextStyle(
        fontSize: fontSize,
        color: Colors.blue,
        decoration: TextDecoration.underline,
        decorationColor: Colors.blue,
        fontWeight: FontWeight.w500,
      ),
      recognizer: recognizer,
    ));

    lastEnd = match.end;
  }

  if (lastEnd < text.length) {
    spans.add(TextSpan(
      text: text.substring(lastEnd),
      style: TextStyle(
        fontSize: fontSize,
        color: AppColors.kRedColor,
        fontWeight: FontWeight.w500,
      ),
    ));
  }

  if (spans.isEmpty) {
    spans.add(TextSpan(
      text: text,
      style: TextStyle(
        fontSize: fontSize,
        color: AppColors.kRedColor,
        fontWeight: FontWeight.w500,
      ),
    ));
  }

  return spans;
}
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final bool arabic = _isArabicText(widget.content);
    final double fontSize = isMobile ? 13 : 14;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 8 : 12,
        horizontal: isMobile ? 16 : 24,
      ),
      child: Row(
        mainAxisAlignment:
            arabic ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: screenSize.width * 0.78),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 8 : 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Directionality(
                textDirection: arabic ? TextDirection.rtl : TextDirection.ltr,
                child: RichText(
                  textAlign: arabic ? TextAlign.right : TextAlign.left,
                  text: TextSpan(
                    children: _buildSpans(widget.content, fontSize),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
