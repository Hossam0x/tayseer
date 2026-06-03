import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tayseer/core/functions/formate_time.dart';
import 'package:tayseer/core/utils/colors.dart';
import 'package:tayseer/core/utils/extensions/extensions.dart';
import 'package:tayseer/core/utils/styles.dart';
import 'package:tayseer/core/widgets/chat_room_list_item/widgets/chat_room_avatar.dart';
import 'package:tayseer/core/widgets/chat_room_list_item/widgets/chat_room_slidable_actions.dart';

/// Widget موحد لعرض chat room item في القوائم
/// يدعم Archive, Delete, Report, وBlock (اختياري)
class ChatRoomListItem extends StatelessWidget {
  final String id;
  final String title;
  final String subtitle;
  final String? statusText;
  final String? imageUrl;
  final bool isOnline;
  final bool showOnlineDot;
  final bool isImageBlurred;
  final DateTime? lastUpdate;
  final int unreadCount;
  final bool isBlocked;
  // ✅ true = أنت الحاظر → يظهر "إلغاء الحظر" فقط
  // false + isBlocked = true → أنت المحظور → لا يظهر block/unblock
  // false + isBlocked = false → لا يوجد block → يظهر "حظر"
  final bool amIBlocker;
  // ✅ System chat → Report option is hidden
  final bool isSystemChat;

  // Actions
  final VoidCallback? onTap;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;
  final VoidCallback? onReport;

  // Block — لو null الزرار مش هيظهر
  final VoidCallback? onBlock;
  final String? blockLabel;

  // Assets
  final String fallbackAsset;

  const ChatRoomListItem({
    super.key,
    required this.id,
    required this.title,
    required this.fallbackAsset,
    this.subtitle = '',
    this.statusText,
    this.imageUrl,
    this.isOnline = false,
    this.showOnlineDot = false,
    this.isImageBlurred = false,
    this.lastUpdate,
    this.unreadCount = 0,
    this.isBlocked = false,
    this.amIBlocker = false,
    this.isSystemChat = false,
    this.onTap,
    this.onArchive,
    this.onDelete,
    this.onReport,
    this.onBlock,
    this.blockLabel,
  });

  /// ✅ ترجمة الـ content type لنص مناسب للعرض في الـ list
  static String formatLastMessage(BuildContext context, String content) {
    final lower = content.trim().toLowerCase();
    if (lower == 'media' || lower == 'image' || lower == 'photo') {
      return '📷 ${context.tr('image_message')}';
    }
    if (lower == 'audio' || lower == 'voice' || lower == 'voice message') {
      return '🎤 ${context.tr('voice_message')}';
    }
    if (lower == 'video' || lower == 'video message') {
      return '🎥 ${context.tr('video_message')}';
    }
    if (lower == 'file' || lower == 'document') {
      return '📄 ${context.tr('file_message')}';
    }
    return content;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ حساب الـ effective block/report actions:
    // - لو أنت الحاظر (amIBlocker=true) → يظهر "إلغاء الحظر" + Report (المستخدم يقدر يبلّغ حتى لو هو اللي بلّك)
    // - لو هو الحاظر (isBlocked=true, amIBlocker=false) → لا block ولا unblock لكن يظهر Report
    // - لو مفيش block → يظهر Report + Block
    final effectiveOnBlock = amIBlocker
        ? onBlock // أنت الحاظر → إلغاء الحظر
        : (isBlocked ? null : onBlock); // هو الحاظر أو مفيش block
    // ✅ Report يظهر فقط للشاتات غير الـ system — حتى لو أنت الحاظر
    final effectiveOnReport = isSystemChat ? null : onReport;
    final effectiveBlockLabel = amIBlocker
        ? blockLabel
        : (isBlocked ? null : blockLabel);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Slidable(
        key: ValueKey('chat_room_$id'),
        startActionPane: onArchive != null
            ? ChatRoomSlidableActions.buildArchiveAction(
                context: context,
                onArchive: onArchive!,
              )
            : null,
        endActionPane: ChatRoomSlidableActions.buildEndActions(
          context: context,
          onDelete: onDelete,
          onReport: effectiveOnReport,
          onBlock: effectiveOnBlock,
          blockLabel: effectiveBlockLabel,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // ✅ أغلق الـ slider عند أي ضغطة على الـ item
              Slidable.of(context)?.close();
              onTap?.call();
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  ChatRoomAvatar(
                    imageUrl: imageUrl,
                    isImageBlurred: isImageBlurred,
                    isBlocked: isBlocked,
                    fallbackAsset: fallbackAsset,
                    showOnlineDot: showOnlineDot,
                    isOnline: isOnline,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: Styles.textStyle16SemiBold,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // ✅ Hide last seen / online status when the other
                            // party is blocked (either direction). The online dot
                            // in ChatRoomAvatar is already guarded by !isBlocked.
                            if (!isBlocked &&
                                statusText != null &&
                                statusText!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isOnline
                                      ? const Color(0xFFE2F7E8)
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  statusText!,
                                  style: Styles.textStyle10.copyWith(
                                    color: isOnline
                                        ? const Color(0xFF1E7D3A)
                                        : Colors.grey.shade700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: Styles.textStyle14.copyWith(
                              color: AppColors.secondary600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (lastUpdate != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            formatTime(lastUpdate!),
                            style: Styles.textStyle12.copyWith(
                              color: AppColors.secondary400,
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.kprimaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "$unreadCount",
                            style: Styles.textStyle10Bold.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
