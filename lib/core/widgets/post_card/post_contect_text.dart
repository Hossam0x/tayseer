import 'package:tayseer/core/widgets/auto_direction_hashtag_text.dart';
import 'package:tayseer/my_import.dart';

class PostContentText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextStyle? hashtagStyle;
  final Function(String)? onHashtagTap;

  const PostContentText({
    super.key,
    required this.text,
    this.style,
    this.hashtagStyle,
    this.onHashtagTap,
  });

  @override
  State<PostContentText> createState() => _PostContentTextState();
}

class _PostContentTextState extends State<PostContentText> {
  bool _isExpanded = false;
  static const int _maxLines = 3; // عدد السطور قبل "عرض المزيد"

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 1. حساب هل النص يتجاوز عدد السطور المسموح به أم لا
        final span = TextSpan(
          text: widget.text,
          style: widget.style ?? Styles.textStyle14,
        );

        final tp = TextPainter(
          text: span,
          maxLines: _maxLines,
          textDirection: TextDirection.rtl, // أو حسب لغة التطبيق
        );

        tp.layout(maxWidth: constraints.maxWidth);

        // 2. إذا كان النص لا يتجاوز الحد، اعرضه عادي
        if (!tp.didExceedMaxLines) {
          return AutoDirectionHashtagText(
            text: widget.text,
            style: widget.style,
            hashtagStyle: widget.hashtagStyle,
            onHashtagTap: widget.onHashtagTap,
          );
        }

        // 3. إذا كان النص طويل، اعرض النص (مقطوع أو كامل) + الزر
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoDirectionHashtagText(
              text: widget.text,
              style: widget.style,
              hashtagStyle: widget.hashtagStyle,
              onHashtagTap: widget.onHashtagTap,
              // لازم تتأكد إن AutoDirectionHashtagText بتقبل المتغيرين دول
              maxLines: _isExpanded ? null : _maxLines,
              overflow: _isExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
            ),

            Gap(context.responsiveHeight(4)),

            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Text(
                _isExpanded ? context.tr("see_less") : context.tr("see_more"),
                style: Styles.textStyle14.copyWith(
                  color: Colors.grey, // لون رمادي زي فيسبوك
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
