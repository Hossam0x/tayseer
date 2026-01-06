import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tayseer/core/utils/helper/picker_helper.dart';
import 'package:tayseer/core/widgets/pick_image_bottom_sheet.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/my_import.dart';

class ConversationInputArea extends StatefulWidget {
  final String sendMessageIcon;
  final String chatEmojiIcon;
  final String cameraIcon;
  final Function(String message)? onSendMessage;
  final Function(List<File> files, String messageType)? onSendMedia;
  final VoidCallback? onTypingStart; // ✅ جديد
  final VoidCallback? onTypingStop; // ✅ جديد
  final ChatMessage? replyingToMessage; // ✅ الرسالة اللي بنرد عليها
  final VoidCallback? onCancelReply; // ✅ إلغاء الرد

  const ConversationInputArea({
    super.key,
    required this.sendMessageIcon,
    required this.chatEmojiIcon,
    required this.cameraIcon,
    this.onSendMessage,
    this.onSendMedia,
    this.onTypingStart, // ✅ جديد
    this.onTypingStop, // ✅ جديد
    this.replyingToMessage,
    this.onCancelReply,
  });

  @override
  State<ConversationInputArea> createState() => _ConversationInputAreaState();
}

class _ConversationInputAreaState extends State<ConversationInputArea> {
  late TextEditingController _messageController;
  Timer? _typingTimer;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _messageController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _typingTimer?.cancel();

    // لو كان بيكتب وخرج من الشاشة، نبعت stop
    if (_isTyping) {
      widget.onTypingStop?.call();
    }
    super.dispose();
  }

  void _onTextChanged() {
    final text = _messageController.text;

    if (text.isNotEmpty) {
      // لو مكانش بيكتب، نبعت typing_start
      if (!_isTyping) {
        _isTyping = true;
        widget.onTypingStart?.call();
        log('⌨️ Started typing...');
      }

      // إلغاء التايمر السابق
      _typingTimer?.cancel();

      // تايمر جديد - لو مكتبش حاجة لمدة 2 ثانية، نعتبره وقف
      _typingTimer = Timer(const Duration(seconds: 2), () {
        if (_isTyping) {
          _isTyping = false;
          widget.onTypingStop?.call();
          log('⌨️ Stopped typing (timeout)');
        }
      });
    } else {
      // لو النص فاضي ووقف، نبعت stop
      if (_isTyping) {
        _isTyping = false;
        _typingTimer?.cancel();
        widget.onTypingStop?.call();
        log('⌨️ Stopped typing (empty text)');
      }
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty && widget.onSendMessage != null) {
      // وقف الـ typing قبل الإرسال
      if (_isTyping) {
        _isTyping = false;
        _typingTimer?.cancel();
        widget.onTypingStop?.call();
      }

      widget.onSendMessage!(message);
      _messageController.clear();
    }
  }

  void _openGallerySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomGallerySheet(
        config: const PickerConfig(
          allowMultiple: true,
          maxCount: 10,
          requestType: RequestType.common,
        ),
        onMediaSelected: (list) {
          if (list.isEmpty) return;

          final List<File> imageFiles = [];
          final List<File> videoFiles = [];

          for (var item in list) {
            if (item.type == AssetType.video) {
              log('Video selected: ${item.file.path}');
              videoFiles.add(item.file);
            } else if (item.type == AssetType.image) {
              log('Image selected: ${item.file.path}');
              imageFiles.add(item.file);
            }
          }

          if (imageFiles.isNotEmpty && widget.onSendMedia != null) {
            widget.onSendMedia!(imageFiles, 'image');
          }

          if (videoFiles.isNotEmpty && widget.onSendMedia != null) {
            widget.onSendMedia!(videoFiles, 'video');
          }
        },
      ),
    );
  }

  /// ✅ بناء ويدجت معاينة الرد
  Widget _buildReplyPreview() {
    final replyMessage = widget.replyingToMessage;
    if (replyMessage == null) return const SizedBox.shrink();

    final isMediaMessage =
        replyMessage.messageType == 'image' ||
        replyMessage.messageType == 'video';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9EEFA),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      child: Row(
        children: [
          // ✅ خط عمودي للدلالة على الرد
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFD84D65),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),

          // ✅ المحتوى
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'رد على ${replyMessage.senderName}',
                  style: const TextStyle(
                    color: Color(0xFFD84D65),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 2),
                if (isMediaMessage)
                  Row(
                    children: [
                      Icon(
                        replyMessage.messageType == 'image'
                            ? Icons.image
                            : Icons.videocam,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        replyMessage.messageType == 'image' ? 'صورة' : 'فيديو',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    replyMessage.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontFamily: 'Cairo',
                    ),
                  ),
              ],
            ),
          ),

          // ✅ صورة مصغرة للميديا
          if (isMediaMessage && replyMessage.contentList.isNotEmpty)
            Container(
              width: 45,
              height: 45,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[300],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: replyMessage.contentList.first,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, size: 20),
                    ),
                  ),
                  if (replyMessage.messageType == 'video')
                    Container(
                      color: Colors.black26,
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_outline,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // ✅ زر الإلغاء
          IconButton(
            onPressed: widget.onCancelReply,
            icon: const Icon(Icons.close, color: Colors.grey, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final paddingH = isMobile ? 12.0 : 14.0;
    final paddingV = isMobile ? 10.0 : 12.0;
    final spacing1 = isMobile ? 8.0 : 10.0;
    final spacing2 = isMobile ? 5.0 : 6.0;
    final spacing3 = isMobile ? 4.0 : 6.0;
    final spacing4 = isMobile ? 6.0 : 8.0;
    final iconSize = isMobile ? 24.0 : 28.0;
    final attachIconSize = isMobile ? 16.0 : 18.0;
    final inputFontSize = isMobile ? 11.0 : 12.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ✅ معاينة الرد
        _buildReplyPreview(),

        // ✅ منطقة الإدخال
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: paddingH,
            vertical: paddingV,
          ),
          color: const Color(0xFFF9EEFA),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: [
                GestureDetector(
                  onTap: _sendMessage,
                  child: SvgPicture.asset(
                    widget.sendMessageIcon,
                    width: iconSize,
                    height: iconSize,
                  ),
                ),
                SizedBox(width: spacing1),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: spacing2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: spacing2),
                        GestureDetector(
                          onTap: () {},
                          child: Icon(
                            Icons.attach_file,
                            color: Colors.grey,
                            size: attachIconSize,
                          ),
                        ),
                        SizedBox(width: spacing3),
                        GestureDetector(
                          onTap: () {},
                          child: SvgPicture.asset(
                            widget.chatEmojiIcon,
                            width: attachIconSize,
                            height: attachIconSize,
                          ),
                        ),
                        SizedBox(width: spacing3),
                        GestureDetector(
                          onTap: _openGallerySheet,
                          child: SvgPicture.asset(
                            widget.cameraIcon,
                            width: attachIconSize,
                            height: attachIconSize,
                          ),
                        ),
                        SizedBox(width: spacing3),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            onSubmitted: (_) => _sendMessage(),
                            decoration: InputDecoration(
                              hintText: "نص الرسالة",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: inputFontSize,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: spacing4,
                              ),
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
