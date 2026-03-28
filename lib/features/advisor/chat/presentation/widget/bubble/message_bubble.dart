import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tayseer/core/enum/message_status_enum.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/message_model.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/presentation/theme/chat_theme.dart';
import 'package:tayseer/my_import.dart';
import 'reply_preview_bubble.dart';
import 'message_time_status.dart';
import 'message_content_builder.dart';
import 'emoji_helper.dart';
import '../conversation/message_reactions_display.dart';

class MessageBubble extends StatefulWidget {
  final Message? oldMessage;
  final ChatMessage? chatMessage;
  final bool isOverlay;
  final bool isHighlighted;
  final Function(String? replyMessageId)? onReplyTap;
  final Function(String emoji)? onReactionTap;

  const MessageBubble({
    super.key,
    this.oldMessage,
    this.chatMessage,
    this.isOverlay = false,
    this.isHighlighted = false,
    this.onReplyTap,
    this.onReactionTap,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _isExpanded = false;
  static const int _maxLines = 10;

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

  bool _isTextExceedsMaxLines(String text, double maxWidth, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: _maxLines,
      textDirection: ui.TextDirection.rtl,
    );
    textPainter.layout(maxWidth: maxWidth);
    return textPainter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    final bool isMe =
        widget.chatMessage?.isMe ?? widget.oldMessage?.isMe ?? false;
    final List<String> contentList =
        widget.chatMessage?.contentList ??
        (widget.oldMessage?.text != null ? [widget.oldMessage!.text] : []);
    final String time =
        widget.chatMessage?.createdAt ?? widget.oldMessage?.time ?? '';
    final MessageStatusEnum status =
        widget.chatMessage?.status ?? MessageStatusEnum.sent;
    final String messageType = widget.chatMessage?.messageType ?? 'text';
    final ReplyInfo? reply = widget.chatMessage?.reply;

    final bgColor = isMe ? ChatColors.bubbleSender : ChatColors.bubbleReceiver;
    final textColor = isMe ? ChatColors.textSender : ChatColors.textReceiver;

    final bool isMediaMessage =
        messageType == 'image' || messageType == 'video';

    final bool hasReply =
        reply?.isReply == true &&
        reply?.replyMessage != null &&
        reply!.replyMessage!.isNotEmpty;

    final String fullText = contentList.join('\n');
    final bool isTextMessage = messageType == 'text';
    final bool isSingleEmoji =
        isTextMessage && EmojiHelper.isSingleEmoji(fullText);
    final textStyle = TextStyle(color: textColor, fontSize: 14.sp, height: 1.4);
    final double maxBubbleWidth = 260.w;
    final double contentMaxWidth = maxBubbleWidth - 24.w;
    final bool needsExpansion =
        isTextMessage &&
        !_isExpanded &&
        _isTextExceedsMaxLines(fullText, contentMaxWidth, textStyle);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: ChatAnimations.messageEntryDuration,
                  decoration: BoxDecoration(
                    color: widget.isHighlighted
                        ? ChatColors.highlightColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  padding: widget.isHighlighted
                      ? EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h)
                      : EdgeInsets.zero,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: maxBubbleWidth),
                    padding: isSingleEmoji
                        ? EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h)
                        : (isMediaMessage && !hasReply
                              ? EdgeInsets.all(4.r)
                              : EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 10.h,
                                )),
                    decoration: isSingleEmoji
                        ? null
                        : BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.only(
                              topLeft: isMe
                                  ? Radius.circular(
                                      ChatDimensions.bubbleRadiusLarge,
                                    )
                                  : Radius.zero,
                              topRight: isMe
                                  ? Radius.zero
                                  : Radius.circular(
                                      ChatDimensions.bubbleRadiusLarge,
                                    ),
                              bottomRight: Radius.circular(
                                ChatDimensions.bubbleRadiusLarge,
                              ),
                              bottomLeft: Radius.circular(
                                ChatDimensions.bubbleRadiusLarge,
                              ),
                            ),
                            border: Border(
                              bottom: BorderSide(
                                color: isMe ? Colors.black12 : Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            boxShadow: widget.isOverlay
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
                        // ====== الرد ======
                        if (hasReply)
                          ReplyPreviewBubble(
                            replyMessage: reply.replyMessage!,
                            replyMessageId: reply.replyMessageId,
                            isMe: isMe,
                            maxWidth: maxBubbleWidth,
                            onTap: () {
                              if (reply.replyMessageId != null) {
                                widget.onReplyTap?.call(reply.replyMessageId);
                              }
                            },
                          ),

                        // ====== محتوى الرسالة ======
                        if (isMediaMessage && hasReply)
                          Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                ChatDimensions.bubbleRadiusSmall,
                              ),
                              child: MessageContentBuilder(
                                messageType: messageType,
                                contentList: contentList,
                                localFilePaths: widget.chatMessage?.localFilePaths,
                                uploadProgress: widget.chatMessage?.uploadProgress,
                                textColor: textColor,
                                fontSize: 14.sp,
                                maxWidth: 236.w,
                              ),
                            ),
                          )
                        else if (needsExpansion)
                          // ✅ رسالة نصية طويلة - عرض مقتطع مع "عرض المزيد"
                          _buildCollapsedText(
                            fullText: fullText,
                            textStyle: textStyle,
                            textColor: textColor,
                            isMe: isMe,
                            maxWidth: contentMaxWidth,
                          )
                        else
                          MessageContentBuilder(
                            messageType: messageType,
                            contentList: contentList,
                            localFilePaths: widget.chatMessage?.localFilePaths,
                            uploadProgress: widget.chatMessage?.uploadProgress,
                            textColor: textColor,
                            fontSize: 14.sp,
                            maxWidth: maxBubbleWidth,
                          ),

                        SizedBox(height: 4.h),
                        // ✅ لو النص مفتوح وطويل - زر "عرض أقل"
                        if (isTextMessage &&
                            _isExpanded &&
                            _isTextExceedsMaxLines(
                              fullText,
                              contentMaxWidth,
                              textStyle,
                            ))
                          _buildShowLessButton(isMe),

                        Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: isSingleEmoji
                              ? Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: MessageTimeStatus(
                                    formattedTime: _formatTime(time),
                                    isMe: isMe,
                                    status: status,
                                    isOverlay: widget.isOverlay,
                                  ),
                                )
                              : MessageTimeStatus(
                                  formattedTime: _formatTime(time),
                                  isMe: isMe,
                                  status: status,
                                  isOverlay: widget.isOverlay,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                // ✅ عرض الـ reactions تحت البابل مباشرة
                if (widget.chatMessage != null &&
                    widget.chatMessage!.reactions.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: MessageReactionsDisplay(
                      reactions: widget.chatMessage!.reactions,
                      currentUserId: kCurrentUserData?.id ?? '',
                      onReactionTap: (emoji) {
                        if (widget.onReactionTap != null) {
                          widget.onReactionTap!(emoji);
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 6.h),
        ],
      ),
    );
  }

  /// ✅ النص المقتطع مع "عرض المزيد" - بدون LayoutBuilder
  Widget _buildCollapsedText({
    required String fullText,
    required TextStyle textStyle,
    required Color textColor,
    required bool isMe,
    required double maxWidth,
  }) {
    final showMoreText = ' عرض المزيد';
    final showMoreStyle = TextStyle(
      color: isMe ? Colors.white70 : ChatColors.bubbleSender,
      fontSize: 13.sp,
      fontWeight: FontWeight.bold,
      height: 1.4,
    );

    // حساب عرض "عرض المزيد"
    final showMoreSpanPainter = TextPainter(
      text: TextSpan(text: showMoreText, style: showMoreStyle),
      textDirection: ui.TextDirection.rtl,
    );
    showMoreSpanPainter.layout();
    final showMoreWidth = showMoreSpanPainter.width + 8;

    // حساب النص اللي يتقطع عنده
    final textPainter = TextPainter(
      text: TextSpan(text: fullText, style: textStyle),
      maxLines: _maxLines,
      textDirection: ui.TextDirection.rtl,
    );
    textPainter.layout(maxWidth: maxWidth);

    // الحصول على موضع نهاية السطر العاشر
    final endOfLastLine = textPainter
        .getPositionForOffset(Offset(showMoreWidth, textPainter.height))
        .offset;

    // قطع النص مع ترك مساحة لـ "عرض المزيد"
    final truncatedText = fullText.substring(
      0,
      endOfLastLine.clamp(0, fullText.length),
    );

    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = true;
        });
      },
      child: RichText(
        textDirection: ui.TextDirection.rtl,
        text: TextSpan(
          children: [
            TextSpan(text: '$truncatedText...', style: textStyle),
            TextSpan(text: showMoreText, style: showMoreStyle),
          ],
        ),
      ),
    );
  }

  /// ✅ زر "عرض أقل"
  Widget _buildShowLessButton(bool isMe) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = false;
          });
        },
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            'عرض أقل',
            style: TextStyle(
              color: isMe ? Colors.white70 : ChatColors.bubbleSender,
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
