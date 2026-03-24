import 'dart:ui';
import 'package:tayseer/core/enum/report_type.dart';
import 'package:tayseer/features/advisor/profille/data/models/archive_models.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive_cubits.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/show_confirmation_dialog.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tayseer/my_import.dart';

class ChatItemWidget extends StatelessWidget {
  final ArchiveChatRoomModel chatRoom;
  final String currentUserId;

  const ChatItemWidget({
    super.key,
    required this.chatRoom,
    required this.currentUserId,
  });

  ArchiveUserModel? get _otherUser {
    try {
      if (currentUserId.isNotEmpty) {
        for (final user in chatRoom.users) {
          if (user.id != currentUserId) return user;
        }
        if (chatRoom.sender != null && chatRoom.sender!.id != currentUserId) {
          return chatRoom.sender;
        }
      }
      if (chatRoom.sender != null) {
        for (final user in chatRoom.users) {
          if (user.id == chatRoom.sender!.id) return user;
        }
        return chatRoom.sender;
      }
      return chatRoom.users.isNotEmpty ? chatRoom.users.first : null;
    } catch (e) {
      return null;
    }
  }

  String _getLastMessageContent(BuildContext context) {
    final lastMessage = chatRoom.lastMessage;
    if (lastMessage == null) return context.tr('new_chat');
    switch (lastMessage.messageType.toLowerCase()) {
      case 'text':
        return lastMessage.content;
      case 'image':
        return context.tr('image');
      case 'video':
        return context.tr('video');
      case 'audio':
        return context.tr('audio');
      case 'file':
        return context.tr('file');
      default:
        return context.tr('message');
    }
  }

  @override
  Widget build(BuildContext context) {
    final otherUser = _otherUser;
    final displayName = otherUser?.name ?? context.tr('unknown_user');
    final lastMessageText = _getLastMessageContent(context);

    return Slidable(
      key: Key('archived_chat_${chatRoom.id}'),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.25,
        children: [
          CustomSlidableAction(
            onPressed: (context) =>
                context.read<ArchivedChatsCubit>().unarchiveChat(chatRoom.id),
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.kprimaryColor,
            autoClose: true,
            padding: EdgeInsets.zero,
            child: _buildUnarchiveButton(context),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.65,
        children: [
          CustomSlidableAction(
            onPressed: (context) => Slidable.of(context)?.close(),
            autoClose: true,
            backgroundColor: Colors.transparent,
            padding: EdgeInsets.zero,
            child: _buildActionsPanel(context, otherUser),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openArchivedChat(context, otherUser),
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Row(
              children: [
                _buildUserAvatar(otherUser?.image, chatRoom.isBlocked),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: Styles.textStyle16.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        lastMessageText,
                        style: Styles.textStyle14.copyWith(
                          color: AppColors.secondary600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Text(
                        chatRoom.lastMessage?.timeAgo ?? '',
                        style: Styles.textStyle12.copyWith(
                          color: AppColors.secondary400,
                        ),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    if (chatRoom.unreadCount > 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.kprimaryColor,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          '${chatRoom.unreadCount}',
                          style: Styles.textStyle10.copyWith(
                            color: AppColors.kWhiteColor,
                            fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildUnarchiveButton(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          width: 70.w,
          height: 66.h,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.unarchive_rounded,
                color: AppColors.kprimaryColor,
                size: 28.h,
              ),
              SizedBox(height: 2.h),
              Text(
                context.tr('unarchive'),
                style: Styles.textStyle10Bold.copyWith(
                  color: AppColors.kprimaryColor,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionsPanel(BuildContext context, ArchiveUserModel? otherUser) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          width: 180.w,
          height: 66.h,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                context,
                svgIcon: AssetsData.deleteIcon,
                label: context.tr('delete'),
                color: AppColors.kRedColor,
                onTap: () {
                  Slidable.of(context)?.close();
                  showConfirmationDialog(
                    context: context,
                    imagePath: AssetsData.deleteIcon,
                    title: context.tr('confirm_delete_chat'),
                    subtitle: context.tr('confirm_delete_chat_message'),
                    onConfirm: () => context
                        .read<ArchivedChatsCubit>()
                        .deleteChatRoom(chatRoom.id),
                  );
                },
              ),
              Container(width: 1, height: 25.h, color: const Color(0xFFD9D9D9)),
              _buildActionButton(
                context,
                svgIcon: AssetsData.reportIcon,
                label: context.tr('report'),
                color: Colors.orange,
                onTap: () {
                  Slidable.of(context)?.close();
                  if (otherUser != null) {
                    context.pushNamed(
                      AppRouter.kReportsView,
                      arguments: {'type': ReportType.user, 'id': otherUser.id},
                    );
                  }
                },
              ),
              Container(width: 1, height: 25.h, color: const Color(0xFFD9D9D9)),
              _buildActionButton(
                context,
                icon: Icons.block,
                label: chatRoom.isBlocked
                    ? context.tr('unblock')
                    : context.tr('block'),
                color: const Color(0xFF581C25),
                onTap: () {
                  Slidable.of(context)?.close();
                  if (chatRoom.isBlocked) {
                    showConfirmationDialog(
                      context: context,
                      imagePath: AssetsData.deleteIcon,
                      title: context.tr('confirm_unblock_user'),
                      subtitle: context.tr('confirm_unblock_user_message'),
                      onConfirm: () =>
                          context.read<ArchivedChatsCubit>().unblockUser(
                            userId: otherUser?.id ?? '',
                            chatId: chatRoom.id,
                          ),
                    );
                  } else {
                    showConfirmationDialog(
                      context: context,
                      imagePath: AssetsData.deleteIcon,
                      title: context.tr('confirm_block_user'),
                      subtitle: context.tr('confirm_block_user_message'),
                      onConfirm: () =>
                          context.read<ArchivedChatsCubit>().blockUser(
                            userId: otherUser?.id ?? '',
                            chatId: chatRoom.id,
                          ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(String? imageUrl, bool isBlocked) {
    return Stack(
      children: [
        Container(
          width: 56.r,
          height: 56.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.secondary100,
            border: Border.all(color: AppColors.secondary200, width: 1),
          ),
          child: ClipOval(child: _buildAvatarImage(imageUrl)),
        ),
        if (isBlocked)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.3),
              ),
              child: Center(
                child: Icon(Icons.block, color: Colors.white, size: 20.w),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatarImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Image.asset(AssetsData.avatarImage, fit: BoxFit.cover),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 56.r,
              height: 56.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
            ),
          );
        },
      );
    }
    return Image.asset(AssetsData.avatarImage, fit: BoxFit.cover);
  }

  Widget _buildActionButton(
    BuildContext context, {
    IconData? icon,
    String? svgIcon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (svgIcon != null)
              SvgPicture.asset(
                svgIcon,
                height: 20.h,
                width: 20.w,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              )
            else if (icon != null)
              Icon(icon, size: 20.h, color: color),
            SizedBox(height: 4.h),
            Text(
              label,
              style: Styles.textStyle10.copyWith(color: color, fontSize: 9.sp),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _openArchivedChat(BuildContext context, ArchiveUserModel? otherUser) {
    if (otherUser == null) {
      AppToast.error(context, context.tr('user_not_found'));
      return;
    }
    context.pushNamed(
      AppRouter.kConversitionView,
      arguments: {
        'receiverid': otherUser.id,
        'chatroomid': chatRoom.id,
        'username': otherUser.name,
        'userimage': otherUser.image,
        'isBlocked': chatRoom.isBlocked,
      },
    );
  }
}
