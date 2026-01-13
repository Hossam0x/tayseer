import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/features/advisor/chat/data/model/chatView/chat_item_model.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_state.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/chat_list_item.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/shared_empty_state.dart';
import 'package:tayseer/my_import.dart';

class ChatListBuilder extends StatelessWidget {
  const ChatListBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        if (state.getallchatrooms == CubitStates.loading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFE96E88)),
          );
        }

        if (state.getallchatrooms == CubitStates.failure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  state.errorMessage ?? 'حدث خطأ ما',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<ChatCubit>().fetchChatRooms(),
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
          );
        }

        if (state.getallchatrooms == CubitStates.success) {
          if (state.chatRoom?.rooms == null || state.chatRoom!.rooms.isEmpty) {
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
            onRefresh: () async => context.read<ChatCubit>().fetchChatRooms(),
            color: const Color(0xFFE96E88),
            child: ListView.separated(
              padding: EdgeInsets.only(bottom: screenHeight * 0.01),
              itemCount: state.chatRoom!.rooms.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey.shade200,
                height: isMobile ? 0.5 : 1,
              ),
              itemBuilder: (context, index) {
                final chatRoom = state.chatRoom!.rooms[index];

                return ChatListItem(
                  index: index,
                  chatRoom: chatRoom,
                  onTap: () {
                    log('test');
                    context.read<ChatCubit>().markMessageRed(chatRoom.id);
                    context.read<ChatCubit>().setActiveChatRoom(chatRoom.id);
                    context.read<ChatCubit>().markChatAsRead(chatRoom.id);

                    context
                        .pushNamed(
                          AppRouter.kConversitionView,
                          arguments: {
                            'receiverid': chatRoom.sender.id,
                            'chatroomid': chatRoom.id,
                            'username': chatRoom.sender.name,
                            'userimage': chatRoom.sender.image,
                            'isBlocked': chatRoom.isBlocked,
                            'onBlockStatusChanged': (bool isBlocked) {
                              context.read<ChatCubit>().updateBlockStatus(
                                chatRoom.id,
                                isBlocked,
                              );
                            },
                          },
                        )
                        .then((_) {
                          context.read<ChatCubit>().setActiveChatRoom(null);
                        });
                  },
                  onArchive: () =>
                      context.read<ChatCubit>().archiveChatRoom(chatRoom.id),
                  onDelete: () =>
                      context.read<ChatCubit>().deleteChatRoom(chatRoom.id),
                  onReport: () => print("Report Clicked"),
                  onToggleBlock: () {
                    if (chatRoom.isBlocked) {
                      context.read<ChatCubit>().unblockUser(
                        blockedId: chatRoom.sender.id,
                        chatRoomId: chatRoom.id,
                      );
                    } else {
                      context.read<ChatCubit>().blockUser(
                        blockedId: chatRoom.sender.id,
                        chatRoomId: chatRoom.id,
                      );
                    }
                  },
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
