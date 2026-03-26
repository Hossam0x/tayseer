import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/widgets/chat_room_list_item/chat_room_list_item.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_list_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_list_state.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/chat_list_shimmer.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/shared_empty_state.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/show_confirmation_dialog.dart';
import 'package:tayseer/my_import.dart';

class ChatListBuilder extends StatelessWidget {
  const ChatListBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return BlocBuilder<ChatListCubit, ChatListState>(
      builder: (context, state) {
        return state.maybeMap(
          loading: (_) => const ChatListShimmer(),
          failure: (s) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  s.message,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<ChatListCubit>().loadChatRooms();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE96E88),
                  ),
                  child: const Text(
                    'إعادة المحاولة',
                    style: TextStyle(fontFamily: 'Cairo', color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          loaded: (s) {
            if (s.chatRooms.isEmpty) {
              return SharedEmptyState(
                title: "لا توجد محادثات حتى الآن",
                subTitleWidget: Text(
                  "ابدأ محادثة جديدة الآن",
                  style: TextStyle(
                    color: Colors.grey,
                    fontFamily: 'Cairo',
                    fontSize: isMobile ? 12 : 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ChatListCubit>().loadChatRooms();
              },
              color: const Color(0xFFE96E88),
              child: ListView.separated(
                padding: EdgeInsets.only(
                  bottom: screenHeight * 0.12,
                  left: 0,
                  right: 0,
                  top: 0,
                ),
                itemCount: s.chatRooms.length,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey.shade200,
                  height: isMobile ? 0.5 : 1,
                ),
                itemBuilder: (context, index) {
                  final chatRoom = s.chatRooms[index];
                  final otherUser = chatRoom.participants.isNotEmpty
                      ? chatRoom.participants.first
                      : null;
                  final displayName = otherUser?.name ?? '';
                  final displayImage = otherUser?.image;

                  return ChatRoomListItem(
                    key: ValueKey('chat_room_${chatRoom.id}'),
                    id: chatRoom.id,
                    title: displayName,
                    subtitle: chatRoom.lastMessage?.content ??
                        context.tr('no_messages'),
                    imageUrl: displayImage,
                    lastUpdate: chatRoom.lastMessage?.sentAt,
                    unreadCount: chatRoom.unreadCount,
                    isBlocked: chatRoom.isBlocked,
                    fallbackAsset: AssetsData.avatarImage,
                    onTap: () {
                      context.read<ChatListCubit>().setActiveChatRoom(chatRoom.id);
                      context.read<ChatListCubit>().markMessageRed(chatRoom.id);
                      context.read<ChatListCubit>().markChatAsRead(chatRoom.id);
                      context
                          .pushNamed(
                            AppRouter.kConversitionView,
                            arguments: {
                              'receiverid': otherUser?.id,
                              'chatroomid': chatRoom.id,
                              'username': otherUser?.name,
                              'userimage': otherUser?.image,
                              'isBlocked': chatRoom.isBlocked,
                              'isSystemChat': chatRoom.isSystemChat,
                              'onBlockStatusChanged': (bool isBlocked) {
                                if (context.mounted) {
                                  context.read<ChatListCubit>().updateBlockStatus(
                                    chatRoom.id,
                                    isBlocked,
                                  );
                                }
                              },
                            },
                          )
                          .then((_) {
                            if (context.mounted) {
                              context.read<ChatListCubit>().setActiveChatRoom(null);
                            }
                          });
                    },
                    onArchive: () {
                      context.read<ChatListCubit>().archiveChatRoom(chatRoom.id);
                      AppToast.success(context, context.tr('chat_archived_success'));
                    },
                    onDelete: () {
                      showConfirmationDialog(
                        context: context,
                        imagePath: AssetsData.deleteIcon,
                        title: context.tr('confirm_delete_chat'),
                        subtitle: context.tr('confirm_delete_chat_message'),
                        onConfirm: () {
                          context.read<ChatListCubit>().deleteChatRoom(chatRoom.id);
                        },
                      );
                    },
                    onReport: () {
                      // TODO: Implement report logic
                    },
                    onBlock: () {
                      if (chatRoom.isBlocked) {
                        showConfirmationDialog(
                          context: context,
                          imagePath: AssetsData.deleteIcon,
                          title: context.tr('confirm_unblock_user'),
                          subtitle: context.tr('confirm_unblock_user_message'),
                          onConfirm: () {
                            context.read<ChatListCubit>().unblockUser(
                              blockedId: otherUser?.id ?? '',
                              chatRoomId: chatRoom.id,
                            );
                          },
                        );
                      } else {
                        showConfirmationDialog(
                          context: context,
                          imagePath: AssetsData.deleteIcon,
                          title: context.tr('confirm_block_user'),
                          subtitle: context.tr('confirm_block_user_message'),
                          onConfirm: () {
                            context.read<ChatListCubit>().blockUser(
                              blockedId: otherUser?.id ?? '',
                              chatRoomId: chatRoom.id,
                            );
                          },
                        );
                      }
                    },
                    blockLabel: chatRoom.isBlocked
                        ? context.tr('unblock')
                        : context.tr('block'),
                  );
                },
              ),
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }
}
