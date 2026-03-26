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
      buildWhen: (previous, current) {
        // Only rebuild if state changes or chat list actually changes
        if (previous.advisorChatState != current.advisorChatState) {
          return true;
        }
        
        // Check if the chat list actually changed (not just lastUpdateTime)
        final prevRooms = previous.advisorChatModel?.data.chatRooms ?? [];
        final currRooms = current.advisorChatModel?.data.chatRooms ?? [];
        
        // If length changed, rebuild
        if (prevRooms.length != currRooms.length) {
          return true;
        }
        
        // If any room's unreadCount or lastMessage changed, rebuild
        for (int i = 0; i < prevRooms.length; i++) {
          if (prevRooms[i].id != currRooms[i].id ||
              prevRooms[i].unreadCount != currRooms[i].unreadCount ||
              prevRooms[i].lastMessage?.content != currRooms[i].lastMessage?.content) {
            return true;
          }
        }
        
        return false;
      },
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
              itemCount: chatRooms.length + 1,
              itemBuilder: (context, index) {
                if (index == chatRooms.length) {
                  return _buildAddAdvisorItem(context);
                }
                final chatRoom = chatRooms[index];

                // الحصول على المستخدم الآخر
                final String title;
                final String? imageUrl;
                final String receiverId;

                if (chatRoom.isSystemChat) {
                  title = 'System';
                  imageUrl = chatRoom.systemChatImage; // استخدام الصورة من systemChatData
                  receiverId = 'system';
                } else {
                  final otherUser = chatRoom.users.isNotEmpty
                      ? chatRoom.users.firstWhere(
                          (user) => user.id == chatRoom.sender.id,
                          orElse: () => chatRoom.users.first,
                        )
                      : chatRoom.sender;
                  title = otherUser.name;
                  imageUrl = otherUser.image;
                  receiverId = otherUser.id;
                }

                return MySpaceListItem(
                  key: ValueKey('chat_${chatRoom.id}'),
                  index: index,
                  id: chatRoom.id,
                  title: title,
                  subtitle: chatRoom.lastMessage?.content ?? '',
                  imageUrl: imageUrl,
                  lastUpdate: chatRoom.lastMessageAt ?? chatRoom.updatedAt,
                  unreadCount: chatRoom.unreadCount,
                  isSystem: chatRoom.isSystemChat,
                  onTap: () {
                    final cubit = context.read<MySpaceCubit>();
                    cubit.markChatAsRead(chatRoom.id);
                    cubit.setActiveChatRoom(chatRoom.id);
                    cubit.markMessageAsReadOnSocket(chatRoom.id);

                    // تحضير الـ arguments
                    final Map<String, dynamic> arguments = {
                      'chatroomid': chatRoom.id,
                      'username': title,
                      'userimage': imageUrl,
                      'isBlocked': chatRoom.isBlocked,
                      'isHaveSession': chatRoom.isHaveSession,
                      'isSystemChat': chatRoom.isSystemChat,
                    };

                    // في حالة System Chat نرسل system: true بدلاً من receiverid
                    if (chatRoom.isSystemChat) {
                      arguments['system'] = true;
                    } else {
                      arguments['receiverid'] = receiverId;
                    }

                    context
                        .pushNamed(
                          AppRouter.kConversitionView,
                          arguments: arguments,
                        )
                        .then((_) {
                          if (context.mounted) {
                            cubit.setActiveChatRoom(null);
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

  Widget _buildAddAdvisorItem(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final containerPadding = isMobile ? 14.0 : 16.0;
    final avatarRadius = isMobile ? 25.0 : 30.0;
    final spacing1 = isMobile ? 14.0 : 18.0;
    final titleFontSize = isMobile ? 15.0 : 17.0;

    return Padding(
      padding: EdgeInsets.only(left: isMobile ? 12.0 : 16.0, top: 6, bottom: 6),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, AppRouter.kAdvisorSearchView);
        },
        child: Container(
          color: Colors.transparent,
          padding: EdgeInsets.only(
            left: isMobile ? 4 : 6,
            right: 20,
            top: containerPadding,
            bottom: containerPadding,
          ),
          child: Row(
            children: [
              // Plus Icon in Circle
              Container(
                width: avatarRadius * 2,
                height: avatarRadius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: Center(
                  child: Icon(
                    Icons.add,
                    color: Colors.grey.shade500,
                    size: isMobile ? 28 : 32,
                  ),
                ),
              ),
              SizedBox(width: spacing1),

              // Title
              Expanded(
                child: Text(
                  'مستشار جديد',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: titleFontSize,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
