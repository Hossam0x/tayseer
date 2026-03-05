import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/features/advisor/profille/data/models/archive_models.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive_cubits.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive_states.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/chats_tab_ui_cubit.dart';
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

    return Dismissible(
      key: Key('archived_chat_${chatRoom.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: AppColors.kWhiteColor,
          border: Border.all(color: AppColors.kprimaryColor),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.unarchive_rounded,
              color: AppColors.kprimaryColor,
              size: 24.w,
            ),
            Gap(8.w),
            Text(
              context.tr('unarchive'),
              style: Styles.textStyle14.copyWith(
                color: AppColors.kprimaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showUnarchiveConfirmation(
          context,
          chatRoom.id,
          displayName,
        );
      },
      onDismissed: (direction) {
        context.read<ArchivedChatsCubit>().unarchiveChat(chatRoom.id);
      },
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
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.kprimaryColor,
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

  Future<bool> _showUnarchiveConfirmation(
    BuildContext context,
    String chatId,
    String userName,
  ) async {
    bool result = false;

    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.r),
          ),
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(maxWidth: 380.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30.r,
                  offset: Offset(0.w, 15.h),
                  spreadRadius: 5.r,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28.r),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFE8B4B8),
                        Color(0xFFF5E6E8),
                        Color(0xFFFAF5F5),
                        Colors.white,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 90.w,
                          height: 90.h,
                          decoration: BoxDecoration(
                            color: AppColors.kprimaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.unarchive_rounded,
                            size: 50.w,
                            color: AppColors.kprimaryColor,
                          ),
                        ),
                        Gap(24.h),
                        Text(
                          context.tr('unarchive'),
                          style: Styles.textStyle16.copyWith(
                            color: const Color(0xFF2D2D2D),
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Gap(12.h),
                        Text(
                          '${context.tr('are_you_want_to_unarchive')} $userName؟',
                          style: Styles.textStyle12.copyWith(
                            color: const Color(0xFF6B6B6B),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Gap(28.h),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDialogButton(
                                text: context.tr('yes'),
                                backgroundColor: Colors.green,
                                textColor: Colors.white,
                                onPressed: () {
                                  result = true;
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                            Gap(12.w),
                            Expanded(
                              child: _buildDialogButton(
                                text: context.tr('no'),
                                backgroundColor: AppColors.kprimaryColor,
                                textColor: Colors.white,
                                onPressed: () {
                                  result = false;
                                  Navigator.of(context).pop();
                                },
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
          ),
        );
      },
    );

    return result;
  }

  Widget _buildDialogButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
    bool fullWidth = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: fullWidth ? double.infinity : null,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withOpacity(0.35),
                blurRadius: 10.r,
                offset: Offset(0.w, 5.h),
              ),
            ],
          ),
          child: Text(
            text,
            style: Styles.textStyle14Meduim.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
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
        'chatroomid': chatRoom.id,
        'receiverid': otherUser.id,
        'username': otherUser.name,
        'userimage': otherUser.image,
        'usertype': otherUser.userType,
        'isBlocked': chatRoom.isBlocked,
        'isHaveSession': chatRoom.isHaveSession,
      },
    );
  }
}
