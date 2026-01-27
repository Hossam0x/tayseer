import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/core/widgets/snack_bar_service.dart';
import 'package:tayseer/features/advisor/profille/data/models/archive_models.dart';
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
                        title: 'المحادثات المؤرشفة',
                        isLargeTitle: true,
                      ),
                    ),

                    // Main Content
                    Expanded(
                      child:
                          BlocConsumer<ArchivedChatsCubit, ArchivedChatsState>(
                            listener: (context, state) {
                              if (state.errorMessage != null) {
                                showSafeSnackBar(
                                  context: context,
                                  text: state.errorMessage!,
                                  isError: true,
                                );
                                context.read<ArchivedChatsCubit>().clearError();
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
              errorMessage ?? 'حدث خطأ في تحميل المحادثات المؤرشفة',
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
                'إعادة المحاولة',
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
            'لا توجد محادثات مؤرشفة',
            style: Styles.textStyle18.copyWith(color: AppColors.secondary600),
          ),
          Gap(8.h),
          Text(
            'سيتم عرض المحادثات المؤرشفة هنا',
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
    final displayName = otherUser?.name ?? 'مستخدم غير معروف';
    final displayImage = otherUser?.image;

    // الحصول على محتوى آخر رسالة
    final lastMessageContent = chatRoom.lastMessageContent;
    final lastMessageText = lastMessageContent.isNotEmpty
        ? lastMessageContent
        : 'لا توجد رسائل';

    // الحصول على الوقت بتوقيت مصر
    // final messageTime = chatRoom.formattedLastMessageTime;

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
              color: AppColors.kWhiteColor,
              size: 24.w,
            ),
            Gap(8.w),
            Text(
              'إلغاء الأرشفة',
              style: Styles.textStyle14.copyWith(
                color: AppColors.kWhiteColor,
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

        showSafeSnackBar(
          context: context,
          text: 'تم إلغاء أرشفة محادثة $displayName',
          isSuccess: true,
        );
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
                // User Avatar
                _buildUserAvatar(displayImage, chatRoom.isBlocked),
                SizedBox(width: 12.w),

                // Chat Info
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

                // Time and Status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Text(
                        chatRoom.lastMessage!.timeAgo,
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
                        // الأيقونة
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

                        // العنوان
                        Text(
                          'إلغاء الأرشفة',
                          style: Styles.textStyle16.copyWith(
                            color: const Color(0xFF2D2D2D),
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Gap(12.h),

                        // النص
                        Text(
                          'هل تريد إلغاء أرشفة محادثة $userName؟',
                          style: Styles.textStyle12.copyWith(
                            color: const Color(0xFF6B6B6B),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Gap(28.h),

                        // الأزرار
                        Row(
                          children: [
                            Expanded(
                              child: _buildDialogButton(
                                text: 'نعم',
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
                                text: 'لا',
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

  // دالة مساعدة لبناء زر الـ Dialog
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
