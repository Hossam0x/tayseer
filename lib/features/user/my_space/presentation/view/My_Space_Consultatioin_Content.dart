import 'package:tayseer/core/widgets/chat_room_list_item/chat_room_list_item.dart';
import 'package:tayseer/core/widgets/chat_room_list_item/helpers/chat_room_dialog_helper.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/my_space/my_space_state.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/my_space/my_state_cubit.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/add_advisor_item.dart';
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
                  return const AddAdvisorItem();
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

                return ChatRoomListItem(
                  key: ValueKey('chat_${chatRoom.id}'),
                  id: chatRoom.id,
                  title: title,
                  subtitle: chatRoom.lastMessage?.content ?? '',
                  imageUrl: imageUrl,
                  lastUpdate: chatRoom.lastMessageAt ?? chatRoom.updatedAt,
                  unreadCount: chatRoom.unreadCount,
                  fallbackAsset: AssetsData.kAppLogotayseerImage,
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
                    ChatRoomDialogHelper.showArchiveDialog(
                      context: context,
                      onConfirm: () async {
                        final cubit = context.read<MySpaceCubit>();
                        final success = await cubit.archiveChatRoom(chatRoom.id);
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
                    );
                  },
                  onDelete: () {
                    ChatRoomDialogHelper.showDeleteDialog(
                      context: context,
                      onConfirm: () async {
                        final cubit = context.read<MySpaceCubit>();
                        final success = await cubit.deleteChatRoom(chatRoom.id);
                        if (context.mounted) {
                          if (success) {
                            AppToast.success(context, 'تم حذف المحادثة بنجاح');
                          } else {
                            AppToast.error(
                              context,
                              'فشل في حذف المحادثة، حاول مرة أخرى',
                            );
                          }
                        }
                      },
                    );
                  },
                  onReport: () {
                    ChatRoomDialogHelper.showReportDialog(
                      context: context,
                      onConfirm: () {
                        // TODO: Implement report logic
                      },
                    );
                  },
                  onBlock: () {
                    if (chatRoom.isBlocked) {
                      ChatRoomDialogHelper.showUnblockDialog(
                        context: context,
                        onConfirm: () {
                          // TODO: Implement unblock logic
                        },
                      );
                    } else {
                      ChatRoomDialogHelper.showBlockDialog(
                        context: context,
                        onConfirm: () {
                          // TODO: Implement block logic
                        },
                      );
                    }
                  },
                  blockLabel: chatRoom.isBlocked ? 'إلغاء الحظر' : 'حظر',
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
}

