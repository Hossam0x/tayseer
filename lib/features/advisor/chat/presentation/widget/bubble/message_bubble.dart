import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tayseer/core/enum/message_status_enum.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/message_model.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/presentation/theme/chat_theme.dart';
import 'reply_preview_bubble.dart';
import 'message_time_status.dart';
import 'message_content_builder.dart';

class MessageBubble extends StatelessWidget {
  final Message? oldMessage;
  final ChatMessage? chatMessage;
  final bool isOverlay;
  final bool isHighlighted;
  final Function(String? replyMessageId)? onReplyTap;

  const MessageBubble({
    super.key,
    this.oldMessage,
    this.chatMessage,
    this.isOverlay = false,
    this.isHighlighted = false,
    this.onReplyTap,
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

  @override
  Widget build(BuildContext context) {
    final bool isMe = chatMessage?.isMe ?? oldMessage?.isMe ?? false;
    final List<String> contentList =
        chatMessage?.contentList ??
        (oldMessage?.text != null ? [oldMessage!.text] : []);
    final String time = chatMessage?.createdAt ?? oldMessage?.time ?? '';
    final MessageStatusEnum status =
        chatMessage?.status ?? MessageStatusEnum.sent;
    final String messageType = chatMessage?.messageType ?? 'text';
    final ReplyInfo? reply = chatMessage?.reply;

    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 1200;

    final bgColor = isMe ? ChatColors.bubbleSender : ChatColors.bubbleReceiver;
    final textColor = isMe ? ChatColors.textSender : ChatColors.textReceiver;

    double maxWidth = isMobile
        ? ChatDimensions.bubbleMaxWidthMobile
        : (isTablet
              ? ChatDimensions.bubbleMaxWidthTablet
              : ChatDimensions.bubbleMaxWidthDesktop);
    maxWidth = screenSize.width * ChatDimensions.bubbleWidthRatio > maxWidth
        ? maxWidth
        : screenSize.width * ChatDimensions.bubbleWidthRatio;

    final paddingH = isMobile
        ? ChatDimensions.paddingHorizontalMobile
        : ChatDimensions.paddingHorizontalTablet;
    final paddingV = isMobile
        ? ChatDimensions.paddingVerticalMobile
        : ChatDimensions.paddingVerticalTablet;
    final fontSize = isMobile
        ? ChatDimensions.fontSizeMobile
        : ChatDimensions.fontSizeTablet;
    final spacingV = isMobile ? 6.0 : 8.0;

    final bool isMediaMessage =
        messageType == 'image' || messageType == 'video';

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
          AnimatedContainer(
            duration: ChatAnimations.messageEntryDuration,
            decoration: BoxDecoration(
              color: isHighlighted
                  ? ChatColors.highlightColor
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
                  topLeft: isMe
                      ? const Radius.circular(ChatDimensions.bubbleRadiusLarge)
                      : Radius.zero,
                  topRight: isMe
                      ? Radius.zero
                      : const Radius.circular(ChatDimensions.bubbleRadiusLarge),
                  bottomRight: const Radius.circular(
                    ChatDimensions.bubbleRadiusLarge,
                  ),
                  bottomLeft: const Radius.circular(
                    ChatDimensions.bubbleRadiusLarge,
                  ),
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
                  if (hasReply)
                    ReplyPreviewBubble(
                      replyMessage: reply.replyMessage!,
                      replyMessageId: reply.replyMessageId,
                      isMe: isMe,
                      maxWidth: maxWidth,
                      onTap: () {
                        if (reply.replyMessageId != null) {
                          onReplyTap?.call(reply.replyMessageId);
                        }
                      },
                    ),
                  if (isMediaMessage && hasReply)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          ChatDimensions.bubbleRadiusSmall,
                        ),
                        child: MessageContentBuilder(
                          messageType: messageType,
                          contentList: contentList,
                          localFilePaths:
                              chatMessage?.localFilePaths, // ✅ Pass local paths
                          textColor: textColor,
                          fontSize: fontSize,
                          maxWidth: maxWidth - paddingH * 2,
                        ),
                      ),
                    )
                  else
                    MessageContentBuilder(
                      messageType: messageType,
                      contentList: contentList,
                      localFilePaths:
                          chatMessage?.localFilePaths, // ✅ Pass local paths
                      textColor: textColor,
                      fontSize: fontSize,
                      maxWidth: maxWidth,
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: spacingV),
          MessageTimeStatus(
            formattedTime: _formatTime(time),
            isMe: isMe,
            status: status,
            isOverlay: isOverlay,
            isMobile: isMobile,
          ),
          SizedBox(height: spacingV),
        ],
      ),
    );
  }
}
