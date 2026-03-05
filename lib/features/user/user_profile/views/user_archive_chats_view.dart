import 'dart:ui';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/core/widgets/snack_bar_service.dart';
import 'package:tayseer/features/advisor/profille/data/models/archive_models.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/show_confirmation_dialog.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive_cubits.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive_states.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_service.dart';
import 'package:tayseer/my_import.dart';

class UserArchiveChatsView extends StatefulWidget {
  const UserArchiveChatsView({super.key});

  @override
  State<UserArchiveChatsView> createState() => _UserArchiveChatsViewState();
}

class _UserArchiveChatsViewState extends State<UserArchiveChatsView> {
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    try {
      final userId = await UserService.getCurrentUserId();
      setState(() {
        _currentUserId = userId;
      });
    } catch (e) {
      print('❌ Error loading current user ID: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ArchivedChatsCubit>(),
      child: Scaffold(
        body: AdvisorBackground(
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 105.h,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AssetsData.homeBarBackgroundImage),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    // Header with Back Button
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 15.h,
                      ),
                      child: SimpleAppBar(
                        title: context.tr('archived_chats'),
                        isLargeTitle: true,
                      ),
                    ),

                    // Main Content
                    Expanded(
                      child: BlocConsumer<ArchivedChatsCubit, ArchivedChatsState>(
                        listener: (context, state) {
                          // ⭐ Handle General Error (e.g. initial fetch failure)
                          if (state.errorMessage != null &&
                              state.state == CubitStates.failure) {
                            AppToast.error(context, state.errorMessage!);
                            context.read<ArchivedChatsCubit>().clearError();
                          }

                          // ⭐ Handle Unarchive Action result
                          if (state.unarchiveActionState ==
                              CubitStates.success) {
                            if (state.unarchiveMessage != null) {
                              AppToast.success(
                                context,
                                context.tr(state.unarchiveMessage!),
                              );
                            }
                            context
                                .read<ArchivedChatsCubit>()
                                .resetUnarchiveState();
                          } else if (state.unarchiveActionState ==
                              CubitStates.failure) {
                            if (state.unarchiveMessage != null) {
                              AppToast.error(context, state.unarchiveMessage!);
                            }
                            context
                                .read<ArchivedChatsCubit>()
                                .resetUnarchiveState();
                          }
                        },
                        builder: (context, state) {
                          return _buildContent(context, state);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ArchivedChatsState state) {
    switch (state.state) {
      case CubitStates.loading:
        return _buildSkeletonChats();
      case CubitStates.failure:
        return _buildErrorChats(context, state.errorMessage);
      case CubitStates.success:
        if (state.chatRooms.isEmpty) {
          return _buildEmptyState();
        }
        return _buildChatsList(context, state);
      default:
        return const SizedBox.shrink();
    }
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
                // Avatar skeleton
                Container(
                  width: 56.r,
                  height: 56.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                  ),
                ),
                SizedBox(width: 12.w),
                // Info skeleton
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
                // Time skeleton
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

  Widget _buildEmptyState() {
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

  Widget _buildChatsList(BuildContext context, ArchivedChatsState state) {
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
                  return _buildChatItem(context, chatRoom);
                },
              ),
            ),
          ),
          if (state.isLoadingMore) _buildLoadingMore(),
        ],
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, ArchiveChatRoomModel chatRoom) {
    // الحصول على المستخدم الآخر
    final otherUser = _getOtherUser(chatRoom);
    final displayName = otherUser?.name ?? context.tr('unknown_user');
    final displayImage = otherUser?.image;

    // الحصول على محتوى آخر رسالة
    final lastMessageContent = chatRoom.lastMessageContent;
    final lastMessageText = lastMessageContent.isNotEmpty
        ? lastMessageContent
        : context.tr('no_messages');

    // الحصول على الوقت بتوقيت مصر
    // final messageTime = chatRoom.formattedLastMessageTime;

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
                            print(otherUser.id);
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

  ArchiveUserModel? _getOtherUser(ArchiveChatRoomModel chatRoom) {
    try {
      // إذا كان لدينا ID المستخدم الحالي
      if (_currentUserId != null) {
        // البحث عن مستخدم ليس هو الحالي
        for (final user in chatRoom.users) {
          if (user.id != _currentUserId) {
            return user;
          }
        }

        // إذا كان جميع users هم نفس المستخدم الحالي
        // نستخدم sender إذا كان مختلفاً
        if (chatRoom.sender != null && chatRoom.sender!.id != _currentUserId) {
          return chatRoom.sender;
        }
      }

      // الحالة الثانية: إذا لم نعرف المستخدم الحالي
      // نستخدم نفس منطق MySpaceConsultationContent
      if (chatRoom.sender != null) {
        // البحث عن user يطابق sender
        for (final user in chatRoom.users) {
          if (user.id == chatRoom.sender!.id) {
            return user;
          }
        }
        // إذا لم نجد، نستخدم sender مباشرة
        return chatRoom.sender;
      }

      // الحالة الأخيرة: نستخدم أول user في القائمة
      return chatRoom.users.isNotEmpty ? chatRoom.users.first : null;
    } catch (e) {
      print('❌ Error getting other user: $e');
      return null;
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

  void _openArchivedChat(
    BuildContext context,
    ArchiveChatRoomModel chatRoom,
    ArchiveUserModel? otherUser,
  ) {
    if (otherUser == null) {
      showSafeSnackBar(
        context: context,
        text: 'لا يمكن فتح المحادثة: بيانات المستخدم غير متوفرة',
        isError: true,
      );
      return;
    }

    // فتح شاشة المحادثة مع البيانات الحقيقية
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
