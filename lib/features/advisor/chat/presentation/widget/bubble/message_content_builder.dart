import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../media/image_message_widget.dart';
import '../media/video_message_widget.dart';
import '../media/audio_message_widget.dart';
import 'emoji_helper.dart';

class MessageContentBuilder extends StatelessWidget {
  final String messageType;
  final List<String> contentList;
  final List<String>? localFilePaths;
  final Color textColor;
  final double fontSize;
  final double maxWidth;
  final double? uploadProgress;
  final bool isArabic;
  // ✅ تفعيل اللينكات بس في system chat
  final bool enableLinks;

  const MessageContentBuilder({
    super.key,
    required this.messageType,
    required this.contentList,
    this.localFilePaths,
    required this.textColor,
    required this.fontSize,
    required this.maxWidth,
    this.uploadProgress,
    required this.isArabic,
    this.enableLinks = false,
  });

  @override
  Widget build(BuildContext context) {
    switch (messageType) {
      case 'image':
        return ImageMessageWidget(
          images: contentList,
          localFilePaths: localFilePaths,
          maxWidth: maxWidth,
          uploadProgress: uploadProgress,
          onImageTap: (index) {
            _openImageViewer(
              context,
              index,
              isLocal: localFilePaths != null && localFilePaths!.isNotEmpty,
            );
          },
        );

      case 'video':
        final hasLocalFiles =
            localFilePaths != null && localFilePaths!.isNotEmpty;
        final displayList = hasLocalFiles ? localFilePaths! : contentList;

        if (displayList.isEmpty) return const SizedBox.shrink();

        if (displayList.length == 1) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: VideoMessageWidget(
              videoUrl: displayList.first,
              maxWidth: maxWidth - 24,
              isLocal: hasLocalFiles,
            ),
          );
        } else {
          return _buildVideoGrid(displayList, isLocal: hasLocalFiles);
        }

      case 'audio':
        return AudioMessageWidget(
          audioUrl: contentList.isNotEmpty ? contentList.first : '',
          maxWidth: maxWidth - 24,
          isMe: textColor == Colors.white,
        );

      default:
        final text = contentList.isNotEmpty ? contentList.first : '';

        // Single emoji → large, no text styling
        if (EmojiHelper.isSingleEmoji(text)) {
          return Text(text, style: const TextStyle(fontSize: 50));
        }

        // Multiple emojis only → slightly larger
        final bool isAllEmojis = EmojiHelper.isOnlyEmojis(text);

        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: isAllEmojis
              ? Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: fontSize * 1.7,
                    fontFamily: 'Cairo',
                    height: 1.4,
                  ),
                )
              : enableLinks
                  ? _LinkableText(
                      text: text,
                      textColor: textColor,
                      fontSize: fontSize,
                      isArabic: isArabic,
                    )
                  : Text(
                      text,
                      style: TextStyle(
                        color: textColor,
                        fontSize: fontSize,
                        fontFamily: 'Cairo',
                        height: 1.4,
                      ),
                    ),
        );
    }
  }

  void _openImageViewer(
    BuildContext context,
    int index, {
    bool isLocal = false,
  }) {
    FocusScope.of(context).unfocus();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(
          images: localFilePaths ?? contentList,
          initialIndex: index,
          isLocal: isLocal,
        ),
      ),
    );
  }

  Widget _buildVideoGrid(List<String> list, {required bool isLocal}) {
    final gridWidth = maxWidth - 8;
    const spacing = 4.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: gridWidth,
        child: Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: list.take(4).map((videoPath) {
            return SizedBox(
              width: list.length == 1 ? gridWidth : (gridWidth - spacing) / 2,
              height: 120,
              child: VideoMessageWidget(
                videoUrl: videoPath,
                maxWidth: list.length == 1
                    ? gridWidth
                    : (gridWidth - spacing) / 2,
                isLocal: isLocal,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}


/// Widget لعرض نص مع دعم اللينكات القابلة للضغط
class _LinkableText extends StatefulWidget {
  final String text;
  final Color textColor;
  final double fontSize;
  final bool isArabic;

  const _LinkableText({
    required this.text,
    required this.textColor,
    required this.fontSize,
    required this.isArabic,
  });

  @override
  State<_LinkableText> createState() => _LinkableTextState();
}

class _LinkableTextState extends State<_LinkableText> {
  final List<TapGestureRecognizer> _recognizers = [];

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

  List<InlineSpan> _buildSpans() {
    for (final r in _recognizers) r.dispose();
    _recognizers.clear();

    // ✅ regex للـ URLs والـ emails معاً
    final urlRegex = RegExp(
      r'https?://[^\s]+|[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}',
      caseSensitive: false,
    );

    final spans = <InlineSpan>[];
    int lastEnd = 0;

    for (final match in urlRegex.allMatches(widget.text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: widget.text.substring(lastEnd, match.start),
          style: TextStyle(
            fontSize: widget.fontSize,
            color: widget.textColor,
            fontFamily: 'Cairo',
            height: 1.4,
          ),
        ));
      }

      final matched = match.group(0)!;
      final isEmail = matched.contains('@') && !matched.startsWith('http');
      final recognizer = TapGestureRecognizer()
        ..onTap = () => _launchUrl(isEmail ? 'mailto:$matched' : matched);
      _recognizers.add(recognizer);

      spans.add(TextSpan(
        text: matched,
        style: TextStyle(
          fontSize: widget.fontSize,
          color: Colors.blue,
          decoration: TextDecoration.underline,
          decorationColor: Colors.blue,
          fontFamily: 'Cairo',
          height: 1.4,
        ),
        recognizer: recognizer,
      ));

      lastEnd = match.end;
    }

    if (lastEnd < widget.text.length) {
      spans.add(TextSpan(
        text: widget.text.substring(lastEnd),
        style: TextStyle(
          fontSize: widget.fontSize,
          color: widget.textColor,
          fontFamily: 'Cairo',
          height: 1.4,
        ),
      ));
    }

    if (spans.isEmpty) {
      spans.add(TextSpan(
        text: widget.text,
        style: TextStyle(
          fontSize: widget.fontSize,
          color: widget.textColor,
          fontFamily: 'Cairo',
          height: 1.4,
        ),
      ));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      textDirection: widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
      text: TextSpan(children: _buildSpans()),
    );
  }
}
