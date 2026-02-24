import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tayseer/features/user/my_space/presentation/manager/my_space/my_space_state.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/my_space/my_state_cubit.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/my_space_list_view_item.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/session_history/empty_session_widget.dart';
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
    context.read<MySpaceCubit>().getAdvisorChat();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MySpaceCubit, MySpaceState>(
      buildWhen: (previous, current) =>
          previous.advisorChatState != current.advisorChatState ||
          previous.advisorChatModel != current.advisorChatModel ||
          previous.lastUpdateTime != current.lastUpdateTime,
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
            return EmptySessionsState(
              title: 'لا يوجد استشارات',
              subtitle: 'احجز جلسه لتتمكن من حل مشاكلك النفسيه',
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<MySpaceCubit>().getAdvisorChat(),
            child: ListView.builder(
              itemCount: chatRooms.length,
              itemBuilder: (context, index) {
                final chatRoom = chatRooms[index];

                // الحصول على المستخدم الآخر
                final otherUser = chatRoom.users.isNotEmpty
                    ? chatRoom.users.firstWhere(
                        (user) => user.id == chatRoom.sender.id,
                      )
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
                    final cubit = context.read<MySpaceCubit>();
                    cubit.markChatAsRead(chatRoom.id);
                    cubit.setActiveChatRoom(chatRoom.id);
                    cubit.markMessageAsReadOnSocket(chatRoom.id);

                    context
                        .pushNamed(
                          AppRouter.kConversitionView,
                          arguments: {
                            'chatroomid': chatRoom.id,
                            'receiverid': otherUser.id,
                            'username': otherUser.name,
                            'userimage': otherUser.image,
                            'isBlocked': chatRoom.isBlocked,
                            'isHaveSession': chatRoom.isHaveSession,
                          },
                        )
                        .then((_) {
                          if (context.mounted) {
                            cubit.setActiveChatRoom(null);
                            cubit.getAdvisorChat();
                          }
                        });
                  },
                  onArchive: () {
                    _showArchiveDialog(context, chatRoom.id);
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
            AppImage(AssetsData.errorIcon, width: 150.w),
            SizedBox(height: 16.h),
            Text(
              'حدث خطأ ما',
              style: Styles.textStyle18,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            CustomBotton(
              width: 200.w,
              title: "إعاده المحاوله",
              onPressed: () {
                context.read<MySpaceCubit>().getAdvisorChat();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String chatId) {
    final cubit = context.read<MySpaceCubit>();
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
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await cubit.deleteChatRoom(chatId);
              if (context.mounted) {
                if (success) {
                  AppToast.success(context, 'تم حذف المحادثة بنجاح');
                } else {
                  AppToast.error(context, 'فشل في حذف المحادثة، حاول مرة أخرى');
                }
              }
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showArchiveDialog(BuildContext context, String chatId) {
    final cubit = context.read<MySpaceCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('أرشفة المحادثة'),
        content: const Text('هل أنت متأكد من أرشفة هذه المحادثة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await cubit.archiveChatRoom(chatId);
              if (context.mounted) {
                if (success) {
                  AppToast.success(context, 'تم أرشفة الاستشارة بنجاح');
                } else {
                  AppToast.error(
                    context,
                    'فشل في أرشفة المحادثة، حاول مرة أخرى',
                  );
                }
              }
            },
            child: const Text(
              'أرشفة',
              style: TextStyle(color: Color(0xFFA12042)),
            ),
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
            },
            child: const Text('إبلاغ', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }
}
