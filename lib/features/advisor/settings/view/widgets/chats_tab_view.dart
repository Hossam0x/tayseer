import 'dart:ui';
import 'package:tayseer/core/enum/report_type.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tayseer/features/advisor/profille/data/models/archive_models.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive_cubits.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive_states.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/chats_tab_ui_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/show_confirmation_dialog.dart';
import 'package:tayseer/my_import.dart';

class ChatsTabView extends StatelessWidget {
  const ChatsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatsTabUiCubit()..loadCurrentUserId(),
      child: const _ChatsTabViewBody(),
    );
  }
}

class _ChatsTabViewBody extends StatelessWidget {
  const _ChatsTabViewBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatsTabUiCubit, ChatsTabUiState>(
      builder: (context, uiState) {
        return BlocConsumer<ArchivedChatsCubit, ArchivedChatsState>(
          listener: (context, state) {
            // ⭐ Handle General Error
            if (state.errorMessage != null &&
                state.state == CubitStates.failure) {
              AppToast.error(context, state.errorMessage!);
              context.read<ArchivedChatsCubit>().clearError();
            }

            // ⭐ Handle Unarchive Action result
            if (state.unarchiveActionState == CubitStates.success) {
              if (state.unarchiveMessage != null) {
                AppToast.success(context, context.tr(state.unarchiveMessage!));
              }
              context.read<ArchivedChatsCubit>().resetUnarchiveState();
            } else if (state.unarchiveActionState == CubitStates.failure) {
              if (state.unarchiveMessage != null) {
                AppToast.error(context, state.unarchiveMessage!);
              }
              context.read<ArchivedChatsCubit>().resetUnarchiveState();
            }
          },
          builder: (context, state) {
            if (uiState.isLoading || uiState.currentUserId == null) {
              return _buildSkeletonChats();
            }

            switch (state.state) {
              case CubitStates.loading:
                return _buildSkeletonChats();
              case CubitStates.failure:
                return _buildErrorChats(context, state.errorMessage);
              case CubitStates.success:
                if (state.chatRooms.isEmpty) {
                  return _buildEmptyState(context);
                }
                return _buildChatsList(context, state, uiState.currentUserId!);
              default:
                return const SizedBox.shrink();
            }
          },
        );
      },
    );
  }

  Widget _buildSkeletonChats() {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
        itemCount: 8,
        separatorBuilder: (context, index) =>
            Divider(color: Colors.grey.shade200, height: 1),
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Row(
              children: [
                Container(
                  width: 56.r,
                  height: 56.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120.w,
                        height: 16.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        width: 180.w,
                        height: 14.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 60.w,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorChats(BuildContext context, String? errorMessage) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.kRedColor, size: 64.w),
            Gap(16.h),
            Text(
              errorMessage ?? context.tr('error_loading_chats'),
              style: Styles.textStyle16.copyWith(color: AppColors.secondary700),
              textAlign: TextAlign.center,
            ),
            Gap(24.h),
            ElevatedButton(
              onPressed: () => context.read<ArchivedChatsCubit>().refresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kprimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
              ),
              child: Text(
                context.tr('retry'),
                style: Styles.textStyle16Meduim.copyWith(
                  color: AppColors.kWhiteColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AssetsData.emptyChatImage, width: 150.w, height: 150.w),
          Gap(20.h),
          Text(
            context.tr('no_archived_chats'),
            style: Styles.textStyle18.copyWith(color: AppColors.secondary600),
          ),
          Gap(8.h),
          Text(
            context.tr('no_archived_chats_message'),
            style: Styles.textStyle14.copyWith(color: AppColors.secondary400),
          ),
        ],
      ),
    );
  }

  Widget _buildChatsList(
    BuildContext context,
    ArchivedChatsState state,
    String currentUserId,
  ) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          if (state.hasMore && !state.isLoadingMore) {
            context.read<ArchivedChatsCubit>().fetchArchivedChats(
              loadMore: true,
            );
          }
        }
        return false;
      },
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator.adaptive(
              onRefresh: () => context.read<ArchivedChatsCubit>().refresh(),
              color: AppColors.kprimaryColor,
              backgroundColor: AppColors.kWhiteColor,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                itemCount: state.chatRooms.length + (state.hasMore ? 1 : 0),
                separatorBuilder: (context, index) =>
                    Divider(color: AppColors.secondary100, height: 1),
                itemBuilder: (context, index) {
                  if (index == state.chatRooms.length) {
                    return _buildLoadMoreIndicator(state);
                  }

                  final chatRoom = state.chatRooms[index];
                  return _buildChatItem(context, chatRoom, currentUserId);
                },
              ),
            ),
          ),
          if (state.isLoadingMore) _buildLoadingMore(),
        ],
      ),
    );
  }

  Widget _buildChatItem(
    BuildContext context,
    ArchiveChatRoomModel chatRoom,
    String currentUserId,
  ) {
    final otherUser = _getOtherUser(chatRoom, currentUserId);
    final displayName = otherUser?.name ?? context.tr('unknown_user');
    final displayImage = otherUser?.image;

    final lastMessageContent = _getLastMessageContent(context, chatRoom);
    final lastMessageText = lastMessageContent.isNotEmpty
        ? lastMessageContent
        : context.tr('no_messages');

    return Slidable(
      key: Key('archived_chat_${chatRoom.id}'),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.25,
        children: [
          CustomSlidableAction(
            onPressed: (context) {
              context.read<ArchivedChatsCubit>().unarchiveChat(chatRoom.id);
            },
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.kprimaryColor,
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
                            onConfirm: () {
                              context.read<ArchivedChatsCubit>().deleteChatRoom(
                                chatRoom.id,
                              );
                            },
                          );
                        },
                      ),
                      Container(
                        width: 1,
                        height: 25.h,
                        color: const Color(0xFFD9D9D9),
                      ),
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
                              arguments: {
                                'type': ReportType.user,
                                'id': otherUser.id,
                              },
                            );
                          }
                        },
                      ),
                      Container(
                        width: 1,
                        height: 25.h,
                        color: const Color(0xFFD9D9D9),
                      ),
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
                                context.read<ArchivedChatsCubit>().unblockUser(
                                  userId: otherUser?.id ?? '',
                                  chatId: chatRoom.id,
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
                                context.read<ArchivedChatsCubit>().blockUser(
                                  userId: otherUser?.id ?? '',
                                  chatId: chatRoom.id,
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
            _openArchivedChat(context, chatRoom, otherUser);
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
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
                        chatRoom.lastMessage?.timeAgo ?? '',
                        style: Styles.textStyle12.copyWith(
                          color: AppColors.secondary400,
                        ),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    if ((chatRoom.unreadCount) > 0)
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

  ArchiveUserModel? _getOtherUser(
    ArchiveChatRoomModel chatRoom,
    String currentUserId,
  ) {
    try {
      if (currentUserId.isNotEmpty) {
        for (final user in chatRoom.users) {
          if (user.id != currentUserId) {
            return user;
          }
        }
        if (chatRoom.sender != null && chatRoom.sender!.id != currentUserId) {
          return chatRoom.sender;
        }
      }

      if (chatRoom.sender != null) {
        for (final user in chatRoom.users) {
          if (user.id == chatRoom.sender!.id) {
            return user;
          }
        }
        return chatRoom.sender;
      }
      return chatRoom.users.isNotEmpty ? chatRoom.users.first : null;
    } catch (e) {
      print('❌ Error getting other user: $e');
      return null;
    }
  }

  String _getLastMessageContent(
    BuildContext context,
    ArchiveChatRoomModel chatRoom,
  ) {
    final lastMessage = chatRoom.lastMessage;
    if (lastMessage == null) {
      return context.tr('new_chat');
    }

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

  Widget _buildLoadMoreIndicator(ArchivedChatsState state) {
    if (!state.hasMore) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: state.isLoadingMore
            ? CircularProgressIndicator(color: AppColors.kprimaryColor)
            : Container(),
      ),
    );
  }

  Widget _buildLoadingMore() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: CircularProgressIndicator(color: AppColors.kprimaryColor),
      ),
    );
  }

  void _openArchivedChat(
    BuildContext context,
    ArchiveChatRoomModel chatRoom,
    ArchiveUserModel? otherUser,
  ) {
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
