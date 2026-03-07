import 'dart:ui';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tayseer/core/functions/formate_time.dart';
import 'package:tayseer/features/advisor/chat/data/model/chatView/chat_item_model.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_list_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/show_confirmation_dialog.dart';
import 'package:tayseer/my_import.dart';

class ChatListItem extends StatelessWidget {
  final int index;
  final ChatRoom chatRoom;
  const ChatListItem({super.key, required this.index, required this.chatRoom});

  static const String chatArchiveIcon = "assets/icons/chat_archive.svg";
  static const String deleteIcon = "assets/icons/delete_icon.svg";
  static const String reportIcon = "assets/icons/report_icon.svg";

  @override
  Widget build(BuildContext context) {
    const Color dividerColor = Color(0xFFD9D9D9);
    final archiveColor = AppColors.kprimaryColor;

    final otherUser = chatRoom.users.isNotEmpty
        ? chatRoom.users.firstWhere(
            (user) => user.id == chatRoom.sender.id,
            orElse: () => chatRoom.sender,
          )
        : chatRoom.sender;

    final displayName = otherUser.name;
    final displayImage = otherUser.image;
    final lastMessageText =
        chatRoom.lastMessage?.content ?? context.tr('no_messages');

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Slidable(
        key: Key('chat_room_${chatRoom.id}'),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.25,
          children: [
            CustomSlidableAction(
              onPressed: (context) {
                context.read<ChatListCubit>().archiveChatRoom(chatRoom.id);
                AppToast.success(context, context.tr('chat_archived_success'));
              },
              backgroundColor: Colors.transparent,
              foregroundColor: archiveColor,
              autoClose: true,
              padding: EdgeInsets.zero,
              child: ClipRRect(
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
                        SvgPicture.asset(
                          chatArchiveIcon,
                          height: 28.h,
                          width: 28.w,
                          colorFilter: ColorFilter.mode(
                            archiveColor,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          context.tr('archive'),
                          style: Styles.textStyle10Bold.copyWith(
                            color: archiveColor,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.65,
          children: [
            CustomSlidableAction(
              onPressed: (context) {
                Slidable.of(context)?.close();
              },
              autoClose: true,
              backgroundColor: Colors.transparent,
              padding: EdgeInsets.zero,
              child: ClipRRect(
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
                          svgIcon: deleteIcon,
                          label: context.tr('delete'),
                          color: AppColors.kRedColor,
                          onTap: () {
                            Slidable.of(context)?.close();
                            showConfirmationDialog(
                              context: context,
                              imagePath: AssetsData.deleteIcon,
                              title: context.tr('confirm_delete_chat'),
                              subtitle: context.tr(
                                'confirm_delete_chat_message',
                              ),
                              onConfirm: () {
                                context.read<ChatListCubit>().deleteChatRoom(
                                  chatRoom.id,
                                );
                              },
                            );
                          },
                        ),
                        Container(width: 1, height: 25.h, color: dividerColor),
                        _buildActionButton(
                          context,
                          svgIcon: reportIcon,
                          label: context.tr('report'),
                          color: Colors.orange,
                          onTap: () {
                            Slidable.of(context)?.close();
                            print("تم اختيار ابلاغ");
                          },
                        ),
                        Container(width: 1, height: 25.h, color: dividerColor),
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
                                subtitle: context.tr(
                                  'confirm_unblock_user_message',
                                ),
                                onConfirm: () {
                                  context.read<ChatListCubit>().unblockUser(
                                    blockedId: otherUser.id,
                                    chatRoomId: chatRoom.id,
                                  );
                                },
                              );
                            } else {
                              showConfirmationDialog(
                                context: context,
                                imagePath: AssetsData.deleteIcon,
                                title: context.tr('confirm_block_user'),
                                subtitle: context.tr(
                                  'confirm_block_user_message',
                                ),
                                onConfirm: () {
                                  context.read<ChatListCubit>().blockUser(
                                    blockedId: otherUser.id,
                                    chatRoomId: chatRoom.id,
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              context.read<ChatListCubit>().setActiveChatRoom(chatRoom.id);
              context.read<ChatListCubit>().markMessageRed(chatRoom.id);
              context.read<ChatListCubit>().markChatAsRead(chatRoom.id);
              context
                  .pushNamed(
                    AppRouter.kConversitionView,
                    arguments: {
                      'receiverid': otherUser.id,
                      'chatroomid': chatRoom.id,
                      'username': otherUser.name,
                      'userimage': otherUser.image,
                      'isBlocked': chatRoom.isBlocked,
                      'onBlockStatusChanged': (bool isBlocked) {
                        if (context.mounted) {
                          context.read<ChatListCubit>().updateBlockStatus(
                            chatRoom.id,
                            isBlocked,
                          );
                        }
                      },
                    },
                  )
                  .then((_) {
                    if (context.mounted) {
                      context.read<ChatListCubit>().setActiveChatRoom(null);
                    }
                  });
            },
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              child: Row(
                children: [
                  _buildUserAvatar(displayImage, chatRoom.isBlocked),
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
                          chatRoom.lastMessage?.timeAgo ??
                              (chatRoom.lastMessageAt != null
                                  ? formatTime(chatRoom.lastMessageAt!)
                                  : ''),
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
                            "${chatRoom.unreadCount}",
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
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(AssetsData.avatarImage, fit: BoxFit.cover);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: Shimmer.fromColors(
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
}
