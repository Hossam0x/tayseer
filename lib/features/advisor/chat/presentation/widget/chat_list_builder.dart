import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_list_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_list_state.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/chat_list_item.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/chat_list_shimmer.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/shared_empty_state.dart';

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
                  return ChatListItem(index: index, chatRoom: chatRoom);
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
