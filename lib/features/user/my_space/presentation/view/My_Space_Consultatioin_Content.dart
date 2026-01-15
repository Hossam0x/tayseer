import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tayseer/features/user/my_space/presentation/manager/my_space/my_space_state.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/my_space/my_state_cubit.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/my_space_list_view_item.dart';
import 'package:tayseer/my_import.dart';

class MySpaceConsultationContent extends StatefulWidget {
  const MySpaceConsultationContent({super.key});

  @override
  State<MySpaceConsultationContent> createState() =>
      _MySpaceConsultationContentState();
}

class _MySpaceConsultationContentState
    extends State<MySpaceConsultationContent> {
  @override
  void initState() {
    super.initState();
    // جلب البيانات عند بناء الـ Widget
    context.read<MySpaceCubit>().getAdvisorChat();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MySpaceCubit, MySpaceState>(
      buildWhen: (previous, current) =>
          previous.advisorChatState != current.advisorChatState,
      builder: (context, state) {
        // Loading State
        if (state.advisorChatState == CubitStates.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Failure State
        if (state.advisorChatState == CubitStates.failure) {
          return _buildErrorWidget(state.errorMessage);
        }

        // Success State
        if (state.advisorChatState == CubitStates.success) {
          final chatRooms = state.advisorChatModel?.data.chatRooms ?? [];

          if (chatRooms.isEmpty) {
            return _buildEmptyWidget();
          }

          return RefreshIndicator(
            onRefresh: () => context.read<MySpaceCubit>().getAdvisorChat(),
            child: ListView.builder(
              itemCount: chatRooms.length,
              itemBuilder: (context, index) {
                final chatRoom = chatRooms[index];

                // الحصول على المستخدم الآخر
                final otherUser = chatRoom.users.isNotEmpty
                    ? chatRoom.users.first
                    : chatRoom.sender;

                return MySpaceListItem(
                  index: index,
                  id: chatRoom.id,
                  title: otherUser.name,
                  subtitle: chatRoom.lastMessage?.content ?? '',
                  imageUrl: otherUser.image,
                  lastUpdate: chatRoom.lastMessageAt ?? chatRoom.updatedAt,
                  unreadCount: chatRoom.unreadCount,
                  onTap: () {
                    context.pushNamed(
                      AppRouter.advisorchatprofile,
                      arguments: chatRoom,
                    );
                  },
                  onArchive: () {
                    AppToast.success(context, 'تم أرشفة الاستشارة بنجاح');
                  },
                  onDelete: () {
                    _showDeleteDialog(context, chatRoom.id);
                  },
                  onReport: () {
                    _showReportDialog(context, chatRoom.id);
                  },
                );
              },
            ),
          );
        }

        // Initial State
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildErrorWidget(String? errorMessage) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: Colors.grey.shade400),
            SizedBox(height: 16.h),
            Text(
              errorMessage ?? 'حدث خطأ ما',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                context.read<MySpaceCubit>().getAdvisorChat();
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد استشارات حتى الآن',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String chatId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف المحادثة'),
        content: const Text('هل أنت متأكد من حذف هذه المحادثة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // TODO: تنفيذ الحذف
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context, String chatId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إبلاغ'),
        content: const Text('هل تريد الإبلاغ عن هذه المحادثة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // TODO: تنفيذ الإبلاغ
            },
            child: const Text('إبلاغ', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }
}
