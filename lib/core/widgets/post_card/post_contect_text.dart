import 'package:tayseer/core/services/post_translation_service.dart';
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

  // Translation state
  bool _isTranslating = false;
  bool _isTranslated = false;
  String? _translatedText;

  late final int _maxLines = widget.maxLines ?? 3;

  String get _displayText =>
      _isTranslated && _translatedText != null ? _translatedText! : widget.text;

  Future<void> _handleTranslateTap() async {
    // If already translated → toggle back to original
    if (_isTranslated) {
      setState(() => _isTranslated = false);
      return;
    }

    // Get current app language
    final locale = Localizations.localeOf(context);
    final targetLang = locale.languageCode; // 'ar' or 'en'

    setState(() => _isTranslating = true);

    final result = await PostTranslationService().translate(
      widget.text,
      targetLang,
    );

    if (!mounted) return;

    setState(() {
      _isTranslating = false;
      _translatedText = result;
      _isTranslated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(
          text: _displayText,
          style: widget.style ?? Styles.textStyle14,
        );

        final tp = TextPainter(
          text: span,
          maxLines: _maxLines,
          textDirection: TextDirection.rtl,
        );

        tp.layout(maxWidth: constraints.maxWidth);

        final bool exceedsMaxLines = tp.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Text body ──
            SocialTextParser(
              text: _displayText,
              style: widget.style,
              hashtagStyle: widget.hashtagStyle,
              parseMentions: false,
              maxLines: exceedsMaxLines && !_isExpanded ? _maxLines : null,
              overflow: exceedsMaxLines && !_isExpanded
                  ? TextOverflow.ellipsis
                  : TextOverflow.visible,
            ),

            // ── See more / See less ──
            if (exceedsMaxLines) ...[
              Gap(context.responsiveHeight(4)),
              GestureDetector(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Text(
                  _isExpanded ? context.tr("see_less") : context.tr("see_more"),
                  style: Styles.textStyle14.copyWith(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],

            // ── Translate button ──
            Gap(context.responsiveHeight(6)),
            GestureDetector(
              onTap: _isTranslating ? null : _handleTranslateTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isTranslating)
                    SizedBox(
                      width: 12.sp,
                      height: 12.sp,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: AppColors.kprimaryColor,
                      ),
                    )
                  else
                    Icon(
                      Icons.translate_rounded,
                      size: 14.sp,
                      color: AppColors.kprimaryColor,
                    ),
                  Gap(4.w),
                  Text(
                    _isTranslating
                        ? context.tr("translating")
                        : _isTranslated
                        ? context.tr("show_original")
                        : context.tr("translate"),
                    style: Styles.textStyle12SemiBold.copyWith(
                      color: AppColors.kprimaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
