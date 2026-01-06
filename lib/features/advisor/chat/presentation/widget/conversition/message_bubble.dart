import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/message_model.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:video_player/video_player.dart';

class MessageBubble extends StatelessWidget {
  final Message? oldMessage;
  final ChatMessage? chatMessage;
  final String readMessageIcon;
  final bool isOverlay;
  final bool isHighlighted; // ✅ جديد - للـ highlight
  final Function(String? replyMessageId)?
  onReplyTap; // ✅ جديد - callback للضغط على الرد

  const MessageBubble({
    super.key,
    this.oldMessage,
    this.chatMessage,
    required this.readMessageIcon,
    this.isOverlay = false,
    this.isHighlighted = false, // ✅ جديد
    this.onReplyTap, // ✅ جديد
  });

  String _formatTime(String timeString) {
    try {
      final dateTime = DateTime.parse(timeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        return DateFormat('h:mm a', 'ar').format(dateTime);
      } else if (difference.inDays == 1) {
        return 'أمس';
      } else if (difference.inDays < 7) {
        return DateFormat('EEEE', 'ar').format(dateTime);
      } else {
        return DateFormat('d/M/yyyy', 'ar').format(dateTime);
      }
    } catch (e) {
      return timeString;
    }
  }

  Widget _buildMessageContent({
    required String messageType,
    required List<String> contentList,
    required Color textColor,
    required double fontSize,
    required double maxWidth,
    required BuildContext context,
  }) {
    switch (messageType) {
      case 'image':
        if (contentList.length == 1) {
          return GestureDetector(
            onTap: () => _openImageViewer(context, contentList, 0),
            child: _buildSingleImage(contentList.first, maxWidth),
          );
        } else {
          return GestureDetector(
            onTap: () => _openImageViewer(context, contentList, 0),
            child: _buildImageGrid(contentList, maxWidth, context),
          );
        }

      case 'video':
        if (contentList.length == 1) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _VideoMessageWidget(
              videoUrl: contentList.first,
              maxWidth: maxWidth - 24,
            ),
          );
        } else {
          return _buildVideoGrid(contentList, maxWidth);
        }

      case 'audio':
        return _AudioMessageWidget(
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
    List<String> images,
    int initialIndex,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            _FullScreenImageViewer(images: images, initialIndex: initialIndex),
      ),
    );
  }

  Widget _buildSingleImage(String imageUrl, double maxWidth) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: maxWidth - 8,
        fit: BoxFit.contain,
        placeholder: (context, url) => Container(
          width: maxWidth - 8,
          height: 200,
          color: Colors.grey[300],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          width: maxWidth - 8,
          height: 200,
          color: Colors.grey[300],
          child: const Icon(Icons.error, color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildImageGrid(
    List<String> images,
    double maxWidth,
    BuildContext context,
  ) {
    final imageCount = images.length;
    final gridWidth = maxWidth - 8;
    final spacing = 4.0;

    if (imageCount == 2) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: gridWidth,
          height: 150,
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _openImageViewer(context, images, 0),
                  child: _gridImage(images[0], height: 150),
                ),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: GestureDetector(
                  onTap: () => _openImageViewer(context, images, 1),
                  child: _gridImage(images[1], height: 150),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (imageCount == 3) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: gridWidth,
          height: 200,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () => _openImageViewer(context, images, 0),
                  child: _gridImage(images[0], height: 200),
                ),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _openImageViewer(context, images, 1),
                        child: _gridImage(images[1]),
                      ),
                    ),
                    SizedBox(height: spacing),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _openImageViewer(context, images, 2),
                        child: _gridImage(images[2]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: gridWidth,
          height: 200,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _openImageViewer(context, images, 0),
                        child: _gridImage(images[0]),
                      ),
                    ),
                    SizedBox(height: spacing),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _openImageViewer(context, images, 2),
                        child: _gridImage(images[2]),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _openImageViewer(context, images, 1),
                        child: _gridImage(images[1]),
                      ),
                    ),
                    SizedBox(height: spacing),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _openImageViewer(context, images, 3),
                        child: imageCount > 4
                            ? _gridImageWithOverlay(images[3], imageCount - 4)
                            : _gridImage(images[3]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _gridImage(String url, {double? height}) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      height: height,
      width: double.infinity,
      placeholder: (context, url) => Container(
        color: Colors.grey[300],
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: const Icon(Icons.error, color: Colors.red, size: 20),
      ),
    );
  }

  Widget _gridImageWithOverlay(String url, int remainingCount) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _gridImage(url),
        Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: Text(
              '+$remainingCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoGrid(List<String> videos, double maxWidth) {
    final gridWidth = maxWidth - 8;
    final spacing = 4.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: gridWidth,
        child: Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: videos.take(4).map((videoUrl) {
            return SizedBox(
              width: videos.length == 1 ? gridWidth : (gridWidth - spacing) / 2,
              height: 120,
              child: _VideoMessageWidget(
                videoUrl: videoUrl,
                maxWidth: videos.length == 1
                    ? gridWidth
                    : (gridWidth - spacing) / 2,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// ✅ بناء معاينة الرسالة الأصلية اللي بنرد عليها - مع إمكانية الضغط
  Widget _buildReplyPreview({
    required String replyMessage,
    required String? replyMessageId,
    required bool isMe,
    required double maxWidth,
    required BuildContext context,
  }) {
    final bool isImageReply = _isImageUrl(replyMessage);
    final bool isVideoReply = _isVideoUrl(replyMessage);
    final bool isMediaReply = isImageReply || isVideoReply;

    return GestureDetector(
      // ✅ عند الضغط على الرد، ننتقل للرسالة الأصلية
      onTap: () {
        if (replyMessageId != null && onReplyTap != null) {
          onReplyTap!(replyMessageId);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isMe
              ? Colors.white.withOpacity(0.15)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border(
            right: BorderSide(
              color: isMe ? Colors.white70 : const Color(0xFFD84D65),
              width: 3,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ لو صورة نعرض الصورة مباشرة، لو فيديو نعرض كونتينر أسود
            if (isMediaReply)
              Container(
                width: 45,
                height: 45,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: isVideoReply ? Colors.black : Colors.grey[300],
                ),
                clipBehavior: Clip.antiAlias,
                child: isVideoReply
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
                          child: const Icon(
                            Icons.image,
                            size: 20,
                            color: Colors.grey,
                          ),
                        ),
                      ),
              ),

            // ✅ النص أو نوع الميديا
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'رد على رسالة',
                        style: TextStyle(
                          color: isMe
                              ? Colors.white70
                              : const Color(0xFFD84D65),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(width: 4),
                      // ✅ أيقونة للإشارة أن الضغط سينقلك للرسالة
                      Icon(
                        Icons.arrow_upward_rounded,
                        size: 12,
                        color: isMe ? Colors.white54 : Colors.grey[500],
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  if (isMediaReply)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isImageReply ? Icons.image : Icons.videocam,
                          size: 14,
                          color: isMe ? Colors.white60 : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isImageReply ? 'صورة' : 'فيديو',
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ التحقق إذا كان URL صورة
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

  /// ✅ التحقق إذا كان URL فيديو
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
    // استخدام البيانات من المصدر المناسب
    final bool isMe = chatMessage?.isMe ?? oldMessage?.isMe ?? false;
    final List<String> contentList =
        chatMessage?.contentList ??
        (oldMessage?.text != null ? [oldMessage!.text] : []);
    final String time = chatMessage?.createdAt ?? oldMessage?.time ?? '';
    final bool isRead = chatMessage?.isRead ?? true;
    final String messageType = chatMessage?.messageType ?? 'text';
    final ReplyInfo? reply = chatMessage?.reply;

    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 1200;

    final bgColor = isMe ? const Color(0xFFD84D65) : Colors.white;
    final textColor = isMe ? Colors.white : Colors.black87;
    final timeColor = isOverlay ? Colors.white : Colors.grey;

    // Responsive width calculation
    double maxWidth = isMobile ? 240 : (isTablet ? 320 : 380);
    maxWidth = screenSize.width * 0.72 > maxWidth
        ? maxWidth
        : screenSize.width * 0.72;

    final paddingH = isMobile ? 12.0 : 14.0;
    final paddingV = isMobile ? 8.0 : 10.0;
    final fontSize = isMobile ? 13.0 : 15.0;
    final timeFontSize = isMobile ? 10.0 : 12.0;
    final spacingH = isMobile ? 4.0 : 6.0;
    final spacingV = isMobile ? 6.0 : 8.0;

    // للميديا نزيل قيود الارتفاع
    final bool isMediaMessage =
        messageType == 'image' || messageType == 'video';

    // ✅ هل الرسالة دي رد على رسالة تانية؟
    final bool hasReply =
        reply?.isReply == true &&
        reply?.replyMessage != null &&
        reply!.replyMessage!.isNotEmpty;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          // ✅ Highlight Container
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? const Color(0xFFD84D65).withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: isHighlighted
                ? const EdgeInsets.symmetric(horizontal: 4, vertical: 2)
                : EdgeInsets.zero,
            child: Container(
              padding: isMediaMessage && !hasReply
                  ? const EdgeInsets.all(4)
                  : EdgeInsets.only(
                      top: paddingV,
                      right: paddingH,
                      bottom: paddingV,
                      left: paddingH,
                    ),
              constraints: BoxConstraints(maxWidth: maxWidth),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.only(
                  topLeft: isMe ? const Radius.circular(16) : Radius.zero,
                  topRight: isMe ? Radius.zero : const Radius.circular(16),
                  bottomRight: const Radius.circular(16),
                  bottomLeft: const Radius.circular(16),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: isMe ? Colors.black12 : Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                boxShadow: isOverlay
                    ? [
                        const BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✅ عرض الرسالة الأصلية اللي بنرد عليها
                  if (hasReply)
                    _buildReplyPreview(
                      replyMessage: reply!.replyMessage!,
                      replyMessageId: reply.replyMessageId,
                      isMe: isMe,
                      maxWidth: maxWidth,
                      context: context,
                    ),

                  // ✅ محتوى الرسالة الحالية
                  if (isMediaMessage && hasReply)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildMessageContent(
                          messageType: messageType,
                          contentList: contentList,
                          textColor: textColor,
                          fontSize: fontSize,
                          maxWidth: maxWidth - paddingH * 2,
                          context: context,
                        ),
                      ),
                    )
                  else
                    _buildMessageContent(
                      messageType: messageType,
                      contentList: contentList,
                      textColor: textColor,
                      fontSize: fontSize,
                      maxWidth: maxWidth,
                      context: context,
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: spacingV),

          // ✅ الوقت + علامة القراءة
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ علامة القراءة (فقط لرسائلي)
              if (isMe) ...[
                SvgPicture.asset(
                  readMessageIcon,
                  width: isMobile ? 10 : 14,
                  height: isMobile ? 10 : 14,
                  colorFilter: isRead
                      ? null
                      : const ColorFilter.mode(
                          Color(0xFF9E9E9E),
                          BlendMode.srcIn,
                        ),
                ),
                SizedBox(width: spacingH),
              ],

              // الوقت
              Text(
                _formatTime(time),
                style: TextStyle(
                  color: timeColor,
                  fontSize: timeFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: spacingV),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Video Message Widget
// ═══════════════════════════════════════════════════════════════════════════

class _VideoMessageWidget extends StatefulWidget {
  final String videoUrl;
  final double maxWidth;

  const _VideoMessageWidget({required this.videoUrl, required this.maxWidth});

  @override
  State<_VideoMessageWidget> createState() => _VideoMessageWidgetState();
}

class _VideoMessageWidgetState extends State<_VideoMessageWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    try {
      await _controller.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  void _openFullScreenVideo() {
    _controller.pause();
    setState(() => _isPlaying = false);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullScreenVideoPlayer(videoUrl: widget.videoUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        width: widget.maxWidth,
        height: 150,
        color: Colors.grey[300],
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final aspectRatio = _controller.value.aspectRatio;
    final videoHeight = widget.maxWidth / aspectRatio;
    final clampedHeight = videoHeight.clamp(100.0, 300.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          GestureDetector(
            onTap: _togglePlay,
            child: SizedBox(
              width: widget.maxWidth,
              height: clampedHeight,
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),
          ),
          if (!_isPlaying)
            Positioned.fill(
              child: GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: _openFullScreenVideo,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.fullscreen,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Audio Message Widget
// ═══════════════════════════════════════════════════════════════════════════

class _AudioMessageWidget extends StatefulWidget {
  final String audioUrl;
  final double maxWidth;
  final bool isMe;

  const _AudioMessageWidget({
    required this.audioUrl,
    required this.maxWidth,
    required this.isMe,
  });

  @override
  State<_AudioMessageWidget> createState() => _AudioMessageWidgetState();
}

class _AudioMessageWidgetState extends State<_AudioMessageWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupAudioPlayer();
  }

  Future<void> _setupAudioPlayer() async {
    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() => _duration = duration);
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() => _position = position);
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource(widget.audioUrl));
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.isMe ? Colors.white : const Color(0xFFD84D65);
    final sliderActiveColor = widget.isMe
        ? Colors.white
        : const Color(0xFFD84D65);
    final sliderInactiveColor = widget.isMe ? Colors.white38 : Colors.grey[300];
    final textColor = widget.isMe ? Colors.white70 : Colors.grey;

    return SizedBox(
      width: widget.maxWidth,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: iconColor,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 12,
                    ),
                    trackHeight: 3,
                    activeTrackColor: sliderActiveColor,
                    inactiveTrackColor: sliderInactiveColor,
                    thumbColor: sliderActiveColor,
                  ),
                  child: Slider(
                    min: 0,
                    max: _duration.inMilliseconds.toDouble(),
                    value: _position.inMilliseconds.toDouble().clamp(
                      0,
                      _duration.inMilliseconds.toDouble(),
                    ),
                    onChanged: (value) async {
                      await _audioPlayer.seek(
                        Duration(milliseconds: value.toInt()),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: TextStyle(fontSize: 10, color: textColor),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: TextStyle(fontSize: 10, color: textColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Full Screen Image Viewer
// ═══════════════════════════════════════════════════════════════════════════

class _FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullScreenImageViewer({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: widget.images.length > 1
            ? Text(
                '${_currentIndex + 1} / ${widget.images.length}',
                style: const TextStyle(color: Colors.white),
              )
            : null,
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: widget.images[index],
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.error, color: Colors.red, size: 50),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: widget.images.length > 1
          ? Container(
              height: 80,
              color: Colors.black,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.images.length,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _currentIndex == index
                              ? const Color(0xFFD84D65)
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CachedNetworkImage(
                          imageUrl: widget.images[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: Colors.grey[800]),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[800],
                            child: const Icon(Icons.error, color: Colors.red),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          : null,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Full Screen Video Player
// ═══════════════════════════════════════════════════════════════════════════

class _FullScreenVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const _FullScreenVideoPlayer({required this.videoUrl});

  @override
  State<_FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<_FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    try {
      await _controller.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _controller.play();
        _isPlaying = true;
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }

    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _isPlaying = _controller.value.isPlaying;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _showControls
          ? AppBar(
              backgroundColor: Colors.black,
              iconTheme: const IconThemeData(color: Colors.white),
              elevation: 0,
            )
          : null,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_isInitialized)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            if (_showControls && _isInitialized)
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            if (_showControls && _isInitialized)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: Color(0xFFD84D65),
                          bufferedColor: Colors.white38,
                          backgroundColor: Colors.white24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ValueListenableBuilder(
                            valueListenable: _controller,
                            builder: (context, value, child) {
                              return Text(
                                _formatDuration(value.position),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                          Text(
                            _formatDuration(_controller.value.duration),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
