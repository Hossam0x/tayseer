import 'package:tayseer/core/widgets/social_text_parser.dart';
import 'package:tayseer/my_import.dart';

class PostContentText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextStyle? hashtagStyle;
  final Function(String)? onHashtagTap;
  final int? maxLines;

  const PostContentText({
    super.key,
    required this.text,
    this.style,
    this.hashtagStyle,
    this.onHashtagTap,
    this.maxLines,
  });

  @override
  State<PostContentText> createState() => _PostContentTextState();
}

class _PostContentTextState extends State<PostContentText> {
  bool _isExpanded = false;

  late final int _maxLines = widget.maxLines ?? 3;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(
          text: widget.text,
          style: widget.style ?? Styles.textStyle14,
        );

        final tp = TextPainter(
          text: span,
          maxLines: _maxLines,
          textDirection: TextDirection.rtl,
        );

        tp.layout(maxWidth: constraints.maxWidth);

        if (!tp.didExceedMaxLines) {
          return SocialTextParser(
            text: widget.text,
            style: widget.style,
            hashtagStyle: widget.hashtagStyle,
            parseMentions: false,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SocialTextParser(
              text: widget.text,
              style: widget.style,
              hashtagStyle: widget.hashtagStyle,
              parseMentions: false,
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
                  color: Colors.grey,
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
