import 'package:flutter/material.dart';
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

  const MessageContentBuilder({
    super.key,
    required this.messageType,
    required this.contentList,
    this.localFilePaths,
    required this.textColor,
    required this.fontSize,
    required this.maxWidth,
    this.uploadProgress,
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

        return Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: isAllEmojis ? fontSize * 1.7 : fontSize,
            fontFamily: 'Cairo',
            height: 1.4,
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
