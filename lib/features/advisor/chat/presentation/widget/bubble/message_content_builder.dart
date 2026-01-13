import 'package:flutter/material.dart';
import '../media/image_message_widget.dart';
import '../media/video_message_widget.dart';
import '../media/audio_message_widget.dart';

class MessageContentBuilder extends StatelessWidget {
  final String messageType;
  final List<String> contentList;
  final List<String>? localFilePaths; // ✅ New parameter
  final Color textColor;
  final double fontSize;
  final double maxWidth;

  const MessageContentBuilder({
    super.key,
    required this.messageType,
    required this.contentList,
    this.localFilePaths,
    required this.textColor,
    required this.fontSize,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    switch (messageType) {
      case 'image':
        final hasLocalFiles =
            localFilePaths != null && localFilePaths!.isNotEmpty;
        return ImageMessageWidget(
          images: contentList,
          localFilePaths: localFilePaths,
          maxWidth: maxWidth,
          onImageTap: (index) =>
              _openImageViewer(context, index, isLocal: hasLocalFiles),
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
        return Text(
          contentList.isNotEmpty ? contentList.first : '',
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(
          images: isLocal ? localFilePaths! : contentList,
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
