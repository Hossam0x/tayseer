import 'package:tayseer/core/widgets/chat_room_list_item/chat_room_list_item.dart';
import 'package:tayseer/core/widgets/chat_room_list_item/helpers/chat_room_dialog_helper.dart';
import 'package:tayseer/core/widgets/error_state_widget.dart';
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
        // ✅ لو loading بس في data موجودة، متعملش rebuild — عشان ما تختفيش الـ rooms
        if (current.advisorChatState == CubitStates.loading &&
            current.advisorChatModel != null) {
          return false;
        }

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
        
        // Create maps for easier comparison by ID
        final prevRoomsMap = {for (var room in prevRooms) room.id: room};
        final currRoomsMap = {for (var room in currRooms) room.id: room};
        
        // Check if any room changed
        for (final roomId in currRoomsMap.keys) {
          final prevRoom = prevRoomsMap[roomId];
          final currRoom = currRoomsMap[roomId];
          
          if (prevRoom == null || currRoom == null) {
            // New room added or removed
            return true;
          }
          
          // Check if unreadCount or lastMessage content changed
          if (prevRoom.unreadCount != currRoom.unreadCount ||
              prevRoom.lastMessage?.content != currRoom.lastMessage?.content ||
              prevRoom.lastMessage?.id != currRoom.lastMessage?.id) {
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
          return ErrorStateWidget(
            errorMessage: state.errorMessage,
            onRetry: () {
              context.read<MySpaceCubit>().getAdvisorChat();
            },
          );
        }

        // Success State
        if (state.advisorChatState == CubitStates.success) {
          final chatRooms = state.advisorChatModel?.data.chatRooms ?? [];

          if (chatRooms.isEmpty) {
            return EmptySessionsState(
              title: context.tr('no_consultations'),
              subtitle: context.tr('no_consultations_subtitle'),
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

                return ChatRoomListItem(
                  key: ValueKey('chat_${chatRoom.id}'),
                  id: chatRoom.id,
                  title: chatRoom.displayTitle,
                  subtitle: ChatRoomListItem.formatLastMessage(context, chatRoom.lastMessage?.content ?? ''),
                  imageUrl: chatRoom.displayImage,
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
                      'username': chatRoom.displayTitle,
                      'userimage': chatRoom.displayImage,
                      'isBlocked': chatRoom.isBlocked,
                      'isHaveSession': chatRoom.isHaveSession,
                      'isSystemChat': chatRoom.isSystemChat,
                    };

                    if (chatRoom.isSystemChat) {
                      arguments['system'] = true;
                    } else {
                      arguments['receiverid'] = chatRoom.displayReceiverId;
                    }

                    context
                        .pushNamed(
                          AppRouter.kConversitionView,
                          arguments: arguments,
                        )
                        .then((result) {
                          if (context.mounted) {
                            cubit.setActiveChatRoom(null);
                            // ✅ لو رجع بآخر رسالة، حدّث الـ list بدون reload كامل
                            if (result is Map<String, dynamic> &&
                                result['lastMessage'] != null) {
                              cubit.updateLastMessage(
                                chatRoomId: chatRoom.id,
                                content: result['lastMessage'] as String,
                                sentAt: result['sentAt'] as DateTime? ?? DateTime.now(),
                              );
                            }
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
                            AppToast.success(context, context.tr('consultation_archived_success'));
                          } else {
                            AppToast.error(context, context.tr('consultation_archive_failed'));
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
                            AppToast.success(context, context.tr('chat_deleted_success'));
                          } else {
                            AppToast.error(context, context.tr('chat_delete_failed'));
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
                  blockLabel: chatRoom.isBlocked ? context.tr('unblock_label') : context.tr('block_label'),
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
}

