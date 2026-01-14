import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/shared_empty_state.dart';
import 'package:tayseer/features/advisor/profille/data/models/archive_models.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive_cubits.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive_states.dart';
import 'package:tayseer/my_import.dart';

class ChatsTabView extends StatelessWidget {
  const ChatsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ArchivedChatsCubit, ArchivedChatsState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.kRedColor,
            ),
          );
          context.read<ArchivedChatsCubit>().clearError();
        }
      },
      builder: (context, state) {
        switch (state.state) {
          case CubitStates.loading:
            return _buildSkeletonChats();
          case CubitStates.failure:
            return _buildErrorChats(context, state.errorMessage);
          case CubitStates.success:
            if (state.chatRooms.isEmpty) {
              return const SharedEmptyState(title: "لا توجد محادثات مؤرشفة");
            }
            return _buildChatsContent(context, state);
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildSkeletonChats() {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        itemCount: 5,
        separatorBuilder: (context, index) =>
            Divider(color: AppColors.hintText),
        itemBuilder: (context, index) {
          return ListTile(
            trailing: Container(
              width: 50.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            title: Container(
              width: 100.w,
              height: 16.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            subtitle: Container(
              width: 80.w,
              height: 14.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            leading: ClipOval(
              child: Container(
                width: 60.r,
                height: 60.r,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorChats(BuildContext context, String? errorMessage) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: AppColors.kRedColor, size: 48.w),
          Gap(16.h),
          Text(
            errorMessage ?? 'حدث خطأ في تحميل المحادثات المؤرشفة',
            style: Styles.textStyle16.copyWith(color: AppColors.kRedColor),
            textAlign: TextAlign.center,
          ),
          Gap(24.h),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kprimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            onPressed: () => context.read<ArchivedChatsCubit>().refresh(),
            child: Text(
              'إعادة المحاولة',
              style: Styles.textStyle14Meduim.copyWith(
                color: AppColors.kWhiteColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatsContent(BuildContext context, ArchivedChatsState state) {
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
            child: RefreshIndicator(
              onRefresh: () => context.read<ArchivedChatsCubit>().refresh(),
              child: ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                itemCount: state.chatRooms.length + (state.hasMore ? 1 : 0),
                separatorBuilder: (context, index) =>
                    Divider(color: AppColors.hintText),
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
    // TODO: استبدل 'currentUserId' بـ ID المستخدم الحقيقي
    final currentUserId = '6947e98df9f8bce3bf355fc0'; // ID مؤقت للاختبار
    final otherUser = chatRoom.getOtherUser(currentUserId);

    return Dismissible(
      key: Key(chatRoom.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.archive_outlined, color: Colors.white, size: 24.sp),
            Gap(8.w),
            Text(
              'إلغاء الأرشفة',
              style: Styles.textStyle14.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        context.read<ArchivedChatsCubit>().unarchiveChat(chatRoom.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إلغاء أرشفة المحادثة'),
            backgroundColor: Colors.green,
          ),
        );
      },
      child: ListTile(
        trailing: Text(
          _formatTime('${chatRoom.lastMessageAt}'),
          style: Styles.textStyle12.copyWith(color: AppColors.gray2),
        ),
        title: Text(
          otherUser?.name ?? 'مستخدم غير معروف',
          textAlign: TextAlign.right,
          style: Styles.textStyle16Meduim,
        ),
        subtitle: Text(
          chatRoom.lastMessage ?? 'لا توجد رسائل',
          textAlign: TextAlign.right,
          style: Styles.textStyle14.copyWith(color: AppColors.gray2),
        ),
        leading: _buildUserAvatar(otherUser?.image, chatRoom.isBlocked),
        onTap: () {
          // TODO: فتح المحادثة
        },
      ),
    );
  }

  Widget _buildUserAvatar(String? imageUrl, bool isBlocked) {
    return ClipOval(
      child: SizedBox(
        width: 60.r,
        height: 60.r,
        child: isBlocked
            ? ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: _buildAvatarImage(imageUrl),
              )
            : _buildAvatarImage(imageUrl),
      ),
    );
  }

  Widget _buildAvatarImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        width: 60.r,
        height: 60.r,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            AssetsData.avatarImage,
            width: 60.r,
            height: 60.r,
            fit: BoxFit.cover,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    }

    return Image.asset(
      AssetsData.avatarImage,
      width: 60.r,
      height: 60.r,
      fit: BoxFit.cover,
    );
  }

  Widget _buildLoadMoreIndicator(ArchivedChatsState state) {
    if (!state.hasMore) return SizedBox.shrink();

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

  String _formatTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('h:mm a').format(date);
    } catch (e) {
      return '--:--';
    }
  }
}
