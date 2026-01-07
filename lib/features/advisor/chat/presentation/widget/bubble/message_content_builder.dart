import 'package:flutter/material.dart';
import '../media/image_message_widget.dart';
import '../media/video_message_widget.dart';
import '../media/audio_message_widget.dart';

class MessageContentBuilder extends StatelessWidget {
  final String messageType;
  final List<String> contentList;
  final Color textColor;
  final double fontSize;
  final double maxWidth;

  const MessageContentBuilder({
    super.key,
    required this.messageType,
    required this.contentList,
    required this.textColor,
    required this.fontSize,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    switch (messageType) {
      case 'image':
        return ImageMessageWidget(
          images: contentList,
          maxWidth: maxWidth,
          onImageTap: (index) => _openImageViewer(context, index),
        );

      case 'video':
        if (contentList.length == 1) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: VideoMessageWidget(
              videoUrl: contentList.first,
              maxWidth: maxWidth - 24,
            ),
          );
        } else {
          return _buildVideoGrid();
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

  void _openImageViewer(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            FullScreenImageViewer(images: contentList, initialIndex: index),
      ),
    );
  }

  Widget _buildVideoGrid() {
    final gridWidth = maxWidth - 8;
    const spacing = 4.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: gridWidth,
        child: Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: contentList.take(4).map((videoUrl) {
            return SizedBox(
              width: contentList.length == 1
                  ? gridWidth
                  : (gridWidth - spacing) / 2,
              height: 120,
              child: VideoMessageWidget(
                videoUrl: videoUrl,
                maxWidth: contentList.length == 1
                    ? gridWidth
                    : (gridWidth - spacing) / 2,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
