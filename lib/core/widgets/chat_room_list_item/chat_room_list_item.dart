import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tayseer/core/functions/formate_time.dart';
import 'package:tayseer/core/utils/colors.dart';
import 'package:tayseer/core/utils/styles.dart';
import 'package:tayseer/core/widgets/chat_room_list_item/widgets/chat_room_avatar.dart';
import 'package:tayseer/core/widgets/chat_room_list_item/widgets/chat_room_slidable_actions.dart';

/// Widget موحد لعرض chat room item في القوائم
/// يدعم Archive, Delete, Report, وBlock (اختياري)
class ChatRoomListItem extends StatelessWidget {
  final String id;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final DateTime? lastUpdate;
  final int unreadCount;
  final bool isBlocked;

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
    this.imageUrl,
    this.lastUpdate,
    this.unreadCount = 0,
    this.isBlocked = false,
    this.onTap,
    this.onArchive,
    this.onDelete,
    this.onReport,
    this.onBlock,
    this.blockLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Slidable(
        key: ValueKey('chat_room_$id'),
        startActionPane: onArchive != null
            ? ChatRoomSlidableActions.buildArchiveAction(
                onArchive: onArchive!,
              )
            : null,
        endActionPane: ChatRoomSlidableActions.buildEndActions(
          context: context,
          onDelete: onDelete,
          onReport: onReport,
          onBlock: onBlock,
          blockLabel: blockLabel,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              child: Row(
                children: [
                  ChatRoomAvatar(
                    imageUrl: imageUrl,
                    isBlocked: isBlocked,
                    fallbackAsset: fallbackAsset,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Styles.textStyle16SemiBold,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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
