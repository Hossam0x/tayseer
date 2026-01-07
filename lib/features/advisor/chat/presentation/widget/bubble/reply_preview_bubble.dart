import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tayseer/features/advisor/chat/presentation/theme/chat_theme.dart';

class ReplyPreviewBubble extends StatelessWidget {
  final String replyMessage;
  final String? replyMessageId;
  final bool isMe;
  final double maxWidth;
  final VoidCallback? onTap;

  const ReplyPreviewBubble({
    super.key,
    required this.replyMessage,
    required this.replyMessageId,
    required this.isMe,
    required this.maxWidth,
    this.onTap,
  });

  bool get _isImageReply => _isImageUrl(replyMessage);
  bool get _isVideoReply => _isVideoUrl(replyMessage);
  bool get _isMediaReply => _isImageReply || _isVideoReply;

  bool _isImageUrl(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('.jpg') ||
        lowerUrl.contains('.jpeg') ||
        lowerUrl.contains('.png') ||
        lowerUrl.contains('.gif') ||
        lowerUrl.contains('.webp') ||
        lowerUrl.contains('/image') ||
        lowerUrl.contains('image/');
  }

  bool _isVideoUrl(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('.mp4') ||
        lowerUrl.contains('.mov') ||
        lowerUrl.contains('.avi') ||
        lowerUrl.contains('.mkv') ||
        lowerUrl.contains('.webm') ||
        lowerUrl.contains('/video') ||
        lowerUrl.contains('video/');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isMe
              ? ChatColors.replyBackgroundSender
              : ChatColors.replyBackgroundReceiver,
          borderRadius: BorderRadius.circular(ChatDimensions.bubbleRadiusSmall),
          border: Border(
            right: BorderSide(
              color: isMe
                  ? ChatColors.replyBorderSender
                  : ChatColors.replyBorderReceiver,
              width: ChatDimensions.replyBorderWidth,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isMediaReply) _buildMediaPreview(),
            Expanded(child: _buildTextContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPreview() {
    return Container(
      width: ChatDimensions.mediaPreviewSize,
      height: ChatDimensions.mediaPreviewSize,
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: _isVideoReply ? Colors.black : Colors.grey[300],
      ),
      clipBehavior: Clip.antiAlias,
      child: _isVideoReply
          ? const Center(
              child: Icon(
                Icons.play_circle_outline,
                color: Colors.white,
                size: 24,
              ),
            )
          : CachedNetworkImage(
              imageUrl: replyMessage,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: const Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 20, color: Colors.grey),
              ),
            ),
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'رد على رسالة',
              style: TextStyle(
                color: isMe ? Colors.white70 : ChatColors.bubbleSender,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_upward_rounded,
              size: 12,
              color: isMe ? Colors.white54 : Colors.grey[500],
            ),
          ],
        ),
        const SizedBox(height: 2),
        if (_isMediaReply)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isImageReply ? Icons.image : Icons.videocam,
                size: 14,
                color: isMe ? Colors.white60 : Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                _isImageReply ? 'صورة' : 'فيديو',
                style: TextStyle(
                  color: isMe ? Colors.white60 : Colors.grey[600],
                  fontSize: 11,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          )
        else
          Text(
            replyMessage,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isMe ? Colors.white60 : Colors.grey[600],
              fontSize: 11,
              fontFamily: 'Cairo',
            ),
          ),
      ],
    );
  }
}
